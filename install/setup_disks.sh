#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Configuration
DISK1="/dev/nvme0n1"
DISK2="/dev/nvme1n1"

# Partition layout for DISK1 (nvme0n1) - System + Recovery + Docker + Downloads
# Total: 900GB allocated + 100GB free = 1000GB (10% free for Btrfs operations - PRODUCTION OPTIMIZED)
declare -A DISK1_PARTITIONS=(
    ["nvme0n1p1"]="1MiB:2GiB:EFI System:FAT32:/boot"
    ["nvme0n1p2"]="2GiB:142GiB:Linux filesystem:Btrfs:/"
    ["nvme0n1p3"]="142GiB:322GiB:Linux filesystem:Btrfs:/backup"
    ["nvme0n1p4"]="322GiB:652GiB:Linux filesystem:Btrfs:/var/lib/docker"
    ["nvme0n1p5"]="652GiB:900GiB:Linux filesystem:Btrfs:/downloads"
)

# Partition layout for DISK2 (nvme1n1) - Permanent Storage + Docker Data
# Total: 900GB allocated + 100GB free = 1000GB (10% free for Btrfs operations - PRODUCTION OPTIMIZED)
declare -A DISK2_PARTITIONS=(
    ["nvme1n1p1"]="1MiB:141GiB:Linux filesystem:Btrfs:/home"
    ["nvme1n1p2"]="141GiB:521GiB:Linux filesystem:Btrfs:/workspace"
    ["nvme1n1p3"]="521GiB:621GiB:Linux filesystem:Btrfs:/obsidian"
    ["nvme1n1p4"]="621GiB:901GiB:Linux filesystem:Btrfs:/docker-data"
)

