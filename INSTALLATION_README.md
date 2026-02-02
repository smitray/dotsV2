# dotFileV2 - Complete Installation Guide

## 📋 Quick Overview

This is a **complete, production-ready Arch Linux installation system** optimized for full-stack development with Docker and multi-version runtime management.

### What You Get
- ✅ Optimized disk layout (8 partitions, 2 drives)
- ✅ Automatic system backups (daily snapshots, weekly images)
- ✅ Docker with split storage (images on NVME 1, data on NVME 2)
- ✅ Multi-runtime support (Node, Python, Bun via Mise)
- ✅ 32GB swapfile + 4GB ZRAM for performance
- ✅ One-command disaster recovery
- ✅ Smart reinstall (preserves all data on NVME 2)

---

## 📚 Documentation Guide

### Start Here
1. **[CORRECTIONS_SUMMARY.md](./CORRECTIONS_SUMMARY.md)** (5 min read)
   - What changed from initial spec
   - Why Docker images on NVME 1, data on NVME 2
   - Files modified and new scripts

2. **[PARTITION_SPEC_CORRECTED.md](./PARTITION_SPEC_CORRECTED.md)** (15 min read)
   - Complete partition specification
   - Mount points and options
   - Docker and Mise architecture
   - Full-stack developer workflow

3. **[INSTALLATION_COMPLETE.md](./INSTALLATION_COMPLETE.md)** (20 min read)
   - Step-by-step installation guide
   - 4 installation phases explained
   - Post-installation verification
   - First-time setup checklist

### Reference Documents
4. **[RECOVERY_GUIDE.md](./RECOVERY_GUIDE.md)**
   - System recovery procedures
   - Restore from snapshots vs images
   - Clean install with data preservation
   - Troubleshooting commands

5. **[SCRIPTS_SUMMARY.md](./SCRIPTS_SUMMARY.md)**
   - Detailed script inventory
   - What each script does
   - Dependencies and execution order
   - Configuration files created

---

## 🚀 Quick Start (5 minutes)

### Prerequisites
- Two 1TB NVMe drives (nvme0n1 and nvme1n1)
- Arch Linux USB live environment
- Internet connection
- ~2 hours for complete installation

### Installation Steps

```bash
# Phase 2: Disk Setup (on Arch USB)
sudo bash install/setup_disks.sh
# ↳ Creates partitions, formats, mounts, collects config

# Phase 3: System Installation (in chroot)
pacstrap /mnt base linux linux-firmware ...
arch-chroot /mnt
bash /root/PHASE_3_SETUP.sh
# ↳ Installs bootloader, configs, swapfile, ZRAM, backups

# Phase 4: First Boot Setup
sudo bash install/setup-docker.sh      # Docker + split storage
bash install/setup-mise.sh [username]  # Runtime manager
```

---

## 📊 Partition Layout

### NVME 1 (System + Backups + Docker Images)
```
nvme0n1p1 /boot              2 GB   (EFI bootloader)
nvme0n1p2 /                150 GB   (OS + applications)
nvme0n1p3 /backup          200 GB   (Snapshots & recovery)
nvme0n1p4 /var/lib/docker  648 GB   (Docker images - disposable)
```

### NVME 2 (Permanent Storage)
```
nvme1n1p1 /home            150 GB   (Configs + Mise runtimes)
nvme1n1p2 /workspace       400 GB   (Development projects)
nvme1n1p3 /obsidian        100 GB   (Obsidian vaults)
nvme1n1p4 /docker-data     350 GB   (Database files - permanent)
```

---

## 📁 Installation Scripts

### Phase 2: Disk Partitioning
| Script | Purpose | Run As | Location |
|--------|---------|--------|----------|
| `setup_disks.sh` | Create partitions, format, mount | `sudo` | USB Live |

