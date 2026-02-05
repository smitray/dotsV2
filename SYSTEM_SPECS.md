# System Specifications

**Source**: `inxi -Fxz` provided by user.

## Hardware
- **Model**: ASUS TUF Gaming A15 (FA506IC)
- **CPU**: AMD Ryzen 7 4800H (8-core/16-thread, Zen 2)
- **GPU 1**: NVIDIA GeForce RTX 3050 Mobile (Ampere)
  - *Driver*: nvidia v: 580.82.09
- **GPU 2**: AMD Radeon Vega (Renoir)
  - *Driver*: amdgpu
- **RAM**: 16 GB Total
- **Storage**: 2x 1TB WD BLACK SN850X NVMe
  - *Note*: Current map shows `/dev/dm-0` (LVM/Luks?) and `/dev/nvme1n1p1` for boot.

## Software Environment
- **OS**: Arch Linux
- **Kernel**: 6.16.8-arch3-1
- **Desktop**: Hyprland v0.51.1
- **Shell**: Bash 5.3.3
- **Audio**: PipeWire 1.4.8

## AI Capability Analysis (Local)
- **VRAM**: RTX 3050 Mobile usually has **4GB VRAM**.
- **System RAM**: 16GB.
- **Inference Constraints**:
  - cannot run large models (8B+) entirely on GPU.
  - **Recommended Models**:
    - Qwen-2.5-Coder-1.5B / 3B (Fast, fits in VRAM)
    - Llama-3.1-8B (Quantized Q4_K_M) -> Requires CPU offloading (approx 6-8GB RAM total), slower generation.
    - Phi-3-Mini (3.8B) -> Fits comfortably.

## Current Partition Layout
User currently has:
- `/` (Root): Btrfs
- `/home`: Btrfs
- `/var/log`: Btrfs
- SWAP: 4GB ZRAM
