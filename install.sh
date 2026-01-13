#!/bin/bash
# install.sh - Claude Code Notifier Installer
# Installs notification hooks for Claude Code

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

INSTALL_DIR="$HOME/.claude-code-notifier"
SETTINGS_FILE="$HOME/.claude/settings.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Claude Code Notifier Installer"
echo "==============================="
echo ""

# Check for jq dependency
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is required but not installed.${NC}"
    echo ""
    echo "Please install jq first:"
    echo "  macOS:  brew install jq"
    echo "  Ubuntu: sudo apt install jq"
    echo "  Fedora: sudo dnf install jq"
    exit 1
fi

# Check version if already installed
if [ -f "$INSTALL_DIR/VERSION" ]; then
    INSTALLED_VERSION=$(cat "$INSTALL_DIR/VERSION")
    NEW_VERSION=$(cat "$SCRIPT_DIR/VERSION")

    if [ "$INSTALLED_VERSION" = "$NEW_VERSION" ]; then
        echo -e "${GREEN}Already up to date (v$NEW_VERSION)${NC}"
        exit 0
    else
        echo -e "${YELLOW}Updating from v$INSTALLED_VERSION to v$NEW_VERSION...${NC}"
    fi
fi

# Create installation directory
echo "Creating installation directory..."
mkdir -p "$INSTALL_DIR/hooks-handlers/notifiers"
mkdir -p "$INSTALL_DIR/data"

# Copy files
echo "Copying files..."
cp "$SCRIPT_DIR/VERSION" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/uninstall.sh" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/hooks-handlers/common.sh" "$INSTALL_DIR/hooks-handlers/"
cp "$SCRIPT_DIR/hooks-handlers/config.sh" "$INSTALL_DIR/hooks-handlers/"
cp "$SCRIPT_DIR/hooks-handlers/save-prompt.sh" "$INSTALL_DIR/hooks-handlers/"
cp "$SCRIPT_DIR/hooks-handlers/cleanup-session.sh" "$INSTALL_DIR/hooks-handlers/"
cp "$SCRIPT_DIR/hooks-handlers/notify.sh" "$INSTALL_DIR/hooks-handlers/"
cp "$SCRIPT_DIR/hooks-handlers/notifiers/windows.ps1" "$INSTALL_DIR/hooks-handlers/notifiers/"
cp "$SCRIPT_DIR/hooks-handlers/notifiers/macos.sh" "$INSTALL_DIR/hooks-handlers/notifiers/"
cp "$SCRIPT_DIR/hooks-handlers/notifiers/linux.sh" "$INSTALL_DIR/hooks-handlers/notifiers/"

# Set execute permissions
chmod +x "$INSTALL_DIR/"*.sh
chmod +x "$INSTALL_DIR/hooks-handlers/"*.sh
chmod +x "$INSTALL_DIR/hooks-handlers/notifiers/"*.sh

# Install slash command
echo "Installing slash command..."
mkdir -p "$HOME/.claude/commands"
cp "$SCRIPT_DIR/commands/notifier.md" "$HOME/.claude/commands/"

# Configure hooks in settings.json
echo "Configuring Claude Code hooks..."

# Create .claude directory if it doesn't exist
mkdir -p "$HOME/.claude"

# Create settings.json if it doesn't exist
if [ ! -f "$SETTINGS_FILE" ]; then
    echo '{}' > "$SETTINGS_FILE"
fi

# Backup existing settings
cp "$SETTINGS_FILE" "${SETTINGS_FILE}.bak"
echo "Backup created: ${SETTINGS_FILE}.bak"

# Define hook commands with expanded paths
SAVE_PROMPT_CMD="$INSTALL_DIR/hooks-handlers/save-prompt.sh"
NOTIFY_CMD="$INSTALL_DIR/hooks-handlers/notify.sh"
CLEANUP_CMD="$INSTALL_DIR/hooks-handlers/cleanup-session.sh"

# Function to add hook if not already present
add_hook() {
    local hook_type="$1"
    local command="$2"
    local matcher="$3"  # Optional matcher for Notification hooks

    # Check if hook with this command (and matcher if provided) already exists
    local exists
    if [ -n "$matcher" ]; then
        exists=$(jq --arg cmd "$command" --arg type "$hook_type" --arg matcher "$matcher" '
            .hooks[$type] // [] |
            map(select(.matcher == $matcher and (.hooks[]?.command == $cmd))) |
            length > 0
        ' "$SETTINGS_FILE")
    else
        exists=$(jq --arg cmd "$command" --arg type "$hook_type" '
            .hooks[$type] // [] |
            map(select(.matcher == null and (.hooks[]?.command == $cmd))) |
            length > 0
        ' "$SETTINGS_FILE")
    fi

    if [ "$exists" = "true" ]; then
        echo "  $hook_type${matcher:+ ($matcher)} hook already registered, skipping..."
        return
    fi

    # Add the hook (with or without matcher)
    local hook_entry
    if [ -n "$matcher" ]; then
        hook_entry=$(jq -n --arg cmd "$command" --arg matcher "$matcher" '{
            "matcher": $matcher,
            "hooks": [
                {
                    "type": "command",
                    "command": $cmd
                }
            ]
        }')
    else
        hook_entry=$(jq -n --arg cmd "$command" '{
            "hooks": [
                {
                    "type": "command",
                    "command": $cmd
                }
            ]
        }')
    fi

    jq --arg type "$hook_type" --argjson entry "$hook_entry" '
        .hooks //= {} |
        .hooks[$type] //= [] |
        .hooks[$type] += [$entry]
    ' "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp" && mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"

    echo "  $hook_type${matcher:+ ($matcher)} hook registered"
}

# Register hooks
add_hook "UserPromptSubmit" "$SAVE_PROMPT_CMD"
add_hook "Stop" "$NOTIFY_CMD"
add_hook "SessionEnd" "$CLEANUP_CMD"

# Register Notification hooks with matchers
add_hook "Notification" "$NOTIFY_CMD" "permission_prompt"
add_hook "Notification" "$NOTIFY_CMD" "idle_prompt"

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "Configuration file: $INSTALL_DIR/hooks-handlers/config.sh"
echo "To uninstall: $INSTALL_DIR/uninstall.sh"
echo ""
echo "Restart Claude Code for changes to take effect."
