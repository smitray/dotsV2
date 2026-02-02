# Whisper STT for Hyprland

Local, GPU-accelerated Speech-to-Text system for Hyprland Wayland compositor using OpenAI's Whisper model.

## Features

- **Local Processing**: 100% offline, no data leaves your machine
- **GPU Acceleration**: Uses CUDA for faster transcription (RTX 3050+ recommended)
- **Smart VRAM Management**: Auto-shutdown after 5 minutes idle, on-demand startup
- **Three-Tier Fallback**: wtype → ydotool → clipboard for text injection
- **Automatic Device Selection**: Prefers Bluetooth headsets over built-in mics
- **OpenAI API Compatible**: Works with OpenWebUI and other tools
- **Real-time Visualization**: Dunst notifications + Waybar status indicator

## Architecture Overview

```
[User presses Super+R]
       ↓
[hfyr-stt starts API server] → GPU if VRAM>600MB, else CPU
       ↓
[hfyr-stt starts pw-record] → Auto-select WH-1000XM5 if connected, else laptop mic
       ↓
[User speaks] → 16kHz mono WAV → /run/user/$UID/hypr-stt-recording.wav
       ↓
[User presses Super+R again]
       ↓
[POST to localhost:7861/v1/audio/transcriptions]
       ↓
[Response] → wtype/ydotool/clipboard → Active window
       ↓
[Schedule server shutdown] → 5min idle timeout
```

## Requirements

### Hardware
- NVIDIA GPU with 4GB+ VRAM recommended (RTX 3050+)
- Or CPU with 16GB+ RAM (slower, ~2-3x)

### Software
- **OS**: Arch Linux (or Arch-based distro)
- **Compositor**: Hyprland (Wayland)
- **Audio Server**: PipeWire with WirePlumber
- **Shell**: bash, zsh, or fish (auto-detected)

## Installation

### Automatic Installation

1. Clone or download this repository:
```bash
cd ~/workspace/whisper-stt
```

2. Run the installer:
```bash
./install.sh
```

The installer will:
- Check and install system packages (pacman)
- Install Python packages via pip
- Install NVIDIA drivers/CUDA if needed
- Copy scripts to `~/.local/bin`
- Install environment file to `~/.config/hypr-stt/env`
- Add shell config sourcing automatically
- Install systemd user service (optional)

### Manual Installation

If you prefer manual installation or encounter issues:

#### 1. Install System Packages
```bash
sudo pacman -S --needed \
  pipewire pipewire-alsa pipewire-pulse wireplumber \
  pavucontrol pamixer \
  wtype ydotool \
  dunst libnotify \
  curl jq \
  wl-clipboard \
  waybar
```

Add user to input group for ydotool:
```bash
sudo usermod -aG input $USER
# Log out and back in
```

Enable ydotool:
```bash
systemctl --user enable --now ydotool.socket
```

#### 2. Install Python Packages
```bash
pip install --user faster-whisper uvicorn fastapi python-multipart
```

#### 3. Install Scripts
```bash
chmod +x bin/whisper-api-server bin/hypr-stt
mkdir -p ~/.local/bin
cp bin/whisper-api-server bin/hypr-stt ~/.local/bin/
```

#### 4. Setup Environment File
```bash
mkdir -p ~/.config/hypr-stt
cp .env ~/.config/hypr-stt/env
```

Add to your shell config (`~/.zshenv` for zsh, `~/.bashrc` for bash):
```bash
# Whisper STT environment variables
[ -f "$HOME/.config/hypr-stt/env" ] && source "$HOME/.config/hypr-stt/env"
```

#### 5. Install Hyprland Keybinding
Add to `~/.config/hypr/hyprland.conf`:
```bash
# Primary: Super+R to toggle recording
bind = SUPER, R, exec, ~/.local/bin/hypr-stt toggle

# Optional: Super+Shift+R to reset STT
bind = SUPER SHIFT, R, exec, ~/.local/bin/hypr-stt reset
```

#### 6. Reload Hyprland
```bash
hyprctl reload
```

## Configuration

### Environment Variables

