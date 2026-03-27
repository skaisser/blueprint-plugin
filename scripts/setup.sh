#!/bin/bash
# Blueprint SDLC Setup Script
# Downloads the Blueprint CLI binary and configures the environment.
# Called automatically by the audit hook on first use (lazy install).
# Can also be run manually: bash scripts/setup.sh [--force] [--quiet]

set -uo pipefail

# Parse flags
FORCE=false
QUIET=false
for arg in "$@"; do
    case "$arg" in
        --force) FORCE=true ;;
        --quiet) QUIET=true ;;
    esac
done

log() { $QUIET || echo "$@"; }
log_err() { echo "$@" >&2; }

# Platform detection
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
esac

BINARY_DIR="$HOME/.blueprint/bin"
BINARY="$BINARY_DIR/blueprint"
GH_REPO="skaisser/blueprint"

# ── Step 1: Download binary ──────────────────────────────────────────────
mkdir -p "$BINARY_DIR"

download_binary() {
    local tmpdir
    tmpdir=$(mktemp -d)

    # Try tar.gz first (GoReleaser format)
    local tar_url="https://github.com/${GH_REPO}/releases/latest/download/blueprint-${OS}-${ARCH}.tar.gz"
    log "📥 Downloading blueprint for ${OS}/${ARCH}..."

    if curl -sL --max-time 30 "$tar_url" -o "$tmpdir/blueprint.tar.gz" 2>/dev/null && [ -s "$tmpdir/blueprint.tar.gz" ]; then
        tar -xzf "$tmpdir/blueprint.tar.gz" -C "$tmpdir" 2>/dev/null
        local found
        found=$(find "$tmpdir" -name "blueprint" -type f | head -1)
        if [ -n "$found" ]; then
            cp "$found" "$BINARY"
            chmod +x "$BINARY"
            rm -rf "$tmpdir"
            log "✅ Installed blueprint to $BINARY"
            return 0
        fi
    fi

    # Fallback to direct binary download (legacy)
    local direct_url="https://github.com/${GH_REPO}/releases/latest/download/blueprint-${OS}-${ARCH}"
    if curl -sL --max-time 30 "$direct_url" -o "$BINARY" 2>/dev/null && [ -s "$BINARY" ]; then
        chmod +x "$BINARY"
        rm -rf "$tmpdir"
        log "✅ Installed blueprint to $BINARY"
        return 0
    fi

    # Both failed
    rm -f "$BINARY"
    rm -rf "$tmpdir"
    log_err "⚠️  Failed to download blueprint binary"
    return 1
}

if [ -x "$BINARY" ] && ! $FORCE; then
    INSTALLED=$("$BINARY" version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "0.0.0")
    LATEST=$(curl -s --max-time 5 "https://api.github.com/repos/${GH_REPO}/releases/latest" 2>/dev/null | grep '"tag_name"' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "")

    if [ -n "$LATEST" ] && [ "$INSTALLED" = "$LATEST" ]; then
        log "✅ Blueprint $INSTALLED is already up to date"
    elif [ -n "$LATEST" ]; then
        log "🔄 Updating Blueprint $INSTALLED → $LATEST..."
        download_binary
    else
        log "✅ Blueprint $INSTALLED installed (couldn't check for updates)"
    fi
else
    download_binary
fi

# ── Step 2: PATH setup ──────────────────────────────────────────────────
if [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
else
    SHELL_RC=""
fi

if [ -n "$SHELL_RC" ]; then
    if ! grep -q '.blueprint/bin' "$SHELL_RC" 2>/dev/null; then
        echo 'export PATH="$HOME/.blueprint/bin:$PATH"' >> "$SHELL_RC"
        log "📝 Added ~/.blueprint/bin to PATH in $SHELL_RC"
    fi
fi

# ── Step 3: Statusline configuration ────────────────────────────────────
SETTINGS="$HOME/.claude/settings.json"
STATUSLINE_CMD="\${CLAUDE_PLUGIN_ROOT}/config/statusline.sh"

if [ -f "$SETTINGS" ]; then
    # Check if statusLine is already configured
    if ! grep -q "statusLine" "$SETTINGS" 2>/dev/null; then
        # Smart merge: add statusLine to existing settings
        if command -v jq >/dev/null 2>&1; then
            jq --arg cmd "$STATUSLINE_CMD" '.statusLine = {"type": "command", "command": $cmd}' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
            log "📝 Configured statusline in settings.json"
        else
            log "⚠️  jq not found — statusline not configured. Install jq and re-run."
        fi
    fi
else
    # Create minimal settings with statusline
    mkdir -p "$(dirname "$SETTINGS")"
    cat > "$SETTINGS" <<SETTINGS_EOF
{
  "statusLine": {
    "type": "command",
    "command": "$STATUSLINE_CMD"
  }
}
SETTINGS_EOF
    log "📝 Created settings.json with statusline"
fi

log ""
log "🚀 Blueprint setup complete!"
[ -x "$BINARY" ] && log "   Version: $("$BINARY" version 2>/dev/null || echo 'unknown')"
log "   Binary: $BINARY"
log "   Statusline: configured"
