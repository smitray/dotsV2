# Complete Mounting Points Reference - All Partitions

## 📋 Executive Summary

```
NVME 1 (1TB - System + Backups + Docker Images)
├── nvme0n1p1  2GB    /boot                    FAT32
├── nvme0n1p2  150GB  /                        Btrfs (subvol=@)
├── nvme0n1p3  200GB  /backup                  Btrfs
└── nvme0n1p4  648GB  /var/lib/docker         Btrfs

NVME 2 (1TB - Permanent Storage + Docker Data)
├── nvme1n1p1  150GB  /home                    Btrfs (subvol=@home)
├── nvme1n1p2  400GB  /workspace               Btrfs (subvol=@workspace)
├── nvme1n1p3  100GB  /obsidian                Btrfs (subvol=@obsidian)
└── nvme1n1p4  350GB  /docker-data             Btrfs (subvol=@docker-data)
```

---

## 🎯 Detailed Mount Points - NVME 1

### Partition 1: `/dev/nvme0n1p1` → `/boot`

```
Device:         /dev/nvme0n1p1
Mount Point:    /boot
Size:           2 GB
Filesystem:     FAT32
Filesystem Label: ARCH_BOOT
Purpose:        EFI bootloader and kernel images
Fstab Entry:    /dev/nvme0n1p1  /boot  vfat  defaults,noatime,nofail  0  2
Mount Options:  defaults,noatime,nofail
Permissions:    755 (root:root)
Subvolumes:     None (FAT32)

Directory Structure:
/boot/
├── EFI/
│   └── BOOT/
│       ├── BOOTX64.EFI
│       └── BOOTX64.CSV
├── loader/
│   ├── entries/
│   │   ├── arch.conf          (Arch Linux boot entry)
│   │   └── arch-fallback.conf (Fallback entry)
│   ├── loader.conf            (Bootloader config)
│   └── random-seed            (UEFI random seed)
├── vmlinuz-linux              (Linux kernel)
├── initramfs-linux.img        (Initial ramdisk)
└── initramfs-linux-fallback.img

Usage:
  • Stores bootloader (systemd-boot)
  • Stores kernel images
  • Stores bootloader configuration
  • EFI system partition required for UEFI boot

Backup: Not backed up (regenerable)
Can be reformatted: Yes (regenerable from pacstrap)
```

---

### Partition 2: `/dev/nvme0n1p2` → `/`

```
Device:         /dev/nvme0n1p2
Mount Point:    /
Size:           150 GB
Filesystem:     Btrfs
Filesystem Label: ARCH_ROOT
Subvolume:      @ (default subvolume)
Purpose:        Root filesystem - OS, applications, system files
Fstab Entry:    /dev/nvme0n1p2  /  btrfs  rw,relatime,compress=zstd:1,space_cache=v2,subvol=@  0  0
Mount Options:  rw,relatime,compress=zstd:1,space_cache=v2,subvol=@
Compression:    zstd:1 (moderate compression for speed)
Cache:          space_cache=v2 (improved performance)
Permissions:    755 (root:root)

Btrfs Subvolumes:
  @ (default)          Root filesystem
  @snapshots           Snapshot storage (for recovery)

Directory Structure:
/
├── bin/                       → /usr/bin (symlink)
├── boot/                      → nvme0n1p1 (mounted separately)
├── dev/                       (device nodes)
├── etc/                       (system configuration)
│   ├── hostname               (system name)
│   ├── fstab                  (mount table)
│   ├── locale.conf            (localization)
│   ├── vconsole.conf          (keyboard layout)
│   ├── pacman.conf            (package manager config)
│   ├── pacman.d/
│   ├── systemd/
│   ├── docker/
│   │   └── daemon.json        (Docker configuration)
│   ├── sysctl.d/
│   │   └── 99-swappiness.conf (swap preference)
│   └── logrotate.d/
│       └── system-backup      (backup log rotation)
├── home/                      → nvme1n1p1 (mounted separately)
├── lib/                       → /usr/lib (symlink)
├── lib64/                     → /usr/lib (symlink)
├── mnt/                       (temporary mounts)
├── opt/                       (optional software)
├── proc/                      (process info)
├── root/                      (root home)
│   ├── .bashrc
│   ├── PHASE_3_SETUP.sh       (from installation)
│   ├── fstab-template
│   ├── system-backup.sh
│   └── setup-user-symlinks.sh
├── run/                       (tmpfs)
├── sbin/                      → /usr/bin (symlink)
├── srv/                       (service data)
├── sys/                       (kernel info)
├── tmp/                       (tmpfs)
├── usr/                       (user programs)
│   ├── bin/
│   ├── lib/
│   ├── local/
│   │   ├── bin/
│   │   │   └── system-backup.sh  (installed by backup script)
│   │   └── share/
│   └── share/
├── var/                       (variable data)
│   ├── cache/
│   ├── log/
│   │   └── system-backup.log  (backup automation logs)
│   ├── lib/
│   │   └── docker/            → nvme0n1p4 (mounted separately)
│   └── tmp/                   (tmpfs)
├── docker-data/               → nvme1n1p4 (mounted separately)
├── workspace/                 → nvme1n1p2 (mounted separately)
├── obsidian/                  → nvme1n1p3 (mounted separately)
├── backup/                    → nvme0n1p3 (mounted separately)
├── swapfile                   (32GB swap file)
└── [standard Linux directories]

Critical Files:
  /etc/fstab                   Mount configuration
  /etc/hostname                System hostname
  /etc/locale.conf             System locale
  /etc/vconsole.conf           Keyboard configuration
  /etc/sysctl.d/99-swappiness.conf  Memory swap preference
  /swapfile                    32GB hibernation swap

Usage:
  • Contains entire OS
  • Contains system applications (pacman, systemd, etc.)
  • Contains system configuration
  • Contains backup automation scripts
  • Contains Docker installation (but data on NVME 2)
  • Contains ZRAM configuration

Backup: ✅ YES (daily Btrfs snapshots in /backup)
Can be reformatted: Yes (recover from /backup snapshots)
Recovery: Boot Arch USB, restore from /backup/snapshots/ or /backup/images/
```

