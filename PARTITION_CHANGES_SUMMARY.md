# Partition Changes Summary - Free Space & Downloads Added

## Quick Overview

```
MAJOR CHANGES:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. ✅ SPLIT /var/lib/docker:
   Before: 648GB monolithic Docker partition
   After:  350GB (Docker images) + 300GB (Downloads)

2. ✅ REDUCED other partitions:
   /, /backup, /home, /workspace, /docker-data all reduced

3. ✅ RESERVED FREE SPACE:
   NVME1: 93GB free (9.3%) ← Critical for Btrfs operations
   NVME2: 90GB free (9%)   ← Critical for Btrfs operations

4. ✅ NEW PARTITION:
   /downloads (300GB) ← For downloads, ISOs, temporary files
```

---

## Before vs After Comparison

### NVME 1 (System + Backups + Docker)

```
BEFORE (No free space - BAD for Btrfs):
╔════════════════════════════════════════════════════════════════════╗
│ p1: /boot      p2: /    p3: /backup    p4: /var/lib/docker       │
│ 2GB           150GB     200GB          648GB                      │
│                                        Total: 1000GB (100% full!) │
╚════════════════════════════════════════════════════════════════════╝
⚠️ Issues:
  • Zero free space for Btrfs operations
  • Can't create new chunks
  • Balance operations may fail
  • Performance degradation
  • No emergency buffer


AFTER (With optimal free space - GOOD for Btrfs):
╔════════════════════════════════════════════════════════════════════╗
│ p1   p2    p3      p4        p5            FREE SPACE             │
│/boot  /   /back /docker/downloads         (Btrfs buffer)         │
│ 2GB 135GB 120GB   350GB    300GB          93GB (9.3%)            │
│                   Total allocated: 907GB  |                      │
│                   Total capacity: 1000GB  |                      │
╚════════════════════════════════════════════════════════════════════╝
✅ Benefits:
  • 93GB free for Btrfs chunk creation
  • Allows balance operations
  • Maintains performance
  • Emergency buffer space
  • Proper fragmentation handling
```

### NVME 2 (Permanent Storage)

```
BEFORE (No free space - BAD for Btrfs):
╔════════════════════════════════════════════════════════════════════╗
│ p1: /home  p2: /workspace  p3: /obsidian  p4: /docker-data       │
│ 150GB      400GB           100GB           350GB                  │
│                            Total: 1000GB (100% full!)             │
╚════════════════════════════════════════════════════════════════════╝
⚠️ Issues:
  • Zero free space
  • Performance degradation
  • Btrfs operations compromised
  • No safety buffer


AFTER (With optimal free space - GOOD for Btrfs):
╔════════════════════════════════════════════════════════════════════╗
│ p1      p2         p3         p4              FREE SPACE           │
│/home  /workspace /obsidian /docker-data     (Btrfs buffer)        │
│135GB   360GB     100GB     315GB            90GB (9%)             │
│                  Total allocated: 910GB  |                       │
│                  Total capacity: 1000GB  |                       │
╚════════════════════════════════════════════════════════════════════╝
✅ Benefits:
  • 90GB free for Btrfs operations
  • Better performance
  • Safer operations
  • Room for expansion
```

---

## Detailed Changes Table

