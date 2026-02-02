# Production-Ready Partition Specification - Optimal Performance & Reliability

## Philosophy

**Maximum Performance + Reliability First**
- Free space: **100-120GB per disk** (10-12% of 1TB) for optimal Btrfs operation
- No compromises on system performance or safety
- Properly sized partitions for each use case
- Room for growth and unforeseen needs

---

## NVME 1 Layout (1TB - System + Recovery + Docker)

| Partition | Mount Point | Size | Type | Filesystem | Purpose |
|-----------|-------------|------|------|------------|---------|
| **p1** | `/boot` | 2 GB | EFI System | FAT32 | Bootloader & kernels |
| **p2** | `/` | 140 GB | Linux | Btrfs | OS + applications |
| **p3** | `/backup` | 180 GB | Linux | Btrfs | System snapshots & recovery images |
| **p4** | `/var/lib/docker` | 330 GB | Linux | Btrfs | Docker images (disposable) |
| **p5** | `/downloads` | 248 GB | Linux | Btrfs | ISOs, media, downloads, temp files |
| **FREE** | (unallocated) | **100 GB** | - | - | **Btrfs optimal operations** |

**Total Allocated**: 900 GB  
**Free Space**: 100 GB (10%) ← **Recommended for Btrfs performance**  
**Total Capacity**: 1000 GB (1 TB)

---

## NVME 2 Layout (1TB - Permanent Storage + Docker Data)

| Partition | Mount Point | Size | Type | Filesystem | Purpose |
|-----------|-------------|------|------|------------|---------|
| **p1** | `/home` | 140 GB | Linux | Btrfs | User configs, dotfiles, Mise runtimes |
| **p2** | `/workspace` | 380 GB | Linux | Btrfs | Development projects, source code |
| **p3** | `/obsidian` | 100 GB | Linux | Btrfs | Obsidian vaults, personal notes |
| **p4** | `/docker-data` | 280 GB | Linux | Btrfs | Docker volumes, database files (permanent) |
| **FREE** | (unallocated) | **100 GB** | - | - | **Btrfs optimal operations** |

**Total Allocated**: 900 GB  
**Free Space**: 100 GB (10%) ← **Recommended for Btrfs performance**  
**Total Capacity**: 1000 GB (1 TB)

---

## Visual Layout

```
╔════════════════════════════════════════════════════════════════════════════╗
║              NVME 1 (1TB) - PRODUCTION OPTIMIZED                          ║
╠════════════════════════════════════════════════════════════════════════════╣
║  p1   p2      p3         p4           p5              FREE                ║
║ /boot  /    /backup  /var/lib/docker /downloads     (Btrfs)              ║
║  2GB  140GB  180GB      330GB        248GB          100GB (10%)           ║
║                                                                           ║
║ Boot   OS   Recovery    Docker       Downloads &    Optimal              ║
║       Apps  + Images    Images       General        Operations           ║
║                         (disp.)      Storage        (Btrfs Headroom)     ║
╚════════════════════════════════════════════════════════════════════════════╝

╔════════════════════════════════════════════════════════════════════════════╗
║           NVME 2 (1TB) - PRODUCTION PERMANENT STORAGE                     ║
╠════════════════════════════════════════════════════════════════════════════╣
║   p1        p2          p3          p4              FREE                   ║
║  /home    /workspace  /obsidian  /docker-data     (Btrfs)                ║
║  140GB     380GB       100GB      280GB          100GB (10%)              ║
║                                                                           ║
║ Configs & Development  Obsidian  Database Files  Optimal                 ║
║ Mise      Projects     Notes     (permanent)     Operations              ║
║ Runtimes                                         (Btrfs Headroom)        ║
╚════════════════════════════════════════════════════════════════════════════╝
```

---

## Complete Partition Creation Commands

### For NVME 1

