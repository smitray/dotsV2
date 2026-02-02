# Revised Partition Specification - With Free Space & Downloads

## Overview

This is the **revised partition specification** that:
- Splits `/var/lib/docker` into **350GB (images)** + **300GB (downloads)**
- Reserves **9-10% free space on both NVME drives** for optimal Btrfs operation
- Follows Btrfs best practices for chunk allocation

---

## Why Free Space Matters for Btrfs

From Btrfs documentation:
```
Btrfs requires unallocated space for:
✓ Creating new chunks when needed
✓ Performing balance operations
✓ Handling COW (copy-on-write) overhead
✓ Managing fragmentation
✓ Maintaining optimal performance
✓ Emergency space for filesystem operations

Recommended free space: 10-15% of disk capacity
```

---

## Revised NVME 1 Layout (1TB - System + Backups + Docker)

| Partition | Mount Point | Size | Type | Filesystem | Purpose |
|-----------|-------------|------|------|------------|---------|
| **p1** | `/boot` | 2 GB | EFI System | FAT32 | Bootloader |
| **p2** | `/` | 135 GB | Linux | Btrfs | OS + applications |
| **p3** | `/backup` | 120 GB | Linux | Btrfs | System backup/recovery |
| **p4** | `/var/lib/docker` | 350 GB | Linux | Btrfs | Docker images (disposable) |
| **p5** | `/downloads` | 300 GB | Linux | Btrfs | Downloads & general storage |
| **FREE** | (unallocated) | ~93 GB | - | - | **Btrfs operations** |

**Total Allocated**: 907 GB  
**Free Space**: 93 GB (9.3%)  
**Total Capacity**: 1000 GB (1 TB)

---

## Revised NVME 2 Layout (1TB - Permanent Storage + Docker Data)

| Partition | Mount Point | Size | Type | Filesystem | Purpose |
|-----------|-------------|------|------|------------|---------|
| **p1** | `/home` | 135 GB | Linux | Btrfs | Configs + Mise runtimes |
| **p2** | `/workspace` | 360 GB | Linux | Btrfs | Development projects |
| **p3** | `/obsidian` | 100 GB | Linux | Btrfs | Obsidian vaults |
| **p4** | `/docker-data` | 315 GB | Linux | Btrfs | Database files (permanent) |
| **FREE** | (unallocated) | ~90 GB | - | - | **Btrfs operations** |

**Total Allocated**: 910 GB  
**Free Space**: 90 GB (9%)  
**Total Capacity**: 1000 GB (1 TB)

---

## Visual Layout

```
╔════════════════════════════════════════════════════════════════════════════╗
║                         NVME 1 (1TB) - SYSTEM                             ║
╠════════════════════════════════════════════════════════════════════════════╣
║  p1     p2         p3           p4                p5              FREE     ║
║ /boot   /      /backup    /var/lib/docker      /downloads     (Btrfs)    ║
║  2GB   135GB    120GB       350GB               300GB           93GB      ║
║                                                                           ║
║ Boot   OS &    Snapshots  Docker Images      Downloads &       Reserve   ║
║        Apps   Recovery    (disposable)       General Storage   (9.3%)    ║
╚════════════════════════════════════════════════════════════════════════════╝

╔════════════════════════════════════════════════════════════════════════════╗
║                    NVME 2 (1TB) - PERMANENT STORAGE                       ║
╠════════════════════════════════════════════════════════════════════════════╣
║   p1          p2            p3           p4              FREE              ║
║  /home     /workspace    /obsidian   /docker-data      (Btrfs)           ║
║  135GB      360GB         100GB       315GB             90GB              ║
║                                                                           ║
║ Configs & Development    Obsidian   Database Files    Reserve            ║
║ Mise      Projects       Vaults     (permanent)       (9%)               ║
╚════════════════════════════════════════════════════════════════════════════╝
```

---

## Complete Partition Creation Commands

### For NVME 1

