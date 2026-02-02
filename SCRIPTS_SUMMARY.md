# Installation Scripts Summary

## Overview

All installation scripts have been created and configured to support the **dotFileV2 partition strategy** with automated backups, recovery capability, and optimized memory management.

---

## Installation Scripts Inventory

### Core Installation Scripts

#### 1. **setup_disks.sh** (Phase 2)
- **Purpose**: Partition, format, and mount all disks
- **Location**: `install/setup_disks.sh`
- **Run as**: `sudo`
- **Environment**: Arch USB live environment
- **Time**: 15-30 minutes

**What it does:**
```bash
✓ Detects NVME 1 and NVME 2 drives
✓ Creates GPT partition tables
✓ Creates 4+4 partitions with correct sizes
✓ Creates Btrfs subvolumes (@, @home, @workspace, @obsidian, @archive)
✓ Formats all partitions (FAT32 for /boot, Btrfs for others)
✓ Mounts partitions to /mnt with optimized options:
  - compress=zstd:1 (compression)
  - space_cache=v2 (improved performance)
  - subvol=@* (Btrfs subvolume references)
✓ Collects system configuration (hostname, passwords, timezone, etc.)
✓ Saves configuration for Phase 3 (stored in /mnt/etc/installation.conf)
```

**Mount options applied:**
```
Boot:   defaults,noatime,nofail
Root:   rw,relatime,compress=zstd:1,space_cache=v2,subvol=@
Backup: rw,relatime,compress=zstd:1,space_cache=v2
Temp:   rw,relatime,compress=zstd:1,space_cache=v2
Home:   rw,relatime,compress=zstd:1,space_cache=v2,subvol=@home
etc...
```

**How to run:**
```bash
sudo bash install/setup_disks.sh
# Answer prompts for system configuration
# Verify with: lsblk and df -h
```

---

#### 2. **PHASE_3_SETUP.sh** (Phase 3)
- **Purpose**: Complete post-pacstrap system configuration
- **Location**: `install/PHASE_3_SETUP.sh`
- **Run as**: `root` (inside chroot)
- **Environment**: Inside arch-chroot /mnt
- **Time**: 20-40 minutes (includes pacstrap + installation)

**What it does:**
```bash
Step 1:  Install systemd-boot bootloader
Step 2:  Configure system settings (hostname, timezone, locale, keyboard)
Step 3:  Setup /etc/fstab with Btrfs options
Step 4:  Create user account with sudo access
Step 5:  Set root and user passwords
Step 6:  Create 32GB swapfile (for hibernation)
Step 7:  Setup ZRAM (4GB compressed RAM)
Step 8:  Configure pacman (parallel downloads, ILoveCandy)
Step 9:  Install essential packages
Step 10: Enable system services
Step 11: Setup backup automation (cron job, log rotation)
```

**How to run:**
```bash
# From Arch USB after pacstrap:
arch-chroot /mnt
bash /root/PHASE_3_SETUP.sh
exit
```

---

### Memory & Swap Scripts

#### 3. **setup-swapfile.sh**
- **Purpose**: Create and configure 32GB swapfile for hibernation
- **Location**: `install/setup-swapfile.sh`
- **Run as**: `sudo`
- **Environment**: After Phase 3 (optional, auto-run in PHASE_3_SETUP)
- **Time**: 5 minutes

**Features:**
```bash
✓ Creates 32GB swapfile at /swapfile
✓ Sets NOCOW attribute (Btrfs optimization)
✓ Sets secure permissions (600 = root only)
✓ Formats and enables swap
✓ Configures swappiness=10 (prefer RAM)
✓ Enables hibernation capability
```

**Manual run:**
```bash
sudo bash install/setup-swapfile.sh
```

---

#### 4. **setup-zram.sh**
- **Purpose**: Setup ZRAM for 4GB in-memory compression
- **Location**: `install/setup-zram.sh`
- **Run as**: `sudo`
- **Environment**: After Phase 3 (optional, auto-run in PHASE_3_SETUP)
- **Time**: 2 minutes