```bash
# Create partition table
parted /dev/nvme0n1 -- mklabel gpt

# Create partitions with PRODUCTION OPTIMIZED sizes
parted /dev/nvme0n1 -- mkpart primary fat32 1MiB 2GiB        # p1: /boot (2GB)
parted /dev/nvme0n1 -- set 1 esp on
parted /dev/nvme0n1 -- mkpart primary btrfs 2GiB 142GiB      # p2: / (140GB)
parted /dev/nvme0n1 -- mkpart primary btrfs 142GiB 322GiB    # p3: /backup (180GB)
parted /dev/nvme0n1 -- mkpart primary btrfs 322GiB 652GiB    # p4: /var/lib/docker (330GB)
parted /dev/nvme0n1 -- mkpart primary btrfs 652GiB 900GiB    # p5: /downloads (248GB)
# Free space: 900GiB to 1000GiB = 100GB unallocated (10% for Btrfs operations)

# Format partitions
mkfs.fat -F 32 -n "ARCH_BOOT" /dev/nvme0n1p1
mkfs.btrfs -f -L "ARCH_ROOT" /dev/nvme0n1p2
mkfs.btrfs -f -L "ARCH_BACKUP" /dev/nvme0n1p3
mkfs.btrfs -f -L "ARCH_DOCKER" /dev/nvme0n1p4
mkfs.btrfs -f -L "ARCH_DOWNLOADS" /dev/nvme0n1p5
```

### For NVME 2

```bash
# Create partition table
parted /dev/nvme1n1 -- mklabel gpt

# Create partitions with PRODUCTION OPTIMIZED sizes
parted /dev/nvme1n1 -- mkpart primary btrfs 1MiB 141GiB      # p1: /home (140GB)
parted /dev/nvme1n1 -- mkpart primary btrfs 141GiB 521GiB    # p2: /workspace (380GB)
parted /dev/nvme1n1 -- mkpart primary btrfs 521GiB 621GiB    # p3: /obsidian (100GB)
parted /dev/nvme1n1 -- mkpart primary btrfs 621GiB 901GiB    # p4: /docker-data (280GB)
# Free space: 901GiB to 1000GiB = 99GB unallocated (10% for Btrfs operations)

# Format partitions
mkfs.btrfs -f -L "ARCH_HOME" /dev/nvme1n1p1
mkfs.btrfs -f -L "ARCH_WORKSPACE" /dev/nvme1n1p2
mkfs.btrfs -f -L "ARCH_OBSIDIAN" /dev/nvme1n1p3
mkfs.btrfs -f -L "ARCH_DOCKER_DATA" /dev/nvme1n1p4
```

---

## Updated fstab Configuration

```bash
# /etc/fstab: static file system information
# <file system>             <mount point>      <type>  <options>                                                   <dump> <pass>

# UEFI System
efivarfs                     /sys/firmware/efi/efivars efivarfs rw,nosuid,nodev,noexec,relatime              0      0

# DISK 1: System + Recovery + Docker (NVME 1 - 1TB, 100GB free for Btrfs - PRODUCTION)
/dev/nvme0n1p1              /boot              vfat    defaults,noatime,nofail                               0      2
/dev/nvme0n1p2              /                  btrfs   rw,relatime,compress=zstd:1,space_cache=v2,subvol=@  0      0
/dev/nvme0n1p3              /backup            btrfs   rw,relatime,compress=zstd:1,space_cache=v2            0      2
/dev/nvme0n1p4              /var/lib/docker    btrfs   rw,relatime,compress=zstd:1,space_cache=v2            0      2
/dev/nvme0n1p5              /downloads         btrfs   rw,relatime,compress=zstd:1,space_cache=v2            0      2

# DISK 2: Permanent Storage (NVME 2 - 1TB, 100GB free for Btrfs - PRODUCTION)
/dev/nvme1n1p1              /home              btrfs   rw,relatime,compress=zstd:1,space_cache=v2,subvol=@home           0      2
/dev/nvme1n1p2              /workspace         btrfs   rw,relatime,compress=zstd:1,space_cache=v2,subvol=@workspace      0      2
/dev/nvme1n1p3              /obsidian          btrfs   rw,relatime,compress=zstd:1,space_cache=v2,subvol=@obsidian       0      2
/dev/nvme1n1p4              /docker-data       btrfs   rw,relatime,compress=zstd:1,space_cache=v2,subvol=@docker-data   0      2

# Swapfile (32GB - for hibernation and memory overflow)
/swapfile                    none               swap    defaults,pri=-2                                       0      0

# Temporary filesystems
tmpfs                        /tmp               tmpfs   defaults,noatime,mode=1777                            0      0
tmpfs                        /var/tmp           tmpfs   defaults,noatime,mode=1777                            0      0
tmpfs                        /run               tmpfs   defaults,noatime,nosuid,nodev,mode=755               0      0
tmpfs                        /dev/shm           tmpfs   defaults,noatime,nosuid,nodev                         0      0
```

