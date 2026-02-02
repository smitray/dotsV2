#!/bin/bash

set -euo pipefail

# Setup Docker with Split Storage Strategy
# Docker images on NVME 1 (disposable)
# Docker volumes/database files on NVME 2 (permanent)

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

# Install Docker
install_docker() {
    log_info "Installing Docker..."
    
    pacman -S --noconfirm docker docker-compose
    
    log_success "Docker installed"
}

# Setup docker group
setup_docker_group() {
    log_info "Setting up docker group..."
    
    # Create docker group if it doesn't exist
    groupadd -f docker
    
    # Get current user (if running with sudo)
    if [[ -n "${SUDO_USER:-}" ]]; then
        usermod -aG docker "$SUDO_USER"
        log_success "Added $SUDO_USER to docker group"
    fi
}

# Create docker data directories
create_docker_directories() {
    log_info "Creating Docker data directories..."
    
    # Permanent Docker data storage (NVME 2)
    mkdir -p /docker-data/{postgres,mysql,mongodb,redis,volumes,backups}
    
    # Docker image storage (NVME 1) - auto-created by Docker
    mkdir -p /var/lib/docker
    
    # Set permissions
    chown -R root:docker /var/lib/docker /docker-data
    chmod -R 750 /var/lib/docker /docker-data
    
    log_success "Docker directories created"
}

# Configure Docker daemon
configure_docker() {
    log_info "Configuring Docker daemon..."
    
    mkdir -p /etc/docker
    
    cat > /etc/docker/daemon.json << 'EOF'
{
  "data-root": "/var/lib/docker",
  "storage-driver": "btrfs",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "live-restore": true,
  "userland-proxy": false
}
EOF
    
    log_success "Docker daemon configured"
}

# Enable Docker service
enable_docker_service() {
    log_info "Enabling Docker service..."
    
    systemctl daemon-reload
    systemctl enable docker
    systemctl start docker
    
    log_success "Docker service enabled and started"
}

# Verify Docker installation
verify_docker() {
    log_info "Verifying Docker installation..."
    
    if ! docker --version > /dev/null 2>&1; then
        log_error "Docker verification failed"
        return 1
    fi
    
    log_success "Docker verified: $(docker --version)"
}

# Print storage configuration
print_storage_info() {
    echo
    log_info "========================================"
    log_info "   Docker Storage Configuration"
    log_info "========================================"
    echo
    log_info "Docker Images Storage (NVME 1 - Disposable):"
    log_info "  Location: /var/lib/docker"
    log_info "  Purpose: Docker images, containers"
    log_info "  Can be: Safely deleted and redownloaded"
    echo
    log_info "Docker Data Storage (NVME 2 - Permanent):"
    log_info "  Location: /docker-data"
    log_info "  Purpose: Database files, volumes, persistent data"
    log_info "  Directories:"
    log_info "    - /docker-data/postgres/    (PostgreSQL data)"
    log_info "    - /docker-data/mysql/       (MySQL data)"
    log_info "    - /docker-data/mongodb/     (MongoDB data)"
    log_info "    - /docker-data/redis/       (Redis data)"
    log_info "    - /docker-data/volumes/     (Named volumes)"
    log_info "    - /docker-data/backups/     (Database backups)"
    echo
    log_info "Current Docker Configuration:"
    docker info | grep -A 5 "Storage Driver"
    echo
}

# Example Docker Compose configuration
print_docker_compose_example() {
    echo
    log_info "========================================"
    log_info "   Example Docker Compose (with volumes)"
    log_info "========================================"
    echo
    cat << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:15
    container_name: my-postgres
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: myuser
      POSTGRES_PASSWORD: mypassword
    volumes:
      # Database files on NVME 2 (permanent)
      - /docker-data/postgres:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  mysql:
    image: mysql:8
    container_name: my-mysql
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: myapp
    volumes:
      # MySQL data on NVME 2 (permanent)
      - /docker-data/mysql:/var/lib/mysql
    ports:
      - "3306:3306"

  mongodb:
    image: mongo:6
    container_name: my-mongo
    volumes:
      # MongoDB data on NVME 2 (permanent)
      - /docker-data/mongodb:/data/db
    ports:
      - "27017:27017"

  redis:
    image: redis:7
    container_name: my-redis
    volumes:
      # Redis data on NVME 2 (permanent)
      - /docker-data/redis:/data
    ports:
      - "6379:6379"

# Named volumes (data stored in /docker-data/volumes/)
volumes:
  postgres_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /docker-data/postgres

Save as: docker-compose.yml
Run with: docker-compose up -d
EOF
    echo
}

# Cleanup function
cleanup_on_exit() {
    :
}

trap cleanup_on_exit EXIT

# Main execution
main() {
    check_root
    
    log_info "========================================="
    log_info "   Docker Setup with Split Storage"
    log_info "========================================="
    echo
    
    install_docker
    setup_docker_group
    create_docker_directories
    configure_docker
    enable_docker_service
    verify_docker
    print_storage_info
    print_docker_compose_example
    
    log_success "Docker setup completed!"
}

# Run main
main "$@"
