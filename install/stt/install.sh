#!/bin/bash
#
# Whisper STT Installation Script
# Installs system-wide speech-to-text for Hyprland
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Installation paths
BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config"
SYSTEMD_DIR="$CONFIG_DIR/systemd/user"

# Logging functions
info() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Use system Python 3
PYTHON_CMD="python3"

# Create local .env from .env.example if it doesn't exist
# This allows users to customize .env without tracking it in git
init_local_env() {
    local env_example="$SCRIPT_DIR/.env.example"
    local env_file="$SCRIPT_DIR/.env"

    if [[ -f "$env_example" ]]; then
        if [[ ! -f "$env_file" ]]; then
            cp "$env_example" "$env_file"
            info "Created local .env from .env.example"
        fi
    else
        warn ".env.example not found at $env_example"
    fi
}

# Check if running on Arch Linux
check_distro() {
    if [[ -f /etc/arch-release ]]; then
        return 0
    else
        warn "This script is designed for Arch Linux. Proceeding anyway..."
        return 0
    fi
}

# Check and install system packages
install_system_packages() {
    info "Checking system packages..."
    
    local packages=(
        # Audio
        "pipewire"
        "pipewire-alsa"
        "pipewire-pulse"
        "wireplumber"
        "pavucontrol"
        "pamixer"
        # Typing
        "wtype"
        "ydotool"
        # Notifications
        "dunst"
        "libnotify"
        # Utilities
        "curl"
        "jq"
        # Waybar (optional but recommended)
        "waybar"
        # Clipboard
        "wl-clipboard"
    )
    
    local missing=()
    
    for pkg in "${packages[@]}"; do
        if ! pacman -Qi "$pkg" &>/dev/null; then
            missing+=("$pkg")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        info "Installing missing packages: ${missing[*]}"
        sudo pacman -S --needed --noconfirm "${missing[@]}"
        success "System packages installed"
    else
        success "All system packages already installed"
    fi
}

# Check and install NVIDIA drivers/CUDA
check_nvidia() {
    info "Checking NVIDIA GPU and CUDA..."
    
    # Check if nvidia-smi is available
    if command -v nvidia-smi &>/dev/null; then
        local gpu_info
        gpu_info=$(nvidia-smi --query-gpu=name,memory.total --format=csv,noheader 2>/dev/null || echo "")
        if [[ -n "$gpu_info" ]]; then
            success "NVIDIA GPU detected: $gpu_info"
            
            # Verify CUDA libraries are available
            if ls /usr/lib/libcuda.so* /usr/lib/libcudart.so* 2>/dev/null | grep -q .; then
                success "CUDA libraries found"
            else
                warn "CUDA libraries not found"
                install_cuda
            fi
            return 0
        fi
    fi
    
    # No NVIDIA GPU detected or missing drivers
    warn "NVIDIA GPU not detected or drivers not installed"
    warn "STT will run on CPU (slower but functional)"
    
    read -p "Would you like to install NVIDIA drivers for GPU acceleration? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_nvidia_drivers
    fi
    
    return 0
}

# Install NVIDIA drivers
install_nvidia_drivers() {
    info "Installing NVIDIA drivers..."
    
    # Detect if kernel is LTS or zen
    local kernel=$(uname -r | grep -oE '^[0-9]+')
    local extra_pkg=""
    
    if uname -r | grep -q "lts"; then
        extra_pkg="nvidia-lts"
    elif uname -r | grep -q "zen"; then
        extra_pkg="nvidia-zen"
    else
        extra_pkg="nvidia"
    fi
    
    # Install NVIDIA packages
    sudo pacman -S --needed --noconfirm \
        "$extra_pkg" \
        nvidia-utils \
        cuda
        
    success "NVIDIA drivers and CUDA installed"
    warn "You may need to reboot for changes to take effect"
}

# Install CUDA if missing but drivers present
install_cuda() {
    info "Installing CUDA toolkit..."
    sudo pacman -S --needed --noconfirm cuda
    success "CUDA installed"
}

