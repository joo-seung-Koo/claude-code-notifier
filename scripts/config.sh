#!/bin/bash
# claude-code-notifier configuration
# Edit these values to customize notification behavior

# Minimum task duration (seconds) to trigger notification
# Tasks shorter than this will not show notifications
MIN_DURATION_SECONDS=30

# Notification messages
MSG_COMPLETED="Task completed!"
MSG_PERMISSION="Permission required!"
MSG_IDLE="Waiting for input..."

# Number of characters to show from the original prompt
PROMPT_PREVIEW_LENGTH=10
