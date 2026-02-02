# Corrected Partition Specification - Full-Stack Developer Setup

## Overview

This is the **final corrected partition specification** optimized for full-stack development with:
- Node.js, Python, Bun runtimes (via Mise)
- Docker with split storage strategy
- System recovery and backups
- Optimized for performance and data integrity

## Final Partition Layout

### NVME 1 (`/dev/nvme0n1` - 1TB) - System + Recovery + Docker Images

| Partition | Mount Point | Size | Filesystem | Purpose |
|-----------|-------------|------|------------|---------|
| **p1** | `/boot` | 2 GB | FAT32 | EFI bootloader |
| **p2** | `/` | 150 GB | Btrfs | OS + applications |
| **p3** | `/backup` | 200 GB | Btrfs | System snapshots + recovery images |
| **p4** | `/var/lib/docker` | 648 GB | Btrfs | **Docker images & containers** |

**Purpose**: System + disposable Docker (can be reformatted)

### NVME 2 (`/dev/nvme1n1` - 1TB) - Permanent Storage + Docker Data

| Partition | Mount Point | Size | Filesystem | Purpose |
|-----------|-------------|------|------------|---------|
| **p1** | `/home` | 150 GB | Btrfs | User configs, dotfiles, **Mise runtimes** |
| **p2** | `/workspace` | 400 GB | Btrfs | Development projects, source code |
| **p3** | `/obsidian` | 100 GB | Btrfs | Obsidian vaults, personal notes |
| **p4** | `/docker-data` | 350 GB | Btrfs | **Docker volumes, database files, persistent data** |

**Purpose**: Permanent storage (NEVER reformatted)

---

## Visual Layout

```
NVME 1: SYSTEM + DISPOSABLE DOCKER
┌─────────┬────────────┬────────────┬──────────────────────────┐
│ /boot   │     /      │  /backup   │   /var/lib/docker       │
│  2GB    │   150GB    │   200GB    │         648GB           │
│         │            │            │                          │
│ Boot    │  OS & Apps │  Snapshots │     DOCKER IMAGES:      │
│ Loader  │            │  Recovery  │     • Images            │
│         │            │  Images    │     • Containers        │
│         │            │  Package   │     • Cache             │
│         │            │  Lists     │     ⚠️ Can reinstall    │
└─────────┴────────────┴────────────┴──────────────────────────┘
           Can format these 3 on system failure


NVME 2: PERMANENT STORAGE
┌──────────┬──────────────────┬──────────────┬─────────────────┐
│  /home   │   /workspace     │  /obsidian   │  /docker-data   │
│  150GB   │     400GB        │    100GB     │     350GB       │
│          │                  │              │                 │
│ Configs  │ Development      │   Obsidian   │  DATABASES:     │
│ + Mise   │   Projects       │    Vaults    │  • PostgreSQL   │
│ Runtimes │   Code           │   Notes      │  • MySQL        │
│          │   Git Repos      │              │  • MongoDB      │
│ Locations│                  │              │  • Redis        │
│ of:      │                  │              │  • App Data     │
│ • node   │                  │              │  ✅ Permanent   │
│ • python │                  │              │  ✅ Backed up   │
│ • bun    │                  │              │                 │
└──────────┴──────────────────┴──────────────┴─────────────────┘
           NEVER reformatted - critical data lives here
```

---

## Runtime Management with Mise

### Installation Locations

```
~/.local/share/mise/    (on NVME 2 - /home partition)
├── shims/
│   ├── node → ../versions/node/20.11.0/bin/node
│   ├── npm → ../versions/node/20.11.0/bin/npm
│   ├── python → ../versions/python/3.12.0/bin/python
│   └── bun → ../versions/bun/1.0.29/bin/bun
│
└── versions/
    ├── node/
    │   ├── 18.19.0/
    │   ├── 20.11.0/    ← Default or project-specific
    │   └── 22.0.0/
    ├── python/
    │   ├── 3.11.0/
    │   ├── 3.12.0/     ← Default or project-specific
    │   └── 3.13.0/
    └── bun/
        ├── 1.0.29/
        └── 1.1.0/
```

### Per-Project Configuration

