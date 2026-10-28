# cmd-stt

Speech-to-text for Linux that records from the microphone, transcribes with Whisper (local or Groq cloud), and auto-types the result into the focused window via global hotkeys.

Designed for KDE Plasma on Wayland, but works anywhere `ydotool` can inject input.

## Features

- Global hotkeys: start / stop / toggle recording.
- Backend: auto (Groq cloud if online + API key, else local Whisper).
- Local: OpenAI Whisper on GPU/CPU (model configurable).
- Cloud: Groq Whisper API (fast, free tier).
- Auto-type via `ydotool` with Wayland settle delay.
- Clipboard fallback.
- Configurable model, language, prompt, delay.

## Dependencies

- `ffmpeg` (audio capture)
- `wl-clipboard` (`wl-copy`)
- `ydotool` + `ydotoold` (input injection)
- `curl`, `jq` (cloud API)
- `notify-send` (notifications)
- `whisper` (OpenAI Whisper) or `whisper-ctranslate2` (local)
- PulseAudio/PipeWire (microphone)
- KDE Plasma (for global shortcuts) — optional but recommended

Install on Arch/CachyOS:

```bash
sudo pacman -S ffmpeg wl-clipboard ydotool curl jq libnotify
# Whisper (local)
uv tool install openai-whisper
# or: uv tool install whisper-ctranslate2
```

## Installation

```bash
git clone <your-repo> cmd-stt
cd cmd-stt
./scripts/install.sh
```

Then:
- Add your Groq/OpenAI API key to `~/.config/cmd-stt/config` (optional).
- Enable ydotool daemon: `systemctl --user start ydotoold`
- (KDE) Logout/login to activate global shortcuts.

## Usage

| Hotkey | Action |
|---|---|
| `Meta+Ctrl+Alt+S` | Start recording |
| `Meta+Ctrl+Alt+D` | Stop & transcribe |
| `Meta+Ctrl+Alt+X` | Toggle |

Workflow: press start → speak → press stop. Text is auto-typed into the focused input after a short delay.

## Configuration

Edit `~/.config/cmd-stt/config`:

```bash
STT_BACKEND="auto"              # auto | cloud | local
WHISPER_MODEL="small"           # tiny base small medium large
WHISPER_LANGUAGE="id"           # id en auto ...
WHISPER_DEVICE="auto"           # auto cpu cuda
GROQ_API_KEY="gsk_..."          # optional
GROQ_WHISPER_MODEL="whisper-large-v3-turbo"
YDOTOOL_SETTLE="2"              # seconds delay before typing
WHISPER_INITIAL_PROMPT="..."    # bias prompt for names/terms
```

## Notes

- On KDE Wayland, `ydotool` needs ~1-2s to bind the virtual input device before typing. Adjust `YDOTOOL_SETTLE`.
- If auto-type fails, text is still in the clipboard.
- The ydotool daemon should run as root with a shared socket (see `systemd/ydotoold.service`).

## License

MIT