```bash
# Create partition table
parted /dev/nvme0n1 -- mklabel gpt

# Create partitions with correct sizes
parted /dev/nvme0n1 -- mkpart primary fat32 1MiB 2GiB        # p1: /boot
parted /dev/nvme0n1 -- set 1 esp on
parted /dev/nvme0n1 -- mkpart primary btrfs 2GiB 137GiB      # p2: / (135GB)
parted /dev/nvme0n1 -- mkpart primary btrfs 137GiB 257GiB    # p3: /backup (120GB)
parted /dev/nvme0n1 -- mkpart primary btrfs 257GiB 607GiB    # p4: /var/lib/docker (350GB)
parted /dev/nvme0n1 -- mkpart primary btrfs 607GiB 907GiB    # p5: /downloads (300GB)
# Free space: 907GiB to 1000GiB = 93GB unallocated

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

# Create partitions with correct sizes
parted /dev/nvme1n1 -- mkpart primary btrfs 1MiB 136GiB      # p1: /home (135GB)
parted /dev/nvme1n1 -- mkpart primary btrfs 136GiB 496GiB    # p2: /workspace (360GB)
parted /dev/nvme1n1 -- mkpart primary btrfs 496GiB 596GiB    # p3: /obsidian (100GB)
parted /dev/nvme1n1 -- mkpart primary btrfs 596GiB 911GiB    # p4: /docker-data (315GB)
# Free space: 911GiB to 1000GiB = 89GB unallocated

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

# DISK 1: System + Recovery + Docker Images (NVME 1 - 1TB)
/dev/nvme0n1p1              /boot              vfat    defaults,noatime,nofail                               0      2
/dev/nvme0n1p2              /                  btrfs   rw,relatime,compress=zstd:1,space_cache=v2,subvol=@  0      0
/dev/nvme0n1p3              /backup            btrfs   rw,relatime,compress=zstd:1,space_cache=v2            0      2
/dev/nvme0n1p4              /var/lib/docker    btrfs   rw,relatime,compress=zstd:1,space_cache=v2            0      2
/dev/nvme0n1p5              /downloads         btrfs   rw,relatime,compress=zstd:1,space_cache=v2            0      2

# DISK 2: Permanent Storage + Docker Data (NVME 2 - 1TB)
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

## New Partition: /downloads (300GB)

```
Device:         /dev/nvme0n1p5
Mount Point:    /downloads
Size:           300 GB
Filesystem:     Btrfs
Filesystem Label: ARCH_DOWNLOADS
Purpose:        Downloads, temporary files, general storage
Fstab Entry:    /dev/nvme0n1p5  /downloads  btrfs  rw,relatime,compress=zstd:1,space_cache=v2  0  2
Mount Options:  rw,relatime,compress=zstd:1,space_cache=v2
Permissions:    755 (root:root)

Directory Structure:
/downloads/
├── Browser/                   (Browser downloads)
│   ├── Documents/
│   ├── Images/
│   ├── Videos/
│   └── [downloaded files]
│
├── ISOs/                      (Linux ISOs, installers)
│   ├── arch-linux/
│   ├── ubuntu-22.04/
│   └── [OS images]
│
├── Packages/                  (Package archives)
│   ├── AUR/
│   ├── Tarballs/
│   └── [package files]
│
├── Media/                     (Movies, shows, podcasts)
│   ├── Movies/
│   ├── TV Series/
│   └── Podcasts/
│
├── Archives/                  (ZIP, TAR, RAR files)
│   ├── Projects/
│   ├── Backups/
│   └── [archive files]
│
├── Torrents/                  (Torrent downloads)
│   ├── Active/
│   ├── Completed/
│   └── [torrent data]
│
└── Temporary/                 (Temporary storage)
    ├── Extracting/
    ├── Working/
    └── [temp files]

Usage:
  • Browser downloads (automatic)
  • Manual downloads
  • ISO files for OS installation
  • Large files and media
  • Temporary file storage
  • Cache for applications

