#!/bin/bash
# notify.sh - OS Router for Claude Code notifications
# Hooks: Stop, Notification
# Detects OS and routes to appropriate notifier

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
source "$SCRIPT_DIR/config.sh"

# Read stdin into variable (for passing to child scripts)
INPUT=$(cat)

# Detect notification type from JSON
NOTIFICATION_TYPE=$(json_get "$INPUT" "notification_type")

# Determine message based on notification type
case "$NOTIFICATION_TYPE" in
    "permission_prompt")
        NOTIFY_MESSAGE="$MSG_PERMISSION"
        ;;
    "idle_prompt")
        NOTIFY_MESSAGE="$MSG_IDLE"
        ;;
    *)
        NOTIFY_MESSAGE="$MSG_COMPLETED"
        ;;
esac

# Export config as environment variables for child scripts
export MIN_DURATION_SECONDS
export NOTIFY_MESSAGE
export NOTIFICATION_TYPE

# Detect OS and route to appropriate notifier
if grep -qi microsoft /proc/version 2>/dev/null; then
    # WSL (Windows Subsystem for Linux)
    NOTIFIER_DATA_DIR_WIN=$(wslpath -w "$DATA_DIR")
    export NOTIFIER_DATA_DIR_WIN
    PS1_PATH_WIN=$(wslpath -w "$SCRIPT_DIR/notifiers/windows.ps1")
    echo "$INPUT" | powershell.exe -ExecutionPolicy Bypass -File "$PS1_PATH_WIN"
elif [ "$(uname)" = "Darwin" ]; then
    # macOS
    echo "$INPUT" | "$SCRIPT_DIR/notifiers/macos.sh"
else
    # Linux (native)
    echo "$INPUT" | "$SCRIPT_DIR/notifiers/linux.sh"
fi

exit 0