# Setup CUDA compatibility layer for newer CUDA versions
# faster-whisper/ctranslate2 may require CUDA 12 libs while system has CUDA 13+
setup_cuda_compat() {
    local cuda_compat_dir="$HOME/.local/lib/cuda-compat"
    local cuda_lib_dir="/opt/cuda/lib64"
    
    # Check if we have CUDA 13+ but need CUDA 12 libs
    if [[ -f "$cuda_lib_dir/libcublas.so.13" ]] && [[ ! -f "$cuda_lib_dir/libcublas.so.12" ]]; then
        info "Setting up CUDA 12 compatibility layer for CUDA 13+..."
        
        mkdir -p "$cuda_compat_dir"
        
        # Create symlinks for libcublas
        if [[ -f "$cuda_lib_dir/libcublas.so.13" ]]; then
            ln -sf "$(readlink -f "$cuda_lib_dir/libcublas.so.13")" "$cuda_compat_dir/libcublas.so.12"
        fi
        
        if [[ -f "$cuda_lib_dir/libcublasLt.so.13" ]]; then
            ln -sf "$(readlink -f "$cuda_lib_dir/libcublasLt.so.13")" "$cuda_compat_dir/libcublasLt.so.12"
        fi
        
        success "CUDA compatibility layer created at $cuda_compat_dir"
    fi
}

# Install Python packages
install_python_packages() {
    info "Checking Python packages..."
    
    local packages=(
        "faster-whisper"
        "uvicorn"
        "fastapi"
        "python-multipart"
        "httpx"
    )
    
    local missing=()
    
    for pkg in "${packages[@]}"; do
        # Convert package name for import check
        local import_name="${pkg//-/_}"
        if [[ "$pkg" == "python-multipart" ]]; then
            import_name="multipart"
        fi
        
        if ! $PYTHON_CMD -c "import $import_name" &>/dev/null; then
            missing+=("$pkg")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        info "Installing Python packages: ${missing[*]}"
        $PYTHON_CMD -m pip install --user --upgrade "${missing[@]}"
        success "Python packages installed"
    else
        success "All Python packages already installed"
    fi
}

# Install scripts to ~/.local/bin
install_scripts() {
    info "Installing scripts to $BIN_DIR..."
    
    mkdir -p "$BIN_DIR"
    
    # Copy scripts
    cp "$SCRIPT_DIR/bin/whisper-api-server" "$BIN_DIR/"
    cp "$SCRIPT_DIR/bin/hypr-stt" "$BIN_DIR/"
    
    # Make executable
    chmod +x "$BIN_DIR/whisper-api-server"
    chmod +x "$BIN_DIR/hypr-stt"
    
    success "Scripts installed to $BIN_DIR"
    
    # Check if ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        warn "$BIN_DIR is not in your PATH"
        warn "Add this to your shell config (~/.bashrc or ~/.zshrc):"
        echo '  export PATH="$HOME/.local/bin:$PATH"'
    fi
}

# Install systemd service
install_systemd_service() {
    info "Installing systemd user service..."

    mkdir -p "$SYSTEMD_DIR"
    cp "$SCRIPT_DIR/config/whisper-api.service" "$SYSTEMD_DIR/"
    
    # Install cleanup script (prevents port conflicts on reboot)
    cp "$SCRIPT_DIR/config/whisper-cleanup.sh" "$SYSTEMD_DIR/"
    chmod +x "$SYSTEMD_DIR/whisper-cleanup.sh"

    systemctl --user daemon-reload

    success "Systemd service installed"
    info "To enable auto-start: systemctl --user enable whisper-api"
    info "To start now: systemctl --user start whisper-api"
}

# Setup ydotool daemon
setup_ydotool() {
    info "Setting up ydotool..."
    
    # Check if user is in input group
    if ! groups | grep -q '\binput\b'; then
        info "Adding user to 'input' group for ydotool..."
        sudo usermod -aG input "$USER"
        warn "You need to log out and back in for group changes to take effect"
    fi
    
    # Enable ydotool socket
    if systemctl --user is-enabled ydotool.service &>/dev/null || \
       systemctl --user is-enabled ydotoold.service &>/dev/null; then
        success "ydotool service already enabled"
    else
        # Try to enable ydotool (package may provide different service names)
        if systemctl --user enable ydotool.socket &>/dev/null; then
            systemctl --user start ydotool.socket &>/dev/null || true
            success "ydotool socket enabled"
        else
            warn "Could not enable ydotool service. You may need to start it manually."
        fi
    fi
}

