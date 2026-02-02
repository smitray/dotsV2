# System Recovery Guide

## Overview

Your system is designed with a dedicated **`/backup` partition** (200GB on NVME 1) specifically for system recovery. This partition is preserved even during smart reinstalls, allowing quick recovery without losing permanent data on NVME 2.

## Partition Layout Reminder

```
NVME 1 (1TB):
├── p1: /boot (2GB)              - Bootloader
├── p2: / (150GB)                - OS + Applications
├── p3: /backup (200GB)          - RECOVERY BACKUPS ← Can format p1, p2, p4 if needed
└── p4: /temp-storage (648GB)    - Temporary files

NVME 2 (1TB) - NEVER TOUCHED:
├── p1: /home (150GB)            - User configs
├── p2: /workspace (400GB)       - Development projects
├── p3: /obsidian (100GB)        - Obsidian vaults
└── p4: /archive (350GB)         - Permanent data
```

## Backup Contents

The `/backup` partition contains:

### 1. **Btrfs Snapshots** (`/backup/snapshots/`)
- **Frequency**: Daily
- **Retention**: Last 30 snapshots
- **Size**: ~5-10GB each
- **Recovery time**: 5-10 minutes
- **Use case**: Quick rollback to recent system state

### 2. **System Images** (`/backup/images/`)
- **Frequency**: Weekly (Sundays)
- **Retention**: Last 4 images
- **Size**: ~30GB compressed each
- **Recovery time**: 15-30 minutes
- **Use case**: Full system recovery when snapshots aren't enough

### 3. **Package Lists** (`/backup/packages/`)
- **Contents**: List of installed packages from `pacman`
- **Frequency**: After every `pacman` update
- **Retention**: Last 10 lists
- **Use case**: Recreating exact package set

### 4. **System Configs** (`/backup/configs/`)
- **Contents**: `/etc/fstab`, `/etc/hostname`, `/etc/locale.conf`, bootloader config, etc.
- **Frequency**: Daily
- **Retention**: All (archive)
- **Use case**: Recovering system configuration

## Recovery Scenarios

### Scenario 1: Minor Issues (Corrupted App/Config)

**Time: 5-10 minutes**

```bash
# Boot normally, restore from latest snapshot
sudo btrfs subvolume delete /
sudo btrfs send /backup/snapshots/system-LATEST | \
  btrfs receive /
sudo reboot
```

### Scenario 2: System Won't Boot

**Time: 15-30 minutes**

```bash
# 1. Boot from Arch USB
sudo arch-chroot /mnt  # Mount root on /mnt first

# 2. Restore system image
gunzip -c /mnt/backup/images/system-img-LATEST.gz | \
  dd of=/dev/nvme0n1p2 bs=4M status=progress

# 3. Reinstall bootloader
bootctl install

# 4. Exit and reboot
exit
sudo reboot
```

### Scenario 3: Want Clean Install (Nuke NVME 1, Keep NVME 2)

**Time: 30-45 minutes**

```bash
# 1. Boot Arch USB
# 2. Format NVME 1 partitions only:
sudo mkfs.fat -F 32 /dev/nvme0n1p1     # /boot
sudo mkfs.btrfs -f /dev/nvme0n1p2      # /
sudo mkfs.btrfs -f /dev/nvme0n1p4      # /temp-storage
# KEEP /dev/nvme0n1p3 (/backup) untouched!

# 3. Run setup script
cd /mnt/install
sudo bash setup_disks.sh  # Use "smart mode" when prompted

# 4. Continue with pacstrap and installation
```

## Recovery Commands Reference

### View Available Backups

```bash
# List snapshots
ls -lh /backup/snapshots/

# List system images
ls -lh /backup/images/

# List package backups
ls -lh /backup/packages/

# View snapshot log
cat /backup/snapshots/.snapshot-log

# View image log
cat /backup/images/.image-log
```

### Manual Snapshot Restore

```bash
# List available snapshots
sudo btrfs subvolume list /backup/snapshots

# Restore from specific snapshot
sudo btrfs send /backup/snapshots/system-20240115-120000 | \
  btrfs receive /
```

### Manual Image Restore