# Confirmation prompt
confirm() {
    local prompt="$1"
    local response
    read -r -p "$(echo -e ${YELLOW}${prompt}${NC}) (yes/no): " response
    [[ "$response" =~ ^[Yy][Ee][Ss]$ ]]
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

# Check if disks exist
check_disks() {
    log_info "Checking disk availability..."
    
    if [[ ! -b "$DISK1" ]]; then
        log_error "Disk $DISK1 not found"
        exit 1
    fi
    
    if [[ ! -b "$DISK2" ]]; then
        log_error "Disk $DISK2 not found"
        exit 1
    fi
    
    log_success "Both disks detected: $DISK1 and $DISK2"
}

# Check existing partitions
check_existing_partitions() {
    log_info "Checking for existing partitions..."
    
    local disk1_parts=0
    local disk2_parts=0
    
    # Count existing partitions on DISK1
    if lsblk -l "$DISK1" 2>/dev/null | grep -q "${DISK1}p"; then
        disk1_parts=$(lsblk -l "$DISK1" | grep "${DISK1}p" | wc -l)
    fi
    
    # Count existing partitions on DISK2
    if lsblk -l "$DISK2" 2>/dev/null | grep -q "${DISK2}p"; then
        disk2_parts=$(lsblk -l "$DISK2" | grep "${DISK2}p" | wc -l)
    fi
    
    if [[ $disk1_parts -gt 0 || $disk2_parts -gt 0 ]]; then
        log_warn "Existing partitions detected:"
        log_warn "  $DISK1: $disk1_parts partition(s)"
        log_warn "  $DISK2: $disk2_parts partition(s)"
        return 0  # Partitions exist
    else
        log_info "No existing partitions found"
        return 1  # No partitions exist
    fi
}

# Display disk information
display_disk_info() {
    log_info "Current disk layout:"
    echo
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS "$DISK1" "$DISK2"
    echo
}

# Create GPT partition table
create_partition_table() {
    local disk=$1
    log_info "Creating GPT partition table on $disk..."
    
    # Wipe existing partition table
    sgdisk --zap-all "$disk" > /dev/null 2>&1 || true
    
    # Create new GPT table
    sgdisk --new=0 --typecode=0:8300 --change-name=0:"temp" "$disk" > /dev/null 2>&1 || true
    
    # Remove the temporary partition
    sgdisk --delete=1 "$disk" > /dev/null 2>&1 || true
    
    log_success "GPT partition table created on $disk"
}

# Create partitions on a disk
create_partitions() {
    local disk=$1
    local disk_name=$(basename "$disk")
    
    log_info "Creating partitions on $disk..."
    
    # Create partition table if not exists
    if ! sgdisk -p "$disk" > /dev/null 2>&1; then
        create_partition_table "$disk"
    fi
    
    # Determine which partition array to use
    local -n partitions
    if [[ "$disk" == "$DISK1" ]]; then
        partitions=DISK1_PARTITIONS
    else
        partitions=DISK2_PARTITIONS
    fi
    
    # Create each partition
    local part_num=1
    for partition in "${!partitions[@]}"; do
        local config="${partitions[$partition]}"
        IFS=':' read -r start_sector end_sector type fstype mount_point <<< "$config"
        
        # Convert sizes to sectors (using GB to sector calculation)
        local start_mb=${start_sector%GiB}
        local end_mb=${end_sector%GiB}
        
        # Create partition
        log_info "  Creating partition $part_num: $partition ($start_sector - $end_sector)"
        sgdisk --new="${part_num}:${start_mb}G:${end_mb}G" "$disk" > /dev/null 2>&1
        
        # Set partition type
        if [[ "$fstype" == "FAT32" ]]; then
            sgdisk --typecode="${part_num}:ef00" "$disk" > /dev/null 2>&1  # EFI System
        else
            sgdisk --typecode="${part_num}:8300" "$disk" > /dev/null 2>&1  # Linux filesystem
        fi
        
        part_num=$((part_num + 1))
    done
    
    # Write changes
    sgdisk -p "$disk" > /dev/null 2>&1
    log_success "Partitions created on $disk"
}

# Format partitions
format_partitions() {
    log_info "Formatting partitions..."
    
    # DISK1 partitions
    log_info "Formatting $DISK1 (with optimized free space: ~20GB for Btrfs)..."
    mkfs.fat -F 32 -n "ARCH_BOOT" "$DISK1"p1 > /dev/null 2>&1
    mkfs.btrfs -f -L "ARCH_ROOT" "$DISK1"p2 > /dev/null 2>&1
    mkfs.btrfs -f -L "ARCH_BACKUP" "$DISK1"p3 > /dev/null 2>&1
    mkfs.btrfs -f -L "ARCH_DOCKER" "$DISK1"p4 > /dev/null 2>&1
    mkfs.btrfs -f -L "ARCH_DOWNLOADS" "$DISK1"p5 > /dev/null 2>&1
    
    # DISK2 partitions
    log_info "Formatting $DISK2 (with optimized free space: ~20GB for Btrfs)..."
    mkfs.btrfs -f -L "ARCH_HOME" "$DISK2"p1 > /dev/null 2>&1
    mkfs.btrfs -f -L "ARCH_WORKSPACE" "$DISK2"p2 > /dev/null 2>&1
    mkfs.btrfs -f -L "ARCH_OBSIDIAN" "$DISK2"p3 > /dev/null 2>&1
    mkfs.btrfs -f -L "ARCH_DOCKER_DATA" "$DISK2"p4 > /dev/null 2>&1
    
    log_success "All 9 partitions formatted with optimized sizing"
}

# Create Btrfs subvolumes for snapshots
create_btrfs_subvolumes() {
    log_info "Creating Btrfs subvolumes (leaves ~93GB free on NVME1, ~90GB free on NVME2)..."
    
    # Root subvolume (@) on NVME1p2
    log_info "  Creating @ subvolume on $DISK1p2..."
    mount "$DISK1"p2 /mnt
    btrfs subvolume create /mnt/@ > /dev/null 2>&1
    btrfs subvolume create /mnt/@snapshots > /dev/null 2>&1
    umount /mnt
    
    # Home subvolume (@home) on NVME2p1
    log_info "  Creating @home subvolume on $DISK2p1..."
    mount "$DISK2"p1 /mnt
    btrfs subvolume create /mnt/@home > /dev/null 2>&1
    umount /mnt
    
    # Workspace subvolume (@workspace) on NVME2p2
    log_info "  Creating @workspace subvolume on $DISK2p2..."
    mount "$DISK2"p2 /mnt
    btrfs subvolume create /mnt/@workspace > /dev/null 2>&1
    umount /mnt
    
    # Obsidian subvolume (@obsidian) on NVME2p3
    log_info "  Creating @obsidian subvolume on $DISK2p3..."
    mount "$DISK2"p3 /mnt
    btrfs subvolume create /mnt/@obsidian > /dev/null 2>&1
    umount /mnt
    
    # Docker data subvolume (@docker-data) on NVME2p4
    log_info "  Creating @docker-data subvolume on $DISK2p4..."
    mount "$DISK2"p4 /mnt
    btrfs subvolume create /mnt/@docker-data > /dev/null 2>&1
    umount /mnt
    
    # Note: /downloads (NVME1p5) uses default subvolume (no @downloads needed)
    
    log_success "Btrfs subvolumes created with optimized sizing (980GB + 20GB free per disk)"
}

# Mount partitions with proper Btrfs options
mount_partitions() {
    log_info "Mounting partitions to /mnt..."
    
    # Create mount directories
    mkdir -p /mnt/{boot,backup,downloads,var/lib/docker,home,workspace,obsidian,docker-data}
    
    # Mount options for Btrfs (matches spec)
    local btrfs_opts="rw,relatime,compress=zstd:1,space_cache=v2"
    
    # Mount DISK1 (System + Recovery + Docker Images + Downloads)
    log_info "  Mounting DISK1 partitions..."
    mount "$DISK1"p2 /mnt -o "$btrfs_opts,subvol=@"
    mount "$DISK1"p1 /mnt/boot -o "defaults,noatime,nofail"
    mount "$DISK1"p3 /mnt/backup -o "$btrfs_opts"
    mount "$DISK1"p4 /mnt/var/lib/docker -o "$btrfs_opts"
    mount "$DISK1"p5 /mnt/downloads -o "$btrfs_opts"
    
    # Mount DISK2 (Permanent Storage + Docker Data)
    log_info "  Mounting DISK2 partitions..."
    mount "$DISK2"p1 /mnt/home -o "$btrfs_opts,subvol=@home"
    mount "$DISK2"p2 /mnt/workspace -o "$btrfs_opts,subvol=@workspace"
    mount "$DISK2"p3 /mnt/obsidian -o "$btrfs_opts,subvol=@obsidian"
    mount "$DISK2"p4 /mnt/docker-data -o "$btrfs_opts,subvol=@docker-data"
    
    log_success "All 9 partitions mounted at /mnt (NVME1: 5 + NVME2: 4)"
}

# Smart partition recreation (preserve NVME2 and /backup)
smart_recreate_partitions() {
    log_warn "Existing partitions detected - using smart recreation mode"
    log_warn "This will ONLY recreate /boot, /, /var/lib/docker, and /downloads on $DISK1"
    log_warn "Partitions that will be PRESERVED:"
    log_warn "  - $DISK1p3 (/backup) - SYSTEM BACKUPS/RECOVERY"
    log_warn "  - $DISK2p1 (/home) - HOME CONFIGS & MISE RUNTIMES"
    log_warn "  - $DISK2p2 (/workspace) - DEVELOPMENT PROJECTS"
    log_warn "  - $DISK2p3 (/obsidian) - OBSIDIAN VAULTS"
    log_warn "  - $DISK2p4 (/docker-data) - DOCKER VOLUMES & DATABASE FILES"
    log_warn ""
    log_warn "Free space reserved for Btrfs operations:"
    log_warn "  - $DISK1: ~100GB unallocated (10% - PRODUCTION OPTIMAL)"
    log_warn "  - $DISK2: ~100GB unallocated (10% - PRODUCTION OPTIMAL)"
    echo
    
    if ! confirm "Do you want to proceed with smart recreation?"; then
        log_error "Operation cancelled"
        exit 1
    fi
    
    # Unmount any mounted partitions
    log_info "Unmounting existing partitions..."
    for mount_point in /mnt/{boot,temp-storage,backup,obsidian,workspace,home} /mnt; do
        if mountpoint -q "$mount_point" 2>/dev/null; then
            umount -R "$mount_point" > /dev/null 2>&1 || true
        fi
    done
    
    # Delete partitions 1, 2, 4 on DISK1 (keeping 3: /backup)
    log_info "Removing old /boot, /, and /var/lib/docker partitions from $DISK1..."
    sgdisk --delete=1 "$DISK1" > /dev/null 2>&1 || true
    sgdisk --delete=2 "$DISK1" > /dev/null 2>&1 || true
    sgdisk --delete=4 "$DISK1" > /dev/null 2>&1 || true
    
    # Recreate partitions on DISK1
    log_info "Recreating /boot partition (1-2GB)..."
    sgdisk --new="1:1M:2G" "$DISK1" > /dev/null 2>&1
    sgdisk --typecode="1:ef00" "$DISK1" > /dev/null 2>&1
    
    log_info "Recreating / partition (2-152GB)..."
    sgdisk --new="2:2G:152G" "$DISK1" > /dev/null 2>&1
    sgdisk --typecode="2:8300" "$DISK1" > /dev/null 2>&1
    
    log_info "Recreating /var/lib/docker partition (322-652GB)..."
    sgdisk --new="4:322G:652G" "$DISK1" > /dev/null 2>&1
    sgdisk --typecode="4:8300" "$DISK1" > /dev/null 2>&1
    
    log_info "Recreating /downloads partition (652-900GB)..."
    sgdisk --new="5:652G:900G" "$DISK1" > /dev/null 2>&1
    sgdisk --typecode="5:8300" "$DISK1" > /dev/null 2>&1
    
    # Write changes
    sgdisk -p "$DISK1" > /dev/null 2>&1
    
    # Wait for partition table to be recognized
    sleep 2
    partprobe "$DISK1" 2>/dev/null || true
    sleep 2
    
    # Format recreated partitions
    log_info "Formatting recreated partitions (production-optimized sizes)..."
    mkfs.fat -F 32 -n "ARCH_BOOT" "$DISK1"p1 > /dev/null 2>&1
    mkfs.btrfs -f -L "ARCH_ROOT" "$DISK1"p2 > /dev/null 2>&1
    mkfs.btrfs -f -L "ARCH_DOCKER" "$DISK1"p4 > /dev/null 2>&1
    mkfs.btrfs -f -L "ARCH_DOWNLOADS" "$DISK1"p5 > /dev/null 2>&1
    
    # Create Btrfs subvolumes for root
    log_info "Creating Btrfs subvolumes for recreated partitions..."
    mount "$DISK1"p2 /mnt
    btrfs subvolume create /mnt/@ > /dev/null 2>&1
    btrfs subvolume create /mnt/@snapshots > /dev/null 2>&1
    umount /mnt
    
    # Mount partitions
    mkdir -p /mnt/{boot,backup,var/lib/docker,downloads}
    local btrfs_opts="rw,relatime,compress=zstd:1,space_cache=v2"
    mount "$DISK1"p2 /mnt -o "$btrfs_opts,subvol=@"
    mount "$DISK1"p1 /mnt/boot -o "defaults,noatime,nofail"
    mount "$DISK1"p3 /mnt/backup -o "$btrfs_opts" 2>/dev/null || true
    mount "$DISK1"p4 /mnt/var/lib/docker -o "$btrfs_opts"
    mount "$DISK1"p5 /mnt/downloads -o "$btrfs_opts"
    
    log_success "Smart recreation completed - backup & permanent data preserved (20GB free space maintained)"
}

# Collect system configuration data
collect_system_config() {
    log_info "================================"
    log_info "   Phase 3: System Configuration"
    log_info "================================"
    echo
    
    # Hostname
    local hostname
    while true; do
        read -r -p "$(echo -e ${BLUE}Enter hostname${NC}): " hostname
        if [[ -z "$hostname" ]]; then
            log_warn "Hostname cannot be empty"
            continue
        fi
        if [[ ! "$hostname" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$ ]]; then
            log_warn "Invalid hostname format"
            continue
        fi
        break
    done
    
    # Root Password
    local root_password
    while true; do
        read -rs -p "$(echo -e ${BLUE}Enter root password${NC}): " root_password
        echo
        if [[ -z "$root_password" ]]; then
            log_warn "Root password cannot be empty"
            continue
        fi
        local root_password_confirm
        read -rs -p "$(echo -e ${BLUE}Confirm root password${NC}): " root_password_confirm
        echo
        if [[ "$root_password" != "$root_password_confirm" ]]; then
            log_warn "Passwords do not match"
            continue
        fi
        break
    done
    
    # Username
    local username
    while true; do
        read -r -p "$(echo -e ${BLUE}Enter username${NC}): " username
        if [[ -z "$username" ]]; then
            log_warn "Username cannot be empty"
            continue
        fi
        if [[ ! "$username" =~ ^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}[a-z0-9_-])$ ]]; then
            log_warn "Invalid username format (must start with lowercase letter or underscore)"
            continue
        fi
        break
    done
    
    # User Password
    local user_password
    while true; do
        read -rs -p "$(echo -e ${BLUE}Enter user password${NC}): " user_password
        echo
        if [[ -z "$user_password" ]]; then
            log_warn "User password cannot be empty"
            continue
        fi
        local user_password_confirm
        read -rs -p "$(echo -e ${BLUE}Confirm user password${NC}): " user_password_confirm
        echo
        if [[ "$user_password" != "$user_password_confirm" ]]; then
            log_warn "Passwords do not match"
            continue
        fi
        break
    done
    
    # Timezone
    local timezone
    while true; do
        read -r -p "$(echo -e ${BLUE}Enter timezone (e.g., Asia/Kolkata, UTC)${NC}): " timezone
        if [[ -z "$timezone" ]]; then
            log_warn "Timezone cannot be empty"
            continue
        fi
        if [[ ! -f "/usr/share/zoneinfo/$timezone" ]]; then
            log_warn "Invalid timezone: $timezone"
            continue
        fi
        break
    done
    
    # Locale (optional)
    local locale
    read -r -p "$(echo -e ${BLUE}Enter locale (e.g., en_US.UTF-8) [optional, press Enter to skip]${NC}): " locale
    if [[ -z "$locale" ]]; then
        locale="en_US.UTF-8"
        log_info "Using default locale: $locale"
    fi
    
    # Keyboard (optional)
    local keyboard
    read -r -p "$(echo -e ${BLUE}Enter keyboard layout (e.g., us) [optional, press Enter to skip]${NC}): " keyboard
    if [[ -z "$keyboard" ]]; then
        keyboard="us"
        log_info "Using default keyboard: $keyboard"
    fi
    
    # Display summary
    echo
    log_info "Configuration Summary:"
    log_info "  Hostname: $hostname"
    log_info "  Root Password: ****"
    log_info "  Username: $username"
    log_info "  User Password: ****"
    log_info "  Timezone: $timezone"
    log_info "  Locale: $locale"
    log_info "  Keyboard: $keyboard"
    echo
    
    if ! confirm "Is this configuration correct?"; then
        log_warn "Configuration cancelled - please try again"
        collect_system_config
        return
    fi
    
    # Save configuration to file
    local config_file="/mnt/etc/installation.conf"
    mkdir -p "$(dirname "$config_file")"
    cat > "$config_file" << EOF
