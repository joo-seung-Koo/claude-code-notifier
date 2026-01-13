---
allowed-tools: Bash(sed:*), Bash(cat:*), Bash(grep:*), Bash(mkdir:*), Bash(echo:*), Bash(~/.claude-code-notifier/uninstall.sh)
argument-hint: <command> [value]
description: Configure claude-code-notifier settings
---

# Claude Code Notifier Configuration

## Available Commands

| Command | Description |
|---------|-------------|
| `help` | Show this help message |
| `status` | Show current configuration |
| `lang <en\|ko>` | Set language (en: English, ko: 한국어) |
| `duration <seconds>` | Set minimum task duration (default: 20) |
| `preview <length>` | Set prompt preview length (default: 45) |
| `test` | Send a test notification |
| `uninstall` | Uninstall claude-code-notifier |

## Task

User command: `$ARGUMENTS`

Perform the appropriate action:

### 1. `status`
Display current settings in this format:
```
📊 Current Configuration
━━━━━━━━━━━━━━━━━━━━━━━━
🌐 Language: {en|ko}
⏱️  Min Duration: {value} seconds
📝 Preview Length: {value} characters
━━━━━━━━━━━━━━━━━━━━━━━━
```
Read values from ~/.claude-code-notifier/scripts/config.sh using grep.

### 2. `lang <en|ko>`
- Validate that the value is "en" or "ko"
- Update NOTIFIER_LANG in config.sh using sed
- Show: "✅ Language updated to {value}"

### 3. `duration <number>`
- Validate that the value is a positive number
- Update MIN_DURATION_SECONDS in config.sh using sed
- Show: "✅ Duration updated to {value} seconds"

### 4. `preview <number>`
- Validate that the value is a positive number
- Update PROMPT_PREVIEW_LENGTH in config.sh using sed
- Show: "✅ Preview length updated to {value} characters"

### 5. `test`
Run these commands:
```bash
mkdir -p ~/.claude-code-notifier/data
echo "Test notification from /notifier" > ~/.claude-code-notifier/data/prompt-test.txt
echo $(date +%s) > ~/.claude-code-notifier/data/timestamp-test.txt
echo '{"session_id": "test"}' | ~/.claude-code-notifier/scripts/notify.sh
```
Show: "✅ Test notification sent!"

### 6. `uninstall`
Run the uninstall script:
```bash
~/.claude-code-notifier/uninstall.sh
```
Show:
```
✅ claude-code-notifier has been uninstalled.

⚠️ Please restart Claude Code to complete the uninstallation.
   (Type /exit or press Ctrl+C)
```

### 7. `help` or empty/invalid command
Show the available commands table above.

### Error Handling
- If config.sh not found: "❌ claude-code-notifier is not installed. Run install.sh first."
- If invalid number provided: "❌ Please provide a valid positive number."
- If invalid language provided: "❌ Please provide a valid language (en or ko)."
- If unknown command: "❌ Unknown command. Use `/notifier help` to see available commands."