```
~/workspace/projects/my-app/
├── .mise.toml
│   [tools]
│   node = "20.11.0"
│   python = "3.12.0"
│   bun = "1.0.29"
├── package.json
├── requirements.txt
├── src/
└── tests/

# When you: cd ~/workspace/projects/my-app
# Mise automatically loads: node 20.11.0, python 3.12.0, bun 1.0.29
# These point to ~/.local/share/mise/versions/
```

---

## Docker Storage Strategy

### Docker Images (NVME 1 - Disposable)

```
/var/lib/docker/
├── overlay2/          ← Docker layer storage (images)
├── containers/        ← Running container data
├── image/            ← Image metadata
└── network/          ← Network configurations

Total size: 50-100GB (varies based on pulled images)
Status: Can be completely deleted, images re-downloaded
```

### Docker Volumes & Data (NVME 2 - Permanent)

```
/docker-data/
├── postgres/         ← PostgreSQL database files
│   └── base/, global/, pg_wal, ...
├── mysql/            ← MySQL database files
│   └── ib_buffer_pool, ibdata1, mysql/, ...
├── mongodb/          ← MongoDB data files
│   └── collection-0, index-1, ...
├── redis/            ← Redis dump files
│   └── dump.rdb
├── volumes/          ← Named Docker volumes
│   ├── myapp-data/
│   └── myapp-cache/
└── backups/          ← Database backups
    ├── postgres-backup-20240115.sql.gz
    └── mysql-backup-20240115.sql.gz
```

### Docker Compose Example

```yaml
version: '3.8'

services:
  # PostgreSQL with data on NVME 2 (permanent)
  postgres:
    image: postgres:15
    volumes:
      - /docker-data/postgres:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: secret

  # MySQL with data on NVME 2 (permanent)
  mysql:
    image: mysql:8
    volumes:
      - /docker-data/mysql:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: secret

  # MongoDB with data on NVME 2 (permanent)
  mongodb:
    image: mongo:6
    volumes:
      - /docker-data/mongodb:/data/db

  # Redis with RDB persistence on NVME 2
  redis:
    image: redis:7
    volumes:
      - /docker-data/redis:/data
    command: redis-server --appendonly yes
```

---

## Complete Mount Options Reference

### NVME 1 Mount Options

```bash
# /boot (FAT32)
defaults,noatime,nofail

# / (Btrfs root)
rw,relatime,compress=zstd:1,space_cache=v2,subvol=@

# /backup (Btrfs)
rw,relatime,compress=zstd:1,space_cache=v2

# /var/lib/docker (Btrfs)
rw,relatime,compress=zstd:1,space_cache=v2
```

### NVME 2 Mount Options

```bash
# /home (Btrfs)
rw,relatime,compress=zstd:1,space_cache=v2,subvol=@home

# /workspace (Btrfs)
rw,relatime,compress=zstd:1,space_cache=v2,subvol=@workspace

# /obsidian (Btrfs)
rw,relatime,compress=zstd:1,space_cache=v2,subvol=@obsidian

# /docker-data (Btrfs)
rw,relatime,compress=zstd:1,space_cache=v2,subvol=@docker-data
```

---

## Backup Strategy

### What Gets Backed Up

**Location**: `/backup` partition on NVME 1

```
✅ Daily Btrfs snapshots of /  (30-day retention)
✅ Weekly full system images   (4-week retention)
✅ Package lists               (10-version retention)
✅ System configurations       (all, archive)

❌ /var/lib/docker            (disposable, can redownload)
❌ /docker-data              (permanent on NVME 2, needs separate backup)
❌ /var/cache, ~/.cache       (application cache, disposable)
```

### Docker Data Backup Recommendation

Since `/docker-data` contains critical database files, create regular backups:

```bash
# Backup script example:
#!/bin/bash
BACKUP_DIR="/backup/docker-data"
DATE=$(date +%Y%m%d-%H%M%S)

# Backup all Docker volumes and database files
sudo rsync -av --delete \
  /docker-data/ \
  $BACKUP_DIR/$DATE/

# Keep last 10 daily backups
find $BACKUP_DIR -maxdepth 1 -type d -mtime +10 -exec rm -rf {} \;
```