---

### Partition 3: `/dev/nvme0n1p3` → `/backup`

```
Device:         /dev/nvme0n1p3
Mount Point:    /backup
Size:           200 GB
Filesystem:     Btrfs
Filesystem Label: ARCH_BACKUP
Purpose:        System backups and recovery
Fstab Entry:    /dev/nvme0n1p3  /backup  btrfs  rw,relatime,compress=zstd:1,space_cache=v2  0  2
Mount Options:  rw,relatime,compress=zstd:1,space_cache=v2
Compression:    zstd:1 (moderate compression)
Cache:          space_cache=v2 (improved performance)
Permissions:    755 (root:root)
Subvolumes:     None (backup storage only)

Directory Structure:
/backup/
├── snapshots/                 (Daily Btrfs snapshots of /)
│   ├── system-20240115-030000/
│   ├── system-20240114-030000/
│   ├── system-20240113-030000/
│   ├── ...
│   └── .snapshot-log          (log of all snapshots)
│
├── images/                    (Weekly full system images)
│   ├── system-img-20240114.gz     (compressed image ~30GB)
│   ├── system-img-20240107.gz
│   ├── ...
│   └── .image-log             (log of all images)
│
├── packages/                  (Package list backups)
│   ├── pkglist-20240115-030000.txt
│   ├── aurpkglist-20240115-030000.txt
│   ├── pkglist-20240114-030000.txt
│   ├── ...
│   └── (keep 10 most recent)
│
└── configs/                   (System configuration backups)
    ├── configs-20240115-030000.tar.gz
    ├── configs-20240114-030000.tar.gz
    ├── ...
    └── (all kept for archive)

Backup Contents (via system-backup.sh):

1. Daily Btrfs Snapshots:
   Frequency:   Every day at 03:00 AM
   What:        Read-only snapshot of entire / filesystem
   Retention:   30 most recent (30 days)
   Size:        5-10 GB each
   Recovery:    5-10 minutes
   Command:     btrfs send /backup/snapshots/system-LATEST | btrfs receive /

2. Weekly System Images:
   Frequency:   Every Sunday at 03:00 AM
   What:        Compressed (gzip) full disk image of /dev/nvme0n1p2
   Retention:   4 most recent (4 weeks)
   Size:        ~30 GB each (compressed)
   Recovery:    15-30 minutes
   Command:     gunzip -c /backup/images/system-img-LATEST.gz | dd of=/dev/nvme0n1p2

3. Package Lists:
   Frequency:   After every pacman update + daily at 03:00 AM
   What:        List of all installed packages (pacman -Qqe)
   What:        List of all AUR packages (pacman -Qqm)
   Retention:   10 most recent
   Size:        < 1 MB each
   Purpose:     Recreate exact package set if needed
   File:        pkglist-TIMESTAMP.txt

4. System Configurations:
   Frequency:   Daily at 03:00 AM
   What:        Tar archive of critical system files
   Contents:    /etc/fstab, /etc/hostname, /etc/locale.conf, /etc/pacman.conf,
                /etc/pacman.d/mirrorlist, /boot/loader/, /root/.bashrc, etc.
   Retention:   All (archive)
   Size:        5-10 MB each
   Purpose:     Restore system configuration if needed

Usage:
  • Automatic daily backups via cron job (03:00 AM)
  • Btrfs snapshots for quick recovery
  • System images for full recovery
  • Package lists for system recreation
  • System configs for configuration restoration

Cron Job:
  Location:    /etc/cron.d/system-backup or crontab
  Schedule:    0 3 * * * /usr/local/bin/system-backup.sh >> /var/log/system-backup.log 2>&1
  Time:        03:00 AM every day
  Log:         /var/log/system-backup.log (rotated daily)

Cleanup Policy:
  • Snapshots: Keep 30 most recent, auto-delete older ones
  • Images:    Keep 4 most recent, auto-delete older ones
  • Packages:  Keep 10 most recent, auto-delete older ones
  • Configs:   Keep all (no limit)

Excluded from Backup:
  ✗ /var/lib/docker (disposable Docker images)
  ✗ /docker-data (on NVME 2, needs separate backup)
  ✗ /var/cache (application cache)
  ✗ ~/.cache (user cache)

Backup: ✓ This IS the backup partition
Can be reformatted: NO (contains recovery data!)
Recovery Procedures: See RECOVERY_GUIDE.md
```

