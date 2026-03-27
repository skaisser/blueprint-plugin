#!/bin/bash
# Blueprint SDLC Auto-Update Check
# Runs on session stop. Checks GitHub for newer version.
# Cache: ~/.blueprint/.update-check (24h TTL)

set -uo pipefail

BINARY="$HOME/.blueprint/bin/blueprint"
CACHE_FILE="$HOME/.blueprint/.update-check"
CACHE_TTL=86400  # 24 hours in seconds
GH_REPO="skaisser/blueprint"

# Skip if binary not installed
[ -x "$BINARY" ] || exit 0

# Skip if cache is fresh
if [ -f "$CACHE_FILE" ]; then
    CACHE_AGE=$(( $(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0) ))
    if [ "$CACHE_AGE" -lt "$CACHE_TTL" ]; then
        exit 0
    fi
fi

# Get installed version
INSTALLED=$("$BINARY" version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "0.0.0")

# Get latest from GitHub (3s timeout)
LATEST=$(curl -s --max-time 3 "https://api.github.com/repos/${GH_REPO}/releases/latest" 2>/dev/null | grep '"tag_name"' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "")

# Update cache
mkdir -p "$(dirname "$CACHE_FILE")"
echo "{\"checked\":$(date +%s),\"installed\":\"$INSTALLED\",\"latest\":\"${LATEST:-unknown}\"}" > "$CACHE_FILE"

# Notify if update available
if [ -n "$LATEST" ] && [ "$LATEST" != "$INSTALLED" ]; then
    echo "update available: Blueprint $LATEST (installed: $INSTALLED) — run: blueprint update" >&2
fi

exit 0
