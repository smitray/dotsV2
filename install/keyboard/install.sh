#!/bin/bash
# keyd Configuration Installation Script for Keychron K2 V2
# This script installs and configures keyd for Arch Linux with Hyprland

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/keyd"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"
BIN_DIR="$HOME/.local/bin"

# Configuration paths
KEYD_SYSTEM_CONFIG="/etc/keyd/default.conf"
KEYD_USER_CONFIG="$HOME/.config/keyd/app.conf"
SYSTEMD_SERVICE="/etc/systemd/system/keyd.service"

# Panic key information
PANIC_KEY="backspace escape enter"
PANIC_INSTRUCTION="Hold ${PANIC_KEY} simultaneously to terminate keyd if it locks your input"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Keychron K2 V2 keyd Configuration Installer  ${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should be run as a regular user, not root."
        echo "Sudo privileges will be requested for specific operations."
        exit 1
    fi
}

# Function to check if keyd is installed
check_keyd_installed() {
    if command -v keyd &> /dev/null; then
        print_success "keyd is already installed (version: $(keyd --version | head -n1))"
        return 0
    else
        print_warning "keyd is not installed"
        return 1
    fi
}

# Function to install keyd
install_keyd() {
    print_info "Installing keyd..."

    # Install keyd via pacman
    sudo pacman -S --noconfirm --needed keyd || {
        print_error "Failed to install keyd via pacman"
        print_info "Please ensure you have sudo privileges and an active internet connection"
        exit 1
    }

    print_success "keyd installed successfully"
}

# Function to backup existing configurations
backup_configs() {
    print_info "Backing up existing configurations..."

    BACKUP_DIR="$HOME/.keyd_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    if [ -f "$KEYD_SYSTEM_CONFIG" ]; then
        sudo cp "$KEYD_SYSTEM_CONFIG" "$BACKUP_DIR/default.conf"
        print_info "Backed up /etc/keyd/default.conf"
    fi

    if [ -f "$KEYD_USER_CONFIG" ]; then
        cp "$KEYD_USER_CONFIG" "$BACKUP_DIR/app.conf"
        print_info "Backed up ~/.config/keyd/app.conf"
    fi

    print_success "Backups created in $BACKUP_DIR"
}

# Function to copy system configuration
copy_system_config() {
    print_info "Copying system configuration to /etc/keyd/..."

    # Create keyd directory if it doesn't exist
    sudo mkdir -p /etc/keyd

    # Copy the main configuration file
    sudo cp "$CONFIG_DIR/default.conf" "$KEYD_SYSTEM_CONFIG"

    # Set proper permissions
    sudo chown root:root "$KEYD_SYSTEM_CONFIG"
    sudo chmod 644 "$KEYD_SYSTEM_CONFIG"

    print_success "System configuration installed to $KEYD_SYSTEM_CONFIG"
}

# Function to copy user configuration
copy_user_config() {
    print_info "Copying user configuration to ~/.config/keyd/..."

    # Create keyd directory if it doesn't exist
    mkdir -p "$HOME/.config/keyd"

    # Copy the application-specific configuration
    cp "$CONFIG_DIR/app.conf" "$KEYD_USER_CONFIG"

    print_success "User configuration installed to $KEYD_USER_CONFIG"
}

# Function to detect keyboard device
detect_keyboard() {
    print_info "Detecting keyboard devices..."

    # List available keyboard devices
    echo -e "${YELLOW}Available keyboard devices:${NC}"
    ls -la /dev/input/by-path/ | grep -i "event-kbd" || echo "  (No keyboard devices found)"

    # Try to detect Keychron keyboards specifically
    KEYCHRON_DEVICES=$(ls -la /dev/input/by-path/ | grep -i "keychron" || true)
    if [ -n "$KEYCHRON_DEVICES" ]; then
        echo -e "${GREEN}Keychron keyboard detected:${NC}"
        echo "$KEYCHRON_DEVICES"
    fi

    echo ""
    print_info "Your Keychron K2 V2 should be detected automatically by keyd."
    print_warning "If keyd doesn't recognize your keyboard, you may need to:"
    print_warning "  1. Check the device paths above"
    print_warning "  2. Manually edit: /etc/keyd/default.conf"
    print_warning "  3. Update the 'device = ' line with your keyboard's event path"
    print_info "  4. Example: device = /dev/input/by-path/platform-1c2c0000.eusb-usb-0:1:1.0-event-kbd"
    echo ""
}

