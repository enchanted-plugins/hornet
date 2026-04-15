#!/usr/bin/env bash
# Test: sanitize_path blocks path traversal attacks
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}/../.."

source "${REPO_ROOT}/shared/sanitize.sh"

FAILED=0

# Test 1: Normal path should pass
RESULT=$(sanitize_path "/home/user/file.txt" "" 2>/dev/null) || true
if [[ -z "$RESULT" ]]; then
  echo "FAIL: Normal absolute path should pass"
  FAILED=1
fi

# Test 2: Path traversal (..) should be blocked
RESULT=$(sanitize_path "../../../etc/passwd" "" 2>/dev/null) || RESULT=""
if [[ -n "$RESULT" ]]; then
  echo "FAIL: Path traversal should be blocked, got: $RESULT"
  FAILED=1
fi

# Test 3: URL-encoded traversal (%2e%2e) should be blocked
RESULT=$(sanitize_path "%2e%2e/%2e%2e/etc/passwd" "" 2>/dev/null) || RESULT=""
if [[ -n "$RESULT" ]]; then
  echo "FAIL: URL-encoded traversal should be blocked, got: $RESULT"
  FAILED=1
fi

# Test 4: Double-encoded traversal (%252e) should be blocked
RESULT=$(sanitize_path "%252e%252e/etc/passwd" "" 2>/dev/null) || RESULT=""
if [[ -n "$RESULT" ]]; then
  echo "FAIL: Double-encoded traversal should be blocked, got: $RESULT"
  FAILED=1
fi

# Test 5: Empty path should fail
RESULT=$(sanitize_path "" "" 2>/dev/null) || RESULT=""
if [[ -n "$RESULT" ]]; then
  echo "FAIL: Empty path should fail"
  FAILED=1
fi

# Test 6: Path within project root should pass
RESULT=$(sanitize_path "src/app.ts" "/home/user/project" 2>/dev/null) || RESULT=""
if [[ -z "$RESULT" ]]; then
  echo "FAIL: Path within project root should pass"
  FAILED=1
fi

# Test 7: Path escaping project root should fail
RESULT=$(sanitize_path "/etc/passwd" "/home/user/project" 2>/dev/null) || RESULT=""
if [[ -n "$RESULT" ]]; then
  echo "FAIL: Path outside project root should be blocked, got: $RESULT"
  FAILED=1
fi

exit $FAILED
