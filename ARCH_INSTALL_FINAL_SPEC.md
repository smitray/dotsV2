# **Production-Ready Arch Linux + Btrfs + Podman for AI/Service Workloads**

## **Final Specification Document**

---

## **1. Vision & Goals**

Build a **lean, secure, high-performance** Arch Linux system on dual 1TB NVMe SSDs optimized for:
- **Rootless Podman** containers (Ollama, OpenWebUI, N8N, Valkey, Qdrant, PostgreSQL, MongoDB)
- **Btrfs** with optimal performance (10% free space, zstd:1 compression)
- **Clear data separation** between OS, user configs, development, and persistent service data
- **Easy backups** and snapshots
- **Minimal attack surface** (no Docker daemon, rootless containers)

---

## **2. Storage Architecture Overview**

```
NVMe 1 (System Disk - /dev/nvme0n1)
├── p1: /boot (2GB) - EFI
├── p2: swap (32GB) - hibernation
├── p3: / (140GB) - OS + system apps
├── p4: /backup (180GB) - Timeshift snapshots
├── p5: /downloads (546GB) - temp files, initial model downloads
└── FREE: 100GB (10% headroom)

NVMe 2 (Services + User Data Disk - /dev/nvme1n1)
├── p1: /home (80GB) - user configs, dotfiles, Mise runtimes, compose files
├── p2: /workspace (300GB) - development projects
├── p3: /obsidian (80GB) - notes vault
├── p4: /srv (440GB) - ALL persistent service data + Podman storage
└── FREE: 100GB (10% headroom)
```

**Total:** 2TB (1.8TB allocated, 200GB free for Btrfs operations)

---

## **3. Partition Specification**

### **NVMe 1: `/dev/nvme0n1` (System + Disposable)**
| Partition | Start | End | Size | Type | Filesystem | Mount Point | Purpose |
|-----------|-------|-----|------|------|------------|-------------|---------|
| p1 | 1MiB | 2GiB | 2GB | EFI System | FAT32 | `/boot` | Bootloader & kernels |
| p2 | 2GiB | 34GiB | 32GB | Linux swap | swap | `none` | Hibernation (swap ≥ RAM) |
| p3 | 34GiB | 174GiB | 140GB | Linux filesystem | Btrfs | `/` | OS + system packages |
| p4 | 174GiB | 354GiB | 180GB | Linux filesystem | Btrfs | `/backup` | System snapshots (Timeshift) |
| p5 | 354GiB | 900GiB | 546GB | Linux filesystem | Btrfs | `/downloads` | ISOs, downloads, temp files |
| **Unallocated** | 900GiB | 1000GiB | **100GB** | - | - | - | **Btrfs headroom (10%)** |

**Total allocated:** 900GB (90%)  
**Free:** 100GB (10%)

---

### **NVMe 2: `/dev/nvme1n1` (Services + User Data)**
| Partition | Start | End | Size | Type | Filesystem | Mount Point | Purpose |
|-----------|-------|-----|------|------|------------|-------------|---------|
| p1 | 1MiB | 81GiB | 80GB | Linux filesystem | Btrfs | `/home` | User configs, dotfiles, Mise, compose files |
| p2 | 81GiB | 381GiB | 300GB | Linux filesystem | Btrfs | `/workspace` | Development projects, source code |
| p3 | 381GiB | 461GiB | 80GB | Linux filesystem | Btrfs | `/obsidian` | Obsidian vault + attachments |
| p4 | 461GiB | 901GiB | 440GB | Linux filesystem | Btrfs | `/srv` | **All persistent service data + Podman storage** |
| **Unallocated** | 901GiB | 1000GiB | **100GB** | - | - | - | **Btrfs headroom (10%)** |

**Total allocated:** 900GB (90%)  
**Free:** 100GB (10%)

---

## **4. Directory Structure**

### **Home Directory (`/home/$USER` - 80GB)**
```
/home/debasmitr/
├── .bashrc / .zshrc          # Shell configs
├── .config/                  # App configs
├── .local/share/mise/        # Mise runtimes (Node, Python, Bun)
├── .ssh/                     # SSH keys
├── services/                 # **Podman compose files**
│   ├── docker-compose.yml
│   ├── .env                  # Secrets (not in git)
│   └── scripts/
└── .gitconfig
```