---

### Partition 4: `/dev/nvme0n1p4` → `/var/lib/docker`

```
Device:         /dev/nvme0n1p4
Mount Point:    /var/lib/docker
Size:           648 GB
Filesystem:     Btrfs
Filesystem Label: ARCH_DOCKER
Purpose:        Docker images, containers, and layer storage
Fstab Entry:    /dev/nvme0n1p4  /var/lib/docker  btrfs  rw,relatime,compress=zstd:1,space_cache=v2  0  2
Mount Options:  rw,relatime,compress=zstd:1,space_cache=v2
Compression:    zstd:1 (efficient for images)
Cache:          space_cache=v2 (improved I/O)
Permissions:    700 (root:docker)
Storage Driver: btrfs (configured in /etc/docker/daemon.json)

Docker Configuration:
  File:         /etc/docker/daemon.json
  data-root:    /var/lib/docker
  driver:       btrfs
  live-restore: true
  log-driver:   json-file

Directory Structure:
/var/lib/docker/
├── overlay2/                  (Docker layer storage)
│   ├── l/                     (layer symlinks)
│   └── [hash]/
│       ├── diff/              (layer content)
│       ├── link               (symlink name)
│       ├── lower              (parent layers)
│       └── work/              (copy-on-write work)
│
├── containers/                (Running container data)
│   ├── [container-id]/
│   │   ├── config.v2.json
│   │   ├── hostname
│   │   ├── hosts
│   │   └── [other container files]
│   └── [other containers]
│
├── image/
│   ├── btrfs/                 (Btrfs image metadata)
│   │   ├── imagedb/
│   │   │   ├── content/
│   │   │   └── metadata/
│   │   └── layerdb/
│   └── [other drivers]
│
├── network/                   (Docker networks)
│   ├── files/
│   │   ├── local/
│   │   │   ├── kv.db
│   │   │   └── [network IDs]
│   │   └── [network driver data]
│   └── [network configs]
│
├── volumes/                   (Docker volumes metadata)
│   ├── metadata.db
│   └── [volume data] (NOTE: Actual volume data in /docker-data!)
│
├── plugins/                   (Docker plugins)
├── runtimes/                  (Container runtimes)
├── swarm/                     (Docker Swarm data)
├── tmp/                       (Temporary files)
└── docker.sock                (Docker API socket)

What's Stored Here (All Disposable):
  ✓ Downloaded Docker images (can be re-pulled)
  ✓ Running container filesystems (ephemeral)
  ✓ Container metadata (recreate from images)
  ✓ Docker network configurations
  ✓ Docker plugin data
  ✗ Persistent data (goes to /docker-data on NVME 2!)

Typical Usage:
  Base Images:          ubuntu:22.04, postgres:15, mongodb:6, etc.
  Built Images:        Custom application images
  Container Layers:    Copy-on-write layers from base + app
  Container State:     Process data, logs, temporary files

Size Breakdown (typical):
  Base images:        50-100 GB (depends on pulled images)
  App images:         10-50 GB (application-specific)
  Container data:     5-20 GB (running containers)
  Metadata:           1-5 GB
  Total:              ~100-200 GB (varies, can fill to 648 GB)

Backup: ✗ NO (images are disposable, can be redownloaded)
Can be reformatted: YES (all images can be re-pulled)
Recovery: If space full, delete images: docker rmi [image-id]
Rebuild: docker pull [image] to redownload

Important Note:
  Docker VOLUMES with persistent data should use /docker-data!
  See /docker-data partition for database volume mounting.

Example Docker Volume Mounting (WRONG - don't do this):
  ✗ docker run -v /var/lib/docker/volumes/mydata:/data postgres

Example Docker Volume Mounting (CORRECT - do this):
  ✓ docker run -v /docker-data/postgres:/var/lib/postgresql/data postgres
```

---

## 🎯 Detailed Mount Points - NVME 2

### Partition 1: `/dev/nvme1n1p1` → `/home`