---

## Partition Sizing Justification

### NVME 1 Partitions

#### `/boot` (2 GB)
```
What: EFI bootloader + kernel images
Typical usage:
  • Current kernel: 50MB
  • Fallback kernel: 50MB
  • Bootloader: 10MB
  • Future kernels: 200MB

2GB allows:
  • 20+ kernels (more than enough)
  • No risk of filling up
  • Room for experimental kernels
```

#### `/` (140 GB)
```
What: Root filesystem - OS + system applications
Breakdown:
  • Arch Linux base: 1-2GB
  • Pacman cache: 2-5GB (can be cleaned)
  • System files: 5-10GB
  • Common apps (git, vim, python, etc): 10-20GB
  • Additional software: 20-50GB

140GB provides:
  • 100GB buffer for applications
  • Room for development tools
  • No space constraints
  • Comfortable headroom
```

#### `/backup` (180 GB)
```
What: System snapshots and recovery images
Breakdown:
  • Daily Btrfs snapshots @ 5GB each = 150GB for 30 days
  • Weekly system images @ 30GB each = 120GB for 4 weeks
  • Package/config backups = 5-10GB

180GB allows:
  • 30+ daily snapshots OR
  • 4+ weekly images OR
  • Mix of both
  • Safe recovery capability
  • Extended history
```

#### `/var/lib/docker` (330 GB)
```
What: Docker images and container layers (DISPOSABLE)
Breakdown:
  • Base images (ubuntu, alpine, etc): 50-100GB
  • Build images (node, python, golang): 50-100GB
  • Application images (custom): 50-100GB
  • Layers and caches: 50-100GB

330GB allows:
  • 50-100 Docker images simultaneously
  • Large development environments
  • Quick container recreation
  • No "disk full" Docker errors
```

#### `/downloads` (248 GB)
```
What: ISOs, media files, temporary downloads
Breakdown:
  • Linux ISOs (10 × 5GB): 50GB
  • Large media files: 100-150GB
  • Temporary extraction: 50GB
  • Browser downloads: 20-30GB

248GB allows:
  • Multiple large ISO libraries
  • Video/music storage
  • Temp files and extraction
  • No frequent cleanup needed
```

### NVME 2 Partitions

#### `/home` (140 GB)
```
What: User home directory + Mise runtimes
Breakdown:
  • Shell configs (.bashrc, etc): 100KB
  • Application configs (.config/): 500MB
  • SSH/GPG keys: 100KB
  • Mise runtimes:
    - Node.js 5 versions: 2-3GB
    - Python 3 versions: 2-3GB
    - Bun: 200MB
    - Total runtimes: 5-10GB

140GB allows:
  • 130GB buffer for runtimes
  • Future runtime versions
  • Personal files (up to 100GB)
  • No constraints
```

#### `/workspace` (380 GB)
```
What: Development projects and source code
Breakdown:
  • 20 medium projects (15GB each): 300GB
  • Git history: 30-50GB
  • node_modules (if stored): 20-50GB

380GB allows:
  • 20-30 full-featured projects
  • Generous git history
  • node_modules and dependencies
  • Growing project portfolio
```

#### `/obsidian` (100 GB)
```
What: Obsidian vaults and personal notes
Breakdown:
  • Vault files (markdown): 1-5GB
  • Attachments (images, PDFs): 50-90GB
  • Plugins and themes: 1GB

100GB allows:
  • Large attachment libraries
  • Years of notes and media
  • Multiple vaults
  • Room for growth
```