# Detect active shell and find config files
get_shell_config_files() {
    local current_shell
    local config_files=()
    
    # Detect current shell
    if [[ -n "$SHELL" ]]; then
        current_shell=$(basename "$SHELL")
    else
        current_shell=$(ps -p $$ -o comm= 2>/dev/null || echo "bash")
    fi
    
    info "Detected shell: $current_shell" >&2
    
    # Get XDG_CONFIG_HOME or default to ~/.config
    local xdg_config="${XDG_CONFIG_HOME:-$HOME/.config}"
    
    case "$current_shell" in
        zsh)
            # Check multiple locations for zsh config
            config_files=(
                "$HOME/.zshenv"
                "$HOME/.zshrc"
                "$xdg_config/zsh/.zshenv"
                "$xdg_config/zsh/.zshrc"
            )
            ;;
        bash)
            config_files=(
                "$HOME/.bashrc"
                "$HOME/.bash_profile"
                "$HOME/.profile"
            )
            ;;
        fish)
            config_files=(
                "$xdg_config/fish/config.fish"
                "$HOME/.config/fish/config.fish"
            )
            ;;
        *)
            warn "Unknown shell: $current_shell, using bash as fallback"
            config_files=(
                "$HOME/.bashrc"
                "$HOME/.bash_profile"
                "$HOME/.profile"
            )
            ;;
    esac
    
    # Filter to only existing files
    for config in "${config_files[@]}"; do
        if [[ -f "$config" ]]; then
            echo "$config"
            return 0
        fi
    done
    
    # Return nothing if no config found
    return 1
}

# Setup environment file and shell integration
setup_env_file() {
    info "Setting up environment configuration..."
    
    local env_config_dir="$HOME/.config/hypr-stt"
    local env_file="$env_config_dir/env"
    local source_env_file="$SCRIPT_DIR/.env"
    
    # Copy .env from source directory
    if [[ -f "$source_env_file" ]]; then
        mkdir -p "$env_config_dir"
        cp "$source_env_file" "$env_file"
        success "Environment file installed: $env_file"
    else
        warn "Environment file not found: $source_env_file"
        warn "Skipping environment setup"
        return 0
    fi
    
    # Get appropriate shell config file
    local shell_config
    shell_config=$(get_shell_config_files)
    
    if [[ -z "$shell_config" ]]; then
        warn "No shell config file found"
        warn "You'll need to manually source $env_file in your shell config"
        
        # Show manual instructions based on detected shell
        local current_shell
        if [[ -n "$SHELL" ]]; then
            current_shell=$(basename "$SHELL")
        else
            current_shell=$(ps -p $$ -o comm= 2>/dev/null || echo "bash")
        fi
        
        case "$current_shell" in
            zsh)
                info "Add this to ~/.zshenv or ~/.zshrc:"
                echo ""
                echo "  # Whisper STT environment variables"
                echo "  [ -f \"$env_file\" ] && source \"$env_file\""
                ;;
            bash)
                info "Add this to ~/.bashrc:"
                echo ""
                echo "  # Whisper STT environment variables"
                echo "  [ -f \"$env_file\" ] && source \"$env_file\""
                ;;
            fish)
                info "Add this to ~/.config/fish/config.fish:"
                echo ""
                echo "  # Whisper STT environment variables"
                echo "  if test -f \"$env_file\""
                echo "      source \"$env_file\""
                echo "  end"
                ;;
        esac
        return 0
    fi
    
    # Check if already sourced
    if ! grep -q "hypr-stt/env" "$shell_config" 2>/dev/null; then
        echo "" >> "$shell_config"
        echo "# Whisper STT environment variables" >> "$shell_config"
        
        # Check if it's a fish config file
        if [[ "$shell_config" == *"fish"* ]]; then
            echo "if test -f \"$env_file\"" >> "$shell_config"
            echo "    source \"$env_file\"" >> "$shell_config"
            echo "end" >> "$shell_config"
        else
            echo "[ -f \"$env_file\" ] && source \"$env_file\"" >> "$shell_config"
        fi
        
        success "Added env source to $shell_config"
    else
        success "Env source already in $shell_config"
    fi
    
    success "Environment configuration installed"
    info "Source file: $env_file"
    info "Reload your shell or run: source $env_file"
}

