# 🚀 START HERE - Initial Installation Script Guide

## Overview

Your dotFileV2 installation system is complete and production-ready. This guide walks you through running the initial installation script (`setup_disks.sh`).

---

## Pre-Installation Checklist

Before running the setup script, verify:

- [ ] You have **Arch Linux USB live environment** ready
- [ ] You have **2 × 1TB NVMe drives** (nvme0n1 and nvme1n1)
- [ ] You have **internet connection** during installation
- [ ] You have **backed up any existing data** on those drives
- [ ] You understand the **partition layout** (see PARTITION_SPEC_PRODUCTION_FINAL.md)
- [ ] You have noted your **system requirements**:
  - Hostname (e.g., asus-tuf-gaming)
  - Root password
  - Username
  - User password
  - Timezone (e.g., Asia/Kolkata)
  - Locale (optional, defaults to en_US.UTF-8)
  - Keyboard layout (optional, defaults to us)

---

## Installation Phases

### Phase 1: Boot & Prepare (Pre-Script)
**Environment**: Arch Linux USB live boot

```bash
# 1. Boot Arch USB in UEFI mode
# 2. Wait for Arch prompt
# 3. Connect to internet
wifi-menu           # Or use ethernet

# 4. Verify boot mode
ls /sys/firmware/efi/efivars

# 5. Check drive detection
lsblk
# Should show: nvme0n1 (1TB) and nvme1n1 (1TB)

# 6. Verify internet
ping -c 2 8.8.8.8
```

---

### Phase 2: Run Disk Setup Script (setup_disks.sh)
**This script will:**
- Detect both NVME drives
- Create partition tables (GPT)
- Create all 9 partitions with production-optimized sizes
- Create Btrfs subvolumes
- Format all partitions
- Mount partitions to `/mnt`
- Collect your system configuration

#### Step 1: Get the Script

```bash
# Navigate to dotFileV2
cd /home/debasmitr/workspace/dotFileV2
# OR if cloning:
git clone https://github.com/yourusername/dotFileV2.git
cd dotFileV2
```

#### Step 2: Run the Script

```bash
# Make sure script is executable
chmod +x install/setup_disks.sh

# Run as root
sudo bash install/setup_disks.sh
```

#### Step 3: Follow Interactive Prompts

The script will ask for:

```
1. Hostname: asus-tuf-gaming
2. Root Password: [enter secure password]
3. Confirm Root Password: [re-enter]
4. Username: debasmitr
5. User Password: [enter secure password]
6. Confirm User Password: [re-enter]
7. Timezone: Asia/Kolkata
8. Locale (optional): en_US.UTF-8 [press Enter for default]
9. Keyboard (optional): us [press Enter for default]
```

#### Step 4: Review & Confirm

```
The script will display:
  ✓ Disk detection
  ✓ Partition layout
  ✓ Configuration summary
  ✓ Mount structure

Review and confirm: YES to proceed
```

#### Step 5: Wait for Completion

```
The script will:
  ✓ Create partition table
  ✓ Create 9 partitions (5 on NVME1 + 4 on NVME2)
  ✓ Format partitions
  ✓ Create Btrfs subvolumes
  ✓ Mount to /mnt
  ✓ Save configuration

Expected time: 5-10 minutes
```

---

### What Phase 2 Creates

#### NVME1 Partitions (900GB allocated + 100GB free):
```
nvme0n1p1 → /boot        (2GB,   FAT32)
nvme0n1p2 → /            (140GB, Btrfs)
nvme0n1p3 → /backup      (180GB, Btrfs)
nvme0n1p4 → /var/lib/docker (330GB, Btrfs)
nvme0n1p5 → /downloads   (248GB, Btrfs)
[Free]                    (100GB)
```

#### NVME2 Partitions (900GB allocated + 100GB free):
```
nvme1n1p1 → /home        (140GB, Btrfs)
nvme1n1p2 → /workspace   (380GB, Btrfs)
nvme1n1p3 → /obsidian    (100GB, Btrfs)
nvme1n1p4 → /docker-data (280GB, Btrfs)
[Free]                    (100GB)
```

---

### Phase 3: System Installation (After Phase 2)
**Environment**: Still Arch USB, now with mounted /mnt

#### Step 1: Install Base System

```bash
# Install base system
pacstrap /mnt base linux linux-firmware \
  btrfs-progs efibootmgr git vim curl

# Expected: 5-15 minutes depending on internet speed
```

#### Step 2: Enter Chroot

```bash
# Copy Phase 3 setup script
sudo cp install/PHASE_3_SETUP.sh /mnt/root/
sudo cp install/fstab-template /mnt/root/
sudo cp install/system-backup.sh /mnt/root/

# Enter chroot
sudo arch-chroot /mnt

# Inside chroot, run Phase 3 setup
bash /root/PHASE_3_SETUP.sh
```

#### Step 3: Exit & Reboot

```bash
# Exit chroot
exit

# Unmount all partitions
sudo umount -R /mnt

# Remove USB and reboot
sudo reboot
```

---

### Phase 4: First Boot Setup
**Environment**: Your newly installed Arch Linux system

```bash
# Login with your username and password

# Update system
sudo pacman -Syu

# Setup Docker
sudo bash /root/setup-docker.sh

# Setup Mise (runtime manager)
bash /root/setup-mise.sh

# Setup user symlinks
sudo bash /root/setup-user-symlinks.sh

# Verify everything
lsblk                    # Check partitions
df -h                    # Check disk usage
free -h                  # Check memory + swap
```

---

## Understanding the Script Flow