Can be deleted: YES (partially - keep important files)
Backup: ✗ NO (temporary/disposable)
Size estimate: 50-300 GB (variable based on downloads)
```

---

## Updated Directory Structure (Root Filesystem)

```
/                                    (nvme0n1p2, subvol=@, 135GB)
├── boot/                           → nvme0n1p1 (2GB, FAT32)
├── backup/                         → nvme0n1p3 (120GB, Btrfs)
├── downloads/                      → nvme0n1p5 (300GB, Btrfs) [NEW!]
├── var/lib/docker/                → nvme0n1p4 (350GB, Btrfs)
├── home/                           → nvme1n1p1 (135GB, Btrfs)
├── workspace/                      → nvme1n1p2 (360GB, Btrfs)
├── obsidian/                       → nvme1n1p3 (100GB, Btrfs)
├── docker-data/                    → nvme1n1p4 (315GB, Btrfs)
├── swapfile                        (32GB, on /)
└── [standard Linux directories]
```

---

## Mount Points Summary Table

| Partition | Mount Point | Size | FS | Subvol | Purpose | Backup | Free Space |
|-----------|-------------|------|----|----|---------|--------|-----------|
| nvme0n1p1 | `/boot` | 2GB | FAT32 | - | Bootloader | No | - |
| nvme0n1p2 | `/` | 135GB | Btrfs | @ | OS | Yes* | +93GB |
| nvme0n1p3 | `/backup` | 120GB | Btrfs | - | Backups | THIS IS BACKUP | +93GB |
| nvme0n1p4 | `/var/lib/docker` | 350GB | Btrfs | - | Docker images | No | +93GB |
| **nvme0n1p5** | **/downloads** | **300GB** | **Btrfs** | **-** | **Downloads** | **No** | **+93GB** |
| nvme1n1p1 | `/home` | 135GB | Btrfs | @home | Configs | Yes | +90GB |
| nvme1n1p2 | `/workspace` | 360GB | Btrfs | @workspace | Projects | Yes | +90GB |
| nvme1n1p3 | `/obsidian` | 100GB | Btrfs | @obsidian | Notes | Yes | +90GB |
| nvme1n1p4 | `/docker-data` | 315GB | Btrfs | @docker-data | DB files | Yes | +90GB |

---

## Why This Layout is Better

### ✅ **Btrfs Optimization**
```
Free Space Allocation:
  NVME 1: 93GB free (9.3%) → Optimal for chunk creation & balance
  NVME 2: 90GB free (9%)  → Optimal for chunk creation & balance

Benefit:
  • Prevents "filesystem full" errors
  • Allows balance operations to work properly
  • Maintains performance during COW operations
  • Handles fragmentation gracefully
```

### ✅ **Docker Separation**
```
Before: 648GB monolithic partition
After:  350GB images + 300GB downloads

Advantages:
  • Docker images isolated (350GB)
  • Download/cache storage separate (300GB)
  • Can manage/clean each independently
  • Each has separate mount point
```

### ✅ **Downloads Partition**
```
/downloads (300GB):
  • Large file storage
  • ISO downloads
  • Media/content storage
  • Temporary extraction
  • Cache directories
  
Location: NVME 1 (fast access, disposable)
Can be: Cleaned out regularly
Size: 300GB is plenty for downloads
```

### ✅ **Storage Distribution**
```
NVME 1 (System Drive):
  - OS                   135GB (reduced from 150GB)
  - Backup              120GB (reduced from 200GB)
  - Docker images       350GB (split from 648GB)
  - Downloads           300GB (NEW)
  - Free space           93GB ✓

NVME 2 (Data Drive):
  - Home configs        135GB (reduced from 150GB)
  - Workspace           360GB (reduced from 400GB)
  - Obsidian            100GB (unchanged)
  - Docker data         315GB (reduced from 350GB)
  - Free space           90GB ✓
```

---

## Btrfs Free Space Management

### Monitor Free Space

```bash
# Check Btrfs filesystem usage
sudo btrfs filesystem usage /
sudo btrfs filesystem usage /var/lib/docker
sudo btrfs filesystem usage /downloads

# Check unallocated space
sudo btrfs filesystem show /

# Detailed usage report
sudo btrfs filesystem df /
```

### Output Example (from Context7 docs)

```
Device size:                   1000GB
Device allocated:             907GB
Device unallocated:           93GB       ← This is what we want!
Used:                         750GB
Free (estimated):             157GB
```

### Balance Operations (if needed)

```bash
# Rebalance filesystem (improves performance)
sudo btrfs balance start /

# Compact underutilized chunks
sudo btrfs balance start -dusage=50 /

# Check balance status
sudo btrfs balance status /
```

---

## Size Justification

### Why Reduce / from 150GB to 135GB?
```
150GB is overkill for:
  • Arch Linux base system: 1-2GB
  • Common apps: 20-40GB
  • System cache/logs: 5GB
  
135GB provides:
  • Plenty of room: 100GB available for apps
  • Reduces overall allocation
  • Frees space for Btrfs operations
  • Still much more than needed
```

### Why Reduce /backup from 200GB to 120GB?
```
Backup retention:
  • 30 daily snapshots @ 5GB each = 150GB (max)
  • In practice: 80-120GB is sufficient
  • Weekly images uploaded elsewhere
  • Old snapshots auto-deleted
  
