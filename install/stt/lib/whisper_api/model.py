"""
Whisper model management for local inference.
Handles model loading, caching, and transcription.
"""

import os
import time
from typing import Optional, Tuple

from faster_whisper import WhisperModel


class ModelManager:
    """
    Manages Whisper model lifecycle and transcription.

    Handles model loading, caching, GPU detection, and audio transcription
    with proper error handling and device fallback.
    """

    def __init__(
        self,
        model_name: str = "small",
        device: str = "auto",
        compute_type: str = "auto",
        min_vram_mb: int = 600,
        fallback_to_cpu: bool = True,
    ):
        self.model_name = model_name
        self.device = device
        self.compute_type = compute_type
        self.min_vram_mb = min_vram_mb
        self.fallback_to_cpu = fallback_to_cpu
        self.model: Optional[WhisperModel] = None
        self._loaded = False

    @property
    def is_loaded(self) -> bool:
        """Check if model is loaded."""
        return self._loaded and self.model is not None

    def _check_gpu_available(self) -> Tuple[bool, int]:
        """
        Check if NVIDIA GPU is available with sufficient VRAM.

        Returns:
            Tuple of (available, free_vram_mb)
        """
        if not os.path.exists("/proc/driver/nvidia"):
            return False, 0

        try:
            result = subprocess.run(
                [
                    "nvidia-smi",
                    "--query-gpu=memory.free",
                    "--format=csv,noheader,nounits",
                ],
                capture_output=True,
                text=True,
                timeout=5,
            )
            if result.returncode == 0:
                free_mem = int(result.stdout.strip().split("\n")[0])
                return free_mem >= self.min_vram_mb, free_mem
        except Exception:
            pass

        return False, 0

    def _detect_device(self) -> Tuple[str, str]:
        """
        Detect best available device for inference.

        Returns:
            Tuple of (device, compute_type)
        """
        if self.device != "auto":
            # User specified device
            compute = "float16" if self.device == "cuda" else "int8"
            return self.device, compute

        # Auto-detect
        gpu_available, free_vram = self._check_gpu_available()

        if gpu_available:
            print(
                f"[{time.strftime('%H:%M:%S')}] NVIDIA GPU detected, {free_vram}MB VRAM free"
            )
            return "cuda", "float16"

        if self.fallback_to_cpu:
            print(
                f"[{time.strftime('%H:%M:%S')}] No GPU available or insufficient VRAM, using CPU"
            )
            return "cpu", "int8"

        raise RuntimeError(
            f"GPU not available (need {self.min_vram_mb}MB, have {free_vram}MB) "
            "and CPU fallback is disabled"
        )

    def load(self) -> WhisperModel:
        """
        Load the Whisper model with GPU/CPU fallback.

        Returns:
            Loaded WhisperModel instance

        Raises:
            RuntimeError: If model loading fails
        """
        if self.model is not None:
            return self.model

        # Detect device
        self.device, self.compute_type = self._detect_device()

        print(
            f"[{time.strftime('%H:%M:%S')}] Loading model '{self.model_name}' "
            f"on {self.device} ({self.compute_type})..."
        )

        start_time = time.time()

        try:
            self.model = WhisperModel(
                self.model_name, device=self.device, compute_type=self.compute_type
            )
            elapsed = time.time() - start_time
            print(f"[{time.strftime('%H:%M:%S')}] Model loaded in {elapsed:.1f}s")
            self._loaded = True

        except RuntimeError as e:
            error_str = str(e).lower()
            if "cuda" in error_str and (
                "libcublas" in error_str or "cuda" in error_str
            ):
                print(f"[{time.strftime('%H:%M:%S')}] CUDA error: {e}")
                if self.fallback_to_cpu:
                    print(f"[{time.strftime('%H:%M:%S')}] Falling back to CPU...")
                    self.device = "cpu"
                    self.compute_type = "int8"
                    self.model = WhisperModel(
                        self.model_name,
                        device=self.device,
                        compute_type=self.compute_type,
                    )
                    elapsed = time.time() - start_time
                    print(
                        f"[{time.strftime('%H:%M:%S')}] Model loaded on CPU in {elapsed:.1f}s"
                    )
                    self._loaded = True
                else:
                    raise
            else:
                raise

        return self.model

    def unload(self) -> None:
        """Unload the model to free memory."""
        if self.model is not None:
            print(f"[{time.strftime('%H:%M:%S')}] Unloading model...")
            del self.model
            self.model = None
            self._loaded = False

            # Force garbage collection
            import gc

            gc.collect()

            print(f"[{time.strftime('%H:%M:%S')}] Model unloaded")

    def transcribe(self, audio_path: str, language: Optional[str] = None) -> str:
        """
        Transcribe audio file to text.

        Args:
            audio_path: Path to audio file
            language: Language code (None for auto-detect)

        Returns:
            Transcribed text
        """
        model = self.load()

        segments, info = model.transcribe(
            audio_path,
            language=language,
            condition_on_previous_text=False,
            vad_filter=False,
        )

        text = " ".join([segment.text for segment in segments]).strip()
        return text

    def get_info(self) -> dict:
        """Get model information."""
        return {
            "model": self.model_name,
            "device": self.device,
            "compute_type": self.compute_type,
            "loaded": self.is_loaded,
        }


# Import subprocess for GPU detection
import subprocess
