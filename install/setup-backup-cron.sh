#!/bin/bash

set -euo pipefail

# Setup Backup Automation with Cron

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

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

# Install backup script
install_backup_script() {
    log_info "Installing system-backup.sh..."
    
    if [[ -f "$(dirname "$0")/system-backup.sh" ]]; then
        cp "$(dirname "$0")/system-backup.sh" /usr/local/bin/system-backup.sh
        chmod +x /usr/local/bin/system-backup.sh
        log_success "Backup script installed to /usr/local/bin/system-backup.sh"
    else
        log_error "system-backup.sh not found in script directory"
        exit 1
    fi
}

# Setup cron job
setup_cron() {
    log_info "Setting up cron job..."
    
    # Create cron job entry (daily at 3 AM)
    local cron_job="0 3 * * * /usr/local/bin/system-backup.sh >> /var/log/system-backup.log 2>&1"
    
    # Check if cron job already exists
    if crontab -l 2>/dev/null | grep -q "system-backup.sh"; then
        log_warn "Cron job already exists, skipping..."
        return
    fi
    
    # Add cron job
    (crontab -l 2>/dev/null; echo "$cron_job") | crontab -
    log_success "Cron job installed: Daily backup at 03:00 AM"
    log_info "Log file: /var/log/system-backup.log"
}

# Setup logrotate for backup logs
setup_logrotate() {
    log_info "Setting up log rotation..."
    
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
    
    log_success "Log rotation configured"
}

# Create backup directory structure
create_backup_structure() {
    log_info "Creating backup directory structure..."
    
    mkdir -p /backup/{snapshots,images,packages,configs}
    
    # Create log files
    touch /backup/snapshots/.snapshot-log
    touch /backup/images/.image-log
    
    log_success "Backup directories created"
}

# Test backup script
test_backup() {
    log_info "Running test backup (this may take a few minutes)..."
    echo
    
    if /usr/local/bin/system-backup.sh; then
        log_success "Test backup completed successfully!"
        return 0
    else
        log_error "Test backup failed"
        return 1
    fi
}

# Print summary
print_summary() {
    echo
    log_info "========================================"
    log_info "   Backup Automation Setup Complete"
    log_info "========================================"
    echo
    log_info "Configuration:"
    log_info "  Backup script: /usr/local/bin/system-backup.sh"
    log_info "  Schedule: Daily at 03:00 AM"
    log_info "  Log file: /var/log/system-backup.log"
    log_info "  Backup location: /backup"
    echo
    log_info "Directory Structure:"
    log_info "  /backup/snapshots/   - Daily Btrfs snapshots (keep 30)"
    log_info "  /backup/images/      - Weekly full system images (keep 4)"
    log_info "  /backup/packages/    - Package lists (keep 10)"
    log_info "  /backup/configs/     - System configs (keep all)"
    echo
    log_info "Retention Policy:"
    log_info "  Btrfs Snapshots: Last 30 days (daily)"
    log_info "  System Images: Last 4 weeks (weekly)"
    log_info "  Package Lists: Last 10 backups"
    echo
    log_info "Excluded from Backup:"
    log_info "  /temp-storage (temporary files are not backed up)"
    echo
    log_info "Manual Commands:"
    log_info "  # Run backup manually"
    log_info "  sudo /usr/local/bin/system-backup.sh"
    echo
    log_info "  # View cron log"
    log_info "  tail -f /var/log/system-backup.log"
    echo
    log_info "  # List available snapshots"
    log_info "  ls -lh /backup/snapshots/"
    echo
    log_info "  # List available images"
    log_info "  ls -lh /backup/images/"
    echo
}

# Main execution
main() {
    check_root
    
    log_info "========================================="
    log_info "   Backup Automation Setup"
    log_info "========================================="
    echo
    
    install_backup_script
    create_backup_structure
    setup_cron
    setup_logrotate
    
    print_summary
    
    # Ask to run test backup
    read -r -p "$(echo -e ${YELLOW}Do you want to run a test backup now?${NC}) (yes/no): " response
    if [[ "$response" =~ ^[Yy][Ee][Ss]$ ]]; then
        test_backup
    else
        log_info "Skipping test backup. First backup will run at 03:00 AM."
    fi
    
    log_success "Setup completed!"
}

# Run main
main "$@"
