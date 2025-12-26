# 🎬 Homelab Media Automation Stack

**Advanced add-on for [homelab-stack](https://github.com/cph911/homelab-stack)**

Automated media acquisition and management for TV shows, movies, music, and audiobooks. Complete *arr stack with download clients, media servers, and request management.

> ⚠️ **CRITICAL WARNINGS - READ BEFORE INSTALLING**
>
> **Resource Requirements:**
> - **16GB RAM minimum** for Conservative profile (adds ~9GB to base stack)
> - **32GB+ RAM recommended** for better performance with Moderate/Relaxed profiles
> - **64GB+ RAM** for Minimal Limits profile (maximum performance)
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

### Dynamic Resource Profiles

The installer **automatically configures resource limits** based on your available RAM. During installation, you'll select a profile:

**1. Conservative (16-32GB RAM)** - ~9GB for media stack
| Service | RAM | CPU | Purpose |
|---------|-----|-----|---------|
| Sonarr/Radarr/Lidarr/Readarr | 1GB | 1.0 | *arr automation |
| qBittorrent | 1GB | 2.0 | Download client |
| Prowlarr | 512MB | 0.5 | Indexer management |
| Bazarr | 512MB | 0.5 | Subtitles |
| FlareSolverr | 512MB | 1.0 | Cloudflare bypass |
| Navidrome/Audiobookshelf/Ombi | 512MB | 0.5 | Media servers |

**2. Moderate (32-48GB RAM)** - ~16GB for media stack
| Service | RAM | CPU |
|---------|-----|-----|
| Sonarr/Radarr/Lidarr/Readarr | 2GB | 1.5 |
| qBittorrent | 2GB | 3.0 |
| Prowlarr | 1GB | 0.75 |
| Bazarr | 1GB | 0.75 |
| FlareSolverr | 1GB | 1.5 |
| Navidrome/Audiobookshelf/Ombi | 1GB | 0.75 |

**3. Relaxed (48-64GB RAM)** - ~24GB for media stack
| Service | RAM | CPU |
|---------|-----|-----|
| Sonarr/Radarr/Lidarr/Readarr | 4GB | 2.0 |
| qBittorrent | 4GB | 4.0 |
| Prowlarr | 2GB | 1.0 |
| Bazarr | 2GB | 1.0 |
| FlareSolverr | 2GB | 2.0 |
| Navidrome/Audiobookshelf/Ombi | 2GB | 1.0 |

**4. Minimal Limits (64GB+ RAM)** - ~32GB for media stack
| Service | RAM | CPU |
|---------|-----|-----|
| Sonarr/Radarr/Lidarr/Readarr | 8GB | 4.0 |
| qBittorrent | 8GB | 6.0 |
| Prowlarr | 4GB | 2.0 |
| Bazarr | 4GB | 2.0 |
| FlareSolverr | 4GB | 2.0 |
| Navidrome/Audiobookshelf/Ombi | 4GB | 2.0 |

### Why Resource Limits?

- **Prevent system crashes** - A runaway process can't consume all RAM
- **Fair resource distribution** - No single service monopolizes resources
- **Predictable performance** - You know exactly how much RAM is allocated
- **Easy capacity planning** - Clear view of total resource usage

**Note:** With 64GB+ RAM, you can safely use the "Minimal Limits" profile for maximum performance without worrying about resource exhaustion.

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
```

**Step 2: Navigate to directory**
```bash
cd homelab-stack-media-automation
```

**Step 3: Make installer executable**
```bash
chmod +x install-media-automation.sh
```

**Step 4: Run the installer**
```bash
./install-media-automation.sh
```

The installer will:
- Verify homelab-stack is installed
- Display warnings and require confirmation
- Ask for domain configuration
- **Detect your RAM and ask you to select a resource profile** (Conservative/Moderate/Relaxed/Minimal)
- Generate secure passwords
- Create directory structure
- Validate DNS records for all services
- Pull Docker images
- Start all services
- Create installation documentation

**Total time: 15-20 minutes**

-----

## 🌐 DNS Configuration

Configure these A records BEFORE installation:

```
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
```

Verify with:
```bash
nslookup sonarr.yourdomain.com
```

-----

## 🔧 Post-Installation Setup

### Step 1: Configure Prowlarr (CRITICAL - Do This First)

Prowlarr manages all indexers centrally.

**Access Prowlarr:**
```
https://prowlarr.yourdomain.com
```

**Setup Steps:**

1. **Add Indexers:**
   - Go to `Indexers` → `Add Indexer`
   - Add your torrent indexers (public or private trackers)
   - Configure FlareSolverr for Cloudflare-protected sites:
     - `Settings` → `Indexers` → `FlareSolverr`
     - Host: `http://flaresolverr:8191`

2. **Connect to Apps:**
   - Go to `Settings` → `Apps` → `Add Application`
   - **Add Sonarr:**
     - Prowlarr Server: `http://prowlarr:9696`
     - Sonarr Server: `http://sonarr:8989`
     - API Key: Get from Sonarr → Settings → General
   - Repeat for Radarr, Lidarr, Readarr

### Step 2: Configure Download Client (qBittorrent)

**Access qBittorrent:**
```
https://qbittorrent.yourdomain.com
```

Login credentials: Check `INSTALLATION_INFO.txt`

**In each *arr app (Sonarr, Radarr, Lidarr, Readarr):**
- Go to `Settings` → `Download Clients` → `Add` → `qBittorrent`
- Configure:
  - Host: `qbittorrent`
  - Port: `8080`
  - Username: `admin`
  - Password: From `INSTALLATION_INFO.txt`

### Step 3: Configure Media Paths

**In Sonarr:**
- `Settings` → `Media Management` → `Root Folders` → Add `/tv`

**In Radarr:**
- `Settings` → `Media Management` → `Root Folders` → Add `/movies`

**In Lidarr:**
- `Settings` → `Media Management` → `Root Folders` → Add `/music`

**In Readarr:**
- `Settings` → `Media Management` → `Root Folders` → Add `/audiobooks`

### Step 4: Link to Jellyfin

The media directories need to be accessible to Jellyfin from base homelab-stack.

**Option A: Bind mount (Recommended)**

Edit your homelab-stack `docker-compose.yml`:
```yaml
jellyfin:
  volumes:
    - jellyfin_config:/config
    - jellyfin_cache:/cache
    - ../homelab-stack-media-automation/media/movies:/media/movies:ro
    - ../homelab-stack-media-automation/media/tv:/media/tv:ro
    - ../homelab-stack-media-automation/media/music:/media/music:ro
```

Restart Jellyfin:
```bash
cd ../homelab-stack
docker compose restart jellyfin
```

**Option B: Symlinks**
```bash
ln -s /home/user/homelab-stack-media-automation/media/movies /home/user/homelab-stack/jellyfin-media/movies
ln -s /home/user/homelab-stack-media-automation/media/tv /home/user/homelab-stack/jellyfin-media/tv
ln -s /home/user/homelab-stack-media-automation/media/music /home/user/homelab-stack/jellyfin-media/music
```

### Step 5: Configure Navidrome

**Access Navidrome:**
```
https://music.yourdomain.com
```

- Create admin account on first visit
- Music library is auto-configured at `/music`
- Download mobile apps:
  - iOS: substreamer, play:Sub
  - Android: DSub, Ultrasonic

### Step 6: Configure Audiobookshelf

**Access Audiobookshelf:**
```
https://audiobooks.yourdomain.com
```

- Create admin account on first visit
- Add library → Audiobooks → `/audiobooks`
- Configure metadata providers
- Download mobile app: Audiobookshelf (iOS/Android)

### Step 7: Setup Ombi (Request Management)

**Access Ombi:**
```
https://requests.yourdomain.com
```

**Setup:**
1. Complete initial wizard
2. **Connect Sonarr:**
   - `Settings` → `Sonarr` → `Add Server`
   - Hostname: `sonarr`
   - Port: `8989`
   - API Key: From Sonarr → Settings → General
3. Repeat for Radarr, Lidarr, Readarr
4. Configure user access and permissions
5. Setup notifications (email, Discord, etc.)

**User Access:**
- Users can request content at `https://requests.yourdomain.com`
- Requests auto-forward to appropriate *arr app
- Notifications when content is available

-----

## 📁 Directory Structure

```
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
```

-----

## 🔧 Management Commands

### Service Control

**View all logs:**
```bash
docker compose logs -f
```

**View specific service:**
```bash
docker compose logs -f sonarr
```

**Restart all services:**
```bash
docker compose restart
```

**Restart specific service:**
```bash
docker compose restart radarr
```

**Stop all services:**
```bash
docker compose down
```

**Start all services:**
```bash
docker compose up -d
```

**Check service status:**
```bash
docker compose ps
```

**View resource usage:**
```bash
docker stats
```

### Updates

**Step 1: Pull latest images**
```bash
docker compose pull
```

**Step 2: Recreate containers**
```bash
docker compose up -d
```

**Step 3: Check logs**
```bash
docker compose logs -f
```

-----

## 💾 Backup & Restore

### What to Backup

- **Application configs:** `./config/*`
- **Download queue:** `./downloads/incomplete/*` (optional)
- **Environment file:** `.env`
- **Metadata:** Each *arr app's database in config folders

### Quick Backup

**Backup all configs:**
```bash
tar czf backup-media-automation-$(date +%Y%m%d).tar.gz config/ .env docker-compose.yml
```

**Backup to remote location:**
```bash
rsync -avz --progress config/ user@backup-server:/backups/media-automation/
```

### Automated Backup Script

Create `/root/backup-media-automation.sh`:
```bash
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
```

Make executable:
```bash
chmod +x /root/backup-media-automation.sh
```

Add to crontab:
```bash
crontab -e
```

Add line:
```
0 3 * * * /root/backup-media-automation.sh >> /var/log/media-backup.log 2>&1
```

### Restore from Backup

**Restore configs:**
```bash
tar xzf backup-media-automation-YYYYMMDD.tar.gz -C /root/homelab-stack-media-automation/
```

**Restart services:**
```bash
docker compose restart
```

-----

## 🔥 Troubleshooting

### Services Won't Start

**Check logs:**
```bash
docker compose logs --tail=100
```

**Check Docker daemon:**
```bash
sudo systemctl status docker
```

**Restart everything:**
```bash
docker compose down
docker compose up -d
```

### *arr App Can't Connect to Prowlarr

**Verify network:**
```bash
docker compose exec sonarr ping prowlarr
```

**Check API keys match:**
- Prowlarr → Settings → Apps → View API key
- Sonarr → Settings → General → Copy API key
- Ensure they match in Prowlarr's app configuration

### qBittorrent Not Downloading

**Check qBittorrent logs:**
```bash
docker compose logs qbittorrent
```

**Verify ports are open:**
```bash
sudo netstat -tulpn | grep 6881
```

**Check disk space:**
```bash
df -h
```

### Indexers Failing in Prowlarr

**Check FlareSolverr:**
```bash
docker compose logs flaresolverr
```

**Test FlareSolverr connection:**
- Prowlarr → Settings → Indexers → Test FlareSolverr

**Common issues:**
- Indexer is down
- API keys expired (private trackers)
- Cloudflare blocking (use FlareSolverr)

### Media Not Appearing in Jellyfin

**Check file permissions:**
```bash
ls -la media/movies/
```

**Verify Jellyfin can access path:**
```bash
docker compose -f ../homelab-stack/docker-compose.yml exec jellyfin ls -la /media/movies
```

**Trigger Jellyfin library scan:**
- Jellyfin → Dashboard → Libraries → Scan All Libraries

### Out of Disk Space

**Check usage:**
```bash
df -h
```

**Check download directory:**
```bash
du -sh downloads/*
```

**Clean completed downloads:**
```bash
rm -rf downloads/movies/* downloads/tv/*
```
*Note: Only do this if media has been moved to final location*

### High RAM Usage

**Identify culprit:**
```bash
docker stats --no-stream --format "table {{.Name}}\t{{.MemUsage}}"
```

**Common causes:**
- qBittorrent with many active torrents
- *arr apps with large libraries
- FlareSolverr with many concurrent requests

**Solution:** Increase limits or reduce concurrent operations

-----

## 🚀 Workflow Example

Here's how the complete automation works:

1. **User requests content** → Ombi (requests.yourdomain.com)
2. **Ombi sends to appropriate app** → Sonarr/Radarr/Lidarr/Readarr
3. **App searches indexers** → via Prowlarr
4. **Download starts** → qBittorrent
5. **Download completes** → App moves to media folder
6. **Subtitles downloaded** → Bazarr (if configured)
7. **Media available** → Jellyfin/Navidrome/Audiobookshelf
8. **User notified** → via Ombi

**Fully automated from request to viewing!**

-----

## ⚙️ Advanced Configuration

### VPN Integration (Recommended for Privacy)

Add VPN container for qBittorrent. Example with Gluetun:

```yaml
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
```

### Custom Quality Profiles

Configure in each *arr app:
- `Settings` → `Profiles` → `Add Custom Profile`
- Define quality preferences (1080p, 4K, etc.)
- Set size limits

### Notification Setup

Each *arr app supports notifications:
- `Settings` → `Connect` → `Add Connection`
- Options: Discord, Telegram, Email, Slack, etc.
- Configure for downloads, upgrades, health issues

### Reverse Proxy Authentication

Add authentication to Traefik for additional security:
- Use Traefik forward auth
- Add Authelia or OAuth proxy
- See homelab-stack documentation

-----

## ⚠️ Important Notes

- Legal compliance is YOUR responsibility
- SSL certificates take 2-5 minutes per service
- DNS must be configured before installation
- **Resource limits are automatically configured** based on your RAM - choose the right profile during installation
- Select "Minimal Limits" profile for 64GB+ RAM systems for best performance
- Backups are critical - automate them from day one
- Private trackers require API keys and account management
- Monitor disk space - downloads can fill drives quickly

-----

## 📚 Documentation Links

### Official Documentation
- [Sonarr](https://wiki.servarr.com/sonarr)
- [Radarr](https://wiki.servarr.com/radarr)
- [Lidarr](https://wiki.servarr.com/lidarr)
- [Readarr](https://wiki.servarr.com/readarr)
- [Prowlarr](https://wiki.servarr.com/prowlarr)
- [Bazarr](https://wiki.bazarr.media/)
- [qBittorrent](https://github.com/qbittorrent/qBittorrent/wiki)
- [Navidrome](https://www.navidrome.org/docs/)
- [Audiobookshelf](https://www.audiobookshelf.org/docs/)
- [Ombi](https://docs.ombi.app/)

### Community Resources
- [TRaSH Guides](https://trash-guides.info/) - Quality profiles and optimization
- [r/sonarr](https://reddit.com/r/sonarr) - Community support
- [r/radarr](https://reddit.com/r/radarr) - Community support
- [ServarrWiki](https://wiki.servarr.com/) - Comprehensive guides

-----

## 🙏 Credits

Built as an add-on for [homelab-stack](https://github.com/cph911/homelab-stack)

Inspired by the *arr community and TRaSH guides.

-----

## 📝 License

Use at your own risk. The maintainers are not responsible for misuse or legal violations.
