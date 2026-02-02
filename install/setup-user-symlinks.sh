#!/bin/bash

set -euo pipefail

# Setup User Directory Symlinks
# Routes temporary files to /temp-storage and permanent files to appropriate partitions

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
USER_HOME="${1:-$HOME}"

# Sanity checks
if [[ ! -d "$USER_HOME" ]]; then
    log_error "Home directory not found: $USER_HOME"
    exit 1
fi

if [[ ! -d "/temp-storage" ]]; then
    log_error "/temp-storage partition not mounted"
    exit 1
fi

log_info "Setting up symlinks for user: $(basename "$USER_HOME")"
echo

# Ensure required mount points exist
mkdir -p /temp-storage/{Downloads,Videos,Cache,Documents}
mkdir -p /obsidian/Documents
mkdir -p /archive/{Pictures,Music,Media}
mkdir -p /workspace/projects

# Function to create symlink safely
create_symlink() {
    local link_name=$1
    local target=$2
    local dir_path="$USER_HOME/$link_name"
    
    # Skip if already a symlink to correct target
    if [[ -L "$dir_path" ]] && [[ "$(readlink "$dir_path")" == "$target" ]]; then
        log_info "  ✓ $link_name → $target (already exists)"
        return
    fi
    
    # Backup existing directory if it exists and is not a symlink
    if [[ -d "$dir_path" ]] && [[ ! -L "$dir_path" ]]; then
        log_warn "  ! Backing up existing $link_name to ${link_name}.backup"
        mv "$dir_path" "$dir_path.backup"
    fi
    
    # Remove existing symlink if pointing elsewhere
    if [[ -L "$dir_path" ]]; then
        log_warn "  ! Removing old symlink: $link_name"
        rm "$dir_path"
    fi
    
    # Create symlink
    if ln -s "$target" "$dir_path"; then
        log_success "  ✓ $link_name → $target"
    else
        log_error "  ✗ Failed to create symlink: $link_name"
        return 1
    fi
}

# TEMPORARY DIRECTORIES (to /temp-storage - can be safely deleted)
log_info "Setting up temporary directories (→ /temp-storage):"
create_symlink "Downloads" "/temp-storage/Downloads"
create_symlink "Videos" "/temp-storage/Videos"
create_symlink ".cache" "/temp-storage/Cache/.cache"
echo

# PERMANENT DIRECTORIES (to NVME2 partitions)
log_info "Setting up permanent directories (→ NVME 2):"

# Documents → /obsidian
create_symlink "Documents" "/obsidian/Documents"

# Pictures, Music, Media → /archive
create_symlink "Pictures" "/archive/Pictures"
create_symlink "Music" "/archive/Music"
create_symlink "Media" "/archive/Media"

# Projects → /workspace
create_symlink "Projects" "/workspace/projects"
echo

# Setup .local/share for applications
log_info "Setting up application data directories:"
mkdir -p "$USER_HOME/.local/share"
mkdir -p /archive/AppData
create_symlink ".local/share" "/archive/AppData"
echo

# Print summary
log_info "========================================"
log_info "   Symlink Setup Complete"
log_info "========================================"
echo
log_info "Directory Structure:"
log_info "  TEMPORARY (can be deleted):"
log_info "    ~/Downloads    → /temp-storage/Downloads"
log_info "    ~/Videos       → /temp-storage/Videos"
log_info "    ~/.cache       → /temp-storage/Cache"
echo
log_info "  PERMANENT (NVME 2):"
log_info "    ~/Documents    → /obsidian/Documents"
log_info "    ~/Pictures     → /archive/Pictures"
log_info "    ~/Music        → /archive/Music"
log_info "    ~/Media        → /archive/Media"
log_info "    ~/Projects     → /workspace/projects"
log_info "    ~/.local/share → /archive/AppData"
echo
log_info "Device Layout:"
log_info "  NVME 1: /boot, /, /backup, /temp-storage"
log_info "  NVME 2: /home, /workspace, /obsidian, /archive"
echo

# Check disk usage
log_info "Current disk usage:"
df -h /temp-storage /obsidian /archive /workspace 2>/dev/null || true
echo

log_success "Symlink setup completed for user: $(basename "$USER_HOME")"
