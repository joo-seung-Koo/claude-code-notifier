# claude-code-notifier

[![License](https://img.shields.io/github/license/js-koo/claude-code-notifier)](LICENSE)
[![Version](https://img.shields.io/github/v/tag/js-koo/claude-code-notifier?label=version)](https://github.com/js-koo/claude-code-notifier/releases)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-blue)]()

[English](README.md) | [한국어](README.ko.md)

Get notified when Claude Code completes your tasks (Windows/macOS/Linux)

<details>
<summary>Demo</summary>

![Demo](assets/demo.gif)

</details>

## Features

- **Cross-platform**: Windows (Native/WSL2), macOS, and Linux support
- **Smart notifications**: Only notifies for tasks taking 20+ seconds
- **Prompt preview**: Shows the first few characters of your prompt
- **Session-aware**: Multiple Claude Code sessions work independently
- **Zero config**: Works out of the box with sensible defaults
- **Slash command**: Easy configuration with `/notifier` command

## Tested Environments

| Platform | Status |
|----------|--------|
| macOS | ✅ Tested |
| Linux | ✅ Tested (Docker) |
| Windows (Native) | ⚠️ Not tested yet |
| Windows (WSL2) | ✅ Tested |

> Found an issue? Please [open an issue](https://github.com/js-koo/claude-code-notifier/issues)!

## Requirements

- [Claude Code CLI](https://claude.ai/code)
- `jq` (JSON processor)
- **Linux only**: `libnotify-bin` (for `notify-send`)

## Installation

### As a Claude Code Plugin (Recommended)

Run Claude Code with the plugin:

```bash
claude --plugin-dir /path/to/claude-code-notifier
```

Or add to your project's `.claude/settings.local.json`:

```json
{
  "plugins": ["/path/to/claude-code-notifier"]
}
```

### Standalone Installation

#### One-line install

```bash
git clone https://github.com/js-koo/claude-code-notifier.git && cd claude-code-notifier && ./install.sh
```

#### Manual install

1. Clone the repository:
   ```bash
   git clone https://github.com/js-koo/claude-code-notifier.git
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

### Using Slash Command (Recommended)

Use the `/notifier` command in Claude Code:

| Command | Description |
|---------|-------------|
| `/notifier help` | Show available commands |
| `/notifier status` | Show current configuration |
| `/notifier lang <en\|ko>` | Set language (en: English, ko: 한국어) |
| `/notifier duration <seconds>` | Set minimum task duration (default: 20) |
| `/notifier preview <length>` | Set prompt preview length (default: 45) |
| `/notifier test` | Send a test notification |
| `/notifier uninstall` | Uninstall claude-code-notifier |

### Manual Configuration

Edit `~/.claude-code-notifier/hooks-handlers/config.sh`:

```bash
# Language setting: "en" (English) or "ko" (한국어)
NOTIFIER_LANG="en"

# Minimum task duration (seconds) to trigger notification
MIN_DURATION_SECONDS=20

# Number of characters to preview from the prompt
PROMPT_PREVIEW_LENGTH=45
```

### Configuration Options Explained

| Option | Default | Description |
|--------|---------|-------------|
| `NOTIFIER_LANG` | `en` | UI language. `en` for English, `ko` for Korean. Affects notification messages and slash command responses. |
| `MIN_DURATION_SECONDS` | `20` | Minimum task duration to trigger notification. Tasks completing faster than this won't show notifications. Set to `0` to notify on every task. |
| `PROMPT_PREVIEW_LENGTH` | `45` | Number of characters to show from your original prompt in the notification. |

### Notification Messages

Messages are automatically set based on `NOTIFIER_LANG`:

| Event | English | 한국어 |
|-------|---------|--------|
| Task completed | Task completed! | 작업 완료! |
| Permission required | Permission required! | 권한 필요! |
| Waiting for input | Waiting for input... | 입력 대기 중... |

### Examples

**Quick tasks without notifications:**
```bash
# Only notify for tasks taking 60+ seconds
/notifier duration 60
```

**Always notify:**
```bash
# Notify on every task completion
/notifier duration 0
```

**Longer prompt preview:**
```bash
# Show more of the original prompt
/notifier preview 100
```

**Switch to Korean:**
```bash
/notifier lang ko
```

## How It Works

This tool uses Claude Code's [hooks system](https://docs.anthropic.com/en/docs/claude-code/hooks) to:

1. **UserPromptSubmit**: Save the prompt and start time when you submit a task
2. **Stop**: Show a notification when Claude Code finishes (if duration > threshold)
3. **Notification**: Alert when permission is required or Claude is waiting for input
4. **SessionEnd**: Clean up temporary files when the session ends

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

Contributions are welcome!

- **Bug reports / Feature requests**: [Open an Issue](https://github.com/js-koo/claude-code-notifier/issues)
- **Code contributions**: Submit a Pull Request
- **New language support**: Add `README.<lang>.md` and update `config.sh`
