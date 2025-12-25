Here's the complete comprehensive README - copy all of this and paste it into the GitHub editor:

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

|
 Service 
|
 RAM Limit 
|
 CPU Limit 
|
 Purpose 
|
|
---------
|
-----------
|
-----------
|
---------
|
|
 Sonarr 
|
 1GB 
|
 1.0 CPU 
|
 TV automation 
|
|
 Radarr 
|
 1GB 
|
 1.0 CPU 
|
 Movie automation 
|
|
 Lidarr 
|
 1GB 
|
 1.0 CPU 
|
 Music automation 
|
|
 Readarr 
|
 1GB 
|
 1.0 CPU 
|
 Audiobook automation 
|
|
 Prowlarr 
|
 512MB 
|
 0.5 CPU 
|
 Indexer management 
|
|
 Bazarr 
|
 512MB 
|
 0.5 CPU 
|
 Subtitle automation 
|
|
 qBittorrent 
|
 1GB 
|
 2.0 CPU 
|
 Download client 
|
|
 FlareSolverr 
|
 512MB 
|
 1.0 CPU 
|
 Cloudflare bypass 
|
|
 Navidrome 
|
 512MB 
|
 0.5 CPU 
|
 Music streaming 
|
|
 Audiobookshelf 
|
 512MB 
|
 0.5 CPU 
|
 Audiobook streaming 
|
|
 Ombi 
|
 512MB 
|
 0.5 CPU 
|
 Request management 
|

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

Step 2: Navigate to directory

cd homelab-stack-media-automation

Step 3: Make installer executable

chmod +x install-media-automation.sh

Step 4: Run the installer

./install-media-automation.sh

The installer will:

Verify homelab-stack is installed
Display warnings and require confirmation
Ask for domain configuration
Generate secure passwords
Create directory structure
Validate DNS records for all services
Pull Docker images
Start all services
Create installation documentation
Total time: 15-20 minutes

🌐 DNS Configuration
Configure these A records BEFORE installation:

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

Verify with:

nslookup sonarr.yourdomain.com

🔧 Post-Installation Setup
Step 1: Configure Prowlarr (CRITICAL - Do This First)
Prowlarr manages all indexers centrally.

Access Prowlarr:

https://prowlarr.yourdomain.com

Setup Steps:

Add Indexers:

Go to Indexers → Add Indexer
Add your torrent indexers (public or private trackers)
Configure FlareSolverr for Cloudflare-protected sites:
Settings → Indexers → FlareSolverr
Host: http://flaresolverr:8191
Connect to Apps:

Go to Settings → Apps → Add Application
Add Sonarr:
Prowlarr Server: http://prowlarr:9696
Sonarr Server: http://sonarr:8989
API Key: Get from Sonarr → Settings → General
Repeat for Radarr, Lidarr, Readarr
Step 2: Configure Download Client (qBittorrent)
Access qBittorrent:

https://qbittorrent.yourdomain.com

Login credentials: Check INSTALLATION_INFO.txt

*In each arr app (Sonarr, Radarr, Lidarr, Readarr):

Go to Settings → Download Clients → Add → qBittorrent
Configure:
Host: qbittorrent
Port: 8080
Username: admin
Password: From INSTALLATION_INFO.txt
Step 3: Configure Media Paths
In Sonarr:

Settings → Media Management → Root Folders → Add /tv
In Radarr:

Settings → Media Management → Root Folders → Add /movies
In Lidarr:

Settings → Media Management → Root Folders → Add /music
In Readarr:

Settings → Media Management → Root Folders → Add /audiobooks
Step 4: Link to Jellyfin
The media directories need to be accessible to Jellyfin from base homelab-stack.

Option A: Bind mount (Recommended)

Edit your homelab-stack docker-compose.yml:

jellyfin:
  volumes:
    - jellyfin_config:/config
    - jellyfin_cache:/cache
    - ../homelab-stack-media-automation/media/movies:/media/movies:ro
    - ../homelab-stack-media-automation/media/tv:/media/tv:ro
    - ../homelab-stack-media-automation/media/music:/media/music:ro

Restart Jellyfin:

cd ../homelab-stack
docker compose restart jellyfin