```
User runs: sudo bash install/setup_disks.sh
                    ↓
    [Script validates hardware]
                    ↓
    [Displays disk information]
                    ↓
    [Check for existing partitions]
                    ↓
    [If exists: ask about smart mode]
    [If new: proceed with creation]
                    ↓
    [Create partition tables]
                    ↓
    [Create 9 partitions]
                    ↓
    [Format with Btrfs]
                    ↓
    [Create Btrfs subvolumes]
                    ↓
    [Mount to /mnt]
                    ↓
    [Collect system config]
                    ↓
    [Save to /mnt/etc/installation.conf]
                    ↓
    Ready for: pacstrap /mnt ...
```

---

## Important Features

### Smart Mode (Automatic)
If partitions already exist:
- Preserves `/backup` (recovery data)
- Preserves all NVME2 data (permanent storage)
- Recreates only `/boot`, `/`, `/var/lib/docker`, `/downloads`
- Maintains 100GB free space

### Configuration Auto-Save
All your inputs are saved to:
```
/mnt/etc/installation.conf
```

Used by Phase 3 setup for:
- Hostname configuration
- User account creation
- Timezone & locale setup
- Password setting

### Verification Built-In

The script will display:
```
✓ Disk detection
✓ Partition layout
✓ Mount structure
✓ Btrfs subvolume status
✓ Free space information
```

---

## Troubleshooting

### "Disk not found"
```bash
# Verify drives
lsblk

# Update device names in setup_disks.sh if needed:
# - Edit: DISK1="/dev/nvme0n1"
# - Edit: DISK2="/dev/nvme1n1"
```

### "Cannot detect as root"
```bash
# Use full sudo
sudo bash install/setup_disks.sh
```

### "Partition table error"
```bash
# If existing partitions cause issues
sudo parted /dev/nvme0n1 -- mklabel gpt
sudo parted /dev/nvme1n1 -- mklabel gpt

# Then re-run script
sudo bash install/setup_disks.sh
```

### "Btrfs mount failed"
```bash
# Check if partitions are formatted
sudo btrfs filesystem show

# If empty, format manually:
sudo mkfs.btrfs -f -L "ARCH_ROOT" /dev/nvme0n1p2
```

---

## Quick Commands Reference

### During Phase 2 (After script runs):
```bash
# Verify mounts
mount | grep /mnt

# Check partition layout
lsblk

# Check free space
df -h /mnt*

# View Btrfs status
sudo btrfs filesystem show
```

### During Phase 3 (In chroot):
```bash
# Inside chroot after arch-chroot /mnt
bash /root/PHASE_3_SETUP.sh
# Follow prompts automatically
```

### After Phase 4 (In new system):
```bash
# Verify complete setup
lsblk                              # Partitions
df -h                              # Disk usage
free -h                            # Memory + swap
sudo btrfs filesystem usage /      # Btrfs details
```

---

## Complete Installation Timeline

| Phase | Step | Time | Environment |
|-------|------|------|-------------|
| **1** | Boot USB | - | Arch USB |
| **1** | Connect internet | - | Arch USB |
| **2** | Run setup_disks.sh | 5-10 min | Arch USB |
| **2** | Enter responses | 2-5 min | Arch USB |
| **2** | Format & mount | 2-5 min | Arch USB |
| **3** | Pacstrap | 5-15 min | Arch USB |
| **3** | Run PHASE_3_SETUP.sh | 10-20 min | Chroot |
| **3** | Reboot | - | Arch USB |
| **4** | First login | - | New system |
| **4** | System update | 5-10 min | New system |
| **4** | Setup Docker/Mise | 10-15 min | New system |
| | **TOTAL** | **~60-90 min** | |

---

## Next Steps After Installation

1. **Verify System Health**
   ```bash
   sudo btrfs filesystem usage /
   sudo btrfs device stats /
   ```

2. **Create First Backup**
   ```bash
   sudo /usr/local/bin/system-backup.sh
   ```

3. **Deploy Dotfiles**
   ```bash
   cd /workspace/projects
   git clone your-dotfiles-repo
   ```

4. **Install Development Tools**
   ```bash
   # Using Mise (already installed)
   mise install node@20
   mise install python@3.12
   ```

5. **Test Docker**
   ```bash
   docker run hello-world
   ```

---

## Support Documentation

- **Partition Details**: See `PARTITION_SPEC_PRODUCTION_FINAL.md`
- **Complete Guide**: See `INSTALLATION_COMPLETE.md`
- **Mount Points**: See `MOUNTING_POINTS_COMPLETE.md`
- **Recovery Info**: See `RECOVERY_GUIDE.md`
- **Script Details**: See `SCRIPTS_SUMMARY.md`

---

## Key Points to Remember

✅ **Run as root**: `sudo bash install/setup_disks.sh`
✅ **Have your info ready**: Hostname, passwords, timezone
✅ **Both drives detected**: Should show nvme0n1 and nvme1n1
✅ **Internet connected**: Needed for pacstrap
✅ **Review prompts**: Confirm configuration before proceeding
✅ **Keep terminal open**: Don't close until reboot
✅ **Be patient**: Installation takes 60-90 minutes total

---

## Ready to Start?

### If you're on Arch USB:
```bash
# Navigate to dotFileV2 repo
cd /path/to/dotFileV2

# Make script executable
chmod +x install/setup_disks.sh

# Run the initial setup
sudo bash install/setup_disks.sh
```

### If you're preparing from Linux:
```bash
# Ensure you have access to dotFileV2
git clone https://github.com/yourusername/dotFileV2.git
cd dotFileV2

# Review this guide once more
cat INSTALLATION_START_HERE.md

# Create USB (when ready):
sudo dd if=arch.iso of=/dev/sdX bs=4M status=progress
sync
```

---

**Your production-optimized installation system is ready. Good luck! 🚀**