**Features:**
```bash
✓ Checks kernel support for ZRAM
✓ Configures zram-generator (preferred method)
✓ Falls back to manual setup if generator unavailable
✓ Compression algorithm: zstd (fast + efficient)
✓ Swap priority: 100 (higher than disk swap)
✓ Size: min(RAM, 4G)
```

**Manual run:**
```bash
sudo bash install/setup-zram.sh
```

---

### Backup & Recovery Scripts

#### 5. **system-backup.sh**
- **Purpose**: Create and maintain system backups
- **Location**: `install/system-backup.sh`
- **Run as**: `root` (via cron or manual)
- **Schedule**: Daily at 03:00 AM (configurable)
- **Time**: 10-20 minutes per run

**What it backs up:**
```bash
1. Daily Btrfs snapshots of /
   Location: /backup/snapshots/system-YYYYMMDD-HHMMSS/
   Retention: 30 most recent

2. Weekly full system images (Sundays)
   Location: /backup/images/system-img-YYYYMMDD.gz
   Compression: gzip
   Retention: 4 most recent (~30GB each)

3. Package lists (after pacman updates)
   Location: /backup/packages/pkglist-YYYYMMDD.txt
   Contents: pacman -Qqe and pacman -Qqm
   Retention: 10 most recent

4. System configuration backups
   Location: /backup/configs/configs-YYYYMMDD.tar.gz
   Contents: fstab, hostname, locale, pacman.conf, bootloader, etc.
   Retention: All (archive)
```

**What it excludes (intentionally):**
```bash
✗ /temp-storage (temporary files, auto-deletable)
✗ /home, /workspace, /obsidian, /archive (permanent storage on NVME2)
✗ /var/cache, ~/.cache (application cache)
```

**Manual run:**
```bash
sudo /usr/local/bin/system-backup.sh
```

**View backups:**
```bash
ls -lh /backup/snapshots/          # Daily snapshots
ls -lh /backup/images/             # Weekly images
tail -f /var/log/system-backup.log # Backup log
```

---

#### 6. **setup-backup-cron.sh**
- **Purpose**: Install backup automation (cron job + logging)
- **Location**: `install/setup-backup-cron.sh`
- **Run as**: `sudo`
- **Environment**: After Phase 3 (auto-run in PHASE_3_SETUP)
- **Time**: 2 minutes

**What it does:**
```bash
✓ Copies system-backup.sh to /usr/local/bin/
✓ Creates cron job (daily at 03:00 AM)
✓ Sets up log rotation (/etc/logrotate.d/system-backup)
✓ Creates backup directory structure
✓ Optional: Runs test backup
```

**Cron job:**
```bash
0 3 * * * /usr/local/bin/system-backup.sh >> /var/log/system-backup.log 2>&1
```

---

### User Configuration Scripts

#### 7. **setup-user-symlinks.sh**
- **Purpose**: Organize user home directories with symlinks
- **Location**: `install/setup-user-symlinks.sh`
- **Run as**: `sudo` (for specific user)
- **Environment**: After Phase 4 (first boot)
- **Time**: 1 minute

**What it does:**
```bash
TEMPORARY (disposable, can be deleted):
  ~/Downloads    → /temp-storage/Downloads
  ~/Videos       → /temp-storage/Videos
  ~/.cache       → /temp-storage/Cache

PERMANENT (never deleted, on NVME2):
  ~/Documents    → /obsidian/Documents
  ~/Pictures     → /archive/Pictures
  ~/Music        → /archive/Music
  ~/Projects     → /workspace/projects
  ~/.local/share → /archive/AppData
```

**Run for user:**
```bash
sudo bash install/setup-user-symlinks.sh /home/username
```

---

#### 8. **fstab-template**
- **Purpose**: Reference /etc/fstab configuration
- **Location**: `install/fstab-template`
- **Used by**: PHASE_3_SETUP.sh
- **Type**: Configuration file (not executable)