---

## Partition Creation Commands

### For NVME 1

```bash
# Create partition table
parted /dev/nvme0n1 -- mklabel gpt

# Create partitions
parted /dev/nvme0n1 -- mkpart primary fat32 1MiB 2GiB
parted /dev/nvme0n1 -- set 1 esp on
parted /dev/nvme0n1 -- mkpart primary btrfs 2GiB 152GiB      # 150GB /
parted /dev/nvme0n1 -- mkpart primary btrfs 152GiB 352GiB    # 200GB /backup
parted /dev/nvme0n1 -- mkpart primary btrfs 352GiB 1000GiB   # 648GB /var/lib/docker

# Format
mkfs.fat -F 32 -n "ARCH_BOOT" /dev/nvme0n1p1
mkfs.btrfs -f -L "ARCH_ROOT" /dev/nvme0n1p2
mkfs.btrfs -f -L "ARCH_BACKUP" /dev/nvme0n1p3
mkfs.btrfs -f -L "ARCH_DOCKER" /dev/nvme0n1p4
```

### For NVME 2

```bash
# Create partition table
parted /dev/nvme1n1 -- mklabel gpt

# Create partitions
parted /dev/nvme1n1 -- mkpart primary btrfs 1MiB 151GiB      # 150GB /home
parted /dev/nvme1n1 -- mkpart primary btrfs 151GiB 551GiB    # 400GB /workspace
parted /dev/nvme1n1 -- mkpart primary btrfs 551GiB 651GiB    # 100GB /obsidian
parted /dev/nvme1n1 -- mkpart primary btrfs 651GiB 1001GiB   # 350GB /docker-data

# Format
mkfs.btrfs -f -L "ARCH_HOME" /dev/nvme1n1p1
mkfs.btrfs -f -L "ARCH_WORKSPACE" /dev/nvme1n1p2
mkfs.btrfs -f -L "ARCH_OBSIDIAN" /dev/nvme1n1p3
mkfs.btrfs -f -L "ARCH_DOCKER_DATA" /dev/nvme1n1p4
```

---

## Filesystem Hierarchy After Installation

```
/
├── boot/                     ← /dev/nvme0n1p1 (FAT32, EFI)
├── /                         ← /dev/nvme0n1p2 (Btrfs, subvol=@)
├── backup/                   ← /dev/nvme0n1p3 (Btrfs, snapshots)
├── var/lib/docker/          ← /dev/nvme0n1p4 (Btrfs, images)
├── home/                     ← /dev/nvme1n1p1 (Btrfs, subvol=@home)
│   └── [user]/
│       ├── .bashrc
│       ├── .config/
│       └── .local/share/mise/  ← RUNTIMES HERE (node, python, bun)
├── workspace/                ← /dev/nvme1n1p2 (Btrfs, subvol=@workspace)
│   ├── projects/
│   │   ├── web-app/
│   │   │   └── .mise.toml
│   │   ├── api-server/
│   │   │   └── .mise.toml
│   │   └── mobile-app/
│   │       └── .mise.toml
│   └── environments/
├── obsidian/                 ← /dev/nvme1n1p3 (Btrfs, subvol=@obsidian)
│   ├── Personal/
│   ├── Work/
│   └── Reference/
├── docker-data/              ← /dev/nvme1n1p4 (Btrfs, subvol=@docker-data)
│   ├── postgres/
│   ├── mysql/
│   ├── mongodb/
│   ├── redis/
│   └── backups/
├── swapfile                  ← 32GB swap
└── [other standard directories]
```

---

## Setup Scripts

### Installation Order

```
1. setup_disks.sh           Phase 2: Partition & mount
2. pacstrap                 Install base system
3. PHASE_3_SETUP.sh         Phase 3: Configure system + swapfile + zram
4. setup-docker.sh          Install & configure Docker
5. setup-mise.sh            Install Mise runtime manager
```

### Script Locations