# Function to validate keyd configuration
validate_config() {
    print_info "Validating keyd configuration..."

    if ! command -v keyd &> /dev/null; then
        print_warning "keyd not installed, skipping config validation"
        return 0
    fi

    # Test configuration syntax
    if ! sudo keyd check "$KEYD_SYSTEM_CONFIG" 2>&1; then
        print_error "Invalid keyd configuration syntax"
        print_info "Please check $KEYD_SYSTEM_CONFIG for errors"
        return 1
    fi

    print_success "Configuration validation passed"
}

# Function to create systemd service
create_systemd_service() {
    print_info "Checking keyd systemd service..."

    if [ -f "$SYSTEMD_SERVICE" ]; then
        print_info "keyd service file already exists"
        return 0
    fi

    print_info "Creating keyd systemd service..."

    sudo tee "$SYSTEMD_SERVICE" > /dev/null <<'EOF'
[Unit]
Description=keyd keyboard remapping daemon
Documentation=https://github.com/rvaiya/keyd
ConditionPathExists=/etc/keyd/default.conf
After=multi-user.target

[Service]
Type=simple
ExecStart=/usr/bin/keyd
Restart=always
RestartSec=5
CapabilityBoundingSet=CAP_SYS_ADMIN

# Security hardening
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/etc/keyd
ProtectControlGroups=false

[Install]
WantedBy=multi-user.target
EOF

    sudo chmod 644 "$SYSTEMD_SERVICE"

    print_success "Systemd service created at $SYSTEMD_SERVICE"
}

# Function to check if keyd service is already running
check_keyd_running() {
    if sudo systemctl is-active --quiet keyd 2>/dev/null; then
        print_warning "keyd service is currently running"
        print_info "The installation will restart the service to apply new configuration."
        return 0
    fi
    return 1
}

# Function to enable and start keyd service
start_keyd_service() {
    print_info "Starting keyd service..."

    sudo systemctl daemon-reload
    sudo systemctl enable keyd

    # Try to start or restart the service
    if sudo systemctl is-active --quiet keyd 2>/dev/null; then
        print_info "Restarting existing keyd service..."
        sudo systemctl restart keyd
    else
        print_info "Starting keyd service..."
        sudo systemctl start keyd
    fi

    # Wait a moment for service to start
    sleep 2

    # Check if service is running
    if sudo systemctl is-active --quiet keyd; then
        print_success "keyd service is running"
    else
        print_error "Failed to start keyd service"
        print_info "Service status:"
        sudo systemctl status keyd --no-pager -l || true
        return 1
    fi
}

# Function to verify installation
verify_installation() {
    print_info "Verifying installation..."

    # Check if keyd is running
    if sudo systemctl is-active --quiet keyd; then
        print_success "keyd service is active"
    else
        print_warning "keyd service is not active"
    fi

    # Check configuration files
    if [ -f "$KEYD_SYSTEM_CONFIG" ]; then
        print_success "System configuration exists"
    else
        print_error "System configuration missing"
    fi

    if [ -f "$KEYD_USER_CONFIG" ]; then
        print_success "User configuration exists"
    else
        print_warning "User configuration missing (optional for terminal integration)"
    fi
}

# Function to show panic key info
show_panic_key() {
    echo ""
    echo -e "${RED}================================================${NC}"
    echo -e "${RED}  IMPORTANT: PANIC KEY INFORMATION             ${NC}"
    echo -e "${RED}================================================${NC}"
    echo ""
    echo -e "${YELLOW}If keyd locks your input, press simultaneously:${NC}"
    echo -e "${GREEN}  Backspace + Escape + Enter${NC}"
    echo ""
    echo -e "${YELLOW}This will immediately terminate the keyd daemon.${NC}"
    echo ""
    print_warning "Test this combination after installation to ensure it works!"
    echo ""
}

# Function to show summary
# Function to install fzf utility scripts
install_scripts() {
    print_info "Installing FZF utility scripts..."

    # Create bin directory if it doesn't exist
    mkdir -p "$BIN_DIR"

    # Check if scripts directory exists
    if [ ! -d "$SCRIPTS_DIR" ]; then
        print_warning "Scripts directory not found: $SCRIPTS_DIR"
        return 0
    fi

    # Copy scripts and make them executable
    local scripts=("fzcd" "fzfind" "fzgit" "fzhist")
    for script in "${scripts[@]}"; do
        if [ -f "$SCRIPTS_DIR/$script" ]; then
            cp "$SCRIPTS_DIR/$script" "$BIN_DIR/$script"
            chmod +x "$BIN_DIR/$script"
            print_success "Installed $script to $BIN_DIR/$script"
        else
            print_warning "Script not found: $SCRIPTS_DIR/$script"
        fi
    done

    # Check if ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        print_warning "$BIN_DIR is not in your PATH"
        print_info "Add the following to your ~/.bashrc or ~/.zshrc:"
        echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
}