# Print configuration instructions
print_config_instructions() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}   Configuration Instructions${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""

    echo -e "${GREEN}1. Hyprland Keybinding${NC}"
    echo "   Add to ~/.config/hypr/hyprland.conf:"
    echo ""
    echo -e "${YELLOW}# Whisper STT Keybindings${NC}"
    echo -e "${YELLOW}# Primary: Super+R to toggle recording${NC}"
    echo "bind = SUPER, R, exec, ~/.local/bin/hypr-stt toggle"
    echo ""
    echo -e "${YELLOW}# Optional: Super+Shift+R to reset STT${NC}"
    echo -e "${YELLOW}# bind = SUPER SHIFT, R, exec, ~/.local/bin/hypr-stt reset${NC}"
    echo ""
    echo -e "${YELLOW}# Optional: Super+Ctrl+R to stop server (free VRAM)${NC}"
    echo -e "${YELLOW}# bind = SUPER CTRL, R, exec, ~/.local/bin/hypr-stt stop-server${NC}"
    echo ""

    echo -e "${GREEN}2. Waybar Module (optional)${NC}"
    echo "   Add to modules in ~/.config/waybar/config:"
    echo ""
    cat << 'WAYBAR_CONFIG'
    "custom/stt": {
        "format": "{}",
        "return-type": "json",
        "interval": 1,
        "exec": "~/.local/bin/hypr-stt status",
        "signal": 8,
        "on-click": "~/.local/bin/hypr-stt toggle"
    }
WAYBAR_CONFIG
    echo ""
    echo "   Then add styles to ~/.config/waybar/style.css:"
    echo ""
    cat << 'WAYBAR_CSS'
    #custom-stt {
        padding: 0 10px;
        margin: 4px 2px;
        border-radius: 4px;
        font-weight: bold;
    }

    #custom-stt.recording {
        background-color: #f38ba8;  /* Catppuccin Red */
        color: #1e1e2e;
        animation: stt-blink 1s ease-in-out infinite;
    }

    #custom-stt.processing {
        background-color: #fab387;  /* Catppuccin Peach */
        color: #1e1e2e;
    }

    #custom-stt.idle {
        background-color: transparent;
        color: #cdd6f4;
    }

    @keyframes stt-blink {
        0%, 100% { opacity: 1; }
        50% { opacity: 0.5; }
    }
WAYBAR_CSS
    echo ""

    echo -e "${GREEN}3. Environment Variables${NC}"
    echo "   Configuration is managed via ~/.config/hypr-stt/env"
    echo "   This file is copied from .env in the installation directory"
    echo ""
    echo "   Before installation: Edit .env file in installation directory"
    echo "   After installation: Edit ~/.config/hypr-stt/env"
    echo "   The installer automatically detects your shell (bash/zsh/fish)"
    echo "   and adds the env file sourcing to the appropriate config file:"
    echo ""
    echo "   - Zsh:  ~/.zshenv, ~/.zshrc, ~/.config/zsh/.zshenv"
    echo "   - Bash: ~/.bashrc, ~/.bash_profile"
    echo "   - Fish: ~/.config/fish/config.fish"
    echo ""
    echo "   Common customizations:"
    echo "   - Change model: export WHISPER_MODEL=tiny (tiny/base/small/medium/large-v3)"
    echo "   - Adjust idle timeout: export WHISPER_IDLE_TIMEOUT=600"
    echo "   - Change language: export HYPR_STT_LANGUAGE=es"
    echo ""
    echo "   After editing env file: source ~/.config/hypr-stt/env"
    echo ""

    echo -e "${GREEN}4. First Run${NC}"
    echo "   The first transcription will download the Whisper model (~244MB)"
    echo "   This is a one-time download."
    echo ""

    echo -e "${GREEN}5. Test Installation${NC}"
    echo "   Run: ~/.local/bin/hypr-stt toggle"
    echo "   Speak, then run again to transcribe."
    echo ""
    echo "   For reset: ~/.local/bin/hypr-stt reset"
    echo ""

    echo -e "${GREEN}6. Reload Hyprland${NC}"
    echo "   Press Super+Shift+E or run: hyprctl reload"
    echo ""
}