| Component | Before | After | Change | Reason |
|-----------|--------|-------|--------|--------|
| **NVME1 p1: /boot** | 2 GB | 2 GB | - | No change |
| **NVME1 p2: /** | 150 GB | 135 GB | -15 GB | Free space allocation |
| **NVME1 p3: /backup** | 200 GB | 120 GB | -80 GB | 20-25 snapshots sufficient |
| **NVME1 p4: /var/lib/docker** | 648 GB | 350 GB | -298 GB | Split with downloads |
| **NVME1 p5: /downloads** | - | 300 GB | +300 GB | NEW: Downloads partition |
| **NVME1 Free Space** | 0 GB | 93 GB | **+93 GB** | **✓ Critical** |
| | | | | |
| **NVME2 p1: /home** | 150 GB | 135 GB | -15 GB | Free space allocation |
| **NVME2 p2: /workspace** | 400 GB | 360 GB | -40 GB | Free space allocation |
| **NVME2 p3: /obsidian** | 100 GB | 100 GB | - | No change needed |
| **NVME2 p4: /docker-data** | 350 GB | 315 GB | -35 GB | Free space allocation |
| **NVME2 Free Space** | 0 GB | 90 GB | **+90 GB** | **✓ Critical** |

---

## Why Each Reduction?

### /boot remains 2GB
```
Why: No change needed
  • Bootloader is tiny
  • Kernels: ~100MB each
  • 2GB holds 20+ kernels
  • Never gets full
```

### / reduced 150GB → 135GB
```
Why: Arch base + apps don't need 150GB
  • Arch base: 1-2 GB
  • Pacman cache: 1-5 GB (can be cleaned)
  • Common apps: 20-40 GB
  • System files: 5-10 GB
  • 135GB provides 100GB free after apps
  • Still plenty of room
```

### /backup reduced 200GB → 120GB
```
Why: Snapshot retention doesn't need 200GB
  Before:
    • 30 daily snapshots @ 5GB each = 150GB max
    • Way over-provisioned
  After:
    • 120GB holds 20-25 snapshots
    • Auto-cleanup removes old ones
    • Still enough for recovery
    • Older images uploaded elsewhere
```

### /var/lib/docker split 648GB → 350GB
```
Why: Docker images != Downloads
  Problem:
    • Mixed images + downloads
    • Hard to manage separately
    • Can't limit image growth independently
  Solution:
    • p4 (350GB): Docker images only
    • p5 (300GB): Downloads + ISOs + temp files
    • Separate mount points
    • Each can be managed independently
```

### /home reduced 150GB → 135GB
```
Why: User config files are small
  Typical /home usage:
    • .bashrc, .config: 500MB
    • .local/share/mise (runtimes): 20-50GB
    • .ssh, .gnupg: 100KB
    • Desktop files: 1-5GB
  135GB provides:
    • 100GB for runtimes
    • 35GB buffer
    • Still excessive
```

### /workspace reduced 400GB → 360GB
```
Why: Project code doesn't need 400GB
  Typical /workspace:
    • Project folders: 50-200GB
    • Git history: 20-50GB
    • node_modules: 30-100GB
  360GB provides:
    • Plenty for 10+ projects
    • Room for growth
    • Still 40GB buffer
```

### /docker-data reduced 350GB → 315GB
```
Why: Database files + volumes
  Typical /docker-data:
    • PostgreSQL: 5-20GB
    • MySQL: 5-20GB
    • MongoDB: 5-20GB
    • Redis: 1-5GB
    • App data: 10-50GB
    • Backups: 20-50GB
  315GB provides:
    • 100GB+ data capacity
    • Room for multiple databases
    • Backup storage included
```

---

## Btrfs Free Space Importance

### From Context7 (Btrfs Documentation)

Free space is critical for:

```
1. CHUNK ALLOCATION
   Btrfs divides disk into chunks (1GB by default)
   New chunks created only when:
     • Current chunks full
     • Free space available
   
   Problem (0% free): Stuck with existing chunks
   Solution (10% free): Can allocate new chunks

2. BALANCE OPERATIONS
   Balance redistributes data across chunks
   Requires working space
   
   Problem (0% free): Can't balance
   Solution (10% free): Balance works smoothly

3. COW (Copy-on-Write) OVERHEAD
   New data written to new locations
   Old blocks freed after sync
   
   Problem (0% free): COW can't complete
   Solution (10% free): COW operations succeed

4. FRAGMENTATION HANDLING
   Prevents disk from becoming unusable
   Allows defrag/rebalance operations
   
   Problem (0% free): Fragmentation issues
   Solution (10% free): Stays defragmented
```

### Recommended Free Space

```
Btrfs Filesystem Usage Output (from docs):
    Device size:                1.82TiB
    Device allocated:           1.17TiB
    Device unallocated:       669.99GiB  ← FREE SPACE!
    
    Free (estimated):          692.57GiB
    
This shows:
  • 37% unallocated space (excellent)
  • Filesystem operates smoothly
  • Balance operations work
  • Performance maintained
```

---

## New /downloads Partition (300GB)

```
Purpose:
  ✓ Large file downloads (ISOs, installers)
  ✓ Media files (movies, music, podcasts)
  ✓ Temporary extraction/working space
  ✓ Application cache files
  ✓ Torrent downloads
  ✓ Archive files

Directory Structure:
/downloads/
├── Browser/          (browser downloads)
├── ISOs/             (Linux, tools)
├── Packages/         (AUR, tarballs)
├── Media/            (movies, shows, music)
├── Archives/         (ZIP, RAR, TAR)
├── Torrents/         (torrent files)
└── Temporary/        (temp extraction)

Size: 300GB
  • Enough for 10+ Linux ISOs
  • Enough for 50+ hours of HD movies
  • Plenty of room for temporary files

Can be deleted: YES (partially)
  • Keep ISOs, delete movies
  • Clean out browser downloads
  • Remove old archive files
  • Purge temporary extraction folders

Why 300GB:
  • Not too large (350GB+)
  • Not too small (100GB)
  • Leaves room for growth
  • Balanced with free space
```

---

## Total Capacity Accounting

### NVME 1 (1000 GB total)

| Component | Size | Percentage |
|-----------|------|-----------|
| /boot | 2 GB | 0.2% |
| / | 135 GB | 13.5% |
| /backup | 120 GB | 12% |
| /var/lib/docker | 350 GB | 35% |
| /downloads | 300 GB | 30% |
| **Free (Btrfs)** | **93 GB** | **9.3%** |
| **Total** | **1000 GB** | **100%** |

### NVME 2 (1000 GB total)

| Component | Size | Percentage |
|-----------|------|-----------|
| /home | 135 GB | 13.5% |
| /workspace | 360 GB | 36% |
| /obsidian | 100 GB | 10% |
| /docker-data | 315 GB | 31.5% |
| **Free (Btrfs)** | **90 GB** | **9%** |
| **Total** | **1000 GB** | **100%** |

---

## Files Updated

### Scripts
- ✅ `setup_disks.sh`
  - Updated partition sizes
  - Added p5 (/downloads) handling
  - Updated logging messages
  - Updated subvolume creation

### Configuration
- ✅ `fstab-template`
  - Added /downloads mount entry
  - Updated all mount options
  - Updated comments with free space info

### Documentation
- ✅ `PARTITION_SPEC_REVISED_WITH_FREESPACE.md` (NEW)
  - Complete revised specification
  - Visual layouts
  - Partition creation commands
  - fstab configuration
  - Btrfs best practices

---

## Quick Reference Commands

### Check Current Layout
```bash
# Partition layout
lsblk

# Disk usage
df -h

# Btrfs filesystem info
sudo btrfs filesystem show

# Detailed Btrfs usage
sudo btrfs filesystem usage /
```

### Monitor Free Space
```bash
# Watch free space grow/shrink
watch -n 5 df -h /

# Btrfs device usage
sudo btrfs device usage /

# Unallocated space info
sudo btrfs filesystem usage / | grep Unallocated
```

### Perform Balance (if needed)
```bash
# Full rebalance (may take time)
sudo btrfs balance start /

# Check balance progress
sudo btrfs balance status /

# Cancel balance
sudo btrfs balance cancel /
```

---

## Migration Strategy (If You Already Have Old Partitions)

### Option 1: Fresh Install (Recommended)
```bash
1. Boot Arch USB
2. Run: sudo bash install/setup_disks.sh
3. Follow prompts for new partition scheme
4. Proceed with pacstrap and installation
```

### Option 2: Resize Existing (Advanced)
```bash
# WARNING: Risky! Backup everything first!

1. Boot Arch USB with GParted
2. Shrink /var/lib/docker from 648GB to 350GB
3. Create new partition p5 with freed 298GB
4. Format new partition: mkfs.btrfs -f /dev/nvme0n1p5
5. Mount and test

# This is complex - fresh install is safer!
```

---

## Benefits Summary

✅ **Better Btrfs Performance**
  • Free space allows chunk creation
  • Balance operations work
  • COW operations complete
  • Fragmentation managed

✅ **Improved Organization**
  • Downloads separate from Docker
  • Each partition has clear purpose
  • Easier to manage and monitor
  • Cleaner filesystem structure

✅ **More Flexibility**
  • Can manage Docker images independently
  • Can manage downloads independently
  • Easy to clean up downloads
  • Easy to expand later

✅ **Safety**
  • Emergency buffer space
  • Can survive disk errors
  • Room for unexpected growth
  • Proper headroom for operations

✅ **Scalability**
  • Can handle more Docker images
  • Can store more downloads
  • 93GB + 90GB = 183GB total buffer
  • Plenty of room for expansion

---

## Summary

This revision provides:

1. **Split Docker storage**: 350GB (images) + 300GB (downloads)
2. **Free space on both drives**: 93GB (9.3%) + 90GB (9%)
3. **Btrfs-optimal configuration**: Follows best practices
4. **Better organization**: Clear partition purposes
5. **Improved reliability**: Emergency buffer space
6. **Future-proof**: Room for growth

The new layout is **production-ready and follows Btrfs best practices**!
