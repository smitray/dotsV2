# Whisper STT Session State - Recovery Guide

**Date:** 2026-02-21  
**Session:** STT System Repair, CUDA Fix, and Boot Notifications  
**Status:** ✅ FULLY OPERATIONAL WITH NOTIFICATIONS

---

## Quick Status Check

After reboot, verify everything is working:
```bash
# Check service status
systemctl --user status whisper-api.service

# Test transcription
curl -s http://localhost:7861/health
curl -s -X POST http://localhost:7861/v1/audio/transcriptions \
  -F "file=@/tmp/test-audio.wav;type=audio/wav" \
  -F "model=small" \
  -F "language=en"

# Or use the client
~/.local/bin/hypr-stt toggle  # Start recording
~/.local/bin/hypr-stt toggle  # Stop and transcribe
```

---

## What Was Broken

### 1. Systemd Watchdog Timeout
- **Symptom:** Service killed during model loading
- **Error:** `whisper-api.service: Watchdog timeout (limit 2min)!`
- **Root Cause:** Model loading took >2 minutes, systemd killed the service

### 2. Cleanup Script Killing Server
- **Symptom:** Service started then immediately stopped
- **Root Cause:** `ExecStartPre` cleanup script was killing the server process

### 3. Missing CUDA 12 Libraries
- **Symptom:** HTTP 500 errors on transcription
- **Error:** `Library libcublas.so.12 is not found or cannot be loaded`
- **Root Cause:** faster-whisper requires CUDA 12, system has CUDA 13

### 4. Boot Notifications (ADDED)
- **Feature:** Desktop notifications when service starts and model loads
- **What you'll see:**
  1. **"Starting Whisper server..."** - Appears immediately on boot
  2. **"🎤 STT Ready! (cuda)"** - Appears after model is loaded (~5-10 seconds)
- **Dependencies:** Added `dunst.service` and `xdg-desktop-portal.service` to ensure notification daemon is ready

---

## All Fixes Applied

### 1. Updated Service Configuration
**File:** `config/whisper-api.service` → `~/.config/systemd/user/whisper-api.service`

```ini
[Unit]
Description=Whisper STT API Server
Documentation=https://github.com/SYSTRAN/faster-whisper
After=graphical-session.target pipewire.service dunst.service
Wants=graphical-session.target pipewire.service
# Wait for notification daemon to be ready
After=xdg-desktop-portal.service

# Restart limits - prevent infinite restart loops
StartLimitBurst=10
StartLimitIntervalSec=300

[Service]
Type=simple
ExecStart=/home/debasmitr/.local/bin/whisper-api-server
ExecStopPost=/home/debasmitr/.config/whisper-api/whisper-cleanup.sh
Restart=on-failure
RestartSec=5

# Timeouts
TimeoutStartSec=600
TimeoutStopSec=30

# Watchdog - systemd will restart if server becomes unresponsive
# Increased to 5 minutes to allow model download on first run
WatchdogSec=300

# Process management - ensure clean shutdown
KillMode=mixed
KillSignal=SIGTERM
SendSIGKILL=yes
FinalKillSignal=SIGKILL

# Environment (minimal - most config in ~/.config/whisper-api/config.yaml)
Environment="PYTHONPATH=/home/debasmitr/workspace/dotFileV2/install/stt/lib"
Environment="LD_LIBRARY_PATH=/home/debasmitr/.local/lib/cuda-compat:/opt/cuda/lib64:/usr/lib"

# Environment (minimal - most config in ~/.config/whisper-api/config.yaml)
Environment="PYTHONPATH=/home/debasmitr/workspace/dotFileV2/install/stt/lib"
Environment="LD_LIBRARY_PATH=/home/debasmitr/.local/lib/cuda-compat:/opt/cuda/lib64:/usr/lib"

# Server runs continuously - no auto-shutdown
# To free VRAM for other ML workloads, use:
#   ~/.local/bin/whisper-ctl stop
# To restart after loading other models:
#   ~/.local/bin/whisper-ctl restart

# Logging
StandardOutput=journal
StandardError=journal

# Keep environment across restarts
RemainAfterExit=yes

[Install]
WantedBy=default.target
```

### 2. Created CUDA Compatibility Symlinks
**Directory:** `~/.local/lib/cuda-compat/`

```bash
# Created symlinks for CUDA 12 compatibility
ln -sf /opt/cuda/lib64/libcublas.so.13 ~/.local/lib/cuda-compat/libcublas.so.12
ln -sf /opt/cuda/lib64/libcublasLt.so.13 ~/.local/lib/cuda-compat/libcublasLt.so.12
```

### 3. Fixed Cleanup Script
**File:** `~/.config/whisper-api/whisper-cleanup.sh`
- Script exists and is executable
- Moved from `ExecStartPre` to `ExecStopPost` to prevent killing server during startup

### 4. Configuration Files Verified
**Server config:** `~/.config/whisper-api/config.yaml`
- Model: small
- Device: auto (detects CUDA)
- Port: 7861

**Client config:** `~/.config/hypr-stt/env`
- All environment variables set correctly
- API URL: http://localhost:7861/v1/audio/transcriptions

### 5. Boot Notification System (ADDED)
**Files updated:**
- `lib/whisper_api/server.py` - Added startup/ready notifications
- `lib/whisper_api/notify.py` - Notification helper class
- `config/whisper-api.service` - Added dunst/portal dependencies

**Notifications:**
- **notify_starting()** - "Starting Whisper server..." 
- **notify_ready()** - "🎤 STT Ready! (device)" with 1-second delay for daemon readiness
- **notify_stopped()** - "Server stopped - VRAM freed"
- **notify_error()** - Error notifications with critical urgency

