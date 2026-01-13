#!/bin/bash
# linux.sh - Linux notification using notify-send
# Called from notify.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$HOME/.claude-code-notifier/data"

# Check if notify-send is available
if ! command -v notify-send &> /dev/null; then
    # Silently exit if notify-send is not installed
    exit 0
fi

# Read config from environment or use defaults
MIN_DURATION=${MIN_DURATION_SECONDS:-30}
NOTIFY_MSG=${NOTIFY_MESSAGE:-"Task completed!"}
NOTIF_TYPE=${NOTIFICATION_TYPE:-""}

# Read stdin (JSON from Claude Code)
INPUT=$(cat)

# Extract session_id
if command -v jq &> /dev/null; then
    SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
else
    SESSION_ID=$(echo "$INPUT" | grep -o '"session_id":"[^"]*"' | sed 's/"session_id":"\(.*\)"/\1/' | head -1)
fi

if [ -z "$SESSION_ID" ]; then
    SESSION_ID="default"
fi

# For Notification hooks (permission_prompt, idle_prompt), skip duration check
if [ -z "$NOTIF_TYPE" ] || [ "$NOTIF_TYPE" = "null" ]; then
    # Stop hook: check elapsed time
    TIMESTAMP_FILE="$DATA_DIR/timestamp-${SESSION_ID}.txt"
    if [ ! -f "$TIMESTAMP_FILE" ]; then
        exit 0
    fi

    START_TIME=$(cat "$TIMESTAMP_FILE" 2>/dev/null)
    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - START_TIME))

    # Skip if task was too short
    if [ "$ELAPSED" -lt "$MIN_DURATION" ]; then
        exit 0
    fi

    # Read prompt preview
    PROMPT_FILE="$DATA_DIR/prompt-${SESSION_ID}.txt"
    PROMPT_TEXT=""

    if [ -f "$PROMPT_FILE" ]; then
        PROMPT_TEXT=$(cat "$PROMPT_FILE" 2>/dev/null)
    fi

    # Show notification with prompt
    if [ -n "$PROMPT_TEXT" ]; then
        notify-send "Claude Code" "$NOTIFY_MSG\n$PROMPT_TEXT"
    else
        notify-send "Claude Code" "$NOTIFY_MSG"
    fi
else
    # Notification hook: show immediately without duration check
    notify-send "Claude Code" "$NOTIFY_MSG"
fi

exit 0
