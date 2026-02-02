#!/bin/bash

set -euo pipefail

# PHASE 3: Complete System Setup After pacstrap/arch-chroot
# This script runs all post-installation configuration
# Should be executed INSIDE the chroot environment

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging
log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }
log_section() { echo -e "\n${CYAN}==== $* ====${NC}\n"; }

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (inside chroot)"
        exit 1
    fi
}

# Load installation configuration from Phase 2
load_config() {
    log_info "Loading installation configuration..."
    
    if [[ -f "/etc/installation.conf" ]]; then
        source "/etc/installation.conf"
        log_success "Configuration loaded"
    else
        log_error "Installation configuration not found"
        log_error "Expected: /etc/installation.conf"
        exit 1
    fi
    
    log_info "Hostname: $HOSTNAME"
    log_info "User: $USERNAME"
    log_info "Timezone: $TIMEZONE"
}

# Step 1: Install and configure bootloader
setup_bootloader() {
    log_section "Step 1: Setting up Bootloader"
    
    log_info "Installing systemd-boot..."
    bootctl install
    
    log_info "Creating bootloader configuration..."
    cat > /boot/loader/loader.conf << 'EOF'
default arch
timeout 3
console-mode keep
editor 0
EOF
    
    log_info "Creating Arch boot entry..."
    cat > /boot/loader/entries/arch.conf << EOF
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=/dev/nvme0n1p2 rw rootflags=subvol=@ resume=/dev/nvme0n1p2 resume_offset=0
EOF
    
    log_success "Bootloader configured"
}

# Step 2: Configure system settings
setup_system_config() {
    log_section "Step 2: Configuring System Settings"
    
    # Set hostname
    log_info "Setting hostname: $HOSTNAME"
    hostnamectl hostname "$HOSTNAME"
    
    # Set timezone
    log_info "Setting timezone: $TIMEZONE"
    timedatectl set-timezone "$TIMEZONE"
    
    # Set locale
    log_info "Setting locale: $LOCALE"
    echo "LANG=$LOCALE" > /etc/locale.conf
    echo "$LOCALE UTF-8" >> /etc/locale.gen
    locale-gen
    
    # Set keyboard layout (if applicable)
    if [[ -n "${KEYBOARD:-}" ]] && [[ "$KEYBOARD" != "us" ]]; then
        log_info "Setting keyboard layout: $KEYBOARD"
        echo "KEYMAP=$KEYBOARD" > /etc/vconsole.conf
        echo "FONT=ter-v32b" >> /etc/vconsole.conf
    fi
    
    log_success "System configuration completed"
}

# Step 3: Setup fstab
setup_fstab() {
    log_section "Step 3: Setting up /etc/fstab"
    
    log_info "Copying fstab configuration..."
    
    if [[ -f "/root/fstab-template" ]]; then
        cp /root/fstab-template /etc/fstab
    else
        log_warn "fstab template not found, using generated fstab"
        genfstab -U /mnt >> /etc/fstab
    fi
    
    log_success "fstab configured"
    log_info "Current fstab:"
    cat /etc/fstab
}

# Step 4: Create user account
create_user() {
    log_section "Step 4: Creating User Account"
    
    log_info "Creating user: $USERNAME"
    
    # Create user with home directory
    useradd -m -s /bin/bash "$USERNAME"
    
    # Set user password
    echo "$USERNAME:$USER_PASSWORD" | chpasswd
    
    # Add user to sudo group (if sudo is installed)
    if command -v sudo &> /dev/null; then
        usermod -aG wheel,audio,video,storage,input "$USERNAME"
        log_success "User added to groups: wheel, audio, video, storage, input"
    fi
    
    log_success "User account created"
}

# Step 5: Set root password
setup_root_password() {
    log_section "Step 5: Setting Root Password"
    
    echo "root:$ROOT_PASSWORD" | chpasswd
    log_success "Root password configured"
}

# Step 6: Setup Swapfile
setup_swapfile() {
    log_section "Step 6: Setting up 32GB Swapfile"
    
    log_info "Creating 32GB swapfile..."
    
    # Create swapfile
    dd if=/dev/zero of=/swapfile bs=1M count=$((32 * 1024)) status=progress
    
    # Set NOCOW attribute (important for Btrfs)
    chattr +C /swapfile 2>/dev/null || log_warn "Could not set NOCOW attribute"
    
    # Set permissions
    chmod 600 /swapfile
    
    # Format and enable
    mkswap /swapfile
    swapon /swapfile
    
    # Set swappiness
    echo "vm.swappiness=10" > /etc/sysctl.d/99-swappiness.conf
    sysctl -p /etc/sysctl.d/99-swappiness.conf > /dev/null
    
    log_success "Swapfile created and enabled (32GB)"
}

# Step 7: Setup ZRAM (optional)
setup_zram() {
    log_section "Step 7: Setting up ZRAM (4GB Compressed RAM)"
    
    log_info "Checking ZRAM kernel support..."
    
    if modprobe -n zram &>/dev/null; then
        log_info "Creating ZRAM configuration..."
        
        mkdir -p /etc/systemd/zram-generator.conf.d
        cat > /etc/systemd/zram-generator.conf.d/zram.conf << 'EOF'
[zram0]
zram-size = min(ram, 4G)
compression-algorithm = zstd
swap-priority = 100
fs-type = none
EOF
        
        log_success "ZRAM configured"
    else
        log_warn "ZRAM not supported by kernel (optional, skipping)"
    fi
}

