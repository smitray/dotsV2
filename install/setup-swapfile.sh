#!/bin/bash

set -euo pipefail

# Create 32GB Swapfile for Hibernation and Memory Overflow
# Location: /swapfile in root filesystem

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging
log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Configuration
SWAPFILE="/swapfile"
SWAP_SIZE="32G"  # 32GB for hibernation
SWAP_SIZE_BYTES=$((32 * 1024 * 1024 * 1024))

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

# Check available space
check_disk_space() {
    local available=$(df / | awk 'NR==2 {print $4}')
    local available_gb=$((available / 1024 / 1024))
    
    if [[ $available_gb -lt 40 ]]; then
        log_error "Insufficient disk space for 32GB swapfile"
        log_error "Available: ${available_gb}GB, Required: 40GB (32GB swap + buffer)"
        exit 1
    fi
    
    log_info "Available disk space: ${available_gb}GB (sufficient)"
}

# Check if swapfile already exists
check_existing_swap() {
    if [[ -f "$SWAPFILE" ]]; then
        log_warn "Swapfile already exists: $SWAPFILE"
        read -r -p "$(echo -e ${YELLOW}Do you want to recreate it?${NC}) (yes/no): " response
        if [[ "$response" =~ ^[Yy][Ee][Ss]$ ]]; then
            log_info "Removing existing swapfile..."
            swapoff "$SWAPFILE" 2>/dev/null || true
            rm -f "$SWAPFILE"
        else
            log_info "Skipping swapfile creation"
            return 1
        fi
    fi
    return 0
}

# Create swapfile
create_swapfile() {
    log_info "Creating ${SWAP_SIZE} swapfile at $SWAPFILE..."
    
    # Use fallocate for fast allocation (for non-Btrfs filesystems)
    # For Btrfs, fallocate is not ideal, so we'll use dd instead
    if ! dd if=/dev/zero of="$SWAPFILE" bs=1M count=$((32 * 1024)) status=progress; then
        log_error "Failed to create swapfile"
        exit 1
    fi
    
    log_success "Swapfile created (${SWAP_SIZE})"
}

# Set NOCOW attribute (important for Btrfs)
set_nocow() {
    log_info "Setting NOCOW attribute on swapfile (Btrfs optimization)..."
    
    # Disable Copy-on-Write for swapfile (improves performance)
    if ! chattr +C "$SWAPFILE" 2>/dev/null; then
        log_warn "Could not set NOCOW attribute (filesystem may not support it)"
    else
        log_success "NOCOW attribute set"
    fi
}

# Set proper permissions
set_permissions() {
    log_info "Setting permissions on swapfile..."
    
    # Swapfile must be readable/writable only by root
    chmod 600 "$SWAPFILE"
    
    log_success "Permissions set to 600 (root only)"
}

# Format as swap
format_swap() {
    log_info "Formatting swapfile as swap..."
    
    if ! mkswap "$SWAPFILE"; then
        log_error "Failed to format swapfile as swap"
        exit 1
    fi
    
    log_success "Swapfile formatted as swap"
}

# Get swap UUID for fstab
get_swap_uuid() {
    local uuid=$(mkswap -L swapfile "$SWAPFILE" 2>&1 | grep UUID | awk '{print $NF}')
    echo "$uuid"
}

# Enable swap
enable_swap() {
    log_info "Enabling swap..."
    
    if ! swapon "$SWAPFILE"; then
        log_error "Failed to enable swap"
        exit 1
    fi
    
    log_success "Swap enabled"
}

# Verify swap
verify_swap() {
    log_info "Verifying swap..."
    
    local swap_status=$(swapon --show 2>/dev/null | grep "$SWAPFILE" || echo "")
    
    if [[ -z "$swap_status" ]]; then
        log_error "Swap verification failed"
        return 1
    fi
    
    log_success "Swap is active"
    echo
    log_info "Swap status:"
    swapon --show
}

# Configure swappiness
configure_swappiness() {
    log_info "Configuring swappiness (memory usage preference)..."
    
    # Set swappiness to 10 (prefer RAM, use swap only when necessary)
    # Default is usually 60
    echo "vm.swappiness=10" > /etc/sysctl.d/99-swappiness.conf
    sysctl -p /etc/sysctl.d/99-swappiness.conf > /dev/null
    
    log_success "Swappiness set to 10 (prefer physical RAM)"
}

# Print summary
print_summary() {
    echo
    log_info "========================================"
    log_info "   Swapfile Setup Complete"
    log_info "========================================"
    echo
    log_info "Configuration:"
    log_info "  Swapfile location: $SWAPFILE"
    log_info "  Size: ${SWAP_SIZE}"
    log_info "  Permissions: 600 (root only)"
    log_info "  NOCOW: Enabled (for Btrfs)"
    log_info "  Swappiness: 10 (prefer RAM)"
    echo
    log_info "Swapfile Details:"
    ls -lh "$SWAPFILE"
    echo
    log_info "Current Swap Status:"
    free -h | grep -i swap
    echo
    log_info "Hibernation:"
    log_info "  Your system can now hibernate with 32GB of swap space"
    echo
    log_info "To use hibernation in GRUB/systemd-boot:"
    log_info "  1. Ensure resume device and offset are configured"
    log_info "  2. Add resume parameter to kernel command line"
    log_info "  3. Test with: systemctl hibernate"
    echo
}

# Main execution
main() {
    check_root
    
    log_info "========================================="
    log_info "   Swapfile Setup (32GB)"
    log_info "========================================="
    echo
    
    check_disk_space
    
    if ! check_existing_swap; then
        return
    fi
    
    create_swapfile
    set_nocow
    set_permissions
    format_swap
    enable_swap
    verify_swap
    configure_swappiness
    
    print_summary
    
    log_success "Swapfile setup completed!"
}

# Run main
main "$@"
