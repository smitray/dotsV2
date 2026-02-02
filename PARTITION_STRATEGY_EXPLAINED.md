# Partition Strategy Explained

## 🎯 The Core Concept

You have **TWO physical hard drives** (called "sticks" or NVMe drives):
- **DISK 1** = `/dev/nvme0n1` (System & Persistent Data) - 1TB
- **DISK 2** = `/dev/nvme1n1` (Home, Workspace, Archive) - 1TB

Each disk is divided into **3 partitions**.

---

## 📊 Complete Partition Table Visualization

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                           YOUR TWO PHYSICAL DRIVES                           ║
╚══════════════════════════════════════════════════════════════════════════════╝

┌──────────────────────────────────────────────────────────────────────────────┐
│ DISK 1: /dev/nvme0n1 (First Physical Drive - 1TB - SYSTEM & PERSISTENT)     │
└──────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────┐  ┌──────────────────┐  ┌─────────────────────────┐
    │ nvme0n1p1   │  │ nvme0n1p2        │  │ nvme0n1p3               │
    │             │  │                  │  │                         │
    │   /boot     │  │       /          │  │    /persistent          │
    │             │  │                  │  │                         │
    │   2 GB      │  │    500 GB        │  │    498 GB               │
    │   FAT32     │  │    Btrfs         │  │    Btrfs                │
    │             │  │                  │  │                         │
    │ Bootloader  │  │ Operating System │  │ User Directories        │
    │ & Kernels   │  │ Root Filesystem  │  │ Downloads, Documents,   │
    │             │  │ Applications     │  │ Desktop, Music, Videos  │
    └─────────────┘  └──────────────────┘  └─────────────────────────┘
         2GB              500GB                      498GB
      └──────────────────────────────────────────────────────────────┘
                    Total: ~1000GB (1TB)


┌──────────────────────────────────────────────────────────────────────────────┐
│ DISK 2: /dev/nvme1n1 (Second Physical Drive - 1TB - HOME, WORK, ARCHIVE)   │
└──────────────────────────────────────────────────────────────────────────────┘

    ┌──────────────┐  ┌──────────────────┐  ┌─────────────────────┐
    │ nvme1n1p1    │  │ nvme1n1p2        │  │ nvme1n1p3           │
    │              │  │                  │  │                     │
    │    /home     │  │   /workspace     │  │      /data          │
    │              │  │                  │  │                     │
    │   150 GB     │  │    400 GB        │  │    450 GB           │
    │   Btrfs      │  │    Btrfs         │  │    Btrfs            │
    │              │  │                  │  │                     │
    │ User Configs │  │ Development      │  │ Games, Media,       │
    │ Dotfiles     │  │ Projects         │  │ VMs, Backups        │
    │ .config/     │  │ Node, Python,    │  │ Archive Storage     │
    │ .local/      │  │ Bun, mise        │  │                     │
    └──────────────┘  └──────────────────┘  └─────────────────────┘
        150GB              400GB                     450GB
      └──────────────────────────────────────────────────────────────┘
                    Total: ~1000GB (1TB)