Option B: Symlinks

ln -s /home/user/homelab-stack-media-automation/media/movies /home/user/homelab-stack/jellyfin-media/movies
ln -s /home/user/homelab-stack-media-automation/media/tv /home/user/homelab-stack/jellyfin-media/tv
ln -s /home/user/homelab-stack-media-automation/media/music /home/user/homelab-stack/jellyfin-media/music

Step 5: Configure Navidrome
Access Navidrome:

https://music.yourdomain.com

Create admin account on first visit
Music library is auto-configured at /music
Download mobile apps:
iOS: substreamer, play:Sub
Android: DSub, Ultrasonic
Step 6: Configure Audiobookshelf
Access Audiobookshelf:

https://audiobooks.yourdomain.com

Create admin account on first visit
Add library → Audiobooks → /audiobooks
Configure metadata providers
Download mobile app: Audiobookshelf (iOS/Android)
Step 7: Setup Ombi (Request Management)
Access Ombi:

https://requests.yourdomain.com

Setup:

Complete initial wizard
Connect Sonarr:
Settings → Sonarr → Add Server
Hostname: sonarr
Port: 8989
API Key: From Sonarr → Settings → General
Repeat for Radarr, Lidarr, Readarr
Configure user access and permissions
Setup notifications (email, Discord, etc.)
User Access:

Users can request content at https://requests.yourdomain.com
Requests auto-forward to appropriate *arr app
Notifications when content is available
📁 Directory Structure
homelab-stack-media-automation/
├── install-media-automation.sh
├── docker-compose.yml
├── .env (generated - contains passwords)
├── INSTALLATION_INFO.txt
├── config/              # Application configs
│   ├── sonarr/
│   ├── radarr/
│   ├── lidarr/
│   ├── readarr/
│   ├── prowlarr/
│   ├── bazarr/
│   ├── qbittorrent/
│   ├── ombi/
│   ├── navidrome/
│   └── audiobookshelf/
├── downloads/           # Download staging
│   ├── movies/
│   ├── tv/
│   ├── music/
│   ├── audiobooks/
│   └── incomplete/
└── media/              # Final media (link to Jellyfin)
    ├── movies/
    ├── tv/
    ├── music/
    └── audiobooks/

🔧 Management Commands
Service Control
View all logs:

docker compose logs -f

View specific service:

docker compose logs -f sonarr

Restart all services:

docker compose restart

Restart specific service:

docker compose restart radarr

Stop all services:

docker compose down

Start all services:

docker compose up -d

Check service status:

docker compose ps

View resource usage:

docker stats

Updates
Step 1: Pull latest images

docker compose pull

Step 2: Recreate containers

docker compose up -d

Step 3: Check logs

docker compose logs -f