Edit `~/.config/hypr-stt/env` or create `.env` before installation:

```bash
# Server Configuration
export WHISPER_PORT=7861                      # API server port
export WHISPER_MODEL=small                   # tiny/base/small/medium/large-v3
export WHISPER_IDLE_TIMEOUT=300              # Idle timeout (seconds)
export WHISPER_DEVICE=cuda                   # cuda/cpu (auto-detected)

# Client Configuration
export HYPR_STT_API_URL=http://localhost:${WHISPER_PORT}/v1/audio/transcriptions
export HYPR_STT_MODEL=${WHISPER_MODEL}
export HYPR_STT_PORT=${WHISPER_PORT}
export HYPR_STT_LANGUAGE=en                   # en/es/fr/de/hi/zh/ja/ko

# Model Cache (Hugging Face)
export HF_HOME=$HOME/.cache/huggingface      # Or custom location
```

### Model Selection

| Model | Size | VRAM (GPU) | VRAM (CPU) | Speed | Accuracy |
|-------|------|------------|------------|-------|----------|
| **tiny** | 39MB | ~300MB | ~500MB | Fastest | Low |
| **base** | 74MB | ~400MB | ~700MB | Fast | Medium |
| **small** | 244MB | ~600MB | ~1GB | Medium | Good **(default)** |
| **medium** | 769MB | ~1.5GB | ~2GB | Slow | Better |
| **large-v3** | 3GB | ~3GB | ~4GB | Slowest | Best |

To change model, edit `~/.config/hypr-stt/env`:
```bash
export WHISPER_MODEL=base
```

Or use temporarily:
```bash
WHISPER_MODEL=base ~/.local/bin/hypr-stt toggle
```

### Language Support

Whisper supports 99 languages. Set in environment:
```bash
# Spanish
export HYPR_STT_LANGUAGE=es

# Hindi
export HYPR_STT_LANGUAGE=hi

# Japanese
export HYPR_STT_LANGUAGE=ja
```

