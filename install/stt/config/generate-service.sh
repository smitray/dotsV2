#!/bin/bash
#
# Generate and install whisper-api.service for current user
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_HOME="$HOME"
USER_ID="$(id -u)"
USER_NAME="$(whoami)"

# Read template
SERVICE_FILE="$SCRIPT_DIR/whisper-api.service.template"
OUTPUT_FILE="$SCRIPT_DIR/whisper-api.service"

cat > "$OUTPUT_FILE" << EOF
[Unit]
Description=Whisper STT API Server
Documentation=https://github.com/SYSTRAN/faster-whisper
After=graphical-session.target
Wants=graphical-session.target

# Restart limits - prevent infinite restart loops
StartLimitBurst=5
StartLimitIntervalSec=60

[Service]
Type=simple
ExecStartPre=${USER_HOME}/.config/systemd/user/whisper-cleanup.sh
ExecStart=${USER_HOME}/.local/bin/whisper-api-server
Restart=on-failure
RestartSec=10
TimeoutStartSec=60
TimeoutStopSec=30

# Process management - ensure clean shutdown
KillMode=mixed
KillSignal=SIGTERM
SendSIGKILL=yes
FinalKillSignal=SIGKILL

# Prevent multiple instances
LockPersonality=yes
MemoryDenyWriteExecute=no
ProtectHome=yes
ProtectSystem=strict
ReadWritePaths=${USER_HOME}/.cache/huggingface /tmp /run/user/${USER_ID}

# Environment configuration
# CUDA compatibility layer for systems with CUDA 13+
Environment="LD_LIBRARY_PATH=${USER_HOME}/.local/lib/cuda-compat:/opt/cuda/lib64"
Environment="WHISPER_DEVICE=cuda"

# Preload CUDA library to avoid cublas loading issues
Environment="LD_PRELOAD=/opt/cuda/lib64/libcublas.so.13"

# Server runs continuously - no auto-shutdown
# To free VRAM for other ML workloads, use:
#   ~/.local/bin/hypr-stt stop-server
# To restart after loading other models:
#   ~/.local/bin/hypr-stt start-server

# Logging
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
EOF

echo "Generated service file: $OUTPUT_FILE"
echo "User: $USER_NAME (UID: $USER_ID)"
echo "Home: $USER_HOME"
