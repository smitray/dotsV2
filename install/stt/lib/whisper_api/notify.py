"""
Desktop notification helper for Whisper API server.
"""

import subprocess
import os
from typing import Optional


class Notifier:
    """Desktop notification handler."""

    def __init__(self, enabled: bool = True):
        self.enabled = enabled and self._check_notify_available()
        self.app_name = "whisper-api"

    def _check_notify_available(self) -> bool:
        """Check if notify-send is available."""
        try:
            subprocess.run(["which", "notify-send"], capture_output=True, check=False)
            return True
        except Exception:
            return False

    def send(
        self,
        message: str,
        urgency: str = "normal",
        icon: str = "audio-input-microphone",
        title: Optional[str] = None,
    ) -> bool:
        """
        Send a desktop notification.

        Args:
            message: The notification message
            urgency: urgency level (low, normal, critical)
            icon: Icon name or path
            title: Optional title (defaults to app name)

        Returns:
            True if notification was sent, False otherwise
        """
        if not self.enabled:
            return False

        title = title or self.app_name

        try:
            result = subprocess.run(
                [
                    "notify-send",
                    "-u",
                    urgency,
                    "-i",
                    icon,
                    "-a",
                    self.app_name,
                    title,
                    message,
                ],
                capture_output=True,
                check=False,
            )
            return result.returncode == 0
        except Exception:
            return False

    def notify_ready(self, device: str, port: int) -> bool:
        """Send ready notification."""
        return self.send(
            f"🎤 STT Ready! ({device})", urgency="normal", title="Whisper API"
        )

    def notify_starting(self) -> bool:
        """Send starting notification."""
        return self.send(
            "Starting Whisper server...", urgency="low", title="Whisper API"
        )

    def notify_error(self, message: str) -> bool:
        """Send error notification."""
        return self.send(
            message, urgency="critical", icon="dialog-error", title="Whisper API Error"
        )

    def notify_stopped(self) -> bool:
        """Send stopped notification."""
        return self.send(
            "Server stopped - VRAM freed", urgency="low", title="Whisper API"
        )