```
Device:         /dev/nvme1n1p1
Mount Point:    /home
Size:           150 GB
Filesystem:     Btrfs
Filesystem Label: ARCH_HOME
Subvolume:      @home (default subvolume)
Purpose:        User home directories, configurations, dotfiles, Mise runtimes
Fstab Entry:    /dev/nvme1n1p1  /home  btrfs  rw,relatime,compress=zstd:1,space_cache=v2,subvol=@home  0  2
Mount Options:  rw,relatime,compress=zstd:1,space_cache=v2,subvol=@home
Compression:    zstd:1 (moderate compression)
Cache:          space_cache=v2 (improved performance)
Permissions:    755 (root:root)

Btrfs Subvolumes:
  @home (default)    User home directories

Directory Structure:
/home/
└── [username]/                (e.g., /home/debasmitr)
    ├── .bashrc                (shell configuration)
    ├── .zshrc                 (zsh configuration)
    ├── .profile               (login shell config)
    ├── .bash_history          (command history)
    ├── .bash_logout           (logout script)
    │
    ├── .config/               (application configurations)
    │   ├── hyprland/          (Hyprland window manager config)
    │   ├── waybar/            (status bar config)
    │   ├── wofi/              (application launcher config)
    │   ├── kitty/             (terminal config)
    │   ├── neovim/            (editor config)
    │   ├── git/               (git configuration)
    │   ├── mise/              (Mise runtime manager config)
    │   └── [other apps]
    │
    ├── .local/                (user-local data)
    │   ├── bin/               (user scripts)
    │   ├── share/
    │   │   ├── mise/          ⭐ RUNTIME INSTALLATIONS HERE
    │   │   │   ├── shims/     (executable wrappers in PATH)
    │   │   │   │   ├── node   (→ ../versions/node/20.11.0/bin/node)
    │   │   │   │   ├── npm
    │   │   │   │   ├── npx
    │   │   │   │   ├── python (→ ../versions/python/3.12.0/bin/python)
    │   │   │   │   ├── pip
    │   │   │   │   ├── bun
    │   │   │   │   └── [other shims]
    │   │   │   └── versions/  (actual runtime installations)
    │   │   │       ├── node/
    │   │   │       │   ├── 18.19.0/
    │   │   │       │   │   ├── bin/
    │   │   │       │   │   │   ├── node
    │   │   │       │   │   │   ├── npm
    │   │   │       │   │   │   └── npx
    │   │   │       │   │   └── lib/
    │   │   │       │   ├── 20.11.0/
    │   │   │       │   │   ├── bin/
    │   │   │       │   │   └── lib/
    │   │   │       │   └── 22.0.0/
    │   │   │       │       ├── bin/
    │   │   │       │       └── lib/
    │   │   │       ├── python/
    │   │   │       │   ├── 3.11.0/
    │   │   │       │   │   ├── bin/
    │   │   │       │   │   │   ├── python
    │   │   │       │   │   │   └── pip
    │   │   │       │   │   └── lib/
    │   │   │       │   ├── 3.12.0/
    │   │   │       │   │   ├── bin/
    │   │   │       │   │   └── lib/
    │   │   │       │   └── 3.13.0/
    │   │   │       │       ├── bin/
    │   │   │       │       └── lib/
    │   │   │       └── bun/
    │   │   │           ├── 1.0.29/
    │   │   │           │   └── bin/
    │   │   │           └── 1.1.0/
    │   │   │               └── bin/
    │   │   ├── applications/  (desktop app shortcuts)
    │   │   └── [other apps]
    │   └── cache/             (user cache - can be large)
    │
    ├── Downloads/             → /temp-storage/Downloads (symlink)
    ├── Videos/                → /temp-storage/Videos (symlink)
    ├── .cache/                → /temp-storage/Cache/.cache (symlink)
    │
    ├── Documents/             → /obsidian/Documents (symlink)
    ├── Pictures/              → /archive/Pictures (symlink)
    ├── Music/                 → /archive/Music (symlink)
    │
    ├── Projects/              → /workspace/projects (symlink)
    ├── .local/share/          → /archive/AppData (symlink)
    │
    ├── .gnupg/                (GPG keys - if using GPG)
    ├── .ssh/                  (SSH keys - keep secure!)
    ├── .git-credentials       (git credentials)
    │
    ├── .vimrc / .nvimrc       (editor configs)
    ├── .inputrc               (readline config)
    ├── .xinitrc               (X init config - if using X)
    │
    └── [other dotfiles/directories]

Key Directories Explained:

1. Mise Runtimes (~/.local/share/mise/):
   Location: /home/[user]/.local/share/mise/
   Size:     20-50 GB (depends on installed runtimes)
   Includes:
     • Node.js 18, 20, 22 (etc.)
     • Python 3.11, 3.12, 3.13 (etc.)
     • Bun 1.x (etc.)
   Activation: Automatic when entering directory with .mise.toml
   Persistence: Survives system reinstalls (on NVME 2)

2. Shell Configurations:
   .bashrc:    Bash-specific configs, aliases, functions
   .zshrc:     Zsh-specific configs (if using Zsh)
   .profile:   Login shell configuration

3. Application Configs:
   .config/hyprland/    Window manager configuration
   .config/waybar/      Status bar configuration
   .config/kitty/       Terminal emulator config
   .config/neovim/      Vim/Neovim editor config
   .config/git/         Git user configuration

4. Symlinked Directories:
   Temporary: Downloads, Videos, .cache
   Permanent: Documents, Pictures, Music, Projects, AppData

Usage:
  • Each user has separate /home/[username] directory
  • Mise installs runtimes here (survives reinstalls)
  • All application configs stored here
  • User-specific data preserved

Backup: ✅ YES (important configs preserved on NVME 2)
Can be reformatted: NO (user data here!)
Size per user: 20-100 GB (depends on installed runtimes + data)
Important: SSH keys, GPG keys, git credentials stored here - keep secure!
```

