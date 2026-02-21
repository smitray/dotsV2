"""
Whisper API Server - FastAPI Application

OpenAI-compatible REST API for local speech-to-text using Whisper model.
Designed for continuous operation with GPU memory management.
"""

import os
import sys
import time
import tempfile
import signal
import traceback
from pathlib import Path
from typing import Optional

from fastapi import FastAPI, File, UploadFile, Form
from fastapi.responses import PlainTextResponse, JSONResponse

from whisper_api import __version__
from whisper_api.model import ModelManager
from whisper_api.config import load_config, get_config_path
from whisper_api.notify import Notifier


# Systemd notification support
try:
    import sdnotify

    SDNOTIFY_AVAILABLE = True
except ImportError:
    SDNOTIFY_AVAILABLE = False


# =============================================================================
# Application Factory
# =============================================================================


def create_app(model_manager: ModelManager, notifier: Notifier, config) -> FastAPI:
    """Create and configure FastAPI application."""

    app = FastAPI(
        title="Whisper STT API",
        description="OpenAI-compatible Speech-to-Text API using local Whisper model",
        version=__version__,
        docs_url="/docs",
        redoc_url="/redoc",
    )

    # Store references in app state
    app.state.model_manager = model_manager
    app.state.notifier = notifier
    app.state.config = config

    @app.get("/")
    async def root():
        """Root endpoint with API info."""
        return {
            "name": "Whisper STT API",
            "version": __version__,
            "docs": "/docs",
            "openapi": "/openapi.json",
        }

    @app.get("/health")
    async def health():
        """
        Health check endpoint.

        Returns server status and configuration.
        """
        model_mgr = app.state.model_manager
        return {
            "status": "ok",
            "model": model_mgr.model_name,
            "device": model_mgr.device,
            "compute_type": model_mgr.compute_type,
            "model_loaded": model_mgr.is_loaded,
        }

    @app.get("/ready")
    async def ready():
        """
        Readiness check endpoint.

        Returns 200 when model is loaded, 503 otherwise.
        """
        if app.state.model_manager.is_loaded:
            return {"status": "ready"}
        return JSONResponse(status_code=503, content={"status": "loading"})

    @app.get("/status")
    async def status():
        """
        Detailed status endpoint with VRAM usage.

        Returns comprehensive server status.
        """
        model_mgr = app.state.model_manager

        # Get VRAM usage
        vram_used = 0
        vram_total = 0
        try:
            result = os.popen(
                "nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits"
            ).read()
            if result:
                parts = result.strip().split(",")
                if len(parts) == 2:
                    vram_used = int(parts[0].strip())
                    vram_total = int(parts[1].strip())
        except Exception:
            pass

        return {
            "status": "ready" if model_mgr.is_loaded else "loading",
            "model": model_mgr.model_name,
            "device": model_mgr.device,
            "compute_type": model_mgr.compute_type,
            "model_loaded": model_mgr.is_loaded,
            "vram": {
                "used_mb": vram_used,
                "total_mb": vram_total,
                "percent": round((vram_used / vram_total) * 100, 1)
                if vram_total > 0
                else 0,
            },
        }

    @app.post("/v1/audio/transcriptions")
    async def transcribe(
        file: UploadFile = File(..., description="Audio file (WAV, MP3, FLAC, etc.)"),
        model: str = Form(
            default="small", description="Model name (for compatibility)"
        ),
        language: Optional[str] = Form(
            default=None, description="Language code (e.g., 'en', 'es')"
        ),
        response_format: str = Form(
            default="json", description="Response format: 'json' or 'text'"
        ),
    ):
        """
        Transcribe audio file to text.

        OpenAI API compatible endpoint. Accepts various audio formats and
        returns transcription in JSON or plain text format.

        Args:
            file: Uploaded audio file
            model: Model name (ignored, uses server's configured model)
            language: Language code for transcription
            response_format: Response format (json/text)

        Returns:
            Transcription result in requested format
        """
        # Save uploaded file temporarily
        tmp_path = None
        try:
            with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as tmp:
                content = await file.read()
                tmp.write(content)
                tmp_path = tmp.name

            # Transcribe
            text = app.state.model_manager.transcribe(tmp_path, language)

            # Return in requested format
            if response_format == "json":
                return {"text": text}
            else:
                return PlainTextResponse(content=text)

        except Exception as e:
            error_trace = traceback.format_exc()
            print(f"[{time.strftime('%H:%M:%S')}] Transcription error: {e}")
            print(f"Traceback:\n{error_trace}")
            return JSONResponse(
                status_code=500, content={"error": str(e), "type": type(e).__name__}
            )

        finally:
            # Cleanup temp file
            if tmp_path and os.path.exists(tmp_path):
                try:
                    os.unlink(tmp_path)
                except Exception:
                    pass

    @app.get("/v1/models")
    async def list_models():
        """
        List available models (OpenAI compatibility).

        Returns:
            List of available models
        """
        return {
            "object": "list",
            "data": [
                {
                    "id": app.state.model_manager.model_name,
                    "object": "model",
                    "created": int(time.time()),
                    "owned_by": "openai",
                }
            ],
        }

    return app