**Contains:**
```bash
✓ Proper Btrfs mount options (space_cache=v2, compress=zstd:1)
✓ All 8 partitions with correct mount points
✓ Swapfile configuration
✓ tmpfs for /tmp, /var/tmp, /run
✓ EFI vars mounting
✓ Proper permissions and mount flags
```

---

## Execution Order

### First Time Installation

```
Phase 1 (USB Boot)
  └─ Boot Arch USB, verify hardware
  
Phase 2 (Disk Setup)
  └─ bash install/setup_disks.sh
     ├─ Detects disks
     ├─ Creates partitions & subvolumes
     ├─ Formats partitions
     ├─ Mounts to /mnt
     └─ Collects system config

Phase 3 (Pacstrap + Configuration)
  ├─ pacstrap /mnt base linux linux-firmware...
  ├─ arch-chroot /mnt
  ├─ bash /root/PHASE_3_SETUP.sh
  │  ├─ Installs bootloader
  │  ├─ Configures system
  │  ├─ Creates swapfile
  │  ├─ Configures ZRAM
  │  ├─ Installs packages
  │  └─ Sets up backups
  ├─ exit
  └─ umount -R /mnt, reboot

Phase 4 (First Boot)
  ├─ Login with new user
  ├─ sudo pacman -Syu (update system)
  ├─ bash /root/setup-user-symlinks.sh
  ├─ Verify: lsblk, df -h, free -h
  └─ Test backup: sudo /usr/local/bin/system-backup.sh
```

---

## Script Dependencies

```
PHASE_3_SETUP.sh
├─ Requires: fstab-template
├─ Uses: system-backup.sh
└─ Calls: setup-swapfile.sh (automated)
          setup-zram.sh (automated)

setup_disks.sh
├─ Standalone
└─ Prepares: /mnt for pacstrap

system-backup.sh
├─ Requires: /backup mounted
├─ Requires: Btrfs filesystem
└─ Called by: cron (daily)

setup-user-symlinks.sh
├─ Requires: All mount points exist
└─ Requires: User home directory exists
```

---

## Configuration Files Created During Installation

### In /etc/
```
/etc/fstab                           ← Mounted filesystems
/etc/hostname                        ← System hostname
/etc/locale.conf                     ← System locale
/etc/vconsole.conf                   ← Keyboard layout (optional)
/etc/sysctl.d/99-swappiness.conf    ← Swap behavior (vm.swappiness=10)
/etc/logrotate.d/system-backup      ← Log rotation for backups
/etc/systemd/zram-generator.conf.d/zram.conf  ← ZRAM config (if enabled)
```

### In /usr/local/bin/
```
/usr/local/bin/system-backup.sh     ← Backup script (auto-called by cron)
/usr/local/bin/init-zram.sh         ← ZRAM init (if manual setup)
```

### In root home (Phase 3)
```
/root/PHASE_3_SETUP.sh              ← Phase 3 setup script
/root/fstab-template                ← fstab reference
/root/system-backup.sh              ← Backup script copy
/root/setup-user-symlinks.sh        ← User symlink setup
```

---

## Backup Retention Policy

| Backup Type | Frequency | Retention | Location |
|-------------|-----------|-----------|----------|
| Btrfs Snapshots | Daily | 30 days | /backup/snapshots/ |
| System Images | Weekly (Sunday) | 4 weeks | /backup/images/ |
| Package Lists | After pacman | 10 backups | /backup/packages/ |
| Configs | Daily | All (archive) | /backup/configs/ |

---

## Recovery Using Backups

### Scenario 1: Restore from Latest Snapshot (5-10 min)
```bash
# Boot Arch USB
arch-chroot /mnt
btrfs send /backup/snapshots/system-LATEST | btrfs receive /
exit
# Reinstall bootloader
arch-chroot /mnt
bootctl install
exit
reboot
```

### Scenario 2: Restore from Weekly Image (15-30 min)
```bash
# Boot Arch USB
gunzip -c /backup/images/system-img-LATEST.gz | \
  dd of=/dev/nvme0n1p2 bs=4M status=progress
# Reinstall bootloader (same as above)
```

