# dotFileV2

A production-ready Arch Linux configuration and installation repository, optimized for dual-NVMe setups and rootless Podman AI/Service workloads.

## 🚀 Quick Start

If you are setting up a new system:

1.  **Hardware Specs**: Check [SYSTEM_SPECS.md](file:///home/debasmitr/workspace/dotFileV2/SYSTEM_SPECS.md) to ensure compatibility.
2.  **Installation Spec**: Read the [ARCH_INSTALL_FINAL_SPEC.md](file:///home/debasmitr/workspace/dotFileV2/ARCH_INSTALL_FINAL_SPEC.md) for the master storage architecture and partition table.
3.  **Automated Setup**:
    - Boot Arch ISO.
    - Run `bash install/setup_disks.sh`.
    - Follow the install process in the spec doc.

## 🛠 Features

- **Disposable vs Permanent Storage**: NVMe 0 for the OS and cache; NVMe 1 for home data, workspace, and services.
- **Rootless Podman**: Secure container management for Ollama, PostgreSQL, n8n, etc., with persistent data stored in `/srv`.
- **Btrfs Optimized**: Best practices implemented, including 10% reserved disk headroom and zstd compression.
- **AI Agent Friendly**: Integrated skills for AI assistants located in `.agents/skills/`.

## 🤖 AI Agents & Skills

This repository is designed to be managed and extended using AI agents. See [AGENTS.md](file:///home/debasmitr/workspace/dotFileV2/AGENTS.md) for a guide on available skills like `git-commit`, `bash-pro`, and `context7`.

## 📁 Repository Structure

```
.
├── ARCH_INSTALL_FINAL_SPEC.md  # Master configuration & install guide
├── SYSTEM_SPECS.md             # Hardware information
├── AGENTS.md                  # AI skills & agent instructions
├── README.md                  # You are here
├── install/                   # Scripts for system setup
└── .agents/                   # AI configuration & skill metadata
```
