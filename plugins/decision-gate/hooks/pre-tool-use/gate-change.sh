#!/usr/bin/env bash
# decision-gate: PreToolUse hook
# Implements V3 (Information-Gain Decision Support) and V5 (Adversarial Self-Review).
# Advisory gating — exit 0 + stderr, NOT exit 2 blocking.
# Fires on Write/Edit/MultiEdit before the write occurs.
# MUST exit 0 always.

trap 'exit 0' ERR INT TERM

set -uo pipefail

# ── Check jq availability ──
if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

# Resolve paths
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
SHARED_DIR="${PLUGIN_ROOT}/../../shared"

# shellcheck source=../../../../shared/constants.sh
source "${SHARED_DIR}/constants.sh"
# shellcheck source=../../../../shared/sanitize.sh
source "${SHARED_DIR}/sanitize.sh"
# shellcheck source=../../../../shared/metrics.sh
source "${SHARED_DIR}/metrics.sh"
# shellcheck source=../../../../shared/compat.sh
source "${SHARED_DIR}/compat.sh"

# ── Read hook input from stdin (capped at 1MB) ──
HOOK_INPUT=$(vigil_read_stdin 1048576)

if ! validate_json "$HOOK_INPUT"; then
  exit 0
fi

# Extract all fields in a single jq call
PARSED=$(printf "%s" "$HOOK_INPUT" | jq -r '[.tool_input.file_path // "", .transcript_path // ""] | join("\t")' 2>/dev/null)
FILE_PATH=$(printf "%s" "$PARSED" | cut -f1)
HOOK_TRANSCRIPT_PATH=$(printf "%s" "$PARSED" | cut -f2)

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# ── Sanitize path ──
DECODED=$(printf "%s" "$FILE_PATH" | sed -e 's/%2[eE]/./g' -e 's/%2[fF]/\//g' -e 's/%25/%/g')
if [[ "$DECODED" == *".."* ]]; then exit 0; fi

# ── Session hash ──
SESSION_HASH=$(vigil_md5_file "${HOOK_TRANSCRIPT_PATH}" || echo "fallback-$$")

# ── Cooldown check ──
COOLDOWN_FILE="${VIGIL_CACHE_PREFIX}gate-cooldown-${SESSION_HASH}"
GATE_TURN_FILE="${VIGIL_CACHE_PREFIX}gate-turn-${SESSION_HASH}"

# Determine current turn from changes cache
CHANGES_CACHE="${VIGIL_CACHE_PREFIX}changes-${SESSION_HASH}.jsonl"
CURRENT_TURN=0
if [[ -f "$CHANGES_CACHE" ]]; then
  CURRENT_TURN=$(wc -l < "$CHANGES_CACHE" 2>/dev/null | tr -d '[:space:]')
fi
CURRENT_TURN=$((CURRENT_TURN + 1))

LAST_ADVISORY_TURN=0
if [[ -f "$COOLDOWN_FILE" ]]; then
  LAST_ADVISORY_TURN=$(cat "$COOLDOWN_FILE" 2>/dev/null | tr -d '[:space:]')
  LAST_ADVISORY_TURN=${LAST_ADVISORY_TURN:-0}
fi

if [[ "$LAST_ADVISORY_TURN" -gt 0 ]] && [[ $((CURRENT_TURN - LAST_ADVISORY_TURN)) -lt "$VIGIL_REVIEW_COOLDOWN_TURNS" ]]; then
  exit 0
fi

# ── Read trust score for this file ──
TRUST_FILE="${PLUGIN_ROOT}/../trust-scorer/state/trust.json"
TRUST_SCORE="0.5"
CHANGE_TYPE="source_code"

if [[ -f "$TRUST_FILE" ]] && jq empty "$TRUST_FILE" >/dev/null 2>&1; then
  FILE_KEY=$(printf "%s" "$FILE_PATH" | jq -Rr @json 2>/dev/null)
  FILE_TRUST=$(jq -r ".[${FILE_KEY}] // empty" "$TRUST_FILE" 2>/dev/null)

  if [[ -n "$FILE_TRUST" ]] && [[ "$FILE_TRUST" != "null" ]]; then
    TRUST_SCORE=$(printf "%s" "$FILE_TRUST" | jq -r '.score // 0.5' 2>/dev/null)
    CHANGE_TYPE=$(printf "%s" "$FILE_TRUST" | jq -r '.type // "source_code"' 2>/dev/null)
  fi
fi

# ── Check if trust is high enough to skip review ──
IS_HIGH=$(jq -n --argjson s "$TRUST_SCORE" --argjson t "$VIGIL_TRUST_HIGH" \
  'if $s >= $t then 1 else 0 end' 2>/dev/null || echo "0")