### **Service Data Directory (`/srv` - 440GB)**
```
/srv/
├── containers/               # Podman storage (images, layers)
│   └── storage/
├── ollama/
│   └── models/               # LLM models (40-100GB each)
├── databases/
│   ├── postgres/             # PostgreSQL data
│   ├── mongo/                # MongoDB data
│   ├── qdrant/               # Qdrant vector storage
│   └── valkey/               # Valkey/Redis data
├── n8n/
│   └── data/                 # Workflows, executions
├── openwebui/
│   └── app/                  # Uploads, user data
└── backups/                  # Optional: periodic dumps
```

**Ownership:** All directories owned by regular user (rootless Podman).

---

## **5. Mise Runtime Accessibility**

Mise runtimes stored in `/home/.local/share/mise/` are **globally accessible** across all partitions:

```bash
# PATH is set via shell config in /home
~/.local/share/mise/shims/node      # Available everywhere
~/.local/share/mise/shims/python    # Available everywhere
~/.local/share/mise/shims/bun       # Available everywhere

# Works from any directory:
cd /workspace/myproject    # Development projects
cd /obsidian               # Notes
cd /srv/ollama/models      # Service data
# Mise tools work in all locations
```

**Why this works:**
- Shell initializes from `/home/.bashrc` or `/home/.zshrc`
- PATH includes `~/.local/share/mise/shims`
- Project-specific versions via `.mise.toml` in `/workspace` projects

---

## **6. Implementation Commands**

### **6.1 Partition Creation (WARNING: DESTROYS ALL DATA)**

```bash
# ============================================
# NVMe 1 - System Disk
# ============================================
sudo parted /dev/nvme0n1 -- mklabel gpt
sudo parted /dev/nvme0n1 -- mkpart primary fat32 1MiB 2GiB
sudo parted /dev/nvme0n1 -- set 1 esp on
sudo parted /dev/nvme0n1 -- mkpart primary linux-swap 2GiB 34GiB
sudo parted /dev/nvme0n1 -- mkpart primary btrfs 34GiB 174GiB
sudo parted /dev/nvme0n1 -- mkpart primary btrfs 174GiB 354GiB
sudo parted /dev/nvme0n1 -- mkpart primary btrfs 354GiB 900GiB

# Format NVMe 1
sudo mkfs.fat -F 32 -n "ARCH_BOOT" /dev/nvme0n1p1
sudo mkswap -L "ARCH_SWAP" /dev/nvme0n1p2
sudo mkfs.btrfs -f -L "ARCH_ROOT" /dev/nvme0n1p3
sudo mkfs.btrfs -f -L "ARCH_BACKUP" /dev/nvme0n1p4
sudo mkfs.btrfs -f -L "ARCH_DOWNLOADS" /dev/nvme0n1p5

# ============================================
# NVMe 2 - Services + User Data Disk
# ============================================
sudo parted /dev/nvme1n1 -- mklabel gpt
sudo parted /dev/nvme1n1 -- mkpart primary btrfs 1MiB 81GiB
sudo parted /dev/nvme1n1 -- mkpart primary btrfs 81GiB 381GiB
sudo parted /dev/nvme1n1 -- mkpart primary btrfs 381GiB 461GiB
sudo parted /dev/nvme1n1 -- mkpart primary btrfs 461GiB 901GiB

# Format NVMe 2
sudo mkfs.btrfs -f -L "ARCH_HOME" /dev/nvme1n1p1
sudo mkfs.btrfs -f -L "ARCH_WORKSPACE" /dev/nvme1n1p2
sudo mkfs.btrfs -f -L "ARCH_OBSIDIAN" /dev/nvme1n1p3
sudo mkfs.btrfs -f -L "ARCH_SRV" /dev/nvme1n1p4
```

---

### **6.2 `/etc/fstab` Configuration**

