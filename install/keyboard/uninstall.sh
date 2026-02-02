#!/bin/bash
# keyd Configuration Uninstallation Script
# This script removes keyd configuration and stops the service

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration paths
KEYD_SYSTEM_CONFIG="/etc/keyd/default.conf"
KEYD_USER_CONFIG="$HOME/.config/keyd/app.conf"
SYSTEMD_SERVICE="/etc/systemd/system/keyd.service"

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

# Function to stop and disable keyd service
stop_keyd_service() {
    print_info "Stopping keyd service..."

    if sudo systemctl is-active --quiet keyd 2>/dev/null; then
        sudo systemctl stop keyd
        print_success "keyd service stopped"
    else
        print_info "keyd service was not running"
    fi

    if sudo systemctl is-enabled --quiet keyd 2>/dev/null; then
        sudo systemctl disable keyd
        print_success "keyd service disabled"
    else
        print_info "keyd service was not enabled"
    fi
}

# Function to remove configuration files
remove_configs() {
    echo ""
    print_info "Removing configuration files..."

    if [ -f "$KEYD_SYSTEM_CONFIG" ]; then
        sudo rm -f "$KEYD_SYSTEM_CONFIG"
        print_success "Removed system configuration: $KEYD_SYSTEM_CONFIG"
    else
        print_info "System configuration not found or already removed"
    fi

    if [ -f "$KEYD_USER_CONFIG" ]; then
        rm -f "$KEYD_USER_CONFIG"
        print_success "Removed user configuration: $KEYD_USER_CONFIG"
    else
        print_info "User configuration not found or already removed"
    fi

    # Remove empty directories
    if [ -d "/etc/keyd" ] && [ "$(ls -A /etc/keyd)" ]; then
        print_info "/etc/keyd directory not empty, leaving it"
    elif [ -d "/etc/keyd" ]; then
        sudo rmdir /etc/keyd 2>/dev/null || true
        print_success "Removed empty /etc/keyd directory"
    fi

    if [ -d "$HOME/.config/keyd" ] && [ "$(ls -A "$HOME/.config/keyd")" ]; then
        print_info "$HOME/.config/keyd directory not empty, leaving it"
    elif [ -d "$HOME/.config/keyd" ]; then
        rmdir "$HOME/.config/keyd" 2>/dev/null || true
        print_success "Removed empty $HOME/.config/keyd directory"
    fi
}

# Function to remove systemd service file
remove_systemd_service() {
    echo ""
    print_info "Removing systemd service file..."

    if [ -f "$SYSTEMD_SERVICE" ]; then
        sudo rm -f "$SYSTEMD_SERVICE"
        print_success "Removed systemd service: $SYSTEMD_SERVICE"

        # Reload systemd daemon
        sudo systemctl daemon-reload
        print_success "Systemd daemon reloaded"
    else
        print_info "Systemd service file not found or already removed"
    fi
}

# Function to offer to remove keyd package
remove_keyd_package() {
    echo ""
    read -p "Do you want to remove the keyd package entirely? (y/N) " -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Removing keyd package..."
        sudo pacman -Rns keyd
        print_success "keyd package removed"
    else
        print_info "keyd package will remain installed"
    fi
}

# Function to show summary
show_summary() {
    echo ""
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}  Uninstallation Complete!                    ${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    echo -e "${BLUE}What was removed:${NC}"
    echo "  - keyd service (stopped and disabled)"
    echo "  - System configuration: $KEYD_SYSTEM_CONFIG"
    echo "  - User configuration:   $KEYD_USER_CONFIG"
    echo "  - Systemd service file:  $SYSTEMD_SERVICE"
    echo ""
    echo -e "${BLUE}To reinstall keyd configuration:${NC}"
    echo "  cd /home/debasmitr/workspace/dotFileV2/install/keyboard"
    echo "  ./install.sh"
    echo ""
}

# Main execution
main() {
    check_root

    echo -e "${RED}================================================${NC}"
    echo -e "${RED}  Keyd Configuration Uninstaller               ${NC}"
    echo -e "${RED}================================================${NC}"
    echo ""
    print_warning "This will:"
    echo "  - Stop and disable the keyd service"
    echo "  - Remove all keyd configuration files"
    echo "  - Remove the systemd service file"
    echo "  - Optionally remove the keyd package"
    echo ""

    read -p "Continue with uninstallation? (y/N) " -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Uninstallation cancelled"
        exit 0
    fi

    # Uninstallation steps
    stop_keyd_service
    remove_configs
    remove_systemd_service
    remove_keyd_package

    show_summary
}

# Run main function
main