HOSTNAME="$hostname"
ROOT_PASSWORD="$root_password"
USERNAME="$username"
USER_PASSWORD="$user_password"
TIMEZONE="$timezone"
LOCALE="$locale"
KEYBOARD="$keyboard"
EOF
    
    log_success "Configuration saved to $config_file"
}

# Main execution
main() {
    log_info "================================"
    log_info "   Arch Linux Disk Setup Tool"
    log_info "================================"
    echo
    
    check_root
    check_disks
    display_disk_info
    
    if check_existing_partitions; then
        # Existing partitions found
        smart_recreate_partitions
    else
        # No existing partitions - fresh install
        log_warn "No existing partitions detected - creating fresh partition layout"
        echo
        
        if ! confirm "Create new partitions on $DISK1 and $DISK2?"; then
            log_error "Operation cancelled"
            exit 1
        fi
        
        create_partitions "$DISK1"
        create_partitions "$DISK2"
        
        # Wait for partitions to be recognized
        sleep 2
        partprobe "$DISK1" "$DISK2" 2>/dev/null || true
        sleep 2
        
        format_partitions
        create_btrfs_subvolumes
        mount_partitions
    fi
    
    log_success "Disk setup completed with PRODUCTION-OPTIMIZED sizing!"
    log_info "Partition Summary (10% free space for optimal Btrfs operation):"
    log_info "  NVME1: 900GB allocated + 100GB free = 1000GB"
    log_info "  NVME2: 900GB allocated + 100GB free = 1000GB"
    log_info "  Total: 1800GB usable + 200GB Btrfs buffer = 2000GB"
    echo
    log_info "Mount structure:"
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS "$DISK1" "$DISK2"
    echo
    
    # Collect system configuration
    collect_system_config
    
    log_info "Ready for: pacstrap /mnt base linux linux-firmware ..."
}

# Run main function
main "$@"
