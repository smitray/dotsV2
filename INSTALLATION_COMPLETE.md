# Complete System Installation Guide - dotFileV2

## Overview

This guide walks through installing Arch Linux with the **dotFileV2 partition strategy**:
- **NVME 1**: System + Recovery + Temporary (with automatic backups)
- **NVME 2**: Permanent data storage (never touched during reinstalls)

## Installation Phases

### Phase 1: Pre-Installation Setup
**Location**: Boot Arch USB
**Time**: 5-10 minutes

```bash
# 1. Boot Arch USB in UEFI mode
# 2. Connect to internet
wifi-menu  # or use ethernet

# 3. Verify boot mode (should show EFI variables)
ls /sys/firmware/efi/efivars

# 4. Check partitions are detected
lsblk  # Should show nvme0n1 and nvme1n1

# 5. Update system clock
timedatectl set-ntp true
```

---

### Phase 2: Disk Partitioning & Mounting
**Location**: Boot Arch USB
**Script**: `install/setup_disks.sh`
**Time**: 15-30 minutes

This phase is **automated** by the setup script:

```bash
# Download/copy installation scripts
cd /home/debasmitr/workspace/dotFileV2

# Run disk setup (creates partitions, formats, mounts)
sudo bash install/setup_disks.sh

# This script will:
# ✓ Detect NVME 1 and NVME 2
# ✓ Create partition tables
# ✓ Create Btrfs subvolumes (@, @home, @workspace, @obsidian, @archive)
# ✓ Format all partitions
# ✓ Mount to /mnt with correct options
# ✓ Prompt for system configuration data
```

**What you'll be asked:**
1. Hostname (e.g., `asus-tuf-gaming`)
2. Root password
3. Username
4. User password
5. Timezone (e.g., `Asia/Kolkata`)
6. Locale (default: `en_US.UTF-8`)
7. Keyboard layout (default: `us`)

**Verification:**
```bash
# After script completes, verify:
lsblk                          # Check partition layout
mount | grep /mnt              # Check all mounts
df -h /mnt*                    # Check available space
```

---

### Phase 3: System Installation & Configuration
**Location**: Arch USB (chroot into /mnt)
**Script**: `install/PHASE_3_SETUP.sh`
**Time**: 20-40 minutes (depends on internet speed)

#### Step 1: Pacstrap (Install base system)
```bash
# Install base system and essential packages
pacstrap /mnt base linux linux-firmware \
    btrfs-progs efibootmgr git vim curl

# This installs:
# - Linux kernel
# - Filesystem tools (Btrfs)
# - Bootloader tools (EFI)
```

#### Step 2: Chroot into new system
```bash
# Copy Phase 3 setup script
cp install/PHASE_3_SETUP.sh /mnt/root/

# Copy supporting files
cp install/fstab-template /mnt/root/
cp install/system-backup.sh /mnt/root/

# Enter chroot
arch-chroot /mnt

# Run Phase 3 setup (INSIDE CHROOT)
bash /root/PHASE_3_SETUP.sh
```

**What Phase 3 Setup does:**
1. ✓ Installs and configures systemd-boot bootloader
2. ✓ Sets hostname, timezone, locale
3. ✓ Generates /etc/fstab with proper Btrfs options
4. ✓ Creates user account with sudo access
5. ✓ Sets root and user passwords
6. ✓ Creates 32GB swapfile for hibernation
7. ✓ Configures ZRAM (4GB compressed RAM)
8. ✓ Installs essential packages
9. ✓ Enables system services
10. ✓ Sets up automatic daily backups at 03:00 AM

#### Step 3: Exit chroot and reboot
```bash
# Exit chroot
exit

# Unmount all partitions
umount -R /mnt

# Remove USB
# (physically remove installation media)

# Reboot
reboot
```

---

### Phase 4: Post-Installation Setup (First Boot)
**Location**: Booted system
**Time**: 10-20 minutes

#### Login and initial setup
```bash
# Login with your username
username: your-username
password: your-password

# Update system
sudo pacman -Syu

# Verify disk layout
lsblk
df -h
free -h  # Check swap

# Verify backups are working (will start at 03:00 AM next day)
# Or manually trigger first backup:
sudo /usr/local/bin/system-backup.sh
```

