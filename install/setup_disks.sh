#!/bin/bash
# setup_disks.sh
# Production-Ready Arch Linux + Btrfs + Podman for AI/Service Workloads
# Based on ARCH_INSTALL_FINAL_SPEC.md

set -e

DISK1="/dev/nvme0n1" # System & Disposable
DISK2="/dev/nvme1n1" # Services + User Data

echo "WARNING: This will WIPE ALL DATA on $DISK1 and $DISK2"
read -p "Are you sure? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

echo ">> Wiping drives..."
wipefs -a $DISK1
wipefs -a $DISK2

# ==========================================
# DRIVE 1: SYSTEM (nvme0n1)
# p1: /boot (2GB) - FAT32
# p2: swap (32GB) - SWAP (Hibernation support)
# p3: / (140GB) - BTRFS
# p4: /backup (180GB) - BTRFS (Snapshots)
# p5: /downloads (546GB) - BTRFS
# Reserved: 100GB (10%)
# ==========================================
echo ">> Partitioning Drive 1 (System)..."
parted -s $DISK1 mklabel gpt
parted -s $DISK1 mkpart "BOOT" fat32 1MiB 2GiB
parted -s $DISK1 set 1 esp on
parted -s $DISK1 mkpart "SWAP" linux-swap 2GiB 34GiB
parted -s $DISK1 mkpart "ROOT" btrfs 34GiB 174GiB
parted -s $DISK1 mkpart "BACKUP" btrfs 174GiB 354GiB
parted -s $DISK1 mkpart "DOWNLOADS" btrfs 354GiB 900GiB

sleep 1

echo ">> Formatting Drive 1..."
mkfs.fat -F32 -n "ARCH_BOOT" ${DISK1}p1
mkswap -L "ARCH_SWAP" ${DISK1}p2
mkfs.btrfs -f -L "ARCH_ROOT" ${DISK1}p3
mkfs.btrfs -f -L "ARCH_BACKUP" ${DISK1}p4
mkfs.btrfs -f -L "ARCH_DOWNLOADS" ${DISK1}p5

# ==========================================
# DRIVE 2: DATA (nvme1n1)
# p1: /home (80GB) - BTRFS
# p2: /workspace (300GB) - BTRFS
# p3: /obsidian (80GB) - BTRFS
# p4: /srv (440GB) - BTRFS (Podman storage)
# Reserved: 100GB (10%)
# ==========================================
echo ">> Partitioning Drive 2 (Services + Data)..."
parted -s $DISK2 mklabel gpt
parted -s $DISK2 mkpart "HOME" btrfs 1MiB 81GiB
parted -s $DISK2 mkpart "WORKSPACE" btrfs 81GiB 381GiB
parted -s $DISK2 mkpart "OBSIDIAN" btrfs 381GiB 461GiB
parted -s $DISK2 mkpart "SRV" btrfs 461GiB 901GiB

sleep 1

echo ">> Formatting Drive 2..."
mkfs.btrfs -f -L "ARCH_HOME" ${DISK2}p1
mkfs.btrfs -f -L "ARCH_WORKSPACE" ${DISK2}p2
mkfs.btrfs -f -L "ARCH_OBSIDIAN" ${DISK2}p3
mkfs.btrfs -f -L "ARCH_SRV" ${DISK2}p4

# ==========================================
# MOUNTING HIERARCHY
# ==========================================
echo ">> Mounting System Tree..."

# 1. Mount Root
mount -o compress=zstd:1,relatime,space_cache=v2 ${DISK1}p3 /mnt

# 2. Create Mount Points
mkdir -p /mnt/{boot,backup,downloads,home,workspace,obsidian,srv}

# 3. Mount Everything Else
mount ${DISK1}p1 /mnt/boot
swapon ${DISK1}p2
mount -o compress=zstd:1,relatime,space_cache=v2 ${DISK1}p4 /mnt/backup
mount -o compress=zstd:1,relatime,space_cache=v2 ${DISK1}p5 /mnt/downloads

mount -o compress=zstd:1,relatime,space_cache=v2 ${DISK2}p1 /mnt/home
mount -o compress=zstd:1,relatime,space_cache=v2 ${DISK2}p2 /mnt/workspace
mount -o compress=zstd:1,relatime,space_cache=v2 ${DISK2}p3 /mnt/obsidian
mount -o compress=zstd:1,relatime,space_cache=v2 ${DISK2}p4 /mnt/srv

# ==========================================
# POST-MOUNT DIRECTORY SETUP
# ==========================================
echo ">> Creating Service Directories..."
# Note: These paths are relative to /mnt because we are in the install environment
mkdir -p /mnt/srv/{containers,ollama/models,databases/{postgres,mongo,qdrant,valkey},n8n/data,openwebui/app,backups}

# Ownership will be handled after user creation in the install process
# But we can set the structure now.

echo ">> Generating fstab..."
# Using UUIDs for robustness
genfstab -U /mnt >> /mnt/etc/fstab

echo ">> Disk Setup Complete!"
lsblk