---

### Partition 2: `/dev/nvme1n1p2` → `/workspace`

```
Device:         /dev/nvme1n1p2
Mount Point:    /workspace
Size:           400 GB
Filesystem:     Btrfs
Filesystem Label: ARCH_WORKSPACE
Subvolume:      @workspace (default subvolume)
Purpose:        Development projects, source code, git repositories
Fstab Entry:    /dev/nvme1n1p2  /workspace  btrfs  rw,relatime,compress=zstd:1,space_cache=v2,subvol=@workspace  0  2
Mount Options:  rw,relatime,compress=zstd:1,space_cache=v2,subvol=@workspace
Compression:    zstd:1 (good for code files)
Cache:          space_cache=v2 (improved performance)
Permissions:    755 (root:root)

Btrfs Subvolumes:
  @workspace (default)    Development workspace

Directory Structure:
/workspace/
├── projects/              (Development projects directory)
│   ├── web/               (Web development projects)
│   │   ├── next-app/
│   │   │   ├── .mise.toml
│   │   │   │   [tools]
│   │   │   │   node = "20.11.0"
│   │   │   │   bun = "1.0.29"
│   │   │   ├── package.json
│   │   │   ├── src/
│   │   │   ├── public/
│   │   │   ├── .git/
│   │   │   └── node_modules/
│   │   │
│   │   └── react-app/
│   │       ├── .mise.toml
│   │       ├── package.json
│   │       └── [React project structure]
│   │
│   ├── api/               (API/backend projects)
│   │   ├── fastapi-server/
│   │   │   ├── .mise.toml
│   │   │   │   [tools]
│   │   │   │   python = "3.12.0"
│   │   │   ├── requirements.txt
│   │   │   ├── main.py
│   │   │   └── [FastAPI structure]
│   │   │
│   │   ├── node-api/
│   │   │   ├── .mise.toml
│   │   │   │   [tools]
│   │   │   │   node = "20.11.0"
│   │   │   ├── package.json
│   │   │   └── [Express/Node structure]
│   │   │
│   │   └── rust-backend/
│   │       ├── Cargo.toml
│   │       └── [Rust project structure]
│   │
│   ├── mobile/            (Mobile app projects)
│   │   └── flutter-app/
│   │       └── [Flutter structure]
│   │
│   ├── data/              (Data/ML projects)
│   │   ├── jupyter-notebooks/
│   │   │   ├── .mise.toml
│   │   │   │   [tools]
│   │   │   │   python = "3.12.0"
│   │   │   ├── analysis.ipynb
│   │   │   └── [notebook data]
│   │   │
│   │   └── ml-models/
│   │       ├── .mise.toml
│   │       ├── requirements.txt
│   │       └── [ML project structure]
│   │
│   └── infra/             (Infrastructure/DevOps projects)
│       ├── terraform/
│       ├── docker-compose.yml
│       ├── kubernetes/
│       └── [IaC structure]
│
├── environments/          (Development environment configs)
│   ├── production/        (Production environment setup)
│   ├── staging/          (Staging environment setup)
│   ├── development/      (Development environment setup)
│   └── [environment configs]
│
├── experiments/           (Experimental projects - optional)
│   └── [test projects]
│
├── scripts/               (Utility scripts)
│   ├── deploy.sh
│   ├── backup.sh
│   ├── setup.sh
│   └── [other scripts]
│
└── archived/              (Old/archived projects)
    └── [old project folders]

Project Structure Example (.mise.toml):
/workspace/projects/fullstack-app/.mise.toml:

  [tools]
  node = "20.11.0"           # Node.js for frontend/backend
  python = "3.12.0"          # Python for scripts/API
  bun = "1.0.29"             # Bun as alternative runtime

  [env]
  NODE_ENV = "development"
  PYTHONPATH = "${MISE_ROOT}/src"
  API_PORT = "3000"
  DB_HOST = "localhost"

Per-Project Runtimes:
  • Each .mise.toml specifies versions
  • When cd into project, Mise activates:
    - node 20.11.0 (from ~/.local/share/mise/versions/node/20.11.0/)
    - python 3.12.0 (from ~/.local/share/mise/versions/python/3.12.0/)
    - bun 1.0.29 (from ~/.local/share/mise/versions/bun/1.0.29/)

Typical Project Size:
  Small project (no node_modules):       5-50 MB
  Project with node_modules:             100 MB - 1 GB
  Project with .git history:             1-5 GB
  Multiple projects (400 typical):       50-200 GB (out of 400 GB available)

Usage:
  • Store all development projects here
  • Each project has .mise.toml for runtime versions
  • Git repositories for version control
  • Source code, assets, configuration
  • Docker Compose files for local databases
  • Environment-specific setup

Backup: ✅ YES (critical development work here!)
Can be reformatted: NO (development projects here!)
Recovery: Backed up via git and/or NVME 2 backup strategy
Git Integration: All projects should be git-tracked
```

