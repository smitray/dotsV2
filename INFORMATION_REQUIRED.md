# Complete Information & Configuration Requirements

## What You Need to Provide (Interactive Prompts)

### During `post_install_system.sh` Execution:

1. **Hostname** ✅
   - Example: `asus-tuf-gaming` or `arch-workstation`
   - Used for: Network identification
   - Constraints: Only letters, numbers, and hyphens

2. **Root Password** ✅
   - Required for: Administrative/sudo operations
   - Minimum: 8 characters recommended
   - Will be prompted twice for confirmation

3. **Primary Username** ✅
   - Example: `debasmitr`, `alex`, `user`
   - Used for: Regular user account
   - Constraints: Only letters, numbers, underscore, hyphens
   - Gets added to `wheel` group for sudo access

4. **Primary User Password** ✅
   - Required for: User login and operations
   - Minimum: 8 characters recommended
   - Will be prompted twice for confirmation

5. **Timezone** ✅
   - Examples: `Asia/Kolkata`, `America/New_York`, `Europe/London`
   - For your location, common options:
     - **India**: `Asia/Kolkata`
     - **USA East**: `America/New_York`
     - **USA West**: `America/Los_Angeles`
     - **UK**: `Europe/London`
     - **Europe Central**: `Europe/Berlin`
   - Default recommended: Based on your location
   - Script will validate against system timezones

6. **Locale** ✅
   - Example: `en_US.UTF-8` (recommended default)
   - Other options: `en_GB.UTF-8`, `de_DE.UTF-8`, `fr_FR.UTF-8`
   - If invalid, will fallback to `en_US.UTF-8`

7. **Keyboard Layout** ✅
   - Example: `us` (recommended default)
   - Other options: `gb`, `de`, `fr`, `jp`
   - Used for: Console and X11 keyboard mapping

---

## What's Automatically Configured (Hardcoded)

### Hardware-Specific Settings
- ✅ **CPU**: AMD Ryzen 7 4800H (auto-detected)
- ✅ **GPU**: NVIDIA RTX 3050 Mobile + AMD Radeon Vega
  - Driver: `nvidia-drm.modeset=1` (Wayland support)
  - CUDA: Pre-configured
  - AMD GPU: `amdgpu` kernel module

### Storage & Partitioning
- ✅ **Disk 1** (`/dev/nvme0n1`):
  - `nvme0n1p1`: 2GB FAT32 EFI `/boot`
  - `nvme0n1p2`: 500GB Btrfs `/` (root)
  - `nvme0n1p3`: 498GB Btrfs `/persistent` (user data)

- ✅ **Disk 2** (`/dev/nvme1n1`):
  - `nvme1n1p1`: 150GB Btrfs `/home` (user configs)
  - `nvme1n1p2`: 400GB Btrfs `/workspace` (development)
  - `nvme1n1p3`: 450GB Btrfs `/data` (bulk storage)

### Btrfs Configuration
- ✅ **Subvolumes Created**:
  - `@` (root filesystem on nvme0n1p2)
  - `@snapshots` (for snapper on nvme0n1p2)
  - `@persistent` (on nvme0n1p3)
  - `@home` (on nvme1n1p1)
  - `@workspace` (on nvme1n1p2)
  - `@data` (on nvme1n1p3)

- ✅ **Compression**: zstd:1 (all data partitions)
- ✅ **Mount Options**: `compress=zstd:1`, `space_cache=v2`, `discard=async`

### Memory
- ✅ **Swap**: 32GB swapfile with NOCOW attribute for hibernation
- ✅ **ZRAM**: 4GB (enabled by default in Arch)

### Bootloader
- ✅ **Type**: GRUB2 (x86_64-efi)
- ✅ **NVIDIA Params**: `nvidia_drm.modeset=1` (Wayland support)
- ✅ **Location**: `/boot/grub/efi`

### Networking
- ✅ **Type**: DHCP (automatic)
- ✅ **Services**: systemd-networkd + systemd-resolved
- ✅ **Drivers**:
  - Ethernet: Realtek RTL8111 (kernel-native)
  - WiFi: MediaTek MT7921 (kernel-native)

### System Packages
- ✅ **Base**: base, linux, linux-firmware
- ✅ **Bootloader**: grub, efibootmgr
- ✅ **GPU**:
  - nvidia, nvidia-utils, nvidia-dkms
  - cuda (NVIDIA compute)
  - mesa, xf86-video-amdgpu (AMD GPU)
- ✅ **Filesystem**: btrfs-progs, snapper
- ✅ **Desktop**: wayland, hyprland
- ✅ **Audio**: pipewire, pipewire-alsa, alsa-utils
- ✅ **Development**: git, python3, nodejs, npm, base-devel
- ✅ **Utils**: vim, nano, curl, wget

---

## Scripts Created & Their Purpose

### 1. **setup_disks.sh** ✅ (Ready to use)
**When**: From Arch ISO before system installation
**Does**:
- Detects existing partitions (smart preservation)
- Creates GPT partition table
- Creates all 6 partitions with correct sizes
- Formats with FAT32 (boot) and Btrfs (data)
- Mounts at `/mnt` for pacstrap
**Output**: Ready for `pacstrap /mnt base linux ...`