### Phase 3: System Configuration
| Script | Purpose | Run As | Location |
|--------|---------|--------|----------|
| `PHASE_3_SETUP.sh` | Complete system setup (auto-calls sub-scripts) | `root` | chroot /mnt |
| `setup-swapfile.sh` | Create 32GB hibernation swap | Auto | (within Phase 3) |
| `setup-zram.sh` | Setup 4GB compressed RAM | Auto | (within Phase 3) |
| `setup-backup-cron.sh` | Install backup automation | Auto | (within Phase 3) |

### Phase 4: Developer Tools
| Script | Purpose | Run As | When |
|--------|---------|--------|------|
| `setup-docker.sh` | Docker + /docker-data | `sudo` | After Phase 3 |
| `setup-mise.sh` | Runtime manager (Node, Python, Bun) | `user` | After Phase 3 |
| `setup-user-symlinks.sh` | Organize home directories | `sudo` | After Phase 3 |

### Supporting Files
| File | Purpose |
|------|---------|
| `fstab-template` | /etc/fstab configuration |
| `system-backup.sh` | Daily backup automation |

---

## 🎯 What Each Script Does

### setup_disks.sh
**Creates**: Partitions, filesystems, Btrfs subvolumes, mount structure
**Collects**: Hostname, passwords, timezone, locale, keyboard
**Mounts**: All 8 partitions to `/mnt` ready for pacstrap

**Key Features**:
- Automatic drive detection
- Smart mode: preserves existing partitions
- Proper Btrfs subvolume structure
- Optimized mount options (compression, caching)

### PHASE_3_SETUP.sh
**Installs**: Bootloader, system packages, swapfile, ZRAM
**Configures**: Hostname, timezone, locale, users, fstab
**Sets up**: Backup automation, cron jobs, log rotation

**Steps**:
1. Install systemd-boot bootloader
2. Configure system settings
3. Create swapfile (32GB)
4. Configure ZRAM (4GB)
5. Install essential packages
6. Enable system services
7. Setup backup automation

### setup-docker.sh
**Installs**: Docker and docker-compose
**Creates**: `/docker-data` directory structure
**Configures**: Docker daemon with Btrfs storage driver

**Directories Created**:
- `/docker-data/postgres/` - PostgreSQL
- `/docker-data/mysql/` - MySQL
- `/docker-data/mongodb/` - MongoDB
- `/docker-data/redis/` - Redis
- `/docker-data/volumes/` - Named volumes
- `/docker-data/backups/` - DB backups

### setup-mise.sh
**Installs**: Mise runtime version manager
**Configures**: Bash/Zsh shell integration
**Creates**: Project structure and aliases

**Runtimes Supported**:
- Node.js (multiple versions)
- Python (multiple versions)
- Bun (Bun runtime)
- Other tools (extensible)

**Install Location**: `~/.local/share/mise/` (NVME 2 - permanent)

---

## 🛠️ Backup Strategy

### What Gets Backed Up
Location: `/backup` partition on NVME 1

```
✅ Daily Btrfs snapshots of /
✅ Weekly full system images  
✅ Package lists
✅ System configurations

❌ Docker images (disposable, re-downloadable)
❌ /docker-data (permanent on NVME 2, needs separate backup)
❌ /var/cache (application cache)
```

### Backup Schedule
- **Daily at 03:00 AM**: Btrfs snapshot + package list + configs
- **Weekly (Sunday)**: Full system image
- **Retention**: 30 snapshots, 4 images, 10 package lists

### Manual Backup
```bash
sudo /usr/local/bin/system-backup.sh
```

---

## 🐳 Docker Setup with Split Storage

### Architecture
```
Docker Images       → /var/lib/docker (NVME 1)
Database Files      → /docker-data (NVME 2)
```

### Why Split Storage?
- **Images are temporary**: Downloaded automatically via `docker pull`
- **Database files are critical**: Must survive system failures
- **Performance**: Heavy I/O (images) on fast drive, permanent data (databases) on safe drive

### Example Docker Compose
```yaml
version: '3.8'
services:
  postgres:
    image: postgres:15
    volumes:
      - /docker-data/postgres:/var/lib/postgresql/data
  
  mongodb:
    image: mongo:6
    volumes:
      - /docker-data/mongodb:/data/db
```