# Step 8: Setup backup automation
setup_backup() {
    log_section "Step 8: Setting up Backup Automation"
    
    if [[ -f "/root/system-backup.sh" ]]; then
        log_info "Installing backup script..."
        cp /root/system-backup.sh /usr/local/bin/system-backup.sh
        chmod +x /usr/local/bin/system-backup.sh
        
        # Create backup directories
        mkdir -p /backup/{snapshots,images,packages,configs}
        touch /backup/snapshots/.snapshot-log
        touch /backup/images/.image-log
        
        # Setup cron job (daily at 3 AM)
        log_info "Installing cron job for daily backups..."
        (crontab -l 2>/dev/null; echo "0 3 * * * /usr/local/bin/system-backup.sh >> /var/log/system-backup.log 2>&1") | crontab -
        
        # Setup log rotation
        cat > /etc/logrotate.d/system-backup << 'EOF'
/var/log/system-backup.log {
    daily
    rotate 30
    compress
    delaycompress
    notifempty
    create 0640 root root
    missingok
}
EOF
        
        log_success "Backup automation installed"
    else
        log_warn "Backup script not found (optional, skipping)"
    fi
}

# Step 9: Install essential packages
install_packages() {
    log_section "Step 9: Installing Essential Packages"
    
    log_info "Updating pacman database..."
    pacman -Sy
    
    log_info "Installing essential packages..."
    pacman -S --noconfirm \
        base-devel \
        git \
        vim \
        nano \
        curl \
        wget \
        htop \
        neofetch \
        man-db \
        btrfs-progs \
        cronie \
        zstd \
        linux-headers
    
    log_info "Enabling cron service..."
    systemctl enable cronie
    
    log_success "Essential packages installed"
}

# Step 10: Enable essential services
enable_services() {
    log_section "Step 10: Enabling Essential Services"
    
    log_info "Enabling system services..."
    
    systemctl enable systemd-timesyncd
    systemctl enable systemd-networkd
    systemctl enable systemd-resolved
    
    # Cron daemon for backups
    systemctl enable cronie
    
    log_success "System services enabled"
}

# Step 11: Configure pacman
configure_pacman() {
    log_section "Step 11: Configuring Pacman"
    
    log_info "Enabling parallel downloads and fancy progress bar..."
    
    # Backup original
    cp /etc/pacman.conf /etc/pacman.conf.bak
    
    # Enable parallel downloads (faster)
    sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
    sed -i 's/^ParallelDownloads = .*/ParallelDownloads = 10/' /etc/pacman.conf
    
    # Enable colors
    sed -i 's/^#Color/Color/' /etc/pacman.conf
    
    # Enable ILoveCandy (fancy progress bar)
    sed -i '/^Color/a ILoveCandy' /etc/pacman.conf
    
    log_success "Pacman configured"
}

# Step 12: Print summary
print_summary() {
    log_section "Installation Summary"
    
    cat << EOF
${GREEN}✓ System Installation Complete!${NC}

Configuration Details:
  Hostname:     $HOSTNAME
  User:         $USERNAME
  Timezone:     $TIMEZONE
  Locale:       $LOCALE
  Keyboard:     ${KEYBOARD:-us}

Partition Layout (NVME 1 - System):
  /boot/          (2GB, FAT32)
  /               (150GB, Btrfs)
  /backup/        (200GB, Btrfs) - System backups
  /temp-storage/  (648GB, Btrfs) - Temporary files

Partition Layout (NVME 2 - Permanent):
  /home/          (150GB, Btrfs)
  /workspace/     (400GB, Btrfs)
  /obsidian/      (100GB, Btrfs)
  /archive/       (350GB, Btrfs)

Memory Configuration:
  Swapfile:  32GB (for hibernation)
  ZRAM:      4GB (compressed RAM)
  Swappiness: 10 (prefer physical RAM)

Backup Configuration:
  Schedule:  Daily at 03:00 AM
  Snapshots: 30-day retention
  Images:    4-week retention
  Location:  /backup partition
  Exclude:   /temp-storage (temporary files)

Next Steps:
  1. Exit chroot and unmount all partitions
  2. Remove installation USB
  3. Reboot system
  4. Login with user: $USERNAME
  5. Run setup-user-symlinks.sh to configure home directories

To verify installation:
  • Check partition layout: lsblk
  • Check swap: free -h
  • Check mounts: df -h
  • Check backups: ls -lh /backup/

Recovery:
  See RECOVERY_GUIDE.md for system recovery procedures
EOF
}

# Main execution
main() {
    check_root
    load_config
    
    log_info "================================================="
    log_info "   PHASE 3: System Installation & Configuration"
    log_info "================================================="
    echo
    
    setup_bootloader
    setup_system_config
    setup_fstab
    create_user
    setup_root_password
    setup_swapfile
    setup_zram
    configure_pacman
    install_packages
    enable_services
    setup_backup
    
    print_summary
    
    log_success "Phase 3 completed! System is ready to reboot."
}

# Error handling
trap 'log_error "Setup failed at line $LINENO"' ERR

# Run main
main "$@"