#### Setup user directory symlinks
```bash
# Run symlink setup script (available in /root/)
sudo bash /root/setup-user-symlinks.sh

# This creates:
# TEMPORARY (auto-deletable):
#   ~/Downloads  → /temp-storage/Downloads
#   ~/Videos     → /temp-storage/Videos
#   ~/.cache     → /temp-storage/Cache
#
# PERMANENT (NVME 2):
#   ~/Documents  → /obsidian/Documents
#   ~/Pictures   → /archive/Pictures
#   ~/Music      → /archive/Music
#   ~/Projects   → /workspace/projects
```

---

## Partition Layout Reference

### NVME 1 (1TB) - System + Recovery + Temporary

| Device | Mount | Size | Purpose |
|--------|-------|------|---------|
| nvme0n1p1 | /boot | 2GB | EFI bootloader |
| nvme0n1p2 | / | 150GB | Root filesystem + OS |
| nvme0n1p3 | /backup | 200GB | **System backups & recovery** |
| nvme0n1p4 | /temp-storage | 648GB | Temporary files (auto-deletable) |

**Mount Options**: `rw,relatime,compress=zstd:1,space_cache=v2`

### NVME 2 (1TB) - Permanent Storage (NEVER FORMATTED)

| Device | Mount | Size | Purpose |
|--------|-------|------|---------|
| nvme1n1p1 | /home | 150GB | User configs |
| nvme1n1p2 | /workspace | 400GB | Development projects |
| nvme1n1p3 | /obsidian | 100GB | Obsidian vaults |
| nvme1n1p4 | /archive | 350GB | Permanent documents & media |

**Mount Options**: `rw,relatime,compress=zstd:1,space_cache=v2,subvol=@*`

---

## Backup Strategy

### What Gets Backed Up

**Location**: `/backup` partition (NVME 1 p3)

```
/backup/
├── snapshots/          ← Daily Btrfs snapshots of /
│   ├── system-20240115-030000/
│   ├── system-20240114-030000/
│   └── ... (keep 30 most recent)
│
├── images/             ← Weekly full system images
│   ├── system-img-20240114.gz
│   ├── system-img-20240107.gz
│   └── ... (keep 4 most recent)
│
├── packages/           ← Package list backups
│   ├── pkglist-20240115-030000.txt
│   ├── aurpkglist-20240115-030000.txt
│   └── ... (keep 10 most recent)
│
└── configs/            ← System configuration backups
    ├── configs-20240115-030000.tar.gz
    └── ... (all, no limit)
```

### What Does NOT Get Backed Up

- `/temp-storage` - Temporary files (auto-deletable)
- `/home`, `/workspace`, `/obsidian`, `/archive` - These are permanent and on a separate drive
- `/var/cache`, `~/.cache` - Application cache

### Backup Automation

**Schedule**: Daily at **03:00 AM** (configured by cron)

```bash
# View backup log
sudo tail -f /var/log/system-backup.log

# View snapshots
ls -lh /backup/snapshots/

# View system images
ls -lh /backup/images/

# Manual backup trigger
sudo /usr/local/bin/system-backup.sh
```

---

## Memory Configuration

### Swapfile (32GB)
- **Location**: `/swapfile` on root filesystem
- **Purpose**: Hibernation + memory overflow
- **Configuration**: NOCOW for Btrfs, chmod 600

```bash
# Check swap
swapon --show
free -h

# Create custom swapfile (if needed)
sudo bash /root/setup-swapfile.sh
```

### ZRAM (4GB Compressed RAM)
- **Purpose**: In-memory compression, faster than disk swap
- **Priority**: 100 (higher than disk swap)
- **Compression**: zstd (efficient)

```bash
# Monitor ZRAM
zramctl

# View swap with ZRAM
swapon --show
```

---

## System Recovery

See `RECOVERY_GUIDE.md` for:
- Quick snapshot restore (5-10 min)
- Full system image restore (15-30 min)
- Clean install while preserving NVME 2 data
- Bootloader troubleshooting

---

## File Structure After Installation