### 2. **post_install_system.sh** ✅ (Ready to use)
**When**: Inside chroot after pacstrap
**Does**:
- **Interactively collects**: hostname, timezone, locale, keymap, passwords
- **Automatically configures**:
  - Locale generation
  - Timezone symlink
  - Hostname and /etc/hosts
  - Root and primary user creation
  - Btrfs subvolume creation
  - 32GB swapfile with NOCOW
  - fstab with proper Btrfs mount options
  - mkinitcpio with NVIDIA modules
  - GRUB bootloader with NVIDIA params
  - Essential package installation

### 3. **setup_xdg_directories.sh** 🔲 (Not yet created)
**When**: As regular user, post-login
**Will do**:
- Create XDG-compliant symlinks
- Link `~/.config` to `/home/username/.config`
- Link `~/Desktop` to `/persistent/Desktop`
- Link `~/Documents` to `/persistent/Documents`
- Link `~/Downloads` to `/persistent/Downloads`
- Link `~/Music` to `/persistent/Music`
- Link `~/Pictures` to `/persistent/Pictures`
- Link `~/Videos` to `/persistent/Videos`

### 4. **configure_snapper.sh** 🔲 (Not yet created)
**When**: As root, post-login
**Will do**:
- Install snapper
- Configure automatic snapshots
- Create snapshot policies
- Setup recovery snapshots
- Setup rollback mechanism

### 5. **setup_dev_workspace.sh** 🔲 (Not yet created)
**When**: As regular user, post-login
**Will do**:
- Install mise (polyglot tool manager)
- Install Node.js via mise
- Install Python via mise
- Install Bun via mise
- Create project directory structure
- Configure git
- Setup development environments

---

## Installation Timeline & Commands

### **Phase 1: Boot & Partition** (5 minutes)
```bash
# Boot Arch ISO
sudo ./install/setup_disks.sh
# Follow interactive prompts
# Result: Partitions created and mounted at /mnt
```

### **Phase 2: Base System** (10 minutes)
```bash
pacstrap /mnt base linux linux-firmware
arch-chroot /mnt
```

### **Phase 3: Post-Install Config** (15 minutes)
```bash
# Still in chroot
./install/post_install_system.sh
# Follow interactive prompts for:
# - Hostname, timezone, locale, keymap
# - Root password
# - Username and password
# Script handles: locale, users, Btrfs, swap, bootloader, packages
exit
reboot
```

### **Phase 4: User Login & Additional Setup** (5 minutes)
```bash
# Login as your username
./install/setup_xdg_directories.sh    # Creates symlinks
sudo ./install/configure_snapper.sh   # Btrfs snapshots
./install/setup_dev_workspace.sh      # Development tools
```

---

## Information Checklist Before Starting

### Required Information (YOU MUST HAVE)
- [ ] Hostname (decide on name like `asus-tuf-gaming`)
- [ ] Timezone (find using `timedatectl list-timezones`)
- [ ] Locale (typically `en_US.UTF-8` is fine)
- [ ] Keyboard layout (typically `us` is fine)
- [ ] Root password (strong, 8+ characters)
- [ ] Primary username (e.g., `debasmitr`)
- [ ] Primary user password (strong, 8+ characters)

### Environment Checks (BEFORE RUNNING SCRIPTS)
- [ ] Booted from Arch ISO (for Phase 1)
- [ ] Internet connected (`ping 8.8.8.8`)
- [ ] Both NVMe drives detected (`lsblk`)
- [ ] No critical data on nvme0n1 or nvme1n1 (will be wiped)

---

## What's Happening Behind the Scenes

### Partition Creation (setup_disks.sh)
1. Detects existing partitions
2. If none exist → creates 6 new partitions
3. If some exist → preserves data partitions, recreates boot/root
4. Mounts everything at `/mnt` for pacstrap

### System Configuration (post_install_system.sh)
1. Generates locale files
2. Sets timezone
3. Creates hostname and network config
4. Creates users with passwords
5. Creates Btrfs subvolumes for snapshots
6. Creates 32GB swapfile (NOCOW for Btrfs)
7. Updates `/etc/fstab` with proper mount options
8. Configures mkinitcpio for NVIDIA
9. Installs and configures GRUB bootloader
10. Installs ~30 essential packages

---

## Data Preservation Guarantee

**If you re-run scripts:**
- `setup_disks.sh`: Only wipes `/boot` and `/` partitions
  - **PRESERVES**: `/persistent`, `/home`, `/workspace`, `/data`
- `post_install_system.sh`: Can be re-run (idempotent)
  - Just re-enter configuration info
  - Doesn't destroy user data

---

## Summary

✅ **Created & Ready**:
1. setup_disks.sh (partitioning)
2. post_install_system.sh (system config with interactive prompts)
3. INSTALLATION_GUIDE.md (complete guide)

🔲 **Still Need to Create**:
1. setup_xdg_directories.sh (XDG symlinks)
2. configure_snapper.sh (Btrfs snapshots)
3. setup_dev_workspace.sh (development environment)

**You need to provide**: Just 7 pieces of information during installation
- Hostname, timezone, locale, keymap, passwords
- Everything else is automatically configured!