---

## 🚀 Mise Runtime Management

### Installation Location
```
~/.local/share/mise/          (NVME 2 - Permanent)
├── shims/                    (Executable wrappers)
│   ├── node → ../versions/node/20.11.0/bin/node
│   ├── python → ../versions/python/3.12.0/bin/python
│   └── bun → ../versions/bun/1.0.29/bin/bun
└── versions/                 (Actual installations)
    ├── node/
    │   ├── 18.19.0/
    │   ├── 20.11.0/
    │   └── 22.0.0/
    ├── python/
    │   ├── 3.11.0/
    │   ├── 3.12.0/
    │   └── 3.13.0/
    └── bun/
        ├── 1.0.29/
        └── 1.1.0/
```

### Per-Project Configuration
```bash
~/workspace/projects/my-app/
├── .mise.toml
│   [tools]
│   node = "20.11.0"
│   python = "3.12.0"
│   bun = "1.0.29"
└── src/
```

### Usage
```bash
cd ~/workspace/projects/my-app

# Mise automatically activates:
mise use

# Verify versions
node --version    # v20.11.0
python --version  # Python 3.12.0
bun --version     # 1.0.29
```

---

## 💾 System Recovery

### Quick Recovery (10 minutes)
**Problem**: Application corruption or small issues
**Solution**: Restore from latest Btrfs snapshot

```bash
# Boot from Arch USB
btrfs send /backup/snapshots/system-LATEST | btrfs receive /
```

### Full Recovery (30 minutes)
**Problem**: System won't boot
**Solution**: Restore from weekly system image

```bash
gunzip -c /backup/images/system-img-LATEST.gz | \
  dd of=/dev/nvme0n1p2 bs=4M status=progress
```

### Clean Install (45 minutes)
**Problem**: Want fresh install
**Solution**: Reformat NVME 1, keep all NVME 2 data

```bash
# Run setup_disks.sh in smart mode
sudo bash install/setup_disks.sh
# Preserves: /backup, /home, /workspace, /obsidian, /docker-data
# Recreates: /boot, /, /var/lib/docker
```

---

## ✅ Installation Checklist

### Before Installation
- [ ] Two 1TB NVMe drives available
- [ ] Arch USB created
- [ ] Internet connection working
- [ ] Read CORRECTIONS_SUMMARY.md

### Phase 2 (Disk Setup)
- [ ] Run setup_disks.sh
- [ ] Verify lsblk output
- [ ] Check df -h /mnt
- [ ] Confirm system configuration saved

### Phase 3 (System Installation)
- [ ] pacstrap completed
- [ ] PHASE_3_SETUP.sh completed
- [ ] Exit chroot and reboot
- [ ] Verify boot successful

### Phase 4 (First Boot)
- [ ] System boots correctly
- [ ] Network working
- [ ] Run setup-docker.sh
- [ ] Run setup-mise.sh
- [ ] Verify: lsblk, df -h, free -h
- [ ] Test first backup: sudo /usr/local/bin/system-backup.sh

### Post-Installation
- [ ] Update system: sudo pacman -Syu
- [ ] Install AUR helper (yay/paru)
- [ ] Install Hyprland/desktop
- [ ] Deploy your dotfiles
- [ ] Test Docker containers
- [ ] Test runtime versions

---

## 📞 Troubleshooting

### "Can't find /dev/nvme0n1 or /dev/nvme1n1"
```bash
# Check device names
lsblk
# If different, edit setup_disks.sh:
# Line 20: DISK1="/dev/your-device"
# Line 21: DISK2="/dev/your-other-device"
```

### "Docker can't find /docker-data"
```bash
# Verify mount
mount | grep docker-data

# Check daemon config
sudo cat /etc/docker/daemon.json

# If missing, mount manually:
sudo mount /dev/nvme1n1p4 /docker-data -o rw,relatime,compress=zstd:1,space_cache=v2,subvol=@docker-data
```