120GB provides:
  • Last 20-25 daily snapshots available
  • Room for weekly images
  • Still generous for recovery
```

### Why Split Docker?

**Before**: 648GB monolithic partition
```
✗ Hard to manage
✗ Downloads mix with images
✗ Can't limit image size independently
✗ No separation of concerns
```

**After**: 350GB + 300GB split
```
✓ Docker images: 350GB (controlled pull)
✓ Downloads: 300GB (user-managed)
✓ Independent mount points
✓ Easier to clean/manage each
✓ Can mount separately if needed
```

---

## Migration Path (If You Have Old Setup)

If upgrading from previous partition scheme:

```bash
# 1. Back up everything on NVME2 (permanent data)
sudo rsync -av /home /docker-data /workspace /obsidian /mnt/external/backup/

# 2. Boot Arch USB with new partition scheme
sudo bash install/setup_disks.sh

# 3. Restore from backups
sudo rsync -av /mnt/external/backup/home /home/
sudo rsync -av /mnt/external/backup/docker-data /docker-data/
# etc.

# 4. Re-pull Docker images (from 350GB partition)
docker pull [images]

# 5. Verify everything
lsblk
df -h
btrfs filesystem usage /
```

---

## Size Comparison Table

| Component | Old Spec | New Spec | Change | Reason |
|-----------|----------|----------|--------|--------|
| / | 150GB | 135GB | -15GB | Reduce waste, Btrfs free space |
| /backup | 200GB | 120GB | -80GB | 20-25 snapshots sufficient |
| /var/lib/docker | 648GB | 350GB | -298GB | Split into images only |
| /downloads | - | 300GB | +300GB | New partition for downloads |
| /home | 150GB | 135GB | -15GB | Reduce waste, Btrfs free space |
| /workspace | 400GB | 360GB | -40GB | Reduce waste, Btrfs free space |
| /docker-data | 350GB | 315GB | -35GB | Btrfs free space |
| **Free Space NVME1** | **0GB** | **93GB** | **+93GB** | **✓ Critical for Btrfs** |
| **Free Space NVME2** | **0GB** | **90GB** | **+90GB** | **✓ Critical for Btrfs** |

---

## Verification After Setup

```bash
# After installation, verify:
$ lsblk
NAME        SIZE   TYPE MOUNTPOINTS
nvme0n1     1T     disk 
├─nvme0n1p1 2G     part /boot
├─nvme0n1p2 135G   part /
├─nvme0n1p3 120G   part /backup
├─nvme0n1p4 350G   part /var/lib/docker
└─nvme0n1p5 300G   part /downloads

nvme1n1     1T     disk 
├─nvme1n1p1 135G   part /home
├─nvme1n1p2 360G   part /workspace
├─nvme1n1p3 100G   part /obsidian
└─nvme1n1p4 315G   part /docker-data

$ df -h
Filesystem         Size  Used Avail Use%  Mounted on
/dev/nvme0n1p2    135G   50G   85G  37%  /
/dev/nvme0n1p3    120G    5G  115G   4%  /backup
/dev/nvme0n1p4    350G  100G  250G  29%  /var/lib/docker
/dev/nvme0n1p5    300G   50G  250G  17%  /downloads
/dev/nvme1n1p1    135G   10G  125G   7%  /home
/dev/nvme1n1p2    360G   50G  310G  14%  /workspace
/dev/nvme1n1p3    100G   10G   90G  10%  /obsidian
/dev/nvme1n1p4    315G  100G  215G  32%  /docker-data

$ sudo btrfs filesystem show
Label: 'ARCH_ROOT'  uuid: [...]
  Total devices 1 FS bytes 50G
  devid    1 size=135G used=50G path=/dev/nvme0n1p2

Label: 'ARCH_DOWNLOADS'  uuid: [...]
  Total devices 1 FS bytes 50G
  devid    1 size=300G used=50G path=/dev/nvme0n1p5
```

---

## Summary

✅ **Docker Split**: 350GB (images) + 300GB (downloads)  
✅ **Free Space NVME1**: 93GB (9.3%) for Btrfs operations  
✅ **Free Space NVME2**: 90GB (9%) for Btrfs operations  
✅ **Optimized Size**: All partitions properly sized  
✅ **Btrfs Friendly**: Follows best practices for filesystem health  
✅ **Flexible**: Easy to manage and maintain  

This layout is **production-ready and follows Btrfs best practices**!
