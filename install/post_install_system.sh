#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }
log_step() { echo -e "\n${MAGENTA}>>> $*${NC}\n"; }

# Hardware configuration
DISK1="/dev/nvme0n1"
DISK2="/dev/nvme1n1"

# Validation functions
validate_timezone() {
    local tz=$1
    if timedatectl list-timezones | grep -q "^$tz$"; then
        return 0
    else
        return 1
    fi
}

validate_locale() {
    local locale=$1
    if locale -a | grep -q "^${locale}$"; then
        return 0
    else
        return 1
    fi
}

is_in_chroot() {
    if [[ "$(stat -c %d:%i /)" != "$(stat -c %d:%i /proc/1/root/.)" ]]; then
        return 0
    else
        return 1
    fi
}

# Check root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (from within chroot)"
        exit 1
    fi
}

# Collect system information interactively
collect_system_info() {
    log_step "SYSTEM INFORMATION SETUP"
    
    # Hostname
    local hostname
    while true; do
        read -r -p "Enter hostname (e.g., asus-tuf-gaming): " hostname
        if [[ -n "$hostname" ]] && [[ ! "$hostname" =~ [^a-zA-Z0-9-] ]]; then
            break
        else
            log_error "Invalid hostname. Use only letters, numbers, and hyphens."
        fi
    done
    
    # Timezone
    local timezone
    while true; do
        read -r -p "Enter timezone (e.g., Asia/Kolkata, America/New_York): " timezone
        if validate_timezone "$timezone"; then
            break
        else
            log_error "Invalid timezone. Run 'timedatectl list-timezones' for valid options."
        fi
    done
    
    # Locale
    local locale="en_US.UTF-8"
    read -r -p "Enter locale (default: en_US.UTF-8): " -e -i "$locale" locale
    if ! validate_locale "$locale"; then
        log_warn "Locale $locale not found, using en_US.UTF-8"
        locale="en_US.UTF-8"
    fi
    
    # Keyboard layout
    local keymap="us"
    read -r -p "Enter keyboard layout (default: us): " -e -i "$keymap" keymap
    
    # Root password
    local root_pass root_pass_confirm
    while true; do
        read -rs -p "Enter root password: " root_pass
        echo
        read -rs -p "Confirm root password: " root_pass_confirm
        echo
        if [[ "$root_pass" == "$root_pass_confirm" ]]; then
            if [[ ${#root_pass} -lt 8 ]]; then
                log_warn "Password is short (less than 8 characters)"
            fi
            break
        else
            log_error "Passwords do not match. Try again."
        fi
    done
    
    # Primary username
    local username
    while true; do
        read -r -p "Enter primary username (e.g., debasmitr): " username
        if [[ -n "$username" ]] && [[ ! "$username" =~ [^a-zA-Z0-9_-] ]]; then
            break
        else
            log_error "Invalid username. Use only letters, numbers, underscore, and hyphens."
        fi
    done
    
    # Primary user password
    local user_pass user_pass_confirm
    while true; do
        read -rs -p "Enter password for $username: " user_pass
        echo
        read -rs -p "Confirm password: " user_pass_confirm
        echo
        if [[ "$user_pass" == "$user_pass_confirm" ]]; then
            if [[ ${#user_pass} -lt 8 ]]; then
                log_warn "Password is short (less than 8 characters)"
            fi
            break
        else
            log_error "Passwords do not match. Try again."
        fi
    done
    
    # Summary and confirmation
    echo
    log_info "=== CONFIGURATION SUMMARY ==="
    echo "  Hostname:       $hostname"
    echo "  Timezone:       $timezone"
    echo "  Locale:         $locale"
    echo "  Keyboard:       $keymap"
    echo "  Root Password:  ****"
    echo "  Username:       $username"
    echo "  User Password:  ****"
    echo "================================"
    echo
    
    read -r -p "Is this correct? (yes/no): " confirm
    if [[ ! "$confirm" =~ ^[Yy][Ee][Ss]$ ]]; then
        log_error "Configuration cancelled. Please run again."
        exit 1
    fi
    
    # Export for use in other functions
    export SYS_HOSTNAME="$hostname"
    export SYS_TIMEZONE="$timezone"
    export SYS_LOCALE="$locale"
    export SYS_KEYMAP="$keymap"
    export SYS_ROOT_PASS="$root_pass"
    export SYS_USERNAME="$username"
    export SYS_USER_PASS="$user_pass"
}

# Setup locale and timezone
setup_locale_timezone() {
    log_step "Setting up locale and timezone..."
    
    # Generate locale
    echo "$SYS_LOCALE UTF-8" >> /etc/locale.gen
    locale-gen > /dev/null 2>&1
    
    # Set locale
    echo "LANG=$SYS_LOCALE" > /etc/locale.conf
    echo "KEYMAP=$SYS_KEYMAP" > /etc/vconsole.conf
    
    # Set timezone
    ln -sf "/usr/share/zoneinfo/$SYS_TIMEZONE" /etc/localtime
    
    # Sync hardware clock
    hwclock --systohc --utc
    
    log_success "Locale and timezone configured"
}

# Setup hostname and networking
setup_hostname() {
    log_step "Setting up hostname and network..."
    
    echo "$SYS_HOSTNAME" > /etc/hostname
    
    # Configure hosts file
    cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${SYS_HOSTNAME}.localdomain ${SYS_HOSTNAME}
EOF
    
    # Enable networking
    systemctl enable systemd-networkd.service > /dev/null 2>&1
    systemctl enable systemd-resolved.service > /dev/null 2>&1
    
    log_success "Hostname configured: $SYS_HOSTNAME"
}

# Create root user and primary user
setup_users() {
    log_step "Creating users..."
    
    # Set root password
    echo "root:$SYS_ROOT_PASS" | chpasswd
    
    # Create primary user
    useradd -m -G wheel -s /bin/bash "$SYS_USERNAME"
    echo "$SYS_USERNAME:$SYS_USER_PASS" | chpasswd
    
    # Enable sudo for wheel group
    echo "%wheel ALL=(ALL:ALL) ALL" | EDITOR='tee -a' visudo > /dev/null 2>&1 || \
    echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers.d/wheel
    
    log_success "Users created: root and $SYS_USERNAME"
}

# Create Btrfs subvolumes
setup_btrfs_subvolumes() {
    log_step "Creating Btrfs subvolumes..."
    
    # Temporary mount for subvolume creation
    mkdir -p /mnt/btrfs_tmp
    
    # Mount DISK1 root
    mount "$DISK1"p2 /mnt/btrfs_tmp
    
    # Create root subvolume if not exists
    if ! btrfs subvolume list /mnt/btrfs_tmp | grep -q "@"; then
        btrfs subvolume create /mnt/btrfs_tmp/@
        log_info "Created @ subvolume on $DISK1"p2
    fi
    
    # Create snapshots subvolume
    if ! btrfs subvolume list /mnt/btrfs_tmp | grep -q "@snapshots"; then
        btrfs subvolume create /mnt/btrfs_tmp/@snapshots
        log_info "Created @snapshots subvolume on $DISK1"p2
    fi
    
    # Create persistent subvolume
    if ! btrfs subvolume list /mnt/btrfs_tmp | grep -q "@persistent"; then
        btrfs subvolume create /mnt/btrfs_tmp/@persistent
        log_info "Created @persistent subvolume on $DISK1"p3
    fi
    
    umount /mnt/btrfs_tmp
    
    # Mount DISK2
    mount "$DISK2"p1 /mnt/btrfs_tmp
    
    # Create home subvolume
    if ! btrfs subvolume list /mnt/btrfs_tmp | grep -q "@home"; then
        btrfs subvolume create /mnt/btrfs_tmp/@home
        log_info "Created @home subvolume on $DISK2"p1
    fi
    
    umount /mnt/btrfs_tmp
    
    # Mount DISK2 workspace
    mount "$DISK2"p2 /mnt/btrfs_tmp
    
    if ! btrfs subvolume list /mnt/btrfs_tmp | grep -q "@workspace"; then
        btrfs subvolume create /mnt/btrfs_tmp/@workspace
        log_info "Created @workspace subvolume on $DISK2"p2
    fi
    
    umount /mnt/btrfs_tmp
    
    # Mount DISK2 data
    mount "$DISK2"p3 /mnt/btrfs_tmp
    
    if ! btrfs subvolume list /mnt/btrfs_tmp | grep -q "@data"; then
        btrfs subvolume create /mnt/btrfs_tmp/@data
        log_info "Created @data subvolume on $DISK2"p3
    fi
    
    umount /mnt/btrfs_tmp
    rmdir /mnt/btrfs_tmp
    
    log_success "Btrfs subvolumes created/verified"
}

# Create swap file
setup_swapfile() {
    log_step "Creating 32GB swapfile..."
    
    # Create swapfile
    touch /swapfile
    chmod 600 /swapfile
    
    # Set NOCOW attribute for Btrfs
    chattr +C /swapfile
    
    # Create swap
    dd if=/dev/zero of=/swapfile bs=1M count=32768 status=progress
    mkswap /swapfile > /dev/null 2>&1
    swapon /swapfile
    
    # Add to fstab
    echo "/swapfile none swap sw 0 0" >> /etc/fstab
    
    log_success "Swapfile created (32GB) with NOCOW attribute"
}

# Configure Btrfs mount options in fstab
setup_fstab() {
    log_step "Configuring fstab with Btrfs mount options..."
    
    # Backup existing fstab
    cp /etc/fstab /etc/fstab.bak
    
    # Create new fstab with proper Btrfs options
    cat > /etc/fstab << 'EOF'
# Root partition with compression
UUID=$(blkid -s UUID -o value /dev/nvme0n1p2) /              btrfs   rw,relatime,compress=zstd:1,space_cache=v2,subvol=@,discard=async 0 0

# Boot partition
UUID=$(blkid -s UUID -o value /dev/nvme0n1p1) /boot          vfat    rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro 0 2

# Persistent partition
UUID=$(blkid -s UUID -o value /dev/nvme0n1p3) /persistent    btrfs   rw,relatime,compress=zstd:1,space_cache=v2,discard=async 0 0

# Home partition
UUID=$(blkid -s UUID -o value /dev/nvme1n1p1) /home          btrfs   rw,relatime,compress=zstd:1,space_cache=v2,discard=async 0 0

# Workspace partition
UUID=$(blkid -s UUID -o value /dev/nvme1n1p2) /workspace     btrfs   rw,relatime,compress=zstd:1,space_cache=v2,discard=async 0 0

# Data partition
UUID=$(blkid -s UUID -o value /dev/nvme1n1p3) /data          btrfs   rw,relatime,compress=zstd:1,space_cache=v2,discard=async 0 0

# Swapfile
/swapfile                                       none          swap    sw                                                                   0 0
EOF
    
    # Generate proper fstab using actual UUIDs
    local uuid_nvme0n1p2=$(blkid -s UUID -o value /dev/nvme0n1p2)
    local uuid_nvme0n1p1=$(blkid -s UUID -o value /dev/nvme0n1p1)
    local uuid_nvme0n1p3=$(blkid -s UUID -o value /dev/nvme0n1p3)
    local uuid_nvme1n1p1=$(blkid -s UUID -o value /dev/nvme1n1p1)
    local uuid_nvme1n1p2=$(blkid -s UUID -o value /dev/nvme1n1p2)
    local uuid_nvme1n1p3=$(blkid -s UUID -o value /dev/nvme1n1p3)
    
    cat > /etc/fstab << EOF
# Root partition with compression
UUID=$uuid_nvme0n1p2 /              btrfs   rw,relatime,compress=zstd:1,space_cache=v2,subvol=@,discard=async 0 0

# Boot partition
UUID=$uuid_nvme0n1p1 /boot          vfat    rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro 0 2

# Persistent partition
UUID=$uuid_nvme0n1p3 /persistent    btrfs   rw,relatime,compress=zstd:1,space_cache=v2,discard=async 0 0

# Home partition
UUID=$uuid_nvme1n1p1 /home          btrfs   rw,relatime,compress=zstd:1,space_cache=v2,discard=async 0 0

# Workspace partition
UUID=$uuid_nvme1n1p2 /workspace     btrfs   rw,relatime,compress=zstd:1,space_cache=v2,discard=async 0 0

# Data partition
UUID=$uuid_nvme1n1p3 /data          btrfs   rw,relatime,compress=zstd:1,space_cache=v2,discard=async 0 0

# Swapfile
/swapfile                            none    swap    sw                                                                   0 0
EOF
    
    log_success "fstab configured with Btrfs mount options"
}

# Install bootloader
setup_bootloader() {
    log_step "Installing and configuring GRUB bootloader..."
    
    # Install GRUB
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB > /dev/null 2>&1
    
    # Configure GRUB with NVIDIA parameters
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet nvidia_drm.modeset=1"/' /etc/default/grub
    sed -i 's/GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="nvidia_drm.modeset=1"/' /etc/default/grub
    
    # Generate GRUB config
    grub-mkconfig -o /boot/grub/grub.cfg > /dev/null 2>&1
    
    log_success "GRUB bootloader installed with NVIDIA parameters"
}

# Install essential packages
install_packages() {
    log_step "Installing essential packages..."
    
    local packages=(
        # System utilities
        base-devel
        git
        vim
        nano
        curl
        wget
        
        # Btrfs tools
        btrfs-progs
        snapper
        
        # NVIDIA drivers
        nvidia
        nvidia-utils
        nvidia-dkms
        
        # GPU support
        cuda
        
        # Display server
        wayland
        hyprland
        
        # Network
        networkmanager
        
        # ALSA/PulseAudio
        alsa-utils
        pipewire
        pipewire-alsa
        
        # Fonts
        ttf-dejavu
        noto-fonts
        
        # Development
        python3
        nodejs
        npm
    )
    
    log_info "Installing ${#packages[@]} packages (this may take a while)..."
    pacman -Sy --noconfirm "${packages[@]}" > /dev/null 2>&1 || {
        log_warn "Some packages may have failed to install"
    }
    
    log_success "Essential packages installed"
}

# Setup mkinitcpio for NVIDIA
setup_initramfs() {
    log_step "Configuring mkinitcpio for NVIDIA..."
    
    # Backup original
    cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.bak
    
    # Update MODULES
    sed -i 's/^MODULES=.*/MODULES=(amdgpu nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    
    # Update HOOKS
    sed -i 's/^HOOKS=.*/HOOKS=(base systemd autodetect modconf kms keyboard block filesystems btrfs fsck)/' /etc/mkinitcpio.conf
    
    # Regenerate initramfs
    mkinitcpio -P > /dev/null 2>&1
    
    log_success "mkinitcpio configured for NVIDIA and Btrfs"
}

# Final summary
show_summary() {
    log_step "INSTALLATION COMPLETE"
    
    cat << EOF
${GREEN}================================
   Post-Installation Summary
================================${NC}

System Information:
  Hostname:   $SYS_HOSTNAME
  Timezone:   $SYS_TIMEZONE
  Locale:     $SYS_LOCALE
  
Users:
  Root:       Set with secure password
  Primary:    $SYS_USERNAME (in wheel group)
  
Storage:
  Swap:       32GB swapfile at /swapfile
  
Bootloader:
  GRUB:       Installed with NVIDIA support
  
NVIDIA Configuration:
  Module:     nvidia_drm.modeset=1
  Drivers:    nvidia, nvidia-utils, nvidia-dkms
  CUDA:       Installed
  
Next Steps:
${YELLOW}1. Exit chroot: exit${NC}
${YELLOW}2. Reboot: reboot${NC}
${YELLOW}3. Login as: $SYS_USERNAME${NC}
${YELLOW}4. Run post-login scripts:${NC}
${YELLOW}   - ./install/setup_xdg_directories.sh${NC}
${YELLOW}   - ./install/configure_snapper.sh${NC}
${YELLOW}   - ./install/setup_dev_workspace.sh${NC}

EOF
}

# Main execution
main() {
    log_info "================================"
    log_info "   Arch Linux Post-Install"
    log_info "================================"
    echo
    
    check_root
    
    # Collect user input
    collect_system_info
    
    # Configure system
    setup_locale_timezone
    setup_hostname
    setup_users
    setup_btrfs_subvolumes
    setup_swapfile
    setup_fstab
    setup_initramfs
    install_packages
    setup_bootloader
    
    # Show summary
    show_summary
}

main "$@"