### "Mise runtimes not found"
```bash
# Source shell config
source ~/.bashrc

# Verify path
echo $PATH | grep mise

# Test
mise --version
```

### "Backup not running"
```bash
# Check cron
sudo systemctl status cronie
sudo crontab -l

# Manual test
sudo /usr/local/bin/system-backup.sh

# View logs
sudo tail -f /var/log/system-backup.log
```

---

## 📖 Reading Order

**If you have 5 minutes:**
- Read: CORRECTIONS_SUMMARY.md

**If you have 30 minutes:**
- Read: CORRECTIONS_SUMMARY.md
- Read: PARTITION_SPEC_CORRECTED.md
- Skim: INSTALLATION_COMPLETE.md

**If you have 1 hour:**
- Read all documentation files
- Review all scripts
- Run through installation steps

**Before installation:**
- Have all 5 documentation files open
- Check device names match
- Ensure 2TB free space

---

## 📂 File Organization

```
dotFileV2/
├── CORRECTIONS_SUMMARY.md           ← What changed
├── PARTITION_SPEC_CORRECTED.md      ← Complete spec
├── INSTALLATION_COMPLETE.md         ← Step-by-step guide
├── INSTALLATION_README.md           ← This file
├── RECOVERY_GUIDE.md                ← Recovery procedures
├── SCRIPTS_SUMMARY.md               ← Script reference
│
├── install/
│   ├── setup_disks.sh               ← Phase 2
│   ├── PHASE_3_SETUP.sh             ← Phase 3
│   ├── setup-docker.sh              ← Phase 4
│   ├── setup-mise.sh                ← Phase 4
│   ├── setup-swapfile.sh            ← Called by Phase 3
│   ├── setup-zram.sh                ← Called by Phase 3
│   ├── setup-backup-cron.sh         ← Called by Phase 3
│   ├── system-backup.sh             ← Called by Phase 3
│   ├── setup-user-symlinks.sh       ← Optional
│   ├── fstab-template               ← Used by Phase 3
│   └── [other files]
│
└── [other dotfiles]
```

---

## 🎓 Learning Resources

### Arch Linux
- Official Wiki: https://wiki.archlinux.org/
- Installation Guide: https://wiki.archlinux.org/title/Installation_guide

### Btrfs
- Official Docs: https://btrfs.readthedocs.io/
- Compression: https://btrfs.readthedocs.io/en/latest/compress.html
- Subvolumes: https://btrfs.readthedocs.io/en/latest/btrfs-subvolume.html

### Docker
- Documentation: https://docs.docker.com/
- Storage Drivers: https://docs.docker.com/storage/storagedriver/
- Volumes: https://docs.docker.com/storage/volumes/

### Mise
- Official: https://mise.jdx.dev/
- GitHub: https://github.com/jdx/mise

---

## ✨ Summary

This installation system provides:

1. **Optimal Disk Layout**
   - Fast NVME 1 for OS, backups, disposable Docker images
   - Reliable NVME 2 for permanent data and databases

2. **Complete Automation**
   - Zero-manual setup with scripts
   - Automatic backups and recovery
   - Smart reinstall capability

3. **Full-Stack Development**
   - Multi-version runtime support (Node, Python, Bun)
   - Docker with persistent database storage
   - Project-specific configuration via .mise.toml

4. **Data Safety**
   - Daily automatic backups
   - Quick disaster recovery (10-30 minutes)
   - Permanent data never touched during reinstalls

5. **Performance**
   - Btrfs compression (zstd:1)
   - Space cache v2 for faster access
   - 32GB swapfile + 4GB ZRAM

---

## 🚀 Get Started

1. Review **CORRECTIONS_SUMMARY.md** (5 min)
2. Read **PARTITION_SPEC_CORRECTED.md** (15 min)
3. Follow **INSTALLATION_COMPLETE.md** (step-by-step)
4. Keep **RECOVERY_GUIDE.md** for reference

**Everything is ready to go. Your complete installation system is production-ready!**

Good luck! 🎉
