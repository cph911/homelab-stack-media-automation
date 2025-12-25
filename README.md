# 🎬 Homelab Media Automation Stack

**Advanced add-on for [homelab-stack](https://github.com/cph911/homelab-stack)**

Automated media acquisition and management for TV shows, movies, music, and audiobooks. Complete *arr stack with download clients, media servers, and request management.

> ⚠️ **CRITICAL WARNINGS - READ BEFORE INSTALLING**
>
> **Resource Requirements:**
> - **32GB RAM minimum** (adds ~9GB to base homelab-stack)
> - 100GB+ free disk space for downloads
> - Quad-core CPU recommended
>
> **Complexity Warning:**
> - Adds 11 services to manage
> - Requires advanced configuration (indexers, download clients, media paths)
> - More complex troubleshooting than base stack
> - NOT recommended for beginners
>
> **Legal Disclaimer:**
> - This software is for LEGAL media acquisition only
> - Piracy is illegal in most jurisdictions
> - You are solely responsible for your use of this software
> - The maintainers assume NO liability for misuse
> - Ensure you comply with all applicable laws in your jurisdiction

-----

## 🎯 What You Get

### Media Automation (*arr Stack)
- **Sonarr** - Automated TV show management and downloading
- **Radarr** - Automated movie management and downloading
- **Lidarr** - Automated music management and downloading
- **Readarr** - Automated audiobook/ebook management and downloading
- **Prowlarr** - Centralized indexer management for all *arr apps
- **Bazarr** - Automated subtitle downloading

### Media Servers
- **Navidrome** - Modern music streaming server (Subsonic API compatible)
- **Audiobookshelf** - Audiobook and podcast server with mobile apps

### Download Infrastructure
- **qBittorrent** - Lightweight torrent client with web UI
- **FlareSolverr** - Cloudflare bypass proxy for indexers
- **Ombi** - Request management system (supports all media types)

-----

## 📊 Resource Usage

**Additional RAM: ~9GB** (on top of base homelab-stack)

| Service | RAM Limit | CPU Limit | Purpose |
|---------|-----------|-----------|---------|
| Sonarr | 1GB | 1.0 CPU | TV automation |
| Radarr | 1GB | 1.0 CPU | Movie automation |
| Lidarr | 1GB | 1.0 CPU | Music automation |
| Readarr | 1GB | 1.0 CPU | Audiobook automation |
| Prowlarr | 512MB | 0.5 CPU | Indexer management |
| Bazarr | 512MB | 0.5 CPU | Subtitle automation |
| qBittorrent | 1GB | 2.0 CPU | Download client |
| FlareSolverr | 512MB | 1.0 CPU | Cloudflare bypass |
| Navidrome | 512MB | 0.5 CPU | Music streaming |
| Audiobookshelf | 512MB | 0.5 CPU | Audiobook streaming |
| Ombi | 512MB | 0.5 CPU | Request management |

**Total with base stack: ~16-17GB RAM**

-----

## ⚡ Quick Start

### Prerequisites

- **homelab-stack MUST be installed first**
- Ubuntu 20.04+ or Debian 11+ server
- 32GB+ RAM (64GB recommended for heavy usage)
- 100GB+ free disk space
- Domain name with DNS access
- Existing Traefik reverse proxy (from homelab-stack)

### Installation

**Step 1: Clone this repository**
```bash
git clone https://github.com/cph911/homelab-stack-media-automation.git
cd homelab-stack-media-automation

chmod +x install-media-automation.sh

./install-media-automation.sh

sonarr.yourdomain.com      →  YOUR_SERVER_IP
radarr.yourdomain.com      →  YOUR_SERVER_IP
lidarr.yourdomain.com      →  YOUR_SERVER_IP
readarr.yourdomain.com     →  YOUR_SERVER_IP
prowlarr.yourdomain.com    →  YOUR_SERVER_IP
bazarr.yourdomain.com      →  YOUR_SERVER_IP
qbittorrent.yourdomain.com →  YOUR_SERVER_IP
music.yourdomain.com       →  YOUR_SERVER_IP
audiobooks.yourdomain.com  →  YOUR_SERVER_IP
requests.yourdomain.com    →  YOUR_SERVER_IP

jellyfin:
  volumes:
    - ../homelab-stack-media-automation/media/movies:/media/movies:ro
    - ../homelab-stack-media-automation/media/tv:/media/tv:ro
    - ../homelab-stack-media-automation/media/music:/media/music:ro

docker compose logs -f

docker compose restart

docker compose pull
docker compose up -d

tar czf backup-$(date +%Y%m%d).tar.gz config/ .env docker-compose.yml

docker compose logs --tail=100

docker compose exec sonarr ping prowlarr

df -h
du -sh downloads/*