```fstab
# /etc/fstab: static file system information

# EFI System
efivarfs /sys/firmware/efi/efivars efivarfs rw,nosuid,nodev,noexec,relatime 0 0

# ============================================
# NVMe 1 - System Disk
# ============================================
/dev/nvme0n1p1 /boot vfat defaults,noatime,nofail 0 2
/dev/nvme0n1p2 none swap defaults,pri=-2 0 0
/dev/nvme0n1p3 / btrfs rw,relatime,compress=zstd:1,space_cache=v2 0 0
/dev/nvme0n1p4 /backup btrfs rw,relatime,compress=zstd:1,space_cache=v2 0 2
/dev/nvme0n1p5 /downloads btrfs rw,relatime,compress=zstd:1,space_cache=v2 0 2

# ============================================
# NVMe 2 - Services + User Data
# ============================================
/dev/nvme1n1p1 /home btrfs rw,relatime,compress=zstd:1,space_cache=v2 0 2
/dev/nvme1n1p2 /workspace btrfs rw,relatime,compress=zstd:1,space_cache=v2 0 2
/dev/nvme1n1p3 /obsidian btrfs rw,relatime,compress=zstd:1,space_cache=v2 0 2
/dev/nvme1n1p4 /srv btrfs rw,relatime,compress=zstd:1,space_cache=v2 0 2

# ============================================
# tmpfs (RAM-based temporary filesystems)
# ============================================
tmpfs /tmp tmpfs defaults,noatime,mode=1777 0 0
tmpfs /var/tmp tmpfs defaults,noatime,mode=1777 0 0
tmpfs /run tmpfs defaults,noatime,nosuid,nodev,mode=755 0 0
tmpfs /dev/shm tmpfs defaults,noatime,nosuid,nodev 0 0
```

---

### **6.3 Post-Install Directory Setup**

```bash
# ============================================
# Create mount points and service directories
# ============================================

# Create all mount points
sudo mkdir -p /{backup,downloads,workspace,obsidian,srv}
sudo mkdir -p /srv/{containers,ollama/models,databases/{postgres,mongo,qdrant,valkey},n8n/data,openwebui/app,backups}

# Set ownership for user operation
sudo chown -R $USER:$USER /srv/{containers,ollama,databases,n8n,openwebui,backups}
sudo chown $USER:$USER /downloads

# ============================================
# Create services directory in home for compose files
# ============================================
mkdir -p ~/services
cd ~/services
```

---

### **6.4 Podman Configuration**

Create `~/.config/containers/containers.conf`:

```ini
[engine]
# Store all container data (images, layers, volumes) in /srv/containers
graphroot = "/srv/containers"

# Rootless configuration
rootless = true

# Storage driver (overlay recommended if kernel supports)
storage_driver = "overlay"
```

**Verify configuration:**
```bash
podman info | grep -E 'root|graphroot|driver'
# Expected: root: false, graphroot: /srv/containers, driver: overlay
```

---

## **7. Docker Compose File**

Save as `~/services/docker-compose.yml`:

```yaml
version: '3.8'

services:
  # Ollama - LLM Server
  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    restart: unless-stopped
    ports:
      - "11434:11434"
    volumes:
      - /srv/ollama/models:/root/.ollama/models
      - /srv/containers/ollama-data:/root/.ollama/data
    networks:
      - ai-network
    # Uncomment for NVIDIA GPU (requires nvidia-container-toolkit)
    # deploy:
    #   resources:
    #     reservations:
    #       devices:
    #         - driver: nvidia
    #           count: all
    #           capabilities: [gpu]

  # Open WebUI - Frontend
  openwebui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: openwebui
    restart: unless-stopped
    ports:
      - "3000:8080"
    environment:
      - OLLAMA_BASE_URL=http://ollama:11434
      - WEBUI_SECRET_KEY=${WEBUI_SECRET_KEY}
    volumes:
      - /srv/openwebui/app:/app/backend/data
    networks:
      - ai-network
    depends_on:
      - ollama

  # N8N - Workflow Automation
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_PROTOCOL=http
      - N8N_HOST=localhost
      - N8N_PORT=5678
      - N8N_EDITOR_BASE_URL=http://localhost:5678
      - N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}
    volumes:
      - /srv/n8n/data:/home/node/.n8n
    networks:
      - ai-network

  # Valkey (Redis) - Cache
  valkey:
    image: valkey/valkey:alpine
    container_name: valkey
    restart: unless-stopped
    ports:
      - "6379:6379"
    command: valkey-server --appendonly yes --save 60 1
    volumes:
      - /srv/databases/valkey:/data
    networks:
      - ai-network

  # Qdrant - Vector Database
  qdrant:
    image: qdrant/qdrant:latest
    container_name: qdrant
    restart: unless-stopped
    ports:
      - "6333:6333"
    volumes:
      - /srv/databases/qdrant:/qdrant/storage
    networks:
      - ai-network

  # PostgreSQL
  postgres:
    image: postgres:15-alpine
    container_name: postgres
    restart: unless-stopped
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
      PGDATA: /var/lib/postgresql/data/pgdata
    volumes:
      - /srv/databases/postgres:/var/lib/postgresql/data
    networks:
      - ai-network

  # MongoDB
  mongo:
    image: mongo:6
    container_name: mongo
    restart: unless-stopped
    ports:
      - "27017:27017"
    environment:
      MONGO_INITDB_ROOT_USERNAME: ${MONGO_ROOT_USER}
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_ROOT_PASSWORD}
      MONGO_INITDB_DATABASE: ${MONGO_DB}
    volumes:
      - /srv/databases/mongo:/data/db
    networks:
      - ai-network

networks:
  ai-network:
    driver: bridge
```

