# Partition Table Specification

This document defines the finalized dual-NVMe storage architecture for the Arch Linux workstation.

## 🧠 Philosophy: Disposable vs. Permanent
- **NVMe 0 (System Disk)**: Contains the OS, core runtimes, and disposable cache. It can be wiped and reinstalled without data loss.
- **NVMe 1 (Data Disk)**: Contains permanent user data, development projects, and persistent service databases.

---

## 💾 Drive 1: `/dev/nvme0n1` (System)
**Focus**: Performance, Snapshots, and Temporary Storage.

| Partition | Mount Point | Size | Filesystem | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **p1** | `/boot` | 2 GB | FAT32 | UEFI Bootloader (systemd-boot) |
| **p2** | `[swap]` | 32 GB | Swap | Hibernation support (RAM $\leq$ 32GB) |
| **p3** | `/` | 140 GB | Btrfs | Arch OS + System Packages |
| **p4** | `/backup` | 180 GB | Btrfs | Timeshift / System Snapshots |
| **p5** | `/downloads` | 546 GB | Btrfs | ISOs, Media Cache, Temp Files |
| **-** | `Unallocated` | **100 GB** | - | **Btrfs Headroom (10%)** |

---

## 📂 Drive 2: `/dev/nvme1n1` (Data)
**Focus**: Persistent Services and User Workspace.

| Partition | Mount Point | Size | Filesystem | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **p1** | `/home` | 80 GB | Btrfs | Configs, Dotfiles, Mise Runtimes |
| **p2** | `/workspace` | 300 GB | Btrfs | Development Projects |
| **p3** | `/obsidian` | 80 GB | Btrfs | Notes Vault & Knowledge Base |
| **p4** | `/srv` | 440 GB | Btrfs | **Podman Storage & Databases** |
| **-** | `Unallocated` | **100 GB** | - | **Btrfs Headroom (10%)** |

---

## 🛠 Mounting Details
All Btrfs partitions are mounted with the following optimized options:
- `compress=zstd:1` for a balance of speed and storage.
- `relatime,space_cache=v2` for performance.
- `/srv` is configured as the `graphroot` for rootless Podman.

---

## 🚀 Impact on Workflow
1.  **Mise Runtimes**: Stored in `/home/.local/share/mise/` (NVMe 2), making them persistent across OS wipes.
2.  **Services**: All container data (PostgreSQL, MongoDB, Ollama models) resides in `/srv/` (NVMe 2).
3.  **OS Wipe**: You can format NVMe 0 (p3) at any time to get a fresh Arch install; just remount NVMe 2 to restore your entire work environment instantly.
