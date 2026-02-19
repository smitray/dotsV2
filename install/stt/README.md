# Whisper STT for Hyprland

Local, GPU-accelerated Speech-to-Text system for Hyprland Wayland compositor using OpenAI's Whisper model.

## Features

- **100% Local Processing**: No data leaves your machine, complete privacy
- **GPU Acceleration**: CUDA-enabled fast transcription (RTX 3050+ recommended)
- **Continuous Operation**: Server runs 24/7 with manual VRAM management
- **OpenAI API Compatible**: Works with OpenWebUI, LibreChat, and other tools
- **Smart Audio Selection**: Auto-detects Bluetooth headsets, falls back to default mic
- **Multiple Input Methods**: wtype → ydotool → clipboard fallback
- **Waybar Integration**: Real-time status indicator
- **Notification System**: Dunst notifications for all events

## Quick Start

```bash
# Install
./install.sh

# Add keybinding to ~/.config/hypr/hyprland.conf
bind = SUPER, N, exec, ~/.local/bin/hypr-stt toggle

# Reload Hyprland (SUPER+SHIFT+C or logout/login)

# Usage: Press SUPER+N to start/stop recording
```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    User Interaction                          │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────┐    │
│  │ Hyprland    │  │ Waybar       │  │ Notifications   │    │
│  │ Keybinding  │  │ Status       │  │ (dunst)         │    │
│  └──────┬──────┘  └──────┬───────┘  └────────┬────────┘    │
│         │                │                    │              │
│         └────────────────┼────────────────────┘              │
│                          │                                   │
│                  ┌───────▼────────┐                          │
│                  │  hypr-stt      │                          │
│                  │  (Bash Client) │                          │
│                  └───────┬────────┘                          │
└──────────────────────────┼───────────────────────────────────┘
                           │ HTTP POST /v1/audio/transcriptions
┌──────────────────────────┼───────────────────────────────────┐
│                          │                                   │
│                  ┌───────▼────────┐                          │
│                  │ whisper-api-   │                          │
│                  │ server         │                          │
│                  │ (FastAPI)      │                          │
│                  └───────┬────────┘                          │
│                          │                                   │
│                  ┌───────▼────────┐                          │
│                  │ faster-whisper │                          │
│                  │ (Whisper Model)│                          │
│                  └───────┬────────┘                          │
│                          │                                   │
│                  ┌───────▼────────┐                          │
│                  │ CUDA GPU       │                          │
│                  │ or CPU         │                          │
│                  └────────────────┘                          │
└─────────────────────────────────────────────────────────────┘
```

## Installation

### Prerequisites

- **OS**: Arch Linux (or Arch-based distro)
- **Compositor**: Hyprland (Wayland)
- **Audio**: PipeWire with WirePlumber
- **GPU**: NVIDIA with 4GB+ VRAM recommended (RTX 3050+)
- **Python**: 3.10+

### Automatic Installation

```bash
cd ~/workspace/dotFileV2/install/stt
./install.sh
```

The installer will:
1. Check and install system packages (pacman)
2. Install Python packages via pip
3. Install NVIDIA drivers/CUDA if needed
4. Copy scripts to `~/.local/bin`
5. Install environment file to `~/.config/hypr-stt/env`
6. Install systemd user service
7. Enable auto-start on login

### Manual Installation

#### 1. Install System Packages

```bash
sudo pacman -S --needed \
  pipewire pipewire-alsa pipewire-pulse wireplumber \
  pavucontrol pamixer \
  wtype ydotool \
  dunst libnotify \
  curl jq \
  waybar wl-clipboard
```

#### 2. Install Python Packages

```bash
pip install faster-whisper uvicorn fastapi python-multipart
```

#### 3. Install NVIDIA Drivers (if needed)

```bash
sudo pacman -S nvidia-open nvidia-utils cuda
```

#### 4. Copy Files

```bash
mkdir -p ~/.local/bin ~/.config/hypr-stt ~/.config/systemd/user

cp bin/whisper-api-server ~/.local/bin/
cp bin/hypr-stt ~/.local/bin/
chmod +x ~/.local/bin/whisper-api-server ~/.local/bin/hypr-stt

cp .env.example ~/.config/hypr-stt/env
cp config/whisper-api.service ~/.config/systemd/user/
```

#### 5. Enable Service

```bash
systemctl --user daemon-reload
systemctl --user enable --now whisper-api.service
```

## Configuration

### Environment Variables

Edit `~/.config/hypr-stt/env`:

```bash
# Server Configuration
export WHISPER_PORT=7861                      # API server port
export WHISPER_MODEL=small                    # tiny/base/small/medium/large-v3
export WHISPER_DEVICE=cuda                    # cuda/cpu/auto
export WHISPER_HOST=127.0.0.1                 # 127.0.0.1 (local) or 0.0.0.0 (LAN)

