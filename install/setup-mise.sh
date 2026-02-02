#!/bin/bash

set -euo pipefail

# Setup Mise - Runtime Version Manager
# Installs Node.js, Python, Bun, and other runtimes on NVME 2
# Location: ~/.local/share/mise/

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
TARGET_USER="${1:=$USER}"
TARGET_HOME=$(eval echo ~"$TARGET_USER")
MISE_DIR="$TARGET_HOME/.local/share/mise"

# Check if user exists
check_user() {
    if ! id "$TARGET_USER" &>/dev/null; then
        log_error "User not found: $TARGET_USER"
        exit 1
    fi
    
    log_info "Setting up Mise for user: $TARGET_USER"
    log_info "Home directory: $TARGET_HOME"
}

# Install Mise
install_mise() {
    log_info "Installing Mise (runtime manager)..."
    
    # Download and run install script
    curl https://mise.run | bash
    
    log_success "Mise installed"
}

# Create Mise directories
create_mise_directories() {
    log_info "Creating Mise directories..."
    
    mkdir -p "$MISE_DIR"/{shims,versions,tools}
    mkdir -p "$TARGET_HOME/.config/mise"
    
    # Set ownership
    chown -R "$TARGET_USER:$TARGET_USER" "$MISE_DIR" "$TARGET_HOME/.config/mise"
    
    log_success "Mise directories created"
}

# Add Mise to shell configuration
configure_shell() {
    log_info "Configuring shell for Mise..."
    
    local bashrc="$TARGET_HOME/.bashrc"
    local zshrc="$TARGET_HOME/.zshrc"
    
    # Mise initialization snippet
    local mise_config='
# Mise configuration - Runtime version manager
export PATH="$HOME/.local/share/mise/shims:$PATH"
eval "$(mise activate bash)"
'
    
    # Add to bashrc if not already present
    if [[ -f "$bashrc" ]] && ! grep -q "mise activate" "$bashrc"; then
        echo "$mise_config" >> "$bashrc"
        log_info "Added Mise to ~/.bashrc"
    fi
    
    # Add to zshrc if not already present
    if [[ -f "$zshrc" ]] && ! grep -q "mise activate" "$zshrc"; then
        sed -i 's/eval "$(mise activate bash)"/eval "$(mise activate zsh)"/' <<< "$mise_config"
        echo "$mise_config" >> "$zshrc"
        log_info "Added Mise to ~/.zshrc"
    fi
    
    log_success "Shell configured for Mise"
}

# Create project structure
create_project_structure() {
    log_info "Creating project structure..."
    
    mkdir -p "$TARGET_HOME/workspace/projects"/{web,api,mobile,data,infra}
    mkdir -p "$TARGET_HOME/workspace/environments"
    
    chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/workspace"
    
    log_success "Project structure created at: ~/workspace/projects/"
}

# Create example .mise.toml
create_example_mise_toml() {
    log_info "Creating example .mise.toml file..."
    
    cat > "$TARGET_HOME/workspace/projects/.mise.toml.example" << 'EOF'
# Example Mise configuration for a full-stack project
# Copy this to your project directory as .mise.toml

[tools]
# Node.js version
node = "20.11.0"

# Python version
python = "3.12.0"

# Bun runtime
bun = "1.0.29"

# Optional: Other runtimes
# rust = "1.75.0"
# go = "1.21.0"
# deno = "1.39.0"

[env]
# Project-specific environment variables
NODE_ENV = "development"
PYTHONPATH = "${MISE_ROOT}/src"

[alias]
# Create project-specific command aliases
start = "npm start"
test = "npm test"
build = "npm run build"
EOF
    
    chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/workspace/projects/.mise.toml.example"
    
    log_success "Example .mise.toml created"
}

# Print Mise usage guide
print_mise_guide() {
    echo
    log_info "========================================"
    log_info "   Mise Setup Complete"
    log_info "========================================"
    echo
    log_info "What is Mise?"
    log_info "  • Runtime version manager (like asdf)"
    log_info "  • Installs multiple versions of Node, Python, etc."
    log_info "  • Per-project version specification via .mise.toml"
    log_info "  • All runtimes stored in: ~/.local/share/mise/"
    echo
    log_info "Installation Location (NVME 2 - Permanent):"
    log_info "  ~/.local/share/mise/"
    log_info "  ├── shims/           (executable wrappers in PATH)"
    log_info "  └── versions/        (actual runtime installations)"
    log_info "      ├── node/"
    log_info "      ├── python/"
    log_info "      └── bun/"
    echo
    log_info "Quick Start:"
    echo
    log_info "1. Source your shell config (or restart terminal):"
    log_info "   source ~/.bashrc     # or ~/.zshrc"
    echo
    log_info "2. Verify Mise installation:"
    log_info "   mise --version"
    echo
    log_info "3. Install a runtime:"
    log_info "   mise install node@20.11.0"
    log_info "   mise install python@3.12.0"
    log_info "   mise install bun@1.0.29"
    echo
    log_info "4. Create a project .mise.toml:"
    log_info "   cd ~/workspace/projects/my-app"
    log_info "   cat > .mise.toml << EOF"
    log_info "   [tools]"
    log_info "   node = \"20.11.0\""
    log_info "   python = \"3.12.0\""
    log_info "   EOF"
    echo
    log_info "5. Activate project runtimes:"
    log_info "   cd ~/workspace/projects/my-app"
    log_info "   mise use  # or just enter directory, it activates automatically"
    log_info "   node --version    # v20.11.0"
    log_info "   python --version  # Python 3.12.0"
    echo
    log_info "Managing Runtimes:"
    log_info "  mise install              List and install available versions"
    log_info "  mise list                 Show installed versions"
    log_info "  mise use NODE=20          Set default node version"
    log_info "  mise uninstall node@20    Remove a specific version"
    echo
    log_info "Configuration Files:"
    log_info "  ~/.config/mise/config.toml      Global Mise config"
    log_info "  ./.mise.toml                    Project-specific config"
    log_info "  ./.misrc.toml / .mise.toml     Workspace config"
    echo
    log_info "Example Project Structure:"
    log_info "  ~/workspace/projects/api-server/"
    log_info "  ├── .mise.toml              (specifies node, python, bun versions)"
    log_info "  ├── package.json"
    log_info "  ├── requirements.txt"
    log_info "  ├── src/"
    log_info "  └── tests/"
    echo
    log_info "When you cd into ~/workspace/projects/api-server:"
    log_info "  • Mise automatically activates specified versions"
    log_info "  • Runtimes loaded from ~/.local/share/mise/versions/"
    log_info "  • Shims in PATH forward to correct version"
    echo
}

# Useful aliases
create_shell_aliases() {
    log_info "Creating project aliases..."
    
    local bashrc="$TARGET_HOME/.bashrc"
    
    local aliases='
# Project shortcuts
alias cdw="cd ~/workspace/projects"
alias proj="cd ~/workspace/projects"
alias mise-list="mise list"
alias mise-versions="mise list --all"
'
    
    if [[ -f "$bashrc" ]] && ! grep -q 'alias cdw=' "$bashrc"; then
        echo "$aliases" >> "$bashrc"
        log_info "Added project aliases to ~/.bashrc"
    fi
}

# Main execution
main() {
    check_user
    
    log_info "========================================="
    log_info "   Mise Runtime Manager Setup"
    log_info "========================================="
    echo
    
    install_mise
    create_mise_directories
    configure_shell
    create_shell_aliases
    create_project_structure
    create_example_mise_toml
    print_mise_guide
    
    log_success "Mise setup completed for user: $TARGET_USER"
}

# Run main
main "$@"
