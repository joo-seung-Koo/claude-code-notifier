#!/bin/bash
# notify.sh - OS Router for Claude Code notifications
# Hooks: Stop, Notification
# Detects OS and routes to appropriate notifier

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration
source "$SCRIPT_DIR/config.sh"

# Read stdin into variable (for passing to child scripts)
INPUT=$(cat)

# Detect notification type from JSON
if command -v jq &> /dev/null; then
    NOTIFICATION_TYPE=$(echo "$INPUT" | jq -r '.notification_type // empty' 2>/dev/null)
    HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // empty' 2>/dev/null)
else
    NOTIFICATION_TYPE=$(echo "$INPUT" | grep -o '"notification_type":"[^"]*"' | sed 's/"notification_type":"\(.*\)"/\1/' | head -1)
    HOOK_EVENT=$(echo "$INPUT" | grep -o '"hook_event_name":"[^"]*"' | sed 's/"hook_event_name":"\(.*\)"/\1/' | head -1)
fi

# Determine message based on notification type
case "$NOTIFICATION_TYPE" in
    "permission_prompt")
        NOTIFY_MESSAGE="$MSG_PERMISSION"
        ;;
    "idle_prompt")
        NOTIFY_MESSAGE="$MSG_IDLE"
        ;;
    *)
        # Default: task completed (Stop hook)
        NOTIFY_MESSAGE="$MSG_COMPLETED"
        ;;
esac

# Export config as environment variables for child scripts
export MIN_DURATION_SECONDS
export MSG_COMPLETED
export MSG_PERMISSION
export MSG_IDLE
export NOTIFY_MESSAGE
export NOTIFICATION_TYPE
export PROMPT_PREVIEW_LENGTH

# Detect OS and route to appropriate notifier
if grep -qi microsoft /proc/version 2>/dev/null; then
    # WSL (Windows Subsystem for Linux)
    export NOTIFIER_DATA_DIR_WIN=$(wslpath -w "$HOME/.claude-code-notifier/data")

    PS1_PATH="$SCRIPT_DIR/notifiers/windows.ps1"
    PS1_PATH_WIN=$(wslpath -w "$PS1_PATH")

    echo "$INPUT" | powershell.exe -ExecutionPolicy Bypass -File "$PS1_PATH_WIN"

elif [ "$(uname)" = "Darwin" ]; then
    # macOS
    echo "$INPUT" | "$SCRIPT_DIR/notifiers/macos.sh"

else
    # Linux (native)
    echo "$INPUT" | "$SCRIPT_DIR/notifiers/linux.sh"
fi

# Always exit successfully (don't block Claude Code)
exit 0