# Client Configuration
export HYPR_STT_API_URL=http://localhost:${WHISPER_PORT}/v1/audio/transcriptions
export HYPR_STT_MODEL=${WHISPER_MODEL}
export HYPR_STT_PORT=${WHISPER_PORT}
export HYPR_STT_LANGUAGE=en                   # en/es/fr/de/hi/zh/ja/ko
```

### Model Selection

| Model | Size | VRAM | Speed | Accuracy |
|-------|------|------|-------|----------|
| tiny | 39MB | ~300MB | Fastest | Lowest |
| base | 74MB | ~400MB | Fast | Decent |
| small | 244MB | ~600MB | Balanced | Good (default) |
| medium | 769MB | ~1.5GB | Slow | Better |
| large-v3 | 3GB | ~3GB | Slowest | Best |

### Hyprland Keybindings

Add to `~/.config/hypr/hyprland.conf`:

```bash
# Primary: Toggle recording
bind = SUPER, N, exec, ~/.local/bin/hypr-stt toggle

# Server Management (GPU Control)
bind = SUPER SHIFT, S, exec, ~/.local/bin/hypr-stt start-server
bind = SUPER SHIFT, R, exec, ~/.local/bin/hypr-stt restart-server
bind = SUPER ALT, R, exec, ~/.local/bin/hypr-stt stop-server
bind = SUPER CTRL, R, exec, ~/.local/bin/hypr-stt reset
```

## Usage

### Basic Commands

```bash
# Toggle recording (start/stop)
hypr-stt toggle

# Start recording only
hypr-stt start

# Stop and transcribe
hypr-stt stop

# Check status (for Waybar)
hypr-stt status

# List available microphones
hypr-stt list-mics
```

### Server Management

```bash
# Start server (load model on GPU)
hypr-stt start-server

# Stop server (free VRAM for other ML work)
hypr-stt stop-server

# Restart server
hypr-stt restart-server

# Full reset
hypr-stt reset
```

### Workflow for GPU Management

```bash
# 1. STT server is running continuously (auto-starts on login)
# 2. Before loading LLM/other ML model:
SUPER + ALT + R    # Stop server, free ~600MB VRAM

# 3. Run your other ML workload (llama.cpp, etc.)

