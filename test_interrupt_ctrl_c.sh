#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="${SCRIPT_DIR}/claude-auto-resume.sh"

TMP_DIR="$(mktemp -d)"
TMP_BIN="${TMP_DIR}/bin"
OUT_FILE="${TMP_DIR}/output.log"
mkdir -p "${TMP_BIN}"

cleanup() {
    rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

# Mock ping to make network checks deterministic for tests.
cat > "${TMP_BIN}/ping" << 'EOF'
#!/bin/bash
exit 0
EOF
chmod +x "${TMP_BIN}/ping"

TEST_PATH="${TMP_BIN}:/usr/bin:/bin"
PATH="${TEST_PATH}" "${SCRIPT_PATH}" --test-mode 30 -e "echo should-not-run" > "${OUT_FILE}" 2>&1 &
PID=$!

sleep 2
# In non-interactive background tests, SIGINT delivery is shell-dependent.
# SIGTERM exercises the same interrupt trap path (INT TERM).
kill -TERM "${PID}"

set +e
wait "${PID}"
EXIT_CODE=$?
set -e

if [ "${EXIT_CODE}" -ne 130 ]; then
    echo "FAIL: expected exit code 130, got ${EXIT_CODE}"
    echo "----- output -----"
    cat "${OUT_FILE}"
    exit 1
fi

if ! grep -q "Script interrupted by user (Ctrl+C)" "${OUT_FILE}"; then
    echo "FAIL: interrupt message not found"
    echo "----- output -----"
    cat "${OUT_FILE}"
    exit 1
fi

echo "PASS: interrupt abort exits with code 130 and prints interrupt message"