```bash
# Decompress and restore image
sudo gunzip -c /backup/images/system-img-20240115.gz | \
  sudo dd of=/dev/nvme0n1p2 bs=4M status=progress

# Verify restore
sudo fsck.btrfs /dev/nvme0n1p2
```

### Reinstall Bootloader

```bash
# If UEFI boot fails
sudo bootctl --path=/boot install

# Or using GRUB (if configured)
sudo grub-install --target=x86_64-efi --efi-directory=/boot
```

### Check /backup Partition Health

```bash
# Check filesystem
sudo btrfs filesystem show /backup
sudo btrfs filesystem df /backup
sudo btrfs device stats /

# Verify integrity
sudo btrfs scrub start /
sudo btrfs scrub status /

# List subvolumes
sudo btrfs subvolume list /backup
```

## Automated Backup Verification

The backup script runs daily at **03:00 AM** and:

1. Creates daily Btrfs snapshots
2. Backs up package lists
3. Backs up critical configs
4. Creates weekly system images (Sundays)
5. Cleans up old backups (retention policy)

**Log location**: `/var/log/system-backup.log`

```bash
# Check backup status
tail -f /var/log/system-backup.log

# Check last backup run
ls -lt /backup/snapshots/ | head -5

# Manual backup trigger
sudo /usr/local/bin/system-backup.sh
```

## What's NOT Backed Up

⚠️ **These are intentionally excluded from `/backup`:**

- `/temp-storage` - Temporary files, downloads, cache
- `~/.cache` - Application cache
- `/var/cache` - Package cache
- Swap files

**Why?** These are temporary and automatically cleaned up. They don't need backup.

**These ARE permanent and never touched:**

- `/home` - User configs
- `/workspace` - Development projects
- `/obsidian` - Obsidian vaults
- `/archive` - Photos, documents, media

## Disaster Recovery Checklist

### If System Crashes:

- [ ] Boot from Arch USB
- [ ] Mount `/backup` partition: `sudo mount /dev/nvme0n1p3 /mnt/recovery`
- [ ] Verify backup contents: `ls /mnt/recovery/`
- [ ] Choose recovery method (snapshot or image)
- [ ] Perform recovery (see scenarios above)
- [ ] Verify `/home`, `/workspace`, `/obsidian`, `/archive` are untouched
- [ ] Reboot and test

### After Recovery:

- [ ] Check system logs: `sudo journalctl -xe`
- [ ] Verify all partitions mount: `df -h`
- [ ] Run filesystem check: `sudo btrfs scrub start /`
- [ ] Ensure backup service running: `sudo systemctl status system-backup.timer`
- [ ] Update package lists: `sudo pacman -Sy`

## Important Notes

1. **Never delete `/backup` partition** - It's your safety net
2. **Keep free space on `/backup`** - Snapshots and images need ~50GB minimum
3. **Test your backups** - Periodically restore to verify they work
4. **Monitor `/backup` usage** - If it fills up, old backups auto-delete
5. **NVME 2 is permanent** - Format NVME 1 without hesitation, NVME 2 is safe

## Quick Reference

| Issue | Recovery Time | Method |
|-------|--------------|--------|
| App crash | 1 min | Kill process, restart |
| Config error | 5-10 min | Restore snapshot |
| System won't boot | 15-30 min | Restore image |
| Major corruption | 30 min | Clean install + restore from backup |
| Need clean system | 45 min | Format NVME 1, keep NVME 2 data |

## Troubleshooting

### "No space left on device" during backup

```bash
# Check /backup usage
df -h /backup

# Manually cleanup old backups
sudo rm -rf /backup/snapshots/system-OLD-DATE
sudo rm -f /backup/images/system-img-OLD-DATE.gz
```

### Btrfs snapshot restore fails

```bash
# Verify partition is mounted
sudo mount | grep backup

# Check Btrfs filesystem health
sudo btrfs filesystem show /backup

# If corrupted, restore from image instead
```

### Bootloader broken but / partition intact

```bash
# Boot from USB, chroot into system
arch-chroot /mnt

# Reinstall bootloader
bootctl --path=/boot install

# Exit and reboot
exit
```

## Additional Resources

- **Btrfs Documentation**: https://btrfs.readthedocs.io
- **Arch Wiki Recovery**: https://wiki.archlinux.org/title/System_recovery
- **Partition Management**: `man sgdisk`, `man parted`