---

## Key Configuration Changes Summary

| Setting | Old Value | New Value | Reason |
|---------|-----------|-----------|---------|
| `WatchdogSec` | 120 | 300 | Allow 5min for model loading |
| `TimeoutStartSec` | 300 | 600 | Allow 10min for first-time model download |
| `Type` | notify | simple | Avoid sdnotify dependency issues |
| `ExecStartPre` | cleanup.sh | (removed) | Was killing server during startup |
| `ExecStopPost` | - | whisper-cleanup.sh | Cleanup after service stops |
| `LD_LIBRARY_PATH` | - | Added cuda-compat path | Fix CUDA 12 library loading |
| `After=` | graphical-session.target | Added dunst.service, xdg-desktop-portal.service | Ensure notification daemon ready |
| **Notifications** | None | notify_starting() + notify_ready() | Boot notifications implemented |

---

## System State

### Service Status
```
● whisper-api.service - Whisper STT API Server
     Loaded: loaded (/home/debasmitr/.config/systemd/user/whisper-api.service; enabled; preset: enabled)
     Active: active (running)
   Main PID: 24087 (python3)
      Tasks: 24
     Memory: 798M (peak: 798M)
        CPU: 3.629s
```

### Health Check
```json
{
  "status": "ok",
  "model": "small",
  "device": "cuda",
  "compute_type": "float16",
  "model_loaded": true
}
```

### Test Results
- ✅ Service starts without timeout
- ✅ Model loads on CUDA GPU
- ✅ Transcription endpoint returns HTTP 200
- ✅ Audio files transcribed successfully

---

## How to Resume After Reboot

### 1. Verify Service Auto-Started
```bash
systemctl --user status whisper-api.service
```
Expected: `Active: active (running)`

### 2. If Service Failed to Start
```bash
# Check logs
journalctl --user -u whisper-api.service -n 50

# Common fixes
systemctl --user daemon-reload
systemctl --user restart whisper-api.service
```

### 3. Verify Transcription Works
```bash
# Create test audio
pw-record --rate=16000 --channels=1 --format=s16 /tmp/test.wav &
sleep 2
kill %1

# Test API
curl -X POST http://localhost:7861/v1/audio/transcriptions \
  -F "file=@/tmp/test.wav;type=audio/wav" \
  -F "model=small" \
  -F "language=en"
```

### 4. Test with Client
```bash
# Toggle recording
~/.local/bin/hypr-stt toggle
# Speak, then toggle again to transcribe
~/.local/bin/hypr-stt toggle
```

---

## Troubleshooting

### Issue: Service won't start
```bash
# Check for port conflicts
lsof -i :7861

# Check logs
journalctl --user -u whisper-api.service -f

# Manual start for debugging
PYTHONPATH=/home/debasmitr/workspace/dotFileV2/install/stt/lib \
  LD_LIBRARY_PATH=/home/debasmitr/.local/lib/cuda-compat:/opt/cuda/lib64:/usr/lib \
  ~/.local/bin/whisper-api-server
```

### Issue: HTTP 500 on transcription
**Cause:** CUDA library not found
**Fix:** Verify `LD_LIBRARY_PATH` in service file includes `~/.local/lib/cuda-compat`

### Issue: Model loading timeout
**Cause:** Watchdog timeout too short
**Fix:** Increase `WatchdogSec` and `TimeoutStartSec` in service file

### Issue: Cleanup script errors
**Cause:** Script killing itself or wrong path
**Fix:** Ensure script is at `~/.config/whisper-api/whisper-cleanup.sh` and executable

---

## File Locations

### Repository Files (DO NOT EDIT DIRECTLY)
- `/home/debasmitr/workspace/dotFileV2/install/stt/config/whisper-api.service` - Source service file
- `/home/debasmitr/workspace/dotFileV2/install/stt/config/whisper-cleanup.sh` - Source cleanup script
- `/home/debasmitr/workspace/dotFileV2/install/stt/lib/whisper_api/` - Python server code

### Installed Files (ACTIVE CONFIGURATION)
- `~/.config/systemd/user/whisper-api.service` - **ACTIVE systemd service**
- `~/.config/whisper-api/config.yaml` - Server configuration
- `~/.config/whisper-api/whisper-cleanup.sh` - Cleanup script
- `~/.config/hypr-stt/env` - Environment variables
- `~/.local/bin/hypr-stt` - Client script
- `~/.local/bin/whisper-api-server` - Server entry point
- `~/.local/lib/cuda-compat/` - CUDA compatibility symlinks

---

## Last Working Configuration

All changes have been saved to:
1. **Repository:** `/home/debasmitr/workspace/dotFileV2/install/stt/config/whisper-api.service`
2. **Systemd:** `~/.config/systemd/user/whisper-api.service`

The system is configured to auto-start on login and should work immediately after reboot.

---

## Session Notes

**Completed Tasks:**
- ✅ Diagnosed watchdog timeout issue
- ✅ Fixed cleanup script killing server
- ✅ Added CUDA library compatibility layer
- ✅ Verified transcription working end-to-end
- ✅ Documented all changes

**Next Steps After Reboot:**
1. Verify service auto-started: `systemctl --user status whisper-api.service`
2. Test transcription: `curl http://localhost:7861/health`
3. Test with client: `~/.local/bin/hypr-stt toggle`

**If Issues Persist:**
- Check this file for troubleshooting steps
- Review systemd logs: `journalctl --user -u whisper-api.service -f`
- Verify CUDA symlinks: `ls -la ~/.local/lib/cuda-compat/`

---

**End of Session State**
**Status: READY FOR REBOOT**