```
/
├── boot/                   ← /dev/nvme0n1p1 (FAT32)
├── /                       ← /dev/nvme0n1p2 (Btrfs, subvol=@)
├── backup/                 ← /dev/nvme0n1p3 (Btrfs) RECOVERY
├── temp-storage/           ← /dev/nvme0n1p4 (Btrfs) TEMPORARY
├── home/                   ← /dev/nvme1n1p1 (Btrfs, subvol=@home)
├── workspace/              ← /dev/nvme1n1p2 (Btrfs, subvol=@workspace)
├── obsidian/               ← /dev/nvme1n1p3 (Btrfs, subvol=@obsidian)
├── archive/                ← /dev/nvme1n1p4 (Btrfs, subvol=@archive)
├── swapfile                ← 32GB swap for hibernation
└── [other standard directories]
```

---

## User Directory Symlinks

After Phase 4 setup, user home directories are organized as:

```
~/
├── Downloads/    → /temp-storage/Downloads/      (temporary)
├── Videos/       → /temp-storage/Videos/         (temporary)
├── .cache/       → /temp-storage/Cache/.cache/   (temporary)
├── Documents/    → /obsidian/Documents/          (permanent)
├── Pictures/     → /archive/Pictures/            (permanent)
├── Music/        → /archive/Music/               (permanent)
├── Projects/     → /workspace/projects/          (permanent)
└── .local/share/ → /archive/AppData/             (permanent)
```

**Why?**
- **Temporary** (Downloads, cache) live on fast NVME 1, can be deleted
- **Permanent** (documents, photos, projects) live on NVME 2, never touched

---

## Troubleshooting

### "Partition table not recognized"
```bash
# Run partprobe to re-read partition table
sudo partprobe /dev/nvme0n1
sudo partprobe /dev/nvme1n1
```

### "Can't find /backup partition"
```bash
# Check if it's mounted
mount | grep backup

# Manually mount if missing
sudo mount /dev/nvme0n1p3 /backup -o rw,relatime,compress=zstd:1,space_cache=v2
```

### "Bootloader not found"
```bash
# Reinstall bootloader
sudo bootctl install
sudo bootctl status
```

### "ZRAM not working"
```bash
# Check kernel support
modprobe -n zram

# Manual ZRAM setup
sudo bash /root/setup-zram.sh
```

### "Cron backup not running"
```bash
# Check cron daemon
sudo systemctl status cronie

# Check cron job
sudo crontab -l

# Check logs
sudo tail -f /var/log/system-backup.log
```

---

## First Time Setup Checklist

- [ ] Phase 1: Boot Arch USB and verify hardware
- [ ] Phase 2: Run `setup_disks.sh` (partitions + config)
- [ ] Phase 2: Verify `lsblk` shows correct layout
- [ ] Phase 3: Run `pacstrap` to install base system
- [ ] Phase 3: Chroot and run `PHASE_3_SETUP.sh`
- [ ] Phase 3: Exit chroot and reboot
- [ ] Phase 4: Login and run initial setup
- [ ] Phase 4: Run `setup-user-symlinks.sh`
- [ ] Verify: `lsblk`, `df -h`, `free -h`, `mount | grep nvme`
- [ ] Test: First manual backup with `sudo /usr/local/bin/system-backup.sh`
- [ ] Check: Backup files at `/backup/snapshots/` and `/backup/images/`

---

## Quick Reference Commands

```bash
# Check system status
lsblk                          # Partition layout
df -h                          # Disk usage
free -h                        # Memory & swap
mount | grep -E "nvme|backup"  # Check mounts

# Backup management
ls -lh /backup/snapshots/      # View snapshots
ls -lh /backup/images/         # View images
sudo tail -f /var/log/system-backup.log  # View backup log

# System information
hostnamectl                    # Hostname & OS
timedatectl                    # Date & timezone
localectl                      # Locale & keyboard

# Filesystem health
sudo btrfs filesystem show     # Btrfs status
sudo btrfs device stats /      # Device statistics
sudo btrfs scrub start /       # Start filesystem check
```

---

## Installation Complete!

Your system is now configured with:
- ✓ Optimized disk layout with automatic recovery capability
- ✓ Daily system snapshots and weekly full backups
- ✓ 32GB swapfile for hibernation
- ✓ 4GB ZRAM for improved performance
- ✓ Proper Btrfs configuration with compression
- ✓ Organized user directories (temporary vs permanent)

**Next**: Install your dotfiles and applications using your dotFileV2 installation scripts.

See `RECOVERY_GUIDE.md` for recovery procedures.