# =============================================================================
# Signal Handling
# =============================================================================


def create_pid_file(pid_path: str) -> None:
    """Create PID file for process management."""
    try:
        os.makedirs(os.path.dirname(pid_path), exist_ok=True)
        with open(pid_path, "w") as f:
            f.write(str(os.getpid()))
    except Exception as e:
        print(f"Warning: Could not write PID file: {e}")


def remove_pid_file(pid_path: str) -> None:
    """Remove PID file on shutdown."""
    try:
        if os.path.exists(pid_path):
            os.unlink(pid_path)
    except Exception:
        pass


# =============================================================================
# Systemd Watchdog Support
# =============================================================================


def systemd_watchdog_thread(interval: float, notifier: Notifier) -> None:
    """Background thread to notify systemd that the service is alive."""
    if not SDNOTIFY_AVAILABLE:
        return

    try:
        sd = sdnotify.SystemdNotifier()
        print(
            f"[{time.strftime('%H:%M:%S')}] Systemd watchdog enabled (interval: {interval}s)"
        )

        while True:
            time.sleep(interval)
            try:
                sd.notify("WATCHDOG=1")
            except Exception as e:
                print(f"[{time.strftime('%H:%M:%S')}] Watchdog notify failed: {e}")
    except Exception as e:
        print(f"[{time.strftime('%H:%M:%S')}] Watchdog thread error: {e}")


# =============================================================================
# Main Entry Point
# =============================================================================


def parse_args():
    """Parse command line arguments."""
    import argparse

    parser = argparse.ArgumentParser(
        description="Whisper STT API Server",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "--config",
        "-c",
        type=str,
        default=None,
        help="Path to config file (default: ~/.config/whisper-api/config.yaml)",
    )
    parser.add_argument(
        "--port", "-p", type=int, default=None, help="Server port (overrides config)"
    )
    parser.add_argument(
        "--model", "-m", type=str, default=None, help="Model name (overrides config)"
    )
    parser.add_argument(
        "--device",
        "-d",
        type=str,
        default=None,
        help="Device: auto, cuda, cpu (overrides config)",
    )
    parser.add_argument(
        "--host", type=str, default=None, help="Host to bind to (overrides config)"
    )
    parser.add_argument(
        "--log-level",
        type=str,
        default="warning",
        choices=["debug", "info", "warning", "error"],
        help="Uvicorn log level",
    )

    return parser.parse_args()


def main():
    """Main entry point."""
    args = parse_args()

    # Load configuration
    config = load_config(args.config)

    # Override with CLI args
    if args.port:
        config.server.port = args.port
    if args.model:
        config.model.name = args.model
    if args.device:
        config.model.device = args.device
    if args.host:
        config.server.host = args.host

    # Create model manager
    model_manager = ModelManager(
        model_name=config.model.name,
        device=config.model.device,
        compute_type=config.model.compute_type,
        min_vram_mb=config.gpu.min_vram_mb,
        fallback_to_cpu=config.gpu.fallback_to_cpu,
    )

    # Create notifier
    notifier = Notifier(config.notification.enabled)

    # Send starting notification immediately
    if config.notification.enabled:
        notifier.notify_starting()

    # Pre-load model (eager loading)
    print("=" * 50)
    print("Whisper STT API Server")
    print("=" * 50)
    print(f"Host: {config.server.host}")
    print(f"Port: {config.server.port}")
    print(f"Model: {config.model.name}")
    print(f"Device: {config.model.device}")
    print(f"Compute: {config.model.compute_type}")
    print("=" * 50)

    # Load model (blocks until loaded)
    model_manager.load()

    # Send desktop notification if enabled - with retry for boot timing
    if config.notification.enabled and config.notification.on_ready:
        # Wait a moment for notification daemon to be ready on boot
        time.sleep(1)
        notifier.notify_ready(model_manager.device, config.server.port)

    # Create PID file
    pid_path = f"/run/user/{os.getuid()}/whisper-api-server.pid"
    try:
        os.makedirs(os.path.dirname(pid_path), exist_ok=True)
        create_pid_file(pid_path)
    except Exception:
        pid_path = "/tmp/whisper-api-server.pid"
        create_pid_file(pid_path)

    # Notify systemd we're ready
    if SDNOTIFY_AVAILABLE:
        try:
            sd = sdnotify.SystemdNotifier()
            sd.notify("READY=1")
        except Exception as e:
            print(f"Warning: Could not notify systemd: {e}")

    # Start watchdog thread
    if SDNOTIFY_AVAILABLE:
        import threading

        watchdog = threading.Thread(
            target=systemd_watchdog_thread, args=(30.0, notifier), daemon=True
        )
        watchdog.start()

    # Create and run FastAPI app
    app = create_app(model_manager, notifier, config)

    import uvicorn

    try:
        uvicorn.run(
            app,
            host=config.server.host,
            port=config.server.port,
            log_level=args.log_level,
        )
    finally:
        print(f"\n[{time.strftime('%H:%M:%S')}] Server shutting down...")

        # Unload model to free VRAM
        model_manager.unload()

        remove_pid_file(pid_path)

        if config.notification.enabled:
            notifier.notify_stopped()


if __name__ == "__main__":
    main()