```
install/
├── setup_disks.sh           ← Phase 2 (USB)
├── PHASE_3_SETUP.sh         ← Phase 3 (chroot)
├── setup-docker.sh          ← After Phase 3
├── setup-mise.sh            ← After Phase 3
├── setup-swapfile.sh        ← Auto-called by PHASE_3
├── setup-zram.sh            ← Auto-called by PHASE_3
├── system-backup.sh         ← Auto-called by PHASE_3
├── fstab-template           ← Used by PHASE_3
└── [other files]
```

---

## Working as a Full-Stack Developer

### Typical Development Workflow

```bash
# 1. Navigate to project
cd ~/workspace/projects/my-app

# 2. Mise automatically activates:
#    - node 20.11.0
#    - python 3.12.0
#    - bun 1.0.29

# 3. Check versions
node --version              # v20.11.0 (from ~/.local/share/mise/)
python --version            # Python 3.12.0
bun --version              # bun 1.0.29

# 4. Start development servers
npm start                   # Node backend
python manage.py runserver  # Python backend
bunx next dev              # Bun frontend

# 5. Work with Docker databases
docker-compose up -d       # Start PostgreSQL, Redis, MongoDB
                          # Data goes to /docker-data (NVME 2)

# 6. Access databases
psql -h localhost          # PostgreSQL from /docker-data
mysql -h localhost         # MySQL from /docker-data
mongo localhost:27017      # MongoDB from /docker-data
```

### Storage Locations Summary

```
Code & Projects:         ~/workspace/        (NVME 2, 400GB)
Runtimes:              ~/.local/share/mise/  (NVME 2, part of 150GB)
Notes:                 ~/obsidian/           (NVME 2, 100GB)
Database Files:        /docker-data/         (NVME 2, 350GB)
Docker Images:         /var/lib/docker/      (NVME 1, disposable)
System:                /                     (NVME 1, 150GB)
Backups:               /backup/              (NVME 1, 200GB)
```

---

## System Failure Recovery

### If System Breaks (NVME 1 failure)

```bash
# What you lose:
# - OS and applications (reinstall)
# - Docker images (re-download)
# - System cache

# What you keep (NVME 2):
# ✅ All source code (/workspace/)
# ✅ All database files (/docker-data/)
# ✅ All configurations (/home/)
# ✅ All notes (/obsidian/)
# ✅ All Mise runtimes (~/.local/share/mise/)

# Recovery:
1. Reinstall system on NVME 1 (using backup snapshots)
2. Reinstall Docker
3. Point Docker to existing /docker-data volumes
4. Reinstall development tools/packages
5. Done! All your data is intact
```

---

## Key Differences from Previous Specs

### Before (Incorrect)

```
NVME 1 p4: /temp-storage      (temporary downloads, cache)
NVME 2 p4: /archive           (documents, media - static data)
```

### After (Correct)

```
NVME 1 p4: /var/lib/docker    (Docker images - disposable)
NVME 2 p4: /docker-data       (Database files - permanent)
```

### Reasoning

- **Docker images are disposable**: They can be redownloaded via `docker pull`
- **Database files are critical**: They contain application data and must be preserved
- **Split storage strategy**: Temporary on fast drive, permanent data on reliable storage

---

## Verification Command

After installation:

```bash
$ df -h | grep nvme
/dev/nvme0n1p1     2G   0.5G  1.5G  25% /boot
/dev/nvme0n1p2   150G    20G  130G  13% /
/dev/nvme0n1p3   200G     5G  195G   3% /backup
/dev/nvme0n1p4   648G   100G  548G  15% /var/lib/docker
/dev/nvme1n1p1   150G    10G  140G   7% /home
/dev/nvme1n1p2   400G    50G  350G  12% /workspace
/dev/nvme1n1p3   100G    10G   90G  10% /obsidian
/dev/nvme1n1p4   350G   100G  250G  29% /docker-data

$ which node
/home/youruser/.local/share/mise/shims/node

$ docker info | grep "Docker Root Dir"
 Docker Root Dir: /var/lib/docker
```

---

## Summary

**This is your final, correct partition specification optimized for:**

✅ Full-stack development (Node, Python, Bun)
✅ Multiple project runtimes via Mise
✅ Docker with persistent database storage
✅ System recovery and backups
✅ Data safety with permanent NVME 2 storage
✅ Performance with Btrfs compression and caching

All scripts have been updated to implement this layout.