if [[ "$IS_HIGH" == "1" ]]; then
  exit 0
fi

# ── V3: Compute Information Gain (binary entropy from trust score) ──
# Round trust to nearest 0.05 for lookup table
TRUST_BUCKET=$(jq -n --argjson s "$TRUST_SCORE" \
  '(($s * 20 | round) * 5) | if . < 5 then 5 elif . > 95 then 95 else . end' \
  2>/dev/null || echo "50")

# Entropy lookup
IG="1.00"
case "$TRUST_BUCKET" in
  5)  IG="$VIGIL_IG_TABLE_05" ;;
  10) IG="$VIGIL_IG_TABLE_10" ;;
  15) IG="$VIGIL_IG_TABLE_15" ;;
  20) IG="$VIGIL_IG_TABLE_20" ;;
  25) IG="$VIGIL_IG_TABLE_25" ;;
  30) IG="$VIGIL_IG_TABLE_30" ;;
  35) IG="$VIGIL_IG_TABLE_35" ;;
  40) IG="$VIGIL_IG_TABLE_40" ;;
  45) IG="$VIGIL_IG_TABLE_45" ;;
  50) IG="$VIGIL_IG_TABLE_50" ;;
  55) IG="$VIGIL_IG_TABLE_55" ;;
  60) IG="$VIGIL_IG_TABLE_60" ;;
  65) IG="$VIGIL_IG_TABLE_65" ;;
  70) IG="$VIGIL_IG_TABLE_70" ;;
  75) IG="$VIGIL_IG_TABLE_75" ;;
  80) IG="$VIGIL_IG_TABLE_80" ;;
  85) IG="$VIGIL_IG_TABLE_85" ;;
  90) IG="$VIGIL_IG_TABLE_90" ;;
  95) IG="$VIGIL_IG_TABLE_95" ;;
esac

# ── V5: Adversarial Self-Review (for low-trust changes) ──
IS_LOW=$(jq -n --argjson s "$TRUST_SCORE" --argjson t "$VIGIL_TRUST_LOW" \
  'if $s < $t then 1 else 0 end' 2>/dev/null || echo "0")

QUESTIONS=""
if [[ "$IS_LOW" == "1" ]]; then
  case "$CHANGE_TYPE" in
    config_change)
      QUESTIONS="Does this config change expose secrets or API keys? Does it break environment-specific overrides?" ;;
    source_code)
      QUESTIONS="Does this change break existing tests? Does it introduce a regression in critical paths?" ;;
    test_change)
      QUESTIONS="Does this weaken test assertions? Does it test implementation details instead of behavior?" ;;
    schema_change)
      QUESTIONS="Is this migration reversible? Does it break existing data or downstream consumers?" ;;
    dependency_change)
      QUESTIONS="Has this dependency been audited? Does this version bump break peer dependencies?" ;;
    documentation)
      QUESTIONS="Does this documentation accurately reflect the current implementation?" ;;
    *)
      QUESTIONS="What is the intent of this change? Does it align with the current task?" ;;
  esac
fi

# ── Construct stderr advisory ──
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DISPLAY_SCORE=$(jq -n --argjson s "$TRUST_SCORE" '$s * 100 | floor / 100' 2>/dev/null || echo "$TRUST_SCORE")
SHORT_FILE=$(basename "$FILE_PATH" 2>/dev/null || echo "$FILE_PATH")

if [[ -n "$QUESTIONS" ]]; then
  printf "[Vigil] REVIEW BEFORE WRITING: %s (trust: %s)\n  %s\n  Ask yourself: %s" \
    "$SHORT_FILE" "$DISPLAY_SCORE" "$CHANGE_TYPE" "$QUESTIONS" >&2
else
  printf "[Vigil] Review: %s (trust: %s, %s)" \
    "$SHORT_FILE" "$DISPLAY_SCORE" "$CHANGE_TYPE" >&2
fi

# ── Update cooldown ──
printf "%s" "$CURRENT_TURN" > "$COOLDOWN_FILE" 2>/dev/null || true

# ── Log metric ──
STATE_DIR="${PLUGIN_ROOT}/state"
METRIC=$(jq -cn \
  --arg event "review_advisory" \
  --arg ts "$TIMESTAMP" \
  --arg file "$FILE_PATH" \
  --argjson score "$TRUST_SCORE" \
  --arg ig "$IG" \
  --arg type "$CHANGE_TYPE" \
  --argjson turn "$CURRENT_TURN" \
  '{event:$event, ts:$ts, file:$file, score:$score, ig:$ig, type:$type, turn:$turn}')

log_metric "${STATE_DIR}/metrics.jsonl" "$METRIC"

exit 0