---

### **6.5 Environment File**

Save as `~/services/.env` (add to `.gitignore`):

```env
# Open WebUI
WEBUI_SECRET_KEY=change-me-to-32-byte-random-string

# N8N
N8N_ENCRYPTION_KEY=change-me-to-32-byte-random-string

# PostgreSQL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=change-me-to-strong-password
POSTGRES_DB=appdb

# MongoDB
MONGO_ROOT_USER=root
MONGO_ROOT_PASSWORD=change-me-to-strong-password
MONGO_DB=appdb
```

**IMPORTANT:** Generate strong random values before deployment.

---

## **8. Deployment & Management**

### **8.1 First-Time Setup**

```bash
# 1. Navigate to services directory
cd ~/services

# 2. Verify .env has real secrets
vim .env

# 3. Start all services
podman compose up -d

# 4. Check status
podman compose ps
podman compose logs -f

# 5. Verify GPU access (if NVIDIA)
podman exec ollama nvidia-smi
```

### **8.2 Systemd User Service (Auto-start)**

```bash
# Create systemd directory
mkdir -p ~/.config/systemd/user
cd ~/.config/systemd/user

# Generate service file
podman compose -f ~/services/docker-compose.yml systemd -n ai-stack > ai-stack.service

# Enable and start
systemctl --user daemon-reload
systemctl --user enable --now ai-stack.service

# Check status
systemctl --user status ai-stack.service
journalctl --user -u ai-stack.service -f
```

### **8.3 Common Commands**

```bash
# Stop all services
cd ~/services && podman compose down

# Restart one service
podman compose restart ollama

# View logs
podman compose logs -f openwebui
podman compose logs --tail 100 ollama

# Execute command in container
podman compose exec ollama ollama list
podman compose exec ollama ollama pull llama3.2

# Update images
podman compose pull
podman compose up -d

# Cleanup
podman system prune -a --volumes
podman system df

# Check disk usage
df -h /srv
du -sh /srv/*
```

---

## **9. Backup Strategy**

| What | Location | Backup Destination | Method | Frequency |
|------|----------|-------------------|--------|-----------|
| **Service Data** | `/srv/databases/*` | `/backup/databases/` | `pg_dumpall`, `mongodump` | Daily |
| **Ollama Models** | `/srv/ollama/models` | External drive/remote | `rsync -avh` | After download |
| **N8N Data** | `/srv/n8n/data` | `/backup/n8n/` | `rsync -avh` | Daily |
| **OpenWebUI** | `/srv/openwebui/app` | `/backup/openwebui/` | `rsync -avh` | Daily |
| **User Configs** | `/home` | `/backup/home/` + Git | `rsync` + dotfiles repo | Daily |
| **Projects** | `/workspace` | Git remote | `git push --all` | On commit |
| **Notes** | `/obsidian` | Git + `/backup/obsidian/` | Obsidian Git + `rsync` | Real-time + daily |
| **Compose Files** | `~/services/` | Git | `git push` | On change |

**Do NOT backup:**
- `/srv/containers` - Reproducible from compose file
- `/downloads` - Temporary files

---

## **10. Monitoring & Maintenance**

### **10.1 Btrfs Health**

```bash
# Check free space (should be ≥10%)
btrfs filesystem usage /
btrfs filesystem usage /srv
btrfs filesystem usage /home

# Balance when needed (quarterly)
sudo btrfs balance start -dusage=80 /srv

# Scrub for data integrity (monthly)
sudo btrfs scrub start /srv
```

### **10.2 Service Monitoring**

