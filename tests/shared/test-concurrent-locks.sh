#!/usr/bin/env bash
# Test: acquire_lock correctly handles concurrent access via atomic mkdir
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}/../.."

source "${REPO_ROOT}/shared/metrics.sh"

LOCK_DIR=$(mktemp -d)/test.lock
RESULTS_FILE=$(mktemp)

# Clean
rmdir "$LOCK_DIR" 2>/dev/null || true

# Spawn 5 concurrent lock attempts
for i in 1 2 3 4 5; do
  (
    if acquire_lock "$LOCK_DIR"; then
      echo "acquired:$i" >> "$RESULTS_FILE"
      sleep 0.2
      release_lock "$LOCK_DIR"
    else
      echo "failed:$i" >> "$RESULTS_FILE"
    fi
  ) &
done

# Wait for all background jobs
wait

# Count successes
ACQUIRED=$(grep -c "acquired" "$RESULTS_FILE" 2>/dev/null || true)
FAILED_COUNT=$(grep -c "failed" "$RESULTS_FILE" 2>/dev/null || true)

# At least one should have acquired
if [[ "$ACQUIRED" -lt 1 ]]; then
  echo "FAIL: No process acquired the lock"
  rm -f "$RESULTS_FILE"
  rmdir "$LOCK_DIR" 2>/dev/null || true
  exit 1
fi

# Total should be 5
TOTAL=$((ACQUIRED + FAILED_COUNT))
if [[ "$TOTAL" -ne 5 ]]; then
  echo "FAIL: Expected 5 total results, got $TOTAL"
  rm -f "$RESULTS_FILE"
  rmdir "$LOCK_DIR" 2>/dev/null || true
  exit 1
fi

# Cleanup
rm -f "$RESULTS_FILE"
rmdir "$LOCK_DIR" 2>/dev/null || true
rmdir "$(dirname "$LOCK_DIR")" 2>/dev/null || true

exit 0