### Scenario 3: Clean Install, Keep NVME2 Data
```bash
# Boot Arch USB
# Only format NVME 1 partitions:
mkfs.fat -F 32 /dev/nvme0n1p1      # /boot
mkfs.btrfs -f /dev/nvme0n1p2       # /
# SKIP /dev/nvme0n1p3 (/backup)
mkfs.btrfs -f /dev/nvme0n1p4       # /temp-storage

# Run setup_disks.sh in smart mode
bash install/setup_disks.sh         # Preserves NVME2 and /backup
```

See `RECOVERY_GUIDE.md` for detailed recovery procedures.

---

## Troubleshooting

### Script won't run
```bash
chmod +x install/script-name.sh
bash install/script-name.sh
```

### Setup_disks.sh says "disk not found"
```bash
# Check if disks are detected
lsblk
# Verify device names match script (nvme0n1, nvme1n1)
# Update script if device names differ
```

### PHASE_3_SETUP.sh fails to read config
```bash
# Ensure installation.conf was created by setup_disks.sh
cat /mnt/etc/installation.conf

# If missing, create manually before running PHASE_3_SETUP
cat > /mnt/etc/installation.conf << EOF
HOSTNAME="your-hostname"
USERNAME="username"
USER_PASSWORD="password"
ROOT_PASSWORD="root-password"
TIMEZONE="Asia/Kolkata"
LOCALE="en_US.UTF-8"
KEYBOARD="us"
EOF
```

### Backups not running
```bash
# Check cron service
sudo systemctl status cronie

# Verify cron job exists
sudo crontab -l

# Check logs
sudo tail -f /var/log/system-backup.log

# Test manual backup
sudo /usr/local/bin/system-backup.sh
```

---

## File Locations After Installation

```
dotFileV2/
├── install/
│   ├── setup_disks.sh                  ← Phase 2 (USB)
│   ├── PHASE_3_SETUP.sh                ← Phase 3 (chroot)
│   ├── setup-swapfile.sh               ← Auto-called
│   ├── setup-zram.sh                   ← Auto-called
│   ├── setup-backup-cron.sh            ← Auto-called
│   ├── setup-user-symlinks.sh          ← Phase 4
│   ├── system-backup.sh                ← Installed to /usr/local/bin/
│   ├── fstab-template                  ← Installed to /etc/fstab
│   └── [other scripts]
│
├── INSTALLATION_COMPLETE.md            ← Full installation guide
├── RECOVERY_GUIDE.md                   ← System recovery procedures
├── SCRIPTS_SUMMARY.md                  ← This file
└── [other dotfiles]
```

---

## Next Steps After Installation

1. **Install AUR Helper** (yay or paru)
   ```bash
   git clone https://aur.archlinux.org/yay.git
   cd yay && makepkg -si
   ```

2. **Install Hyprland** (from your dotfiles)
   ```bash
   yay -S hyprland
   ```

3. **Deploy Dotfiles**
   ```bash
   cd dotFileV2
   # Run your dotfile installation scripts
   ```

4. **Verify System Health**
   ```bash
   lsblk                    # Partition layout
   df -h                    # Disk usage
   free -h                  # Memory & swap
   sudo btrfs filesystem show  # Btrfs status
   ```

5. **Test Recovery** (optional but recommended)
   ```bash
   # Create test snapshot
   sudo /usr/local/bin/system-backup.sh
   
   # Verify snapshot was created
   ls -lh /backup/snapshots/
   ```

---

## Summary

Your Arch Linux installation now features:

✓ **Optimized disk layout** with automatic recovery capability
✓ **Daily automated backups** (snapshots + weekly images)
✓ **32GB swapfile** for hibernation
✓ **4GB ZRAM** for in-memory compression
✓ **Proper Btrfs configuration** with compression + caching
✓ **Quick disaster recovery** (5-30 minutes)
✓ **Separate permanent storage** (NVME 2 never touched)
✓ **Organized user directories** (temporary vs permanent)

All scripts are production-ready and tested. Installation should take approximately 1-2 hours total.

**See `INSTALLATION_COMPLETE.md` for step-by-step installation guide.**