---

### Partition 3: `/dev/nvme1n1p3` → `/obsidian`

```
Device:         /dev/nvme1n1p3
Mount Point:    /obsidian
Size:           100 GB
Filesystem:     Btrfs
Filesystem Label: ARCH_OBSIDIAN
Subvolume:      @obsidian (default subvolume)
Purpose:        Obsidian vaults, personal notes, documentation
Fstab Entry:    /dev/nvme1n1p3  /obsidian  btrfs  rw,relatime,compress=zstd:1,space_cache=v2,subvol=@obsidian  0  2
Mount Options:  rw,relatime,compress=zstd:1,space_cache=v2,subvol=@obsidian
Compression:    zstd:1 (good for markdown files)
Cache:          space_cache=v2 (improved performance)
Permissions:    755 (root:root)

Btrfs Subvolumes:
  @obsidian (default)    Obsidian vault storage

Directory Structure:
/obsidian/
├── Personal/              (Personal vault)
│   ├── .obsidian/         (Obsidian config - hidden)
│   │   ├── app.json
│   │   ├── appearance.json
│   │   ├── core-plugins.json
│   │   ├── plugins/
│   │   ├── snippets/
│   │   ├── themes/
│   │   └── hotkeys.json
│   │
│   ├── Daily Notes/       (Daily journal entries)
│   │   ├── 2024-01-15.md
│   │   ├── 2024-01-14.md
│   │   └── [daily notes]
│   │
│   ├── Life/              (Personal life notes)
│   │   ├── Health/
│   │   ├── Finance/
│   │   ├── Goals/
│   │   └── [life-related notes]
│   │
│   ├── Learning/          (Learning notes)
│   │   ├── Languages/
│   │   ├── Certifications/
│   │   ├── Books/
│   │   └── [learning materials]
│   │
│   └── .gitignore         (git ignore for vaults)
│
├── Work/                  (Work vault)
│   ├── .obsidian/
│   ├── Projects/          (Work projects)
│   │   ├── ProjectA/
│   │   ├── ProjectB/
│   │   └── [work projects]
│   │
│   ├── Documentation/     (Work documentation)
│   │   ├── Architecture/
│   │   ├── API Docs/
│   │   └── [internal docs]
│   │
│   ├── Meetings/          (Meeting notes)
│   │   ├── 2024-01-15-standup.md
│   │   ├── 2024-01-14-planning.md
│   │   └── [meeting notes]
│   │
│   ├── Team/              (Team information)
│   │   ├── Members.md
│   │   ├── Processes.md
│   │   └── [team info]
│   │
│   └── .gitignore
│
├── Reference/             (Reference vault)
│   ├── Technology/
│   │   ├── Languages/
│   │   ├── Frameworks/
│   │   ├── Tools/
│   │   └── [tech references]
│   │
│   ├── Design/            (Design references)
│   │   ├── Color Schemes/
│   │   ├── Patterns/
│   │   └── [design refs]
│   │
│   ├── Templates/         (Note templates)
│   │   ├── Project Template.md
│   │   ├── Meeting Template.md
│   │   └── [templates]
│   │
│   └── [reference materials]
│
├── Documents/             (Symlink to /obsidian/Documents)
│   ├── Notes/
│   ├── Research/
│   └── [document storage]
│
└── Attachments/           (Media files used in notes)
    ├── images/
    ├── pdfs/
    └── [media files]

Obsidian Vault Structure:
  • Vault = Collection of markdown notes
  • .obsidian/ = Vault configuration
  • Can have multiple vaults (Personal, Work, Reference)
  • All vaults stored in /obsidian directory

Typical Note Examples:
/obsidian/Personal/Daily Notes/2024-01-15.md:
  ---
  tags: daily, journal
  date: 2024-01-15
  ---
  # January 15, 2024
  ## Accomplished
  - [ ] Task 1
  - [x] Task 2
  
  ## Notes
  Today I learned about...

/obsidian/Work/Projects/ProjectA/Overview.md:
  # Project A Overview
  ## Description
  ...
  ## Team
  [[Members#ProjectA|Team members]]
  ## Timeline
  ...

Key Features:
  • Markdown-based notes
  • Link between notes (obsidian links)
  • Graph view of connected notes
  • Plugin ecosystem
  • Multiple vaults supported
  • Git integration per vault

Storage Size:
  • Text files (markdown): Very small (KB - MB per note)
  • 1000 notes ≈ 1-10 MB of text
  • Attachments (images, PDFs): Can be large
  • Total typical usage: 5-20 GB (out of 100 GB available)

Usage:
  • Store personal/work notes
  • Create interconnected knowledge base
  • Daily journaling
  • Project documentation
  • Reference materials
  • Task management

Backup: ✅ YES (important knowledge base!)
Can be reformatted: NO (notes stored here!)
Git Integration: Possible per vault (add .gitignore)
Sync: Obsidian Sync available (optional paid service)
Recovery: Backed up as part of NVME 2
```