# Function to show fzf scripts help
show_fzf_help() {
    echo ""
    echo -e "${BLUE}FZF Utility Scripts:${NC}"
    echo "  fzcd     - Interactive directory jumping with zoxide"
    echo "  fzfind   - File search with fd/rg + preview"
    echo "  fzgit    - Git operations (log, branch, stash, commit)"
    echo "  fzhist   - Command history search"
    echo ""
    echo -e "${BLUE}Keyd FZF Layer:${NC}"
    echo "  Hold LeftControl (oneshot) to activate FZF layer"
    echo "  Or press Tab while in TOOLS layer (CapsLock + Tab)"
    echo ""
    echo -e "${BLUE}FZF Layer Keybindings:${NC}"
    echo "  j - fzcd (zoxide jump)"
    echo "  f - fzfind (file search)"
    echo "  g - rg content search"
    echo "  b - fzgit branch"
    echo "  l - fzgit log"
    echo "  s - fzgit status/stash"
    echo "  c - fzgit commit"
    echo "  h - fzhist (history)"
    echo ""
}

show_summary() {
    echo ""
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}  Installation Complete!                        ${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    echo -e "${BLUE}Configuration files:${NC}"
    echo "  System: $KEYD_SYSTEM_CONFIG"
    echo "  User:   $KEYD_USER_CONFIG"
    echo ""
    echo -e "${BLUE}Scripts installed:${NC}"
    echo "  Location: $BIN_DIR"
    echo "  Scripts: fzcd, fzfind, fzgit, fzhist"
    echo ""
    echo -e "${BLUE}Layer mappings:${NC}"
    echo "  CODE Layer:    RightAlt (toggle)"
    echo "  POWER Layer:   RightControl (oneshot/toggle)"
    echo "  NUM Layer:     Menu key (toggle)"
    echo "  TOOLS Layer:   CapsLock (toggle)"
    echo "  FZF Layer:     LeftControl (oneshot) or Tab from TOOLS"
    echo ""
    echo -e "${BLUE}Key remappings:${NC}"
    echo "  LeftShift  -> Escape"
    echo "  RightShift -> Backspace"
    echo "  Home row:  A/S/D/F = Meta/Alt/Shift/Ctrl (left)"
    echo "  Home row:  J/K/L/; = Ctr/Shift/Alt/Meta (right)"
    echo ""
    show_fzf_help
    echo -e "${BLUE}Next steps:${NC}"
    echo "  1. Verify keyboard detection: sudo keyd monitor"
    echo "  2. Test layer toggles: Press RightAlt, RightControl, CapsLock"
    echo "  3. Test FZF layer: Hold LeftControl and press 'j' for fzcd"
    echo "  4. Test panic key:  Backspace + Escape + Enter simultaneously"
    echo "  5. Add $BIN_DIR to your PATH if not already done"
    echo ""
    echo -e "${BLUE}Useful commands:${NC}"
    echo "  Check status:    sudo systemctl status keyd"
    echo "  Restart daemon:  sudo systemctl restart keyd"
    echo "  Monitor events:  sudo keyd monitor"
    echo "  Stop daemon:    sudo systemctl stop keyd"
    echo "  Disable daemon: sudo systemctl disable keyd"
    echo ""
}

# Main execution
main() {
    check_root

    # Check if configuration directory exists
    if [ ! -d "$CONFIG_DIR" ]; then
        print_error "Configuration directory not found: $CONFIG_DIR"
        print_info "Please run this script from the correct directory"
        exit 1
    fi

    # Check if configuration files exist
    if [ ! -f "$CONFIG_DIR/default.conf" ]; then
        print_error "Configuration file not found: $CONFIG_DIR/default.conf"
        exit 1
    fi

    # Show panic key info early
    show_panic_key

    echo ""
    read -p "Continue with installation? (y/N) " -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installation cancelled"
        exit 0
    fi

    # Installation steps
    if ! check_keyd_installed; then
        install_keyd
    fi

    backup_configs
    detect_keyboard
    copy_system_config
    copy_user_config
    install_scripts
    create_systemd_service
    check_keyd_running
    validate_config

    if start_keyd_service; then
        verify_installation
        show_summary
    else
        print_error "Installation completed but service failed to start"
        print_info "Please check the error messages above and try:"
        print_info "  sudo systemctl status keyd"
        print_info "  sudo journalctl -xe --no-pager | grep keyd"
        exit 1
    fi
}

# Run main function
main
