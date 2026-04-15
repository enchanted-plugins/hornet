#!/usr/bin/env bash
# Test: save-session.sh creates session-graph.json and session-summary.md
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}/../.."
HOOK="${REPO_ROOT}/plugins/session-memory/hooks/pre-compact/save-session.sh"

MOCK_TRANSCRIPT=$(mktemp)
echo '{"role":"user","content":"test"}' > "$MOCK_TRANSCRIPT"

# Set up test data in sibling plugins
CT_STATE="${REPO_ROOT}/plugins/change-tracker/state"
TS_STATE="${REPO_ROOT}/plugins/trust-scorer/state"
DG_STATE="${REPO_ROOT}/plugins/decision-gate/state"
SM_STATE="${REPO_ROOT}/plugins/session-memory/state"

mkdir -p "$CT_STATE" "$TS_STATE" "$DG_STATE" "$SM_STATE"

# Create sample changes
echo '{"ts":"2026-04-14T10:00:00Z","file":"src/app.ts","hash":"abc123","type":"source_code","changed":true,"cluster_id":"","tool":"Write","turn":1}' > "${CT_STATE}/changes.jsonl"
echo '{"ts":"2026-04-14T10:01:00Z","file":"src/db.ts","hash":"def456","type":"schema_change","changed":true,"cluster_id":"","tool":"Edit","turn":2}' >> "${CT_STATE}/changes.jsonl"

# Create sample trust
echo '{"src/app.ts":{"alpha":3.2,"beta":1.8,"score":0.64,"type":"source_code","ts":"2026-04-14T10:00:00Z"},"src/db.ts":{"alpha":2.3,"beta":3.7,"score":0.38,"type":"schema_change","ts":"2026-04-14T10:01:00Z"}}' > "${TS_STATE}/trust.json"

# Clean session-memory state
rm -f "${SM_STATE}/session-graph.json"
rm -rf "${SM_STATE}/session-graph.json.lock"
rm -f "${SM_STATE}/session-summary.md"
rm -f "${SM_STATE}/metrics.jsonl"
rm -rf "${SM_STATE}/metrics.jsonl.lock"

INPUT=$(jq -n \
  --arg transcript "$MOCK_TRANSCRIPT" \
  '{transcript_path: $transcript, cwd: "/tmp", hook_event_name: "PreCompact"}')

# Run the hook
printf "%s" "$INPUT" | CLAUDE_PLUGIN_ROOT="${REPO_ROOT}/plugins/session-memory" bash "$HOOK" 2>/dev/null

# Verify session-graph.json was created
if [[ ! -f "${SM_STATE}/session-graph.json" ]]; then
  echo "FAIL: session-graph.json not created"
  rm -f "$MOCK_TRANSCRIPT"
  exit 1
fi

# Verify it's valid JSON
if ! jq empty "${SM_STATE}/session-graph.json" >/dev/null 2>&1; then
  echo "FAIL: session-graph.json is not valid JSON"
  rm -f "$MOCK_TRANSCRIPT"
  exit 1
fi

# Verify session-summary.md was created
if [[ ! -f "${SM_STATE}/session-summary.md" ]]; then
  echo "FAIL: session-summary.md not created"
  rm -f "$MOCK_TRANSCRIPT"
  exit 1
fi

# Verify summary contains trust overview
if ! grep -q "Trust Overview" "${SM_STATE}/session-summary.md"; then
  echo "FAIL: session-summary.md missing Trust Overview section"
  rm -f "$MOCK_TRANSCRIPT"
  exit 1
fi

# Cleanup
rm -f "$MOCK_TRANSCRIPT"
rm -f "${CT_STATE}/changes.jsonl"
rm -f "${TS_STATE}/trust.json"
rm -f "${SM_STATE}/session-graph.json"
rm -rf "${SM_STATE}/session-graph.json.lock"
rm -f "${SM_STATE}/session-summary.md"
rm -f "${SM_STATE}/metrics.jsonl"
rm -rf "${SM_STATE}/metrics.jsonl.lock"

exit 0
