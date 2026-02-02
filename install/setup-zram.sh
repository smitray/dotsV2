#!/bin/bash

set -euo pipefail

# Setup ZRAM (4GB Compressed RAM Disk)
# Provides in-memory compression for improved performance with limited memory

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
ZRAM_SIZE="4G"  # 4GB
ZRAM_SIZE_BYTES=$((4 * 1024 * 1024 * 1024))

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

# Check if ZRAM is available
check_zram_support() {
    log_info "Checking ZRAM kernel support..."
    
    if ! modprobe -n zram &>/dev/null; then
        log_error "ZRAM kernel module not available"
        log_error "Your kernel may not be compiled with ZRAM support"
        exit 1
    fi
    
    log_success "ZRAM kernel module available"
}

# Create systemd zram-generator configuration
setup_zram_generator() {
    log_info "Setting up ZRAM with zram-generator..."
    
    # Check if zram-generator package is installed
    if ! command -v zram-generator &> /dev/null; then
        log_warn "zram-generator not installed"
        read -r -p "$(echo -e ${YELLOW}Install zram-generator from AUR?${NC}) (yes/no): " response
        if [[ "$response" =~ ^[Yy][Ee][Ss]$ ]]; then
            log_info "Installing zram-generator (requires yay/paru)..."
            if command -v yay &> /dev/null; then
                yay -S zram-generator --noconfirm
            elif command -v paru &> /dev/null; then
                paru -S zram-generator --noconfirm
            else
                log_error "No AUR helper found (yay/paru). Please install manually:"
                log_error "  yay -S zram-generator"
                return 1
            fi
        else
            log_info "Using manual zram setup with systemd-zram-setup@"
            setup_zram_manual
            return
        fi
    fi
    
    # Create configuration
    log_info "Creating zram-generator configuration..."
    mkdir -p /etc/systemd/zram-generator.conf.d
    
    cat > /etc/systemd/zram-generator.conf.d/zram.conf << 'EOF'
# ZRAM Configuration
# Provides 4GB compressed in-memory swap for improved performance
#
# zram-generator automatically creates and manages ZRAM devices
# See: https://github.com/systemd/zram-generator

[zram0]
# Size of the ZRAM device
zram-size = min(ram, 4G)

# Compression algorithm
compression-algorithm = zstd

# Priority (higher priority than disk swap)
swap-priority = 100

# Filesystem type (none for swap, ext4 for block device)
fs-type = none
EOF
    
    log_success "ZRAM generator configuration created"
    
    # Reload systemd to apply changes
    systemctl daemon-reload
    log_success "Systemd daemon reloaded"
}

# Manual ZRAM setup (without zram-generator)
setup_zram_manual() {
    log_info "Setting up ZRAM manually..."
    
    # Create modprobe configuration
    log_info "Creating modprobe configuration..."
    cat > /etc/modprobe.d/zram.conf << 'EOF'
# ZRAM kernel module configuration
# Enables compression algorithm selection
options zram num_devices=1
EOF
    
    log_success "Modprobe configuration created"
    
    # Create systemd service to initialize ZRAM on boot
    log_info "Creating systemd service for ZRAM initialization..."
    cat > /etc/systemd/system/zram-init.service << 'EOF'
[Unit]
Description=Initialize ZRAM compression
Before=swap-zram.mount
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/init-zram.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
    
    # Create initialization script
    log_info "Creating ZRAM initialization script..."
    cat > /usr/local/bin/init-zram.sh << 'EOFSCRIPT'
#!/bin/bash
set -euo pipefail

# Initialize ZRAM device
modprobe zram num_devices=1

# Set compression algorithm (zstd is faster than lz4 with better compression)
echo zstd > /sys/block/zram0/comp_algorithm

# Set device size to 4GB
echo 4G > /sys/block/zram0/disksize

# Initialize as swap
mkswap /dev/zram0

# Enable swap
swapon -p 100 /dev/zram0
EOFSCRIPT
    
    chmod +x /usr/local/bin/init-zram.sh
    
    # Enable and start service
    systemctl daemon-reload
    systemctl enable zram-init.service
    systemctl start zram-init.service
    
    log_success "ZRAM manual service installed and started"
}

# Verify ZRAM
verify_zram() {
    log_info "Verifying ZRAM setup..."
    
    sleep 2  # Wait for ZRAM to initialize
    
    if [[ ! -b /dev/zram0 ]]; then
        log_error "ZRAM device not found"
        return 1
    fi
    
    local zram_size=$(cat /sys/block/zram0/disksize 2>/dev/null || echo "0")
    local zram_size_mb=$((zram_size / 1024 / 1024))
    
    log_success "ZRAM device found: /dev/zram0"
    log_info "  Configured size: ${zram_size_mb}MB"
    
    # Check if it's in swap
    if swapon --show 2>/dev/null | grep -q "/dev/zram0"; then
        log_success "ZRAM is active in swap"
    else
        log_warn "ZRAM not found in swap (may initialize on next boot)"
    fi
}

# Print summary
print_summary() {
    echo
    log_info "========================================"
    log_info "   ZRAM Setup Complete"
    log_info "========================================"
    echo
    log_info "Configuration:"
    log_info "  Device: /dev/zram0"
    log_info "  Size: ${ZRAM_SIZE}"
    log_info "  Compression: zstd (efficient compression)"
    log_info "  Swap Priority: 100 (higher than disk swap)"
    echo
    log_info "What is ZRAM?"
    log_info "  • Compresses RAM data in-memory"
    log_info "  • Provides additional virtual swap capacity"
    log_info "  • Faster than disk-based swap"
    log_info "  • Reduces memory pressure on system"
    echo
    log_info "Current Swap Status:"
    swapon --show 2>/dev/null || echo "No swap active yet"
    echo
    log_info "ZRAM Device Info:"
    if [[ -b /dev/zram0 ]]; then
        cat /sys/block/zram0/stat 2>/dev/null || echo "ZRAM device exists but not yet initialized"
    else
        echo "ZRAM device will initialize on next boot"
    fi
    echo
    log_info "Monitor ZRAM Usage:"
    log_info "  # Watch ZRAM compression ratio"
    log_info "  watch -n 1 'zramctl'"
    log_info "  # Or view swap usage"
    log_info "  free -h"
    log_info "  swapon --show"
    echo
}

# Cleanup function
cleanup_on_exit() {
    # Nothing to clean up on success
    :
}

trap cleanup_on_exit EXIT

# Main execution
main() {
    check_root
    
    log_info "========================================="
    log_info "   ZRAM Setup (4GB Compressed RAM)"
    log_info "========================================="
    echo
    
    check_zram_support
    setup_zram_generator
    verify_zram
    print_summary
    
    log_success "ZRAM setup completed!"
}

# Run main
main "$@"
