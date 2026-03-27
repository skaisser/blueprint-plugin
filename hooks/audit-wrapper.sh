#!/bin/bash
# Blueprint SDLC Audit Hook
# Wraps the Go CLI audit command for plugin-based installation.
# Lazy-installs the binary on first use if missing.

set -uo pipefail

BINARY="$HOME/.blueprint/bin/blueprint"
SETUP_SCRIPT="${CLAUDE_PLUGIN_ROOT}/scripts/setup.sh"

# Save stdin (tool call JSON payload) before any other operation
INPUT=$(cat)

# Lazy install: if binary missing, try setup
if [ ! -x "$BINARY" ]; then
    if [ -x "$SETUP_SCRIPT" ]; then
        bash "$SETUP_SCRIPT" --quiet 2>/dev/null || true
    fi
    # If still missing after setup attempt, allow the tool call (non-blocking)
    if [ ! -x "$BINARY" ]; then
        exit 0
    fi
fi

# Forward to audit engine
echo "$INPUT" | "$BINARY" audit
exit $?