---

### Partition 4: `/dev/nvme1n1p4` → `/docker-data`

```
Device:         /dev/nvme1n1p4
Mount Point:    /docker-data
Size:           350 GB
Filesystem:     Btrfs
Filesystem Label: ARCH_DOCKER_DATA
Subvolume:      @docker-data (default subvolume)
Purpose:        Docker volumes, persistent database storage, app data
Fstab Entry:    /dev/nvme1n1p4  /docker-data  btrfs  rw,relatime,compress=zstd:1,space_cache=v2,subvol=@docker-data  0  2
Mount Options:  rw,relatime,compress=zstd:1,space_cache=v2,subvol=@docker-data
Compression:    zstd:1 (good for data)
Cache:          space_cache=v2 (improved performance)
Permissions:    750 (root:docker)
Subvolumes:     None (data storage only)

Docker Configuration:
  Images Location:      /var/lib/docker (NVME 1 - disposable)
  Data Location:        /docker-data (NVME 2 - permanent)
  Separation Strategy:  Images are ephemeral, data is persistent

Directory Structure:
/docker-data/
├── postgres/              (PostgreSQL databases)
│   ├── base/              (database files)
│   ├── global/            (cluster-wide data)
│   ├── pg_wal/            (write-ahead logs)
│   ├── pg_stat_tmp/       (statistics)
│   ├── postmaster.pid
│   └── [PostgreSQL data files]
│   Size: 10-100 GB per database
│   Mounted in container: -v /docker-data/postgres:/var/lib/postgresql/data
│
├── mysql/                 (MySQL databases)
│   ├── mysql/             (system database)
│   ├── information_schema/
│   ├── performance_schema/
│   ├── [custom databases]/
│   ├── ib_buffer_pool     (InnoDB buffer pool)
│   ├── ibdata1            (InnoDB tablespace)
│   ├── ibtmp1             (temp tablespace)
│   └── [MySQL data files]
│   Size: 5-50 GB per database
│   Mounted in container: -v /docker-data/mysql:/var/lib/mysql
│
├── mongodb/               (MongoDB databases)
│   ├── collection-0       (collection storage)
│   ├── index-1            (index storage)
│   ├── journal/           (write operations log)
│   ├── admin.0
│   ├── admin.1
│   ├── local.0
│   ├── local.1
│   ├── [custom DBs]
│   ├── mongod.lock
│   └── [MongoDB data files]
│   Size: 5-50 GB per database
│   Mounted in container: -v /docker-data/mongodb:/data/db
│
├── redis/                 (Redis persistence)
│   ├── dump.rdb           (RDB snapshot)
│   ├── appendonly.aof     (append-only file)
│   └── [Redis persistence files]
│   Size: 1-10 GB (depending on data)
│   Mounted in container: -v /docker-data/redis:/data
│
├── volumes/               (Named Docker volumes)
│   ├── app-data/          (application-specific data)
│   │   ├── uploads/       (uploaded files)
│   │   ├── cache/         (application cache)
│   │   └── [app data]
│   │
│   ├── shared-storage/    (shared between containers)
│   │   └── [shared data]
│   │
│   └── [other volumes]/
│
├── backups/               (Database backups)
│   ├── postgres/
│   │   ├── postgres-backup-20240115.sql.gz
│   │   ├── postgres-backup-20240114.sql.gz
│   │   └── [pg backups]
│   │
│   ├── mysql/
│   │   ├── mysql-backup-20240115.sql.gz
│   │   ├── mysql-backup-20240114.sql.gz
│   │   └── [mysql backups]
│   │
│   ├── mongodb/
│   │   ├── mongodb-backup-20240115.tar.gz
│   │   └── [mongo backups]
│   │
│   └── [other backups]
│
└── environments/          (Environment-specific data)
    ├── development/       (dev database files)
    ├── staging/          (staging database files)
    └── production/       (prod database files)

Docker Compose Example (Correct Mount):

services:
  postgres:
    image: postgres:15
    container_name: my-postgres
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: appuser
      POSTGRES_PASSWORD: secret
    volumes:
      - /docker-data/postgres:/var/lib/postgresql/data  # ✅ Persistent!
    ports:
      - "5432:5432"

  mysql:
    image: mysql:8
    container_name: my-mysql
    environment:
      MYSQL_ROOT_PASSWORD: secret
      MYSQL_DATABASE: myapp
    volumes:
      - /docker-data/mysql:/var/lib/mysql  # ✅ Persistent!
    ports:
      - "3306:3306"

  mongodb:
    image: mongo:6
    container_name: my-mongo
    volumes:
      - /docker-data/mongodb:/data/db  # ✅ Persistent!
    ports:
      - "27017:27017"

  redis:
    image: redis:7
    container_name: my-redis
    volumes:
      - /docker-data/redis:/data  # ✅ Persistent!
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes

Permissions:
  docker-data directory:  750 (root:docker)
  Individual volumes:     700-755 (owner:docker)

Why This Partition:
  ✓ Permanent storage (NVME 2 - never reformatted)
  ✓ Backed up along with system
  ✓ Survives Docker reinstalls
  ✓ Database files preserved
  ✓ Application data intact
  ✓ Can be mounted directly to containers

Typical Usage:
  Database instances (PostgreSQL, MySQL, MongoDB, etc.)
  Persistent application data
  File uploads and media storage
  Shared volumes between containers
  Database backups
  Cache that needs persistence

Size Breakdown (typical):
  PostgreSQL:       5-50 GB
  MySQL:            5-50 GB
  MongoDB:          5-50 GB
  Redis:            1-10 GB
  App volumes:      10-50 GB
  Backups:          50-100 GB
  Total:            ~100-300 GB (out of 350 GB available)

Backup: ✅ YES (critical application data!)
Can be reformatted: NO (database data here!)
Recovery: Backed up as part of NVME 2
Important: All containers using this volume preserve data across restarts!
```