```

---

## 🔍 What Each Partition Stores

### **DISK 1 Partitions**

#### **nvme0n1p1 - /boot (2GB) - FAT32**
- **What**: Bootloader and Linux kernels
- **Who accesses**: Only during system startup
- **Why separate**: Recovery from a bootable USB if needed
- **Backup needed**: NO (rarely changes, can be regenerated)
- **Snapshot**: NO (Snapper doesn't work here - it's FAT32, not Btrfs)

#### **nvme0n1p2 - / (500GB) - Btrfs - ROOT FILESYSTEM**
- **What**: 
  - Linux kernel
  - System libraries (/lib, /usr)
  - System binaries (/bin, /sbin)
  - Package manager database
  - System configuration (/etc)
  - Installed applications
- **Who accesses**: System and all applications
- **Why separate**: Need to protect against broken updates or crashes
- **Backup needed**: YES (critical for system stability)
- **Snapshot**: YES ✅ (Snapper creates snapshots here)
- **When**: 
  - Automatically before/after `pacman -S` (package install)
  - Hourly automatic snapshots
  - Manual snapshots before risky changes
- **Rollback example**: If update breaks system, rollback to previous snapshot

---

#### **nvme0n1p3 - /persistent (498GB) - Btrfs**
- **What**: 
  - ~/Desktop
  - ~/Documents
  - ~/Downloads
  - ~/Music
  - ~/Pictures
  - ~/Videos
  - ~/Projects
- **Who accesses**: YOU (personal user data)
- **Why separate**: Personal data shouldn't be affected by system reinstalls
- **Backup needed**: YES (your important data)
- **Snapshot**: ❌ **NO - NOT BACKED UP BY SNAPPER**
- **Why NOT snapper**: 
  - This is YOUR personal data, not system data
  - Snapper is for system recovery (rolling back broken updates)
  - Personal data should be backed up EXTERNALLY (USB, cloud, external drive)
  - If system breaks, you still have your data intact
  - If you delete a file, Snapper won't help (it's for system snapshots, not personal file recovery)

**⚠️ IMPORTANT**: `/persistent` is **PRESERVED** when you reinstall the system!
- If system is broken → Reinstall OS
- Your downloads, documents, projects are STILL THERE (different partition)

---

### **DISK 2 Partitions**

#### **nvme1n1p1 - /home (150GB) - Btrfs**
- **What**: 
  - User configurations (~/. config)
  - User local data (~/.local)
  - User cache (~/. cache)
  - Dotfiles
  - Application configs
- **Who accesses**: Your login user account
- **Why separate**: Config data survives system reinstalls
- **Backup needed**: YES (your configurations are valuable)
- **Snapshot**: ❌ **NO**
- **Why**: Personal config data (not system). Backup externally if concerned.

---

#### **nvme1n1p2 - /workspace (400GB) - Btrfs**
- **What**: 
  - Development projects (git repos)
  - Source code (Node, Python, JavaScript)
  - Development environments (mise, runtimes)
  - Work-in-progress projects
- **Who accesses**: You (developer)
- **Why separate**: Easy to manage development separately from system
- **Backup needed**: YES (your code is valuable!)
- **Snapshot**: ❌ **NO**
- **Why**: Code should be in git (version control), not filesystem snapshots
- **Better approach**: Push to GitHub/GitLab regularly

---

#### **nvme1n1p3 - /data (450GB) - Btrfs**
- **What**: 
  - Games
  - ISO files
  - Virtual machine images
  - Media (if too large for /persistent)
  - Archive/backups
- **Who accesses**: You (bulk storage)
- **Why separate**: Keep archive data separate from active system
- **Backup needed**: OPTIONAL (depends on content)
- **Snapshot**: ❌ **NO**

---

## 🎯 Snapshot vs Backup - What's the Difference?

### **SNAPPER (Snapshots)** - System Recovery ✅
- **Purpose**: Rollback system if broken
- **What it backs up**: `/` partition (operating system)
- **Frequency**: Automatic (hourly, before updates)
- **Retention**: Keeps last 10-20 snapshots
- **Recovery**: Boot from snapshot, system restored
- **Example**: Package update breaks system → Rollback → System works again

```
Timeline:
08:00 - System working (Snapshot 1)
09:00 - Automatic snapshot (Snapshot 2)
10:00 - Run pacman -S package
10:05 - System broken ❌
10:06 - Rollback to Snapshot 2
10:07 - System working ✅
```

### **EXTERNAL BACKUP** - Personal Data Protection ❌ NOT IMPLEMENTED YET
- **Purpose**: Protect YOUR files (documents, photos, code)
- **What it backs up**: `/home`, `/persistent`, `/workspace`, `/data`
- **Frequency**: Weekly/monthly (your choice)
- **Retention**: Multiple versions kept
- **Storage**: External USB drive, cloud, external drive
- **Recovery**: If deleted or corrupted, restore from backup
- **Example**: Accidentally delete important document → Restore from backup

```
Timeline:
Monday    - Create backup on USB drive
Wednesday - Accidentally delete file ❌
Thursday  - Restore from Monday's backup ✅
```

---

## ❓ WHY NOT BACKUP /persistent WITH SNAPPER?

### The Philosophy:

**Snapper is for SYSTEM backups, not DATA backups.**

```
System Partitions (backed up by Snapper):
├─ / (root)           ← OS, libraries, apps → If broken, rollback
├─ /boot              ← Kernels, bootloader → Recovery
└─ REASON: Need to recover from broken system updates