#### `/docker-data` (280 GB)
```
What: Docker volumes and database files (PERMANENT)
Breakdown:
  • PostgreSQL (5 × 20GB): 100GB
  • MySQL (3 × 10GB): 30GB
  • MongoDB (2 × 20GB): 40GB
  • Redis: 5-10GB
  • Application data: 50-100GB

280GB allows:
  • Multiple production databases
  • Large datasets
  • Database backups
  • Room for growth
```

### FREE SPACE: 100GB per disk (10%)

```
Why 100GB is optimal:
  • Btrfs recommended: 10-15% free
  • 10% of 1TB = 100GB ✓
  • Allows chunk creation
  • Enables balance operations
  • Handles COW overhead
  • Emergency buffer
  • Performance optimization
```

---

## Partition Comparison Table

| Component | Size | Justification |
|-----------|------|---|
| **NVME 1** | | |
| /boot | 2GB | Enough for 20+ kernels |
| / | 140GB | OS + 100GB apps buffer |
| /backup | 180GB | 30+ snapshots + 4 weekly images |
| /var/lib/docker | 330GB | 50-100 Docker images |
| /downloads | 248GB | ISOs, media, temp files |
| **Free** | **100GB** | **10% for Btrfs operations** |
| **Total** | **1000GB** | |
| | | |
| **NVME 2** | | |
| /home | 140GB | Configs + runtimes + personal files |
| /workspace | 380GB | 20-30 projects with history |
| /obsidian | 100GB | Notes + large attachments |
| /docker-data | 280GB | Multiple databases + backups |
| **Free** | **100GB** | **10% for Btrfs operations** |
| **Total** | **1000GB** | |

---

## Performance Characteristics

### Btrfs With 100GB Free Space

```
✓ CHUNK ALLOCATION
  • Plenty of room for new chunks
  • Multiple allocation operations
  • Optimal performance

✓ BALANCE OPERATIONS
  • Can rebalance data freely
  • Redistributes across chunks
  • Maintains performance

✓ COW (Copy-on-Write)
  • Smooth data writing
  • No "no space" errors
  • Efficient block freeing

✓ FRAGMENTATION
  • Prevents fragmentation issues
  • Can defragment if needed
  • Long-term stability

✓ GROWTH POTENTIAL
  • Partitions not near full
  • Can add more software
  • Handles unexpected files
```

### Storage Utilization

```
NVME 1:
  • Allocated: 900GB (90%)
  • Free: 100GB (10%)
  • Usage: Comfortable headroom

NVME 2:
  • Allocated: 900GB (90%)
  • Free: 100GB (10%)
  • Usage: Comfortable headroom

Total:
  • Allocated: 1800GB (90% of 2TB)
  • Free: 200GB (10% of 2TB)
  • Status: Production-grade ✓
```

---

## Quick Size Reference

```
NVME 1 (1000GB):
  2GB boot + 140GB / + 180GB /backup + 330GB /docker + 248GB /downloads = 900GB
  +100GB free = 1000GB ✓

NVME 2 (1000GB):
  140GB /home + 380GB /workspace + 100GB /obsidian + 280GB /docker-data = 900GB
  +100GB free = 1000GB ✓
```

---

## Why This is PRODUCTION-READY

✅ **Proper free space**: 10% per disk (Btrfs best practices)
✅ **No compromises**: Each partition has breathing room
✅ **Scalable**: Room for growth in all areas
✅ **Reliable**: Safe buffer for unforeseen needs
✅ **Performant**: Optimal Btrfs chunk allocation
✅ **Balanced**: All partitions well-sized
✅ **Future-proof**: Growth potential built-in

---

## Summary

This partition scheme is **optimized for production use**:

- **100GB free space per disk** (10%) - Btrfs recommended
- **900GB allocated per disk** (90%) - Maximum usable storage
- **All partitions properly sized** - No constraints or bottlenecks
- **Room for growth** - Multiple partitions have expansion capacity
- **Reliable operation** - Safe buffer for Btrfs and applications
- **Professional setup** - Enterprise-grade configuration

This is the **final, permanent partition scheme** ready for your production system!