```bash
# Container stats
podman stats

# Disk usage by service
sudo du -sh /srv/*
sudo du -sh /srv/databases/*
sudo du -sh /srv/ollama/models/*
```

### **10.3 Maintenance Schedule**

| Task | Frequency | Command |
|------|-----------|---------|
| Update containers | Weekly | `podman compose pull && podman compose up -d` |
| Prune unused images | Monthly | `podman system prune -a --volumes` |
| Btrfs balance | Quarterly | `btrfs balance start -dusage=80 /srv` |
| Btrfs scrub | Monthly | `btrfs scrub start /` |
| Full backup | Weekly | Custom backup script |

---

## **11. Validation Checklist**

### **Installation**
- [ ] All partitions created with correct sizes
- [ ] All filesystems formatted (FAT32, Btrfs)
- [ ] `fstab` entries correct and mounts succeed (`mount -a`)
- [ ] Swap partition active (`swapon --show`)
- [ ] `/srv` directories created with correct ownership
- [ ] Podman configured with `graphroot = "/srv/containers"`

### **Services**
- [ ] `podman info` shows `root: false` and correct `graphroot`
- [ ] `podman compose up -d` starts all services
- [ ] All services accessible:
  - Ollama: `http://localhost:11434`
  - Open WebUI: `http://localhost:3000`
  - N8N: `http://localhost:5678`
  - Valkey: `localhost:6379`
  - Qdrant: `http://localhost:6333`
  - PostgreSQL: `localhost:5432`
  - MongoDB: `localhost:27017`
- [ ] Services communicate via `ai-network`
- [ ] Systemd user service starts on boot

### **Data**
- [ ] Btrfs free space ≥10% on each filesystem
- [ ] Mise runtimes accessible from `/workspace`
- [ ] GPU accessible in Ollama (if applicable)

---

## **12. Troubleshooting**

### **Permission denied on `/srv/...`**
```bash
sudo chown -R $USER:$USER /srv
```

### **Port already in use**
```bash
# Change ports in compose file or stop conflicting service
sudo ss -tlnp | grep :3000
```

### **Services can't resolve each other**
```bash
# Check network
podman network ls
podman network inspect ai-network
```

### **Btrfs free space < 10%**
```bash
podman system prune -a --volumes
btrfs balance start -dusage=80 /srv
```

### **GPU not visible**
```bash
# Test GPU
podman run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi
# Update compose with GPU config
```

---

## **13. Quick Reference**

### **Partition Sizes Summary**

| Disk | Partition | Size | Mount | Purpose |
|------|-----------|------|-------|---------|
| NVMe 1 | p1 | 2GB | /boot | EFI |
| NVMe 1 | p2 | 32GB | - | Swap |
| NVMe 1 | p3 | 140GB | / | OS |
| NVMe 1 | p4 | 180GB | /backup | Snapshots |
| NVMe 1 | p5 | 546GB | /downloads | Downloads |
| NVMe 1 | FREE | 100GB | - | Btrfs headroom |
| NVMe 2 | p1 | 80GB | /home | Configs, Mise, Compose |
| NVMe 2 | p2 | 300GB | /workspace | Projects |
| NVMe 2 | p3 | 80GB | /obsidian | Notes |
| NVMe 2 | p4 | 440GB | /srv | Service data |
| NVMe 2 | FREE | 100GB | - | Btrfs headroom |

### **Key File Locations**

| File/Dir | Location | Purpose |
|----------|----------|---------|
| Compose file | `~/services/docker-compose.yml` | Service definitions |
| Secrets | `~/services/.env` | Passwords, keys |
| Podman config | `~/.config/containers/containers.conf` | Storage location |
| Service data | `/srv/` | Databases, models |
| Downloads | `/downloads` | Temp files, ISOs |
| Backups | `/backup` | System snapshots |

---

## **14. Summary**

This specification provides a **production-ready, secure, high-performance** Arch Linux system:

- ✅ **Dual-NVMe Btrfs** with 10% free space per disk
- ✅ **Rootless Podman** for security
- ✅ **Clear separation**: Configs (`/home`), Code (`/workspace`), Data (`/srv`)
- ✅ **Mise runtimes** globally accessible
- ✅ **Compose files** in `~/services/` (version controlled)
- ✅ **Auto-start** via systemd user service
- ✅ **Backup strategy** for stateful data

**Ready to implement.** 🚀