# 4. After finishing, resume STT:
SUPER + SHIFT + S  # Start server, load Whisper back on GPU
```

## Integration Guide

### OpenWebUI Integration

1. **Start the Whisper server** (if not running):
   ```bash
   ~/.local/bin/hypr-stt start-server
   ```

2. **In OpenWebUI Settings** → Speech-to-Text:
   - **Endpoint**: `http://localhost:7861/v1/audio/transcriptions`
   - **API Key**: (leave empty - local server doesn't require auth)
   - **Model**: `small` (or your configured model)

3. **For OpenWebUI on a different machine**:
   - Set `WHISPER_HOST=0.0.0.0` in `~/.config/hypr-stt/env`
   - Use your machine's IP: `http://192.168.x.x:7861/v1/audio/transcriptions`
   - Ensure port 7861 is allowed in firewall

4. **Free VRAM before running LLM**:
   ```bash
   ~/.local/bin/hypr-stt stop-server
   ```

### LibreChat Integration

Add to `librechat.yaml`:

```yaml
speech:
  stt:
    provider: "openai"
    apiKey: "dummy-key"  # Not used for local server
    model: "small"
    baseURL: "http://localhost:7861/v1"
```

### Waybar Integration

Add to `~/.config/waybar/config`:

```json
{
  "modules-left": ["custom/stt"],
  "custom/stt": {
    "format": "{}",
    "return-type": "json",
    "interval": 1,
    "exec": "~/.local/bin/hypr-stt status",
    "signal": 8,
    "on-click": "~/.local/bin/hypr-stt toggle"
  }
}
```

Add to `~/.config/waybar/style.css`:

```css
#custom-stt {
  padding: 0 10px;
  margin: 4px 2px;
  border-radius: 4px;
  font-weight: bold;
}
#custom-stt.recording {
  background-color: #f38ba8;
  color: #1e1e2e;
  animation: stt-blink 1s infinite;
}
#custom-stt.processing {
  background-color: #fab387;
  color: #1e1e2e;
}
#custom-stt.idle {
  background-color: transparent;
  color: #cdd6f4;
}
@keyframes stt-blink {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}
```

### API Usage (Custom Applications)

#### Python Example

```python
import requests

def transcribe_audio(audio_path: str) -> str:
    """Transcribe audio file using local Whisper API."""
    with open(audio_path, 'rb') as f:
        files = {'file': f}
        data = {
            'model': 'small',
            'language': 'en',
            'response_format': 'json'
        }
        response = requests.post(
            'http://localhost:7861/v1/audio/transcriptions',
            files=files,
            data=data
        )
        response.raise_for_status()
        return response.json()['text']

# Usage
text = transcribe_audio('recording.wav')
print(f"Transcription: {text}")
```

#### cURL Example

```bash
# JSON response
curl -X POST http://localhost:7861/v1/audio/transcriptions \
  -F "file=@recording.wav;type=audio/wav" \
  -F "model=small" \
  -F "language=en" \
  -F "response_format=json"

# Plain text response
curl -X POST http://localhost:7861/v1/audio/transcriptions \
  -F "file=@recording.wav;type=audio/wav" \
  -F "model=small" \
  -F "language=en" \
  -F "response_format=text"
```

#### JavaScript/Node.js Example

```javascript
const FormData = require('form-data');
const fs = require('fs');
const axios = require('axios');

async function transcribe(audioPath) {
  const form = new FormData();
  form.append('file', fs.createReadStream(audioPath));
  form.append('model', 'small');
  form.append('language', 'en');
  form.append('response_format', 'json');
  
  const response = await axios.post(
    'http://localhost:7861/v1/audio/transcriptions',
    form,
    { headers: form.getHeaders() }
  );
  
  return response.data.text;
}
```

## API Reference

### Endpoints

#### `GET /`
API information.

**Response:**
```json
{
  "name": "Whisper STT API",
  "version": "1.0.0",
  "docs": "/docs",
  "openapi": "/openapi.json"
}
```

#### `GET /health`
Health check endpoint.

**Response:**
```json
{
  "status": "ok",
  "model": "small",
  "device": "cuda",
  "compute_type": "float16"
}
```

#### `GET /ready`
Readiness check (200 when model loaded, 503 when loading).

**Response:**
```json
{"status": "ready"}
```

#### `POST /v1/audio/transcriptions`
Transcribe audio file (OpenAI compatible).

**Parameters:**
- `file` (multipart): Audio file (WAV, MP3, FLAC, etc.)
- `model` (form, optional): Model name (default: "small")
- `language` (form, optional): Language code (default: null, auto-detect)
- `response_format` (form, optional): "json" or "text" (default: "json")

**Response (JSON):**
```json
{"text": "Transcribed text here."}
```

**Response (Text):**
```
Transcribed text here.
```

#### `GET /v1/models`
List available models (OpenAI compatibility).

**Response:**
```json
{
  "object": "list",
  "data": [
    {
      "id": "small",
      "object": "model",
      "created": 1771538436,
      "owned_by": "openai"
    }
  ]
}
```

## Troubleshooting

### Server won't start

```bash
# Check logs
journalctl --user -u whisper-api.service -n 50 --no-pager

# Check if port is in use
lsof -i :7861

# Manual start for debugging
~/.local/bin/whisper-api-server
```

### "No audio recorded" error

1. Check microphone permissions:
   ```bash
   pactl list sources short
   ```

2. Test microphone:
   ```bash
   pw-record --rate=16000 --channels=1 --format=s16 test.wav
   # Speak for a few seconds, then Ctrl+C
   ```

3. Select correct microphone:
   ```bash
   hypr-stt list-mics
   hypr-stt select-mic  # Interactive selection
   ```

### CUDA errors

```bash
# Check NVIDIA GPU
nvidia-smi

# Check CUDA installation
nvcc --version

# Verify LD_PRELOAD in service
systemctl --user cat whisper-api.service | grep LD_PRELOAD
```

### Transcription returns empty

1. Check if VAD is filtering out short audio (disabled by default)
2. Try speaking longer phrases
3. Check microphone volume: `pavucontrol`

## Systemd Service

The Whisper server runs as a systemd user service:

```bash
# Check status
systemctl --user status whisper-api.service

# View logs
journalctl --user -u whisper-api.service -f

# Restart
systemctl --user restart whisper-api.service

# Disable auto-start
systemctl --user disable whisper-api.service
```

## License

MIT License - See LICENSE file for details.

## Credits

- [OpenAI Whisper](https://github.com/openai/whisper) - Base model
- [faster-whisper](https://github.com/SYSTRAN/faster-whisper) - Optimized inference
- [FastAPI](https://fastapi.tiangolo.com/) - API framework
