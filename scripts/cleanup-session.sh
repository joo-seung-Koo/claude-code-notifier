#!/bin/bash
# cleanup-session.sh - Cleans up session files when Claude Code session ends
# Hook: SessionEnd

DATA_DIR="$HOME/.claude-code-notifier/data"

# Read stdin (JSON from Claude Code)
INPUT=$(cat)

# Extract session_id from JSON
if command -v jq &> /dev/null; then
    SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
else
    # Fallback: basic extraction with grep/sed
    SESSION_ID=$(echo "$INPUT" | grep -o '"session_id":"[^"]*"' | sed 's/"session_id":"\(.*\)"/\1/' | head -1)
fi

# Clean up session files if session_id exists
if [ -n "$SESSION_ID" ]; then
    rm -f "$DATA_DIR/prompt-${SESSION_ID}.txt"
    rm -f "$DATA_DIR/timestamp-${SESSION_ID}.txt"
fi

exit 0