Personal Partitions (NOT backed up by Snapper):
├─ /persistent        ← Your downloads, documents, photos
├─ /home              ← Your configs, dotfiles
├─ /workspace         ← Your code projects
└─ /data              ← Your media, games, archives
└─ REASON: Need external backup (USB, cloud, external drive)
```

### Scenario 1: System Update Breaks
```
Problem: pacman -S major-update breaks system
Solution: Snapper rollback (on / partition)
Result: System works, /persistent/Downloads still intact ✅
```

### Scenario 2: You Delete File Accidentally
```
Problem: rm -rf ~/Downloads/important-file.zip
Snapper helps: NO ❌ (only tracks system changes, not your files)
Solution: External backup (USB, cloud, etc.)
Result: Restore from backup ✅
```

### Scenario 3: Disk Failure
```
Problem: nvme0n1p3 (/persistent) fails
Snapper helps: NO ❌ (only on / partition)
Solution: External backup (separate physical device)
Result: Restore from backup ✅
```

---

## 🛡️ COMPLETE BACKUP STRATEGY

### **What IS Protected by Snapper**
```
nvme0n1p2 (/)  ✅ Snapper snapshots
  ├─ System files
  ├─ Applications
  ├─ Libraries
  └─ Can rollback if broken
```

### **What SHOULD Be Protected by External Backup**
```
nvme0n1p3 (/persistent)  ← Your files (need external backup)
nvme1n1p1 (/home)         ← Your configs (need external backup)
nvme1n1p2 (/workspace)    ← Your code (use git + external backup)
nvme1n1p3 (/data)         ← Your media (external backup optional)
```

### **Recommended External Backup Solution**
```bash
# Option 1: USB Drive (Weekly)
rsync -av --delete /persistent /home /workspace /media/usb-backup/

# Option 2: Cloud Backup (Automatic)
# Use: Nextcloud, Backblaze, Duplicati, restic

# Option 3: External HDD (Monthly)
# Weekly incrementals, monthly full backups
```

---

## 📝 SUMMARY

| Component | Purpose | Backed Up By | Method | Frequency |
|-----------|---------|--------------|--------|-----------|
| **/** (root) | OS, apps, system | Snapper | Auto snapshots | Hourly + before updates |
| **/boot** | Kernels, bootloader | None | Regeneratable | N/A |
| **/persistent** | Your files (downloads, docs) | External | USB/Cloud/HDD | Weekly/Monthly |
| **/home** | Your configs | External | USB/Cloud/HDD | Weekly/Monthly |
| **/workspace** | Your code | Git + External | GitHub + USB | After commits + Monthly |
| **/data** | Media, games, archives | Optional | USB/Cloud (optional) | Monthly (optional) |

---

## 🎯 Your Action Items

### ✅ Already Handled (In Scripts)
- Snapper for `/` partition (system recovery)
- Separate partitions for data preservation

### ⚠️ You Need to Add (Not in scripts yet)
- **External backup strategy** for `/persistent`, `/home`, `/workspace`
- **Regular backup routine** (weekly/monthly to USB or cloud)
- **Git for code** (push to GitHub regularly)

---

## ❓ Is This Clear Now?

**Key Takeaways:**
1. ✅ **Snapper** = System recovery (for / partition only)
2. ❌ **Snapper does NOT** backup your personal data
3. ✅ **/persistent** is PRESERVED if system breaks (different disk partition)
4. ⚠️ **External backup needed** for your files (USB/cloud/external drive)
5. 🎯 **Separation of concerns**: System backups ≠ Personal data backups

Would you like me to create a backup script for `/persistent` and other data partitions?
