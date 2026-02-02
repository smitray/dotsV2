#!/bin/bash

set -euo pipefail

# System Backup Script - Daily snapshots + Weekly full images
# Location: /usr/local/bin/system-backup.sh
# Cron: 0 3 * * * /usr/local/bin/system-backup.sh

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
BACKUP_ROOT="/backup"
SNAPSHOTS_DIR="$BACKUP_ROOT/snapshots"
IMAGES_DIR="$BACKUP_ROOT/images"
PACKAGES_DIR="$BACKUP_ROOT/packages"
CONFIGS_DIR="$BACKUP_ROOT/configs"
DATE=$(date +%Y%m%d-%H%M%S)
WEEK_DAY=$(date +%u)  # 1=Monday, 7=Sunday

# Ensure backup directories exist
mkdir -p "$SNAPSHOTS_DIR" "$IMAGES_DIR" "$PACKAGES_DIR" "$CONFIGS_DIR"

# Check if /backup partition is mounted
check_backup_mount() {
    if ! mountpoint -q "$BACKUP_ROOT" 2>/dev/null; then
        log_error "/backup partition not mounted!"
        exit 1
    fi
    
    # Check available space (need at least 10GB free)
    local available_space=$(df "$BACKUP_ROOT" | awk 'NR==2 {print $4}')
    if [[ $available_space -lt 10485760 ]]; then  # 10GB in KB
        log_warn "Low disk space on /backup: $(numfmt --to=iec $((available_space * 1024))) available"
    fi
}

# 1. Create daily Btrfs snapshot
create_snapshot() {
    log_info "Creating Btrfs snapshot of / ..."
    
    local snapshot_name="system-$DATE"
    local snapshot_path="$SNAPSHOTS_DIR/$snapshot_name"
    
    if btrfs subvolume snapshot -r / "$snapshot_path" > /dev/null 2>&1; then
        log_success "Snapshot created: $snapshot_name"
        
        # Store snapshot info
        echo "$DATE: $snapshot_name" >> "$SNAPSHOTS_DIR/.snapshot-log"
    else
        log_error "Failed to create snapshot"
        return 1
    fi
}

# 2. Backup package list
backup_packages() {
    log_info "Backing up package list..."
    
    local pkg_file="$PACKAGES_DIR/pkglist-$DATE.txt"
    local aur_file="$PACKAGES_DIR/aurpkglist-$DATE.txt"
    
    pacman -Qqe > "$pkg_file"
    pacman -Qqm > "$aur_file"
    
    log_success "Package lists backed up"
}

# 3. Backup system configs
backup_configs() {
    log_info "Backing up critical system configs..."
    
    local config_archive="$CONFIGS_DIR/configs-$DATE.tar.gz"
    
    tar -czf "$config_archive" \
        /etc/fstab \
        /etc/hostname \
        /etc/locale.conf \
        /etc/vconsole.conf \
        /etc/os-release \
        /etc/pacman.conf \
        /etc/pacman.d/mirrorlist \
        /boot/loader \
        /root/.bashrc \
        2>/dev/null || true
    
    log_success "Config backup completed: $(basename "$config_archive")"
}

# 4. Create weekly system image (Sunday only)
create_system_image() {
    # Only run on Sunday (day 7)
    if [[ "$WEEK_DAY" != "7" ]]; then
        return 0
    fi
    
    log_info "Creating weekly system image (this may take 10-20 minutes)..."
    
    local image_file="$IMAGES_DIR/system-img-$DATE.gz"
    
    if dd if=/dev/nvme0n1p2 bs=4M status=progress 2>&1 | gzip > "$image_file"; then
        local size=$(numfmt --to=iec $(stat -f%z "$image_file" 2>/dev/null || stat -c%s "$image_file"))
        log_success "System image created: $(basename "$image_file") ($size)"
        
        # Store image info
        echo "$DATE: $(basename "$image_file")" >> "$IMAGES_DIR/.image-log"
    else
        log_error "Failed to create system image"
        return 1
    fi
}

# 5. Cleanup old backups (retention policy)
cleanup_old_backups() {
    log_info "Cleaning up old backups (retention: 30 snapshots, 4 images, 10 package lists)..."
    
    # Keep only last 30 snapshots
    local snap_count=$(ls -1 "$SNAPSHOTS_DIR"/system-* 2>/dev/null | wc -l)
    if [[ $snap_count -gt 30 ]]; then
        log_info "Removing old snapshots (current: $snap_count, keeping: 30)..."
        ls -1dt "$SNAPSHOTS_DIR"/system-* 2>/dev/null | tail -n +31 | while read -r snapshot; do
            if btrfs subvolume delete "$snapshot" > /dev/null 2>&1; then
                log_info "  Deleted: $(basename "$snapshot")"
            fi
        done
    fi
    
    # Keep only last 4 system images
    local img_count=$(ls -1 "$IMAGES_DIR"/system-img-*.gz 2>/dev/null | wc -l)
    if [[ $img_count -gt 4 ]]; then
        log_info "Removing old images (current: $img_count, keeping: 4)..."
        ls -1dt "$IMAGES_DIR"/system-img-*.gz 2>/dev/null | tail -n +5 | while read -r image; do
            rm -f "$image"
            log_info "  Deleted: $(basename "$image")"
        done
    fi
    
    # Keep only last 10 package lists
    local pkg_count=$(ls -1 "$PACKAGES_DIR"/pkglist-*.txt 2>/dev/null | wc -l)
    if [[ $pkg_count -gt 10 ]]; then
        log_info "Removing old package lists (current: $pkg_count, keeping: 10)..."
        ls -1dt "$PACKAGES_DIR"/pkglist-*.txt 2>/dev/null | tail -n +11 | xargs -r rm -f
    fi
    
    log_success "Cleanup completed"
}

# Print backup summary
print_summary() {
    log_info "Backup Summary:"
    log_info "  Snapshots: $(ls -1 "$SNAPSHOTS_DIR"/system-* 2>/dev/null | wc -l)"
    log_info "  Images: $(ls -1 "$IMAGES_DIR"/system-img-*.gz 2>/dev/null | wc -l)"
    log_info "  /backup usage: $(du -sh "$BACKUP_ROOT" | awk '{print $1}')"
    echo
}

# Main execution
main() {
    log_info "========================================="
    log_info "   System Backup Script"
    log_info "========================================="
    echo
    
    check_backup_mount
    
    # Run all backup operations
    create_snapshot || log_error "Snapshot creation failed"
    backup_packages || log_error "Package backup failed"
    backup_configs || log_error "Config backup failed"
    create_system_image || log_error "System image creation failed"
    
    # Cleanup old backups
    cleanup_old_backups
    
    # Summary
    print_summary
    log_success "Backup cycle completed: $DATE"
}

# Error handling
trap 'log_error "Backup failed with exit code $?"' ERR

# Run main function
main "$@"
