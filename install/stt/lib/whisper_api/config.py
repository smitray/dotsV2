"""
Configuration management for Whisper API server.
Supports YAML configuration files with environment variable fallback.
"""

import os
import yaml
from pathlib import Path
from typing import Optional, Any
from dataclasses import dataclass, field


@dataclass
class ServerConfig:
    """Server configuration."""

    host: str = "127.0.0.1"
    port: int = 7861


@dataclass
class ModelConfig:
    """Model configuration."""

    name: str = "small"
    device: str = "auto"
    compute_type: str = "auto"


@dataclass
class GPUConfig:
    """GPU configuration."""

    min_vram_mb: int = 600
    fallback_to_cpu: bool = True


@dataclass
class NotificationConfig:
    """Notification configuration."""

    enabled: bool = True
    on_ready: bool = True


@dataclass
class LoggingConfig:
    """Logging configuration."""

    level: str = "INFO"
    file: Optional[str] = None


@dataclass
class Config:
    """Main configuration container."""

    server: ServerConfig = field(default_factory=ServerConfig)
    model: ModelConfig = field(default_factory=ModelConfig)
    gpu: GPUConfig = field(default_factory=GPUConfig)
    notification: NotificationConfig = field(default_factory=NotificationConfig)
    logging: LoggingConfig = field(default_factory=LoggingConfig)


def get_default_config_dir() -> Path:
    """Get the default configuration directory."""
    xdg_config = os.environ.get("XDG_CONFIG_HOME", os.path.expanduser("~/.config"))
    return Path(xdg_config) / "whisper-api"


def get_config_path() -> Path:
    """Get the configuration file path."""
    return get_default_config_dir() / "config.yaml"


def load_config(config_path: Optional[str] = None) -> Config:
    """
    Load configuration from YAML file with environment variable fallbacks.

    Args:
        config_path: Optional path to config file. If None, uses default location.

    Returns:
        Config object with loaded settings.
    """
    config = Config()

    # Determine config file path
    if config_path:
        config_file = Path(config_path)
    else:
        config_file = get_config_path()

    # Load from YAML if exists
    if config_file.exists():
        try:
            with open(config_file, "r") as f:
                data = yaml.safe_load(f)

            if data:
                # Server config
                if "server" in data:
                    for key, value in data["server"].items():
                        if hasattr(config.server, key):
                            setattr(config.server, key, value)

                # Model config
                if "model" in data:
                    for key, value in data["model"].items():
                        if hasattr(config.model, key):
                            setattr(config.model, key, value)

                # GPU config
                if "gpu" in data:
                    for key, value in data["gpu"].items():
                        if hasattr(config.gpu, key):
                            setattr(config.gpu, key, value)

                # Notification config
                if "notification" in data:
                    for key, value in data["notification"].items():
                        if hasattr(config.notification, key):
                            setattr(config.notification, key, value)

                # Logging config
                if "logging" in data:
                    for key, value in data["logging"].items():
                        if hasattr(config.logging, key):
                            setattr(config.logging, key, value)
        except Exception as e:
            print(f"Warning: Failed to load config from {config_file}: {e}")
            print("Using default configuration")

    # Override with environment variables
    env_port = os.environ.get("WHISPER_PORT")
    if env_port:
        config.server.port = int(env_port)

    env_model = os.environ.get("WHISPER_MODEL")
    if env_model:
        config.model.name = env_model

    env_device = os.environ.get("WHISPER_DEVICE")
    if env_device:
        config.model.device = env_device

    env_host = os.environ.get("WHISPER_HOST")
    if env_host:
        config.server.host = env_host

    return config


def get_config() -> Config:
    """Get the global configuration (convenience function)."""
    return load_config()