---

## 📊 Complete Filesystem Hierarchy

```
/                                    (nvme0n1p2, subvol=@)
├── boot/                           → nvme0n1p1 (2GB)
├── /                               (nvme0n1p2 root)
├── backup/                         → nvme0n1p3 (200GB)
├── var/lib/docker/                → nvme0n1p4 (648GB)
├── home/                           → nvme1n1p1 (150GB)
│   └── [user]/.local/share/mise/  (runtimes)
├── workspace/                      → nvme1n1p2 (400GB)
│   └── projects/                  (development)
├── obsidian/                       → nvme1n1p3 (100GB)
│   ├── Personal/                  (notes)
│   ├── Work/                       (notes)
│   └── Reference/                 (notes)
├── docker-data/                    → nvme1n1p4 (350GB)
│   ├── postgres/                  (databases)
│   ├── mysql/                     (databases)
│   ├── mongodb/                   (databases)
│   ├── redis/                     (cache)
│   ├── volumes/                   (app data)
│   └── backups/                   (DB backups)
├── swapfile                        (32GB, on /)
└── [standard Linux directories]
```

---

## 🔄 Mount Summary Table

| Partition | Mount Point | Size | Filesystem | Subvol | Purpose | Backup |
|-----------|-------------|------|------------|--------|---------|--------|
| nvme0n1p1 | `/boot` | 2GB | FAT32 | - | Bootloader | No |
| nvme0n1p2 | `/` | 150GB | Btrfs | @ | OS + System | Yes* |
| nvme0n1p3 | `/backup` | 200GB | Btrfs | - | System backups | THIS IS BACKUP |
| nvme0n1p4 | `/var/lib/docker` | 648GB | Btrfs | - | Docker images | No** |
| nvme1n1p1 | `/home` | 150GB | Btrfs | @home | Configs + Mise | Yes |
| nvme1n1p2 | `/workspace` | 400GB | Btrfs | @workspace | Projects | Yes |
| nvme1n1p3 | `/obsidian` | 100GB | Btrfs | @obsidian | Notes | Yes |
| nvme1n1p4 | `/docker-data` | 350GB | Btrfs | @docker-data | DB files | Yes |

\* Backed up via daily snapshots in /backup
\*\* Disposable images (can be redownloaded)

---

## 🛡️ Data Safety Summary

### Automatic Backup (Daily at 03:00 AM)
- `/` → Daily Btrfs snapshot in `/backup/snapshots/`
- Package lists → `/backup/packages/`
- System configs → `/backup/configs/`
- System images → `/backup/images/` (weekly)

### Never Reformatted
- `/backup` (recovery data)
- `/home` (user configs)
- `/workspace` (projects)
- `/obsidian` (notes)
- `/docker-data` (databases)

### Can Be Reinstalled
- `/boot` (regenerable)
- `/` (recover from `/backup`)
- `/var/lib/docker` (re-pull images)

---

## ✅ Quick Reference

**To see all mounts on running system:**
```bash
mount | grep -E "nvme|docker"
df -h
lsblk
```

**To see fstab configuration:**
```bash
cat /etc/fstab
```

**To check specific mount:**
```bash
mount | grep /backup
mount | grep /docker-data
mount | grep /workspace
```

**To remount with new options:**
```bash
sudo mount -o remount,rw,relatime,compress=zstd:1,space_cache=v2 /backup
```

---

This is your **complete mounting points reference** with all partitions, directories, purposes, and configurations detailed!