# Verify installation
verify_installation() {
    info "Verifying installation..."
    
    local errors=0
    
    # Check scripts
    if [[ -x "$BIN_DIR/whisper-api-server" ]]; then
        success "whisper-api-server installed"
    else
        error "whisper-api-server not found"
        ((errors++))
    fi
    
    if [[ -x "$BIN_DIR/hypr-stt" ]]; then
        success "hypr-stt installed"
    else
        error "hypr-stt not found"
        ((errors++))
    fi
    
    # Check Python imports
    if $PYTHON_CMD -c "from faster_whisper import WhisperModel" &>/dev/null; then
        success "faster-whisper working"
    else
        error "faster-whisper import failed"
        ((errors++))
    fi
    
    # Check audio tools
    if command -v pw-record &>/dev/null; then
        success "pw-record available"
    else
        error "pw-record not found"
        ((errors++))
    fi
    
    if command -v wtype &>/dev/null; then
        success "wtype available"
    else
        warn "wtype not found (will use fallback)"
    fi
    
    if [[ $errors -gt 0 ]]; then
        error "Installation completed with $errors error(s)"
        return 1
    fi
    
    success "Installation verified successfully!"
    return 0
}

# Uninstall function
uninstall() {
    info "Uninstalling Whisper STT..."

    # Stop and disable service
    systemctl --user stop whisper-api.service &>/dev/null || true
    systemctl --user disable whisper-api.service &>/dev/null || true

    # Remove files
    rm -f "$BIN_DIR/whisper-api-server"
    rm -f "$BIN_DIR/hypr-stt"
    rm -f "$SYSTEMD_DIR/whisper-api.service"
    rm -f "$SYSTEMD_DIR/whisper-cleanup.sh"
    
    # Cleanup runtime files (both old /tmp location and new /run/user/$UID/ location)
    rm -f /tmp/hypr-stt-* /tmp/whisper-*
    rm -f "/run/user/$(id -u)/hypr-stt-"*
    rm -f "/run/user/$(id -u)/whisper-"*
    
    # Remove env config directory
    local env_config_dir="$HOME/.config/hypr-stt"
    rm -rf "$env_config_dir"
    
    # Detect current shell for cleanup
    local current_shell
    if [[ -n "$SHELL" ]]; then
        current_shell=$(basename "$SHELL")
    else
        current_shell=$(ps -p $$ -o comm= 2>/dev/null || echo "bash")
    fi
    
    local xdg_config="${XDG_CONFIG_HOME:-$HOME/.config}"
    local cleanup_configs=()
    
    case "$current_shell" in
        zsh)
            cleanup_configs=(
                "$HOME/.zshenv"
                "$HOME/.zshrc"
                "$xdg_config/zsh/.zshenv"
                "$xdg_config/zsh/.zshrc"
            )
            ;;
        bash)
            cleanup_configs=(
                "$HOME/.bashrc"
                "$HOME/.bash_profile"
                "$HOME/.profile"
            )
            ;;
        fish)
            cleanup_configs=(
                "$xdg_config/fish/config.fish"
                "$HOME/.config/fish/config.fish"
            )
            ;;
    esac
    
    # Remove sourcing from all possible shell configs
    local cleaned=0
    for config in "${cleanup_configs[@]}"; do
        if [[ -f "$config" ]]; then
            # Remove the env sourcing lines
            sed -i '/hypr-stt\/env/d' "$config" 2>/dev/null || true
            # Remove empty line that might have been added before the comment
            sed -i '/^# Whisper STT environment variables$/d' "$config" 2>/dev/null || true
            ((cleaned++))
        fi
    done
    
    if [[ $cleaned -gt 0 ]]; then
        success "Removed env sourcing from $cleaned shell config(s)"
    fi
    
    systemctl --user daemon-reload
    
    success "Uninstalled successfully"
    info "Note: Python packages and system packages were not removed"
    info "Remove Hyprland keybinding manually from ~/.config/hypr/hyprland.conf"
}

# Main installation
main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Whisper STT Installer for Hyprland   ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""

    # Initialize local .env from .env.example
    init_local_env

    case "${1:-install}" in
        install)
            check_distro
            install_system_packages
            check_nvidia
            setup_cuda_compat
            install_python_packages
            install_scripts
            install_systemd_service
            setup_ydotool
            setup_env_file
            verify_installation
            print_config_instructions
            ;;
        uninstall)
            uninstall
            ;;
        verify)
            verify_installation
            ;;
        *)
            echo "Usage: $0 [install|uninstall|verify]"
            exit 1
            ;;
    esac
}

main "$@"
