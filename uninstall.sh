#!/bin/bash
# uninstall.sh - Claude Code Notifier Uninstaller
# Removes notification hooks and installation directory

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

INSTALL_DIR="$HOME/.claude-code-notifier"
SETTINGS_FILE="$HOME/.claude/settings.json"

echo "Claude Code Notifier Uninstaller"
echo "================================="
echo ""

# Check for jq
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is required for uninstallation.${NC}"
    echo "Please install jq and try again."
    exit 1
fi

# Remove hooks from settings.json
if [ -f "$SETTINGS_FILE" ]; then
    echo "Removing hooks from settings.json..."

    # Backup settings
    cp "$SETTINGS_FILE" "${SETTINGS_FILE}.bak"

    # Remove hooks containing .claude-code-notifier in command path
    jq 'if .hooks then
        .hooks |= with_entries(
            .value |= [.[] | select(
                (.hooks // []) | all(.command | (contains(".claude-code-notifier") | not))
            )]
        ) |
        .hooks |= with_entries(select(.value | length > 0)) |
        if .hooks == {} then del(.hooks) else . end
    else . end' "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp" && mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"

    echo "Hooks removed."
fi

# Remove installation directory
if [ -d "$INSTALL_DIR" ]; then
    echo "Removing installation directory..."
    rm -rf "$INSTALL_DIR"
fi

# Remove slash command
if [ -f "$HOME/.claude/commands/notifier.md" ]; then
    echo "Removing slash command..."
    rm -f "$HOME/.claude/commands/notifier.md"
fi

echo ""
echo -e "${GREEN}Successfully uninstalled Claude Code Notifier.${NC}"
echo ""
echo "Backup of settings.json saved as: ${SETTINGS_FILE}.bak"
