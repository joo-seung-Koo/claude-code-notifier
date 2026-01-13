# claude-code-notifier

Get notified when Claude Code completes your tasks (WSL/macOS/Linux)

## Features

- **Cross-platform**: Windows (WSL2), macOS, and Linux support
- **Smart notifications**: Only notifies for tasks taking 30+ seconds
- **Prompt preview**: Shows the first few characters of your prompt
- **Session-aware**: Multiple Claude Code sessions work independently
- **Zero config**: Works out of the box with sensible defaults

## Requirements

- [Claude Code CLI](https://claude.ai/code)
- `jq` (JSON processor)
- **Linux only**: `libnotify-bin` (for `notify-send`)

## Installation

### One-line install

```bash
git clone https://github.com/joo-seung-Koo/claude-code-notifier.git && cd claude-code-notifier && ./install.sh
```

### Manual install

1. Clone the repository:
   ```bash
   git clone https://github.com/joo-seung-Koo/claude-code-notifier.git
   cd claude-code-notifier
   ```

2. Install jq if not already installed:
   ```bash
   # macOS
   brew install jq

   # Ubuntu/Debian
   sudo apt install jq

   # Fedora
   sudo dnf install jq
   ```

3. Run the installer:
   ```bash
   ./install.sh
   ```

4. Restart Claude Code for changes to take effect.

## Uninstall

```bash
~/.claude-code-notifier/uninstall.sh
```

Or if you still have the repo:

```bash
./uninstall.sh
```

## Configuration

Edit `~/.claude-code-notifier/scripts/config.sh`:

```bash
# Minimum task duration (seconds) to trigger notification
MIN_DURATION_SECONDS=30

# Notification message
MSG_COMPLETED="Task completed!"

# Number of characters to preview from the prompt
PROMPT_PREVIEW_LENGTH=10
```

## How It Works

This tool uses Claude Code's [hooks system](https://docs.anthropic.com/en/docs/claude-code/hooks) to:

1. **UserPromptSubmit**: Save the prompt and start time when you submit a task
2. **Stop**: Show a notification when Claude Code finishes (if duration > threshold)
3. **SessionEnd**: Clean up temporary files when the session ends

Session data is stored in `~/.claude-code-notifier/data/`.

## Troubleshooting

### Notifications not appearing

**Windows (WSL)**:
- Ensure Windows notifications are enabled in Settings > System > Notifications
- Check that Focus Assist is not blocking notifications

**macOS**:
- Allow notifications from "Script Editor" in System Preferences > Notifications

**Linux**:
- Install `libnotify-bin`: `sudo apt install libnotify-bin`
- Check if `notify-send` works: `notify-send "Test" "Hello"`

### jq not found

Install jq using your package manager (see Installation section).

### Hooks not registered

1. Check `~/.claude/settings.json` for hook entries
2. Re-run the installer: `./install.sh`
3. Restart Claude Code

### WSL path issues

If you're using a non-default WSL distribution, the path conversion should still work automatically. If issues persist, check that `wslpath` is available.

## License

MIT License - see [LICENSE](LICENSE) file.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
