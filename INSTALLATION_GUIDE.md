# Arch Linux Installation Guide - Complete Checklist

## Required Information During Installation

### 1. **System Information** (REQUIRED - Interactive Prompts)
- [ ] **Hostname** - e.g., `asus-tuf-gaming`
- [ ] **Root Password** - For administrative tasks
- [ ] **Primary Username** - Your regular user account (e.g., `debasmitr`)
- [ ] **Primary User Password** - Login password for regular user
- [ ] **Timezone** - e.g., `Asia/Kolkata` (use `timedatectl list-timezones`)
- [ ] **Locale** - e.g., `en_US.UTF-8` (default recommended)
- [ ] **Keyboard Layout** - e.g., `us` (default recommended)

### 2. **System Configuration** (HARDCODED - No Input Needed)
- [x] **Disk Setup**: nvme0n1 & nvme1n1 partitioning (via `setup_disks.sh`)
- [x] **Bootloader**: GRUB with NVIDIA parameters (`nvidia_drm.modeset=1`)
- [x] **Btrfs Compression**: zstd:1 on all data partitions
- [x] **Swap**: 32GB swapfile with NOCOW attribute
- [x] **Network**: DHCP (automatic, no static IP)

---

## Installation Phases & Scripts

### **Phase 1: Boot & Partition (From Arch ISO)**
```bash
sudo ./install/setup_disks.sh
```
**Outputs**: Partitions created and mounted at `/mnt`

---

### **Phase 2: Base System Installation (From Arch ISO)**
```bash
pacstrap /mnt base linux linux-firmware
```
**Then enter chroot**:
```bash
arch-chroot /mnt
```

---

### **Phase 3: Post-Installation Configuration (Inside Chroot)**
```bash
./install/post_install_system.sh
```
**Handles** (interactively):
1. Locale & timezone setup
2. Hostname configuration
3. Root password setup
4. Create Btrfs subvolumes (@, @snapshots, @home, @workspace, @data, @persistent)
5. Create 32GB swapfile
6. Install & configure bootloader (GRUB) with NVIDIA parameters
7. Configure Btrfs mount options
8. Install essential packages

---

### **Phase 4: Post-Login Configuration (As Regular User)**
```bash
./install/setup_xdg_directories.sh    # Creates XDG symlinks
./install/setup_dev_workspace.sh      # Configures development environment
./install/configure_snapper.sh        # Sets up Btrfs snapshots
```

---

## Information Reference Sheet

### Timezone Examples
```
Asia/Kolkata          - India (IST)
Asia/Shanghai         - China (CST)
Europe/London         - UK (GMT/BST)
America/New_York      - USA East Coast
America/Los_Angeles   - USA West Coast
Australia/Sydney      - Australia
```

### Locale Examples
```
en_US.UTF-8          - English (USA)
en_GB.UTF-8          - English (UK)
de_DE.UTF-8          - German
fr_FR.UTF-8          - French
ja_JP.UTF-8          - Japanese
zh_CN.UTF-8          - Chinese (Simplified)
```

### Keyboard Layouts
```
us                    - English (USA)
gb                    - English (UK)
de                    - German
fr                    - French
jp                    - Japanese
```

---

## System Specifications Recap

| Component | Configuration |
|-----------|---------------|
| CPU | AMD Ryzen 7 4800H (8-core/16-thread) |
| GPU | NVIDIA RTX 3050 Mobile + AMD Radeon Vega |
| RAM | 16GB DDR4 + 4GB ZRAM |
| Storage | 2x 1TB NVMe (WD Black SN850X) |
| Display | 2560x1440 + 1920x1080 (Wayland/Hyprland) |
| Network | DHCP (Realtek RTL8111 + MediaTek MT7921) |

---

## Disk Layout Summary

```
DISK1: /dev/nvme0n1 (1TB)
├─ nvme0n1p1 (2GB)   - /boot (FAT32)
├─ nvme0n1p2 (500GB) - / (Btrfs)
└─ nvme0n1p3 (498GB) - /persistent (Btrfs)

DISK2: /dev/nvme1n1 (1TB)
├─ nvme1n1p1 (150GB) - /home (Btrfs)
├─ nvme1n1p2 (400GB) - /workspace (Btrfs)
└─ nvme1n1p3 (450GB) - /data (Btrfs)
```

---

## Pre-Installation Checklist

- [ ] Arch ISO prepared and booted
- [ ] Internet connectivity verified
- [ ] Both NVMe drives detected (`lsblk`)
- [ ] Backup important data if upgrading from existing system
- [ ] Read through all phases before starting
- [ ] Have hostname ready (e.g., `asus-tuf-gaming`)
- [ ] Have timezone ready (e.g., `Asia/Kolkata`)
- [ ] Have username ready (e.g., `debasmitr`)
- [ ] Have strong password prepared

---

## What's Currently Missing (To Be Created)

1. [ ] **post_install_system.sh** - Main post-install configuration script
   - Locale & timezone
   - Hostname & users
   - Btrfs subvolumes & swapfile
   - Bootloader setup
   - Essential packages

2. [ ] **setup_xdg_directories.sh** - XDG symlink setup
   - Creates ~/.config → /home/username/.config
   - Creates ~/Desktop → /persistent/Desktop
   - And other XDG directories

3. [ ] **configure_snapper.sh** - Btrfs snapshot management
   - Snapper installation & config
   - Snapshot policies
   - Recovery configuration

4. [ ] **setup_dev_workspace.sh** - Development environment
   - mise installation (Node/Python/Bun)
   - Workspace directory structure
   - Git configuration
   - IDE/editor setup

---

## Notes

- All scripts are **idempotent** - can be re-run safely
- Interactive prompts will guide you through each phase
- Estimated installation time: **30-45 minutes** total
- After Phase 3, you'll have a working Arch Linux system
- Phases 4 are for development workspace setup