💾 Backup & Restore
What to Backup
Application configs: ./config/*
Download queue: ./downloads/incomplete/* (optional)
Environment file: .env
Metadata: Each *arr app's database in config folders
Quick Backup
Backup all configs:

tar czf backup-media-automation-$(date +%Y%m%d).tar.gz config/ .env docker-compose.yml

Backup to remote location:

rsync -avz --progress config/ user@backup-server:/backups/media-automation/

Automated Backup Script
Create /root/backup-media-automation.sh:

#!/bin/bash
BACKUP_DIR="/root/backups/media-automation"
DATE=$(date +%Y%m%d_%H%M%S)
STACK_DIR="/root/homelab-stack-media-automation"

mkdir -p $BACKUP_DIR

# Backup configs
tar czf $BACKUP_DIR/config-$DATE.tar.gz \
  -C $STACK_DIR config/ .env docker-compose.yml

# Keep only last 7 days
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Media automation backup completed: $DATE"

Make executable:

chmod +x /root/backup-media-automation.sh

Add to crontab:

crontab -e

Add line:

0 3 * * * /root/backup-media-automation.sh >> /var/log/media-backup.log 2>&1

Restore from Backup
Restore configs:

tar xzf backup-media-automation-YYYYMMDD.tar.gz -C /root/homelab-stack-media-automation/

Restart services:

docker compose restart

🔥 Troubleshooting
Services Won't Start
Check logs:

docker compose logs --tail=100

Check Docker daemon:

sudo systemctl status docker

Restart everything:

docker compose down
docker compose up -d

*arr App Can't Connect to Prowlarr
Verify network:

docker compose exec sonarr ping prowlarr

Check API keys match:

Prowlarr → Settings → Apps → View API key
Sonarr → Settings → General → Copy API key
Ensure they match in Prowlarr's app configuration
qBittorrent Not Downloading
Check qBittorrent logs:

docker compose logs qbittorrent

Verify ports are open:

sudo netstat -tulpn | grep 6881

Check disk space:

df -h

Indexers Failing in Prowlarr
Check FlareSolverr:

docker compose logs flaresolverr

Test FlareSolverr connection:

Prowlarr → Settings → Indexers → Test FlareSolverr
Common issues:

Indexer is down
API keys expired (private trackers)
Cloudflare blocking (use FlareSolverr)
Media Not Appearing in Jellyfin
Check file permissions:

ls -la media/movies/

Verify Jellyfin can access path:

docker compose -f ../homelab-stack/docker-compose.yml exec jellyfin ls -la /media/movies

Trigger Jellyfin library scan:

Jellyfin → Dashboard → Libraries → Scan All Libraries
Out of Disk Space
Check usage:

df -h

Check download directory:

du -sh downloads/*

Clean completed downloads:

rm -rf downloads/movies/* downloads/tv/*

Note: Only do this if media has been moved to final location

High RAM Usage
Identify culprit:

docker stats --no-stream --format "table {{.Name}}\t{{.MemUsage}}"

Common causes:

qBittorrent with many active torrents
*arr apps with large libraries
FlareSolverr with many concurrent requests
Solution: Increase limits or reduce concurrent operations

🚀 Workflow Example
Here's how the complete automation works:

User requests content → Ombi (requests.yourdomain.com)
Ombi sends to appropriate app → Sonarr/Radarr/Lidarr/Readarr
App searches indexers → via Prowlarr
Download starts → qBittorrent
Download completes → App moves to media folder
Subtitles downloaded → Bazarr (if configured)
Media available → Jellyfin/Navidrome/Audiobookshelf
User notified → via Ombi
Fully automated from request to viewing!

⚙️ Advanced Configuration
VPN Integration (Recommended for Privacy)
Add VPN container for qBittorrent. Example with Gluetun:

gluetun:
  image: qmcgaw/gluetun
  container_name: gluetun
  cap_add:
    - NET_ADMIN
  environment:
    - VPN_SERVICE_PROVIDER=your_provider
    - VPN_TYPE=openvpn
    - OPENVPN_USER=your_username
    - OPENVPN_PASSWORD=your_password
  networks:
    - media
  restart: unless-stopped

qbittorrent:
  network_mode: "service:gluetun"
  depends_on:
    - gluetun

Custom Quality Profiles
Configure in each *arr app:

Settings → Profiles → Add Custom Profile
Define quality preferences (1080p, 4K, etc.)
Set size limits
Notification Setup
Each *arr app supports notifications:

Settings → Connect → Add Connection
Options: Discord, Telegram, Email, Slack, etc.
Configure for downloads, upgrades, health issues
Reverse Proxy Authentication
Add authentication to Traefik for additional security:

Use Traefik forward auth
Add Authelia or OAuth proxy
See homelab-stack documentation
⚠️ Important Notes
Legal compliance is YOUR responsibility
SSL certificates take 2-5 minutes per service
DNS must be configured before installation
Resource limits prevent system crashes - don't remove them
Backups are critical - automate them from day one
Private trackers require API keys and account management
Monitor disk space - downloads can fill drives quickly
📚 Documentation Links
Official Documentation
Sonarr
Radarr
Lidarr
Readarr
Prowlarr
Bazarr
qBittorrent
Navidrome
Audiobookshelf
Ombi
Community Resources
TRaSH Guides - Quality profiles and optimization
r/sonarr - Community support
r/radarr - Community support
ServarrWiki - Comprehensive guides
🙏 Credits
Built as an add-on for homelab-stack

Inspired by the *arr community and TRaSH guides.

📝 License
Use at your own risk. The maintainers are not responsible for misuse or legal violations.