Full list: [Whisper Language Support](https://github.com/openai/whisper#available-languages-and-english-only-models)

## Usage

### Basic Usage

1. Press **Super+R** to start recording
2. Speak into your microphone
3. Press **Super+R** again to stop and transcribe
4. Text automatically types at cursor position

### Reset System

If something goes wrong or you want to start fresh:
- Press **Super+Shift+R** (if configured)
- Or run: `~/.local/bin/hypr-stt reset`

This stops recording, stops the server, and cleans all state.

### Stop Server Manually

To free VRAM immediately:
- Press **Super+Ctrl+R** (if configured)
- Or run: `~/.local/bin/hypr-stt stop-server`

### Audio Device Selection

The system automatically selects:
1. Bluetooth headset (Sony WH-1000XM5) if connected
2. Default system microphone otherwise

To check available audio sources:
```bash
pactl list sources short
```

### Waybar Integration (Optional)

Add module to `~/.config/waybar/config`:

```jsonc
"custom/stt": {
    "format": "{}",
    "return-type": "json",
    "interval": 1,
    "exec": "~/.local/bin/hypr-stt status",
    "signal": 8,
    "on-click": "~/.local/bin/hypr-stt toggle"
}
```

Add styles to `~/.config/waybar/style.css`:

```css
#custom-stt {
    padding: 0 10px;
    margin: 4px 2px;
    border-radius: 4px;
    font-weight: bold;
}

#custom-stt.recording {
    background-color: #f38ba8;  /* Catppuccin Red */
    color: #1e1e2e;
    animation: stt-blink 1s ease-in-out infinite;
}

#custom-stt.processing {
    background-color: #fab387;  /* Catppuccin Peach */
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

## Environment Variables Reference

### Server Variables (`whisper-api-server`)

| Variable | Default | Description |
|----------|---------|-------------|
| `WHISPER_PORT` | `7861` | API server port |
| `WHISPER_MODEL` | `small` | Whisper model size |
| `WHISPER_IDLE_TIMEOUT` | `300` | Seconds before auto-shutdown |
| `WHISPER_DEVICE` | `auto` | Force device: `cuda` or `cpu` |

### Client Variables (`hypr-stt`)

| Variable | Default | Description |
|----------|---------|-------------|
| `HYPR_STT_API_URL` | `http://localhost:7861/v1/audio/transcriptions` | Full API endpoint |
| `HYPR_STT_MODEL` | `small` | Model name sent to API |
| `HYPR_STT_PORT` | `7861` | Port for health checks |
| `HYPR_STT_LANGUAGE` | `en` | Language code |
| `HYPR_STT_SERVER` | `auto` | Path to server script |

### Cache Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `HF_HOME` | `~/.cache/huggingface/` | Hugging Face cache location |
| `TRANSFORMERS_CACHE` | `~/.cache/huggingface/` | Alternative cache location |

## File Documentation

### `bin/whisper-api-server`

Python FastAPI server that hosts the Whisper model.

**Purpose**: Provides OpenAI-compatible REST API for audio transcription.

**Key Features**:
- Auto-detects NVIDIA GPU with VRAM availability check
- Auto-shutdown after 5 minutes idle to free VRAM
- Voice Activity Detection (VAD) to filter silence
- Graceful shutdown with proper cleanup

**Default Port**: 7861

**API Endpoints**:
- `POST /v1/audio/transcriptions` - Transcribe audio
- `GET /health` - Health check
- `GET /` - Root endpoint
- `GET /docs` - Auto-generated API docs (FastAPI)

**Environment Variables**:
- `WHISPER_PORT` - Server port
- `WHISPER_MODEL` - Model size (tiny/base/small/medium/large-v3)
- `WHISPER_IDLE_TIMEOUT` - Idle timeout in seconds
- `WHISPER_DEVICE` - Force device (cuda/cpu)

**Dependencies**:
- `faster-whisper` - Optimized Whisper implementation
- `uvicorn` - ASGI server
- `fastapi` - API framework
- `python-multipart` - File upload support

### `bin/hypr-stt`

Bash client script that manages the recording/transcription workflow.

**Purpose**: Main user-facing script for STT operations.

**Commands**:
```bash
~/.local/bin/hypr-stt           # Toggle recording (default)
~/.local/bin/hypr-stt toggle    # Start/stop recording
~/.local/bin/hypr-stt reset     # Reset everything to clean state
~/.local/bin/hypr-stt status    # JSON status for Waybar
~/.local/bin/hypr-stt stop-server # Stop API server
~/.local/bin/hypr-stt help      # Show help
```

**State Machine**:
```
idle → recording → processing → idle
       ↑_______________|
```

**Runtime Files** (stored in `/run/user/$UID/`):
- `hypr-stt-state` - Current state (idle/recording/processing)
- `hypr-stt-pid` - Recording process PID
- `hypr-stt-recording.wav` - Temporary audio file
- `whisper-api-server.pid` - Server process PID
- `whisper-server.log` - Server log file

**Runtime Paths (use `/run/user/$UID/` for security)
RUN_DIR="/run/user/$(id -u)"
mkdir -p "$RUN_DIR" 2>/dev/null || RUN_DIR="/tmp"

STATE_FILE="$RUN_DIR/hypr-stt-state"
AUDIO_FILE="$RUN_DIR/hypr-stt-recording.wav"
PID_FILE="$RUN_DIR/hypr-stt-pid"
SERVER_PID_FILE="$RUN_DIR/whisper-api-server.pid"
SERVER_LOG="$RUN_DIR/whisper-server.log"

# Secure file permissions
umask 077

# Cleanup trap - remove artifacts on exit
cleanup() {
    rm -f "$PID_FILE" "$SERVER_PID_FILE" "$SERVER_LOG" 2>/dev/null || true
}
trap cleanup EXIT

# Cleanup old artifacts on startup (in case of previous crash)
cleanup_old_artifacts() {
    # Remove stale PID files (process not running)
    local pid
    if [[ -f "$PID_FILE" ]]; then
        pid=$(cat "$PID_FILE" 2>/dev/null || echo "")
        if [[ -n "$pid" ]] && ! kill -0 "$pid" 2>/dev/null; then
            rm -f "$PID_FILE"
        fi
    fi
    if [[ -f "$SERVER_PID_FILE" ]]; then
        pid=$(cat "$SERVER_PID_FILE" 2>/dev/null || echo "")
        if [[ -n "$pid" ]] && ! kill -0 "$pid" 2>/dev/null; then
            rm -f "$SERVER_PID_FILE" "$SERVER_LOG"
        fi
    fi
}

# Initialize state file atomically
init_state() {
    if [[ ! -f "$STATE_FILE" ]]; then
        echo "idle" > "$STATE_FILE" 2>/dev/null || true
        chmod 600 "$STATE_FILE" 2>/dev/null || true
    fi
}

get_state() {
    cat "$STATE_FILE" 2>/dev/null || echo "idle"
}

set_state() {
    # Atomic write: write to temp file, then move
    local tmp_state
    tmp_state=$(mktemp)
    echo "$1" > "$tmp_state"
    mv "$tmp_state" "$STATE_FILE" 2>/dev/null || true
    chmod 600 "$STATE_FILE" 2>/dev/null || true
    
    # Signal waybar to update (RTMIN+8 = signal 42)
    pkill -RTMIN+8 waybar 2>/dev/null || true
}

# Notification helper using notify-send
# Uses app-name/urgency grouping to avoid notification spam in dunst
notify() {
    local icon="$1"
    local msg="$2"
    local urgency="${3:-normal}"
    
    if command -v notify-send &>/dev/null; then
        # Use app-name for grouping (dunst replaces same app + urgency)
        # This avoids the -p flag compatibility issue with older dunst
        notify-send -u "$urgency" -i "$icon" -a "hypr-stt-$urgency" "hypr-stt" "$msg" 2>/dev/null || true
    fi
}

# Check if GPU has enough free VRAM (>600MB)
check_gpu_available() {
    if ! command -v nvidia-smi &>/dev/null; then
        return 1
    fi
    local free_mem
    free_mem=$(nvidia-smi --query-gpu=memory.free --format=csv,noheader,nounits 2>/dev/null | head -1)
    [[ -n "$free_mem" && "$free_mem" -gt 600 ]]
}

# Check if API server is running and healthy
server_healthy() {
    curl -sf "http://localhost:$PORT/health" >/dev/null 2>&1
}

# Start API server on demand
start_server() {
    if server_healthy; then
        return 0
    fi
    
    notify "system-run" "Starting Whisper server..." "low"
    
    # Determine device based on VRAM availability
    if check_gpu_available; then
        export WHISPER_DEVICE="cuda"
    else
        export WHISPER_DEVICE="cpu"
        notify "dialog-warning" "GPU busy, using CPU (slower)" "normal"
    fi
    
    # Find the server script
    local server_script
    for path in \
        "${HYPR_STT_SERVER:-}" \
        "$HOME/.local/bin/whisper-api-server" \
        "$(dirname "$(readlink -f "$0")")/whisper-api-server"; do
        if [[ -n "$path" && -x "$path" ]]; then
            server_script="$path"
            break
        fi
    done
    
    if [[ -z "${server_script:-}" ]]; then
        notify "dialog-error" "Server script not found" "critical"
        return 1
    fi
    
    # Start server in background with environment variables
    WHISPER_PORT="${WHISPER_PORT:-7861}" \
    WHISPER_MODEL="${WHISPER_MODEL:-small}" \
    WHISPER_IDLE_TIMEOUT="${WHISPER_IDLE_TIMEOUT:-300}" \
    WHISPER_DEVICE="${WHISPER_DEVICE:-}" \
    "$server_script" > "$SERVER_LOG" 2>&1 &
    local pid=$!
    # Atomic PID write
    echo "$pid" > "$SERVER_PID_FILE" 2>/dev/null || true
    chmod 600 "$SERVER_PID_FILE" 2>/dev/null || true
    
    # Wait for server to be ready (max 30s for model download on first run)
    local max_wait=30
    local waited=0
    while [[ $waited -lt $max_wait ]]; do
        sleep 1
        ((waited++))
        if server_healthy; then
            notify "emblem-ok" "Server ready" "low"
            return 0
        fi
        # Check if process died
        if ! kill -0 "$pid" 2>/dev/null; then
            notify "dialog-error" "Server crashed. Check $SERVER_LOG" "critical"
            return 1
        fi
    done
    
    notify "dialog-error" "Server timeout" "critical"
    return 1
}

# Get preferred audio source (Bluetooth headset > default)
get_preferred_mic() {
    local source
    
    # Check for Sony WH-1000XM5 or other Bluetooth headset
    source=$(pactl list sources short 2>/dev/null | grep -iE "bluez.*input|wh-1000xm5" | awk '{print $2}' | head -1)
    
    if [[ -n "$source" ]]; then
        echo "$source"
    else
        pactl get-default-source 2>/dev/null || echo "@DEFAULT_SOURCE@"
    fi
}

# Start recording
start_recording() {
    # Ensure server is running
    if ! start_server; then
        set_state "idle"
        return 1
    fi
    
    set_state "recording"
    notify "audio-input-microphone" "Recording... (press again to stop)" "normal"
    
    local mic
    mic=$(get_preferred_mic)
    
    # Start pw-record in background
    pw-record --target="$mic" --rate=16000 --channels=1 --format=s16 "$AUDIO_FILE" &
    local pid=$!
    echo "$pid" > "$PID_FILE" 2>/dev/null || true
    chmod 600 "$PID_FILE" 2>/dev/null || true
}

# Stop recording and transcribe
stop_recording() {
    local pid
    pid=$(cat "$PID_FILE" 2>/dev/null || echo "")
    
    if [[ -n "$pid" ]]; then
        kill "$pid" 2>/dev/null || true
        # Wait for process to fully terminate and flush audio
        wait "$pid" 2>/dev/null || true
    fi
    rm -f "$PID_FILE"
    
    set_state "processing"
    notify "emblem-synchronizing" "Processing..." "normal"
    
    # Ensure audio file exists and has content
    sleep 0.5
    # Wait for file to be written
    local timeout=10
    while [[ ! -f "$AUDIO_FILE" ]] && [[ $timeout -gt 0 ]]; do
        sleep 0.1
        ((timeout--))
    done
    
    if [[ ! -f "$AUDIO_FILE" || ! -s "$AUDIO_FILE" ]]; then
        notify "dialog-error" "No audio recorded" "critical"
        set_state "idle"
        return 1
    fi
    
    # Secure audio file before use
    chmod 600 "$AUDIO_FILE" 2>/dev/null || true
    
    # API call
    local response http_code body
    response=$(curl -s -w "\n%{http_code}" \
        --max-time 60 \
        -X POST "$API_URL" \
        -F "file=@$AUDIO_FILE;type=audio/wav" \
        -F "model=$MODEL" \
        -F "language=$LANGUAGE" \
        -F "response_format=text" 2>/dev/null) || true
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    # Cleanup audio file
    rm -f "$AUDIO_FILE"
    
    if [[ "$http_code" == "200" && -n "$body" && "$body" != "null" ]]; then
        # Capitalize first letter
        local text
        text=$(echo "$body" | sed 's/^./\U&/')
        
        # Type the text
        type_text "$text"
        
        # Show truncated notification
        local display_text="${text:0:50}"
        [[ ${#text} -gt 50 ]] && display_text="${display_text}..."
        notify "emblem-ok" "Typed: $display_text" "normal"
    else
        notify "dialog-error" "Transcription failed (HTTP ${http_code:-error})" "critical"
        echo "[hypr-stt] Error - HTTP $http_code: $body" >&2
    fi
    
    set_state "idle"
}

# Type text with fallback chain
type_text() {
    local text="$1"
    
    # Primary: wtype (Wayland native)
    if command -v wtype &>/dev/null; then
        if wtype -- "$text" 2>/dev/null; then
            return 0
        fi
    fi
    
    # Fallback: ydotool (works with XWayland apps)
    if command -v ydotool &>/dev/null; then
        if ydotool type -- "$text" 2>/dev/null; then
            return 0
        fi
    fi
    
    # Ultimate fallback: clipboard
    if command -v wl-copy &>/dev/null; then
        echo -n "$text" | wl-copy
        notify "edit-paste" "Copied to clipboard (Ctrl+V to paste)" "normal"
        return 0
    fi
    
    notify "dialog-error" "No typing method available" "critical"
    return 0
}

# Main toggle logic
toggle() {
    cleanup_old_artifacts
    init_state
    
    case "$(get_state)" in
        "idle")
            start_recording
            ;;
        "recording")
            stop_recording
            ;;
        "processing")
            notify "dialog-information" "Still processing, please wait..." "low"
            ;;
        *)
            set_state "idle"
            toggle
            ;;
    esac
}

