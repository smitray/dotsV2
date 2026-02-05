#!/bin/bash
# setup_podman.sh
# Configure rootless Podman to use /srv/containers for storage

set -e

echo ">> Configuring Podman storage..."

# Create config directory
mkdir -p ~/.config/containers

# Create containers.conf
cat <<EOF > ~/.config/containers/containers.conf
[engine]
# Store all container data (images, layers, volumes) in /srv/containers
graphroot = "/srv/containers"

# Rootless configuration
rootless = true

# Storage driver (overlay recommended if kernel supports)
storage_driver = "overlay"
EOF

echo ">> Verifying configuration..."
podman info | grep -E 'root|graphroot|driver'

echo ">> Podman configuration complete!"