# Status for waybar
status() {
    cleanup_old_artifacts
    init_state
    local state
    state=$(get_state)
    
    case "$state" in
        "recording")
            echo '{"text":"REC","class":"recording","tooltip":"Recording... Click to stop"}'
            ;;
        "processing")
            echo '{"text":"...","class":"processing","tooltip":"Processing audio..."}'
            ;;
        *)
            echo '{"text":"","class":"idle","tooltip":"STT Ready (Super+R)"}'
            ;;
    esac
}

# Stop server manually
stop_server() {
    local pid
    pid=$(cat "$SERVER_PID_FILE" 2>/dev/null || echo "")
    if [[ -n "$pid" ]]; then
        kill "$pid" 2>/dev/null || true
        # Wait for graceful shutdown
        local timeout=5
        while kill -0 "$pid" 2>/dev/null && [[ $timeout -gt 0 ]]; do
            sleep 0.2
            ((timeout--))
        done
        # Force kill if still running
        kill -9 "$pid" 2>/dev/null || true
        rm -f "$SERVER_PID_FILE"
        rm -f "$SERVER_LOG"
        notify "emblem-ok" "Server stopped" "low"
    else
        notify "dialog-information" "Server not running" "low"
    fi
}

# Reset everything to clean state
reset() {
    cleanup_old_artifacts
    
    local current_state
    current_state=$(get_state)
    
    if [[ "$current_state" == "recording" ]]; then
        local pid
        pid=$(cat "$PID_FILE" 2>/dev/null || echo "")
        if [[ -n "$pid" ]]; then
            kill "$pid" 2>/dev/null || true
            wait "$pid" 2>/dev/null || true
        fi
    fi
    
    # Clean up all runtime files
    rm -f "$STATE_FILE" "$PID_FILE" "$SERVER_PID_FILE" "$SERVER_LOG" "$AUDIO_FILE" 2>/dev/null || true
    
    # Force-kill server if still running
    local server_pid
    server_pid=$(pgrep -f "whisper-api-server" || echo "")
    if [[ -n "$server_pid" ]]; then
        kill "$server_pid" 2>/dev/null || true
        kill -9 "$server_pid" 2>/dev/null || true
    fi
    
    # Reinitialize state as idle
    init_state
    
    notify "emblem-ok" "STT reset to idle" "normal"
}

# Show help
show_help() {
    cat <<EOF
hypr-stt - Hyprland Speech-to-Text

Usage: hypr-stt [command]

Commands:
    toggle      Start/stop recording (default)
    status      JSON status for waybar
    reset       Reset everything to clean state (stop recording, server, cleanup)
    stop-server Stop the API server
    help        Show this help

Environment variables:
    HYPR_STT_API_URL    API endpoint (default: http://localhost:7861/v1/audio/transcriptions)
    HYPR_STT_MODEL      Whisper model (default: small)
    HYPR_STT_PORT       API port (default: 7861)
    HYPR_STT_LANGUAGE   Language code (default: en)
    HYPR_STT_SERVER     Path to server script

EOF
}

# Entry point
case "${1:-toggle}" in
    toggle)
        toggle
        ;;
    status)
        status
        ;;
    reset)
        reset
        ;;
    stop-server)
        stop_server
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1" >&2
        show_help
        exit 1
        ;;
esac
