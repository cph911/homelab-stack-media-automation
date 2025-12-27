#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Media Automation Stack Installer${NC}"
echo -e "${GREEN}  Add-on for homelab-stack${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if homelab-stack is installed
if [ ! -f "../homelab-stack/docker-compose.yml" ] && [ ! -f "/root/homelab-stack/docker-compose.yml" ]; then
    echo -e "${RED}ERROR: homelab-stack not found!${NC}"
    echo "This add-on requires homelab-stack to be installed first."
    echo "Install it from: https://github.com/cph911/homelab-stack"
    exit 1
fi

echo -e "${GREEN}✓ homelab-stack installation detected${NC}"
echo ""

# Display warnings
echo -e "${YELLOW}⚠️  IMPORTANT WARNINGS ⚠️${NC}"
echo ""
echo -e "${RED}1. RESOURCE REQUIREMENTS:${NC}"
echo "   - Minimum 32GB RAM required (adds ~9GB to base stack)"
echo "   - 100GB+ free disk space for downloads"
echo "   - Quad-core CPU recommended"
echo ""
echo -e "${RED}2. COMPLEXITY WARNING:${NC}"
echo "   - Adds 11 additional services to manage"
echo "   - Requires configuration of indexers, download clients, and media paths"
echo "   - More complex troubleshooting"
echo ""
echo -e "${RED}3. LEGAL DISCLAIMER:${NC}"
echo "   - This stack is designed for LEGAL media acquisition only"
echo "   - Piracy is illegal in most jurisdictions"
echo "   - You are responsible for your use of this software"
echo "   - The maintainers assume no liability for misuse"
echo ""
echo -e "${YELLOW}Services to be installed:${NC}"
echo "  Media Automation:"
echo "    - Sonarr (TV shows)"
echo "    - Radarr (Movies)"
echo "    - Lidarr (Music)"
echo "    - Readarr (Audiobooks/Ebooks) - DISABLED due to image compatibility issues"
echo "  Media Servers:"
echo "    - Navidrome (Music streaming)"
echo "    - Audiobookshelf (Audiobooks/Podcasts)"
echo "  Download & Infrastructure:"
echo "    - qBittorrent (Torrent client)"
echo "    - Prowlarr (Indexer manager)"
echo "    - Bazarr (Subtitles)"
echo "    - FlareSolverr (Cloudflare bypass)"
echo "    - Ombi (Request management for all media)"
echo ""

read -p "Do you understand and accept these warnings? (yes/no): " ACCEPT_WARNINGS
if [ "$ACCEPT_WARNINGS" != "yes" ]; then
    echo "Installation cancelled."
    exit 0
fi

# Get domain from homelab-stack .env or ask user
if [ -f "../homelab-stack/.env" ]; then
    DOMAIN=$(grep "DOMAIN=" ../homelab-stack/.env | cut -d'=' -f2)
elif [ -f "/root/homelab-stack/.env" ]; then
    DOMAIN=$(grep "DOMAIN=" /root/homelab-stack/.env | cut -d'=' -f2)
fi

# Validate DOMAIN is not empty, prompt if needed
if [ -z "$DOMAIN" ]; then
    read -p "Enter your domain name (e.g., example.com): " DOMAIN
    # Validate user actually entered something
    while [ -z "$DOMAIN" ]; do
        echo -e "${RED}Domain cannot be empty!${NC}"
        read -p "Enter your domain name (e.g., example.com): " DOMAIN
    done
fi

read -p "Enter your email for SSL certificates: " EMAIL
# Validate EMAIL is not empty
while [ -z "$EMAIL" ]; do
    echo -e "${RED}Email cannot be empty!${NC}"
    read -p "Enter your email for SSL certificates: " EMAIL
done

# RAM detection and resource limit configuration
echo ""
echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}  RESOURCE LIMIT CONFIGURATION${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""

# Detect system RAM
TOTAL_RAM=$(free -g | awk '/^Mem:/{print $2}')

echo -e "Detected System RAM: ${GREEN}${TOTAL_RAM}GB${NC}"
echo ""
echo "How much RAM does your server have?"
echo ""
echo "1) 16-32GB  - Conservative limits (~9GB for media stack)"
echo "2) 32-48GB  - Moderate limits (~16GB for media stack)"
echo "3) 48-64GB  - Relaxed limits (~24GB for media stack)"
echo "4) 64GB+    - Minimal limits (~32GB for media stack)"
echo ""
read -p "Select profile [1-4]: " RAM_PROFILE

# Validate input
while [[ ! "$RAM_PROFILE" =~ ^[1-4]$ ]]; do
  echo -e "${RED}Invalid selection. Please choose 1, 2, 3, or 4.${NC}"
  read -p "Select profile [1-4]: " RAM_PROFILE
done

# Set resource limits based on profile
case $RAM_PROFILE in
  1)
    # Conservative (16-32GB)
    PROFILE_NAME="Conservative"
    ARR_MEM="1G"
    ARR_CPU="1.0"
    QBIT_MEM="1G"
    QBIT_CPU="2.0"
    PROWLARR_MEM="512M"
    PROWLARR_CPU="0.5"
    BAZARR_MEM="512M"
    BAZARR_CPU="0.5"
    FLARE_MEM="512M"
    FLARE_CPU="1.0"
    MEDIA_MEM="512M"
    MEDIA_CPU="0.5"
    ;;
  2)
    # Moderate (32-48GB)
    PROFILE_NAME="Moderate"
    ARR_MEM="2G"
    ARR_CPU="1.5"
    QBIT_MEM="2G"
    QBIT_CPU="3.0"
    PROWLARR_MEM="1G"
    PROWLARR_CPU="0.75"
    BAZARR_MEM="1G"
    BAZARR_CPU="0.75"
    FLARE_MEM="1G"
    FLARE_CPU="1.5"
    MEDIA_MEM="1G"
    MEDIA_CPU="0.75"
    ;;
  3)
    # Relaxed (48-64GB)
    PROFILE_NAME="Relaxed"
    ARR_MEM="4G"
    ARR_CPU="2.0"
    QBIT_MEM="4G"
    QBIT_CPU="4.0"
    PROWLARR_MEM="2G"
    PROWLARR_CPU="1.0"
    BAZARR_MEM="2G"
    BAZARR_CPU="1.0"
    FLARE_MEM="2G"
    FLARE_CPU="2.0"
    MEDIA_MEM="2G"
    MEDIA_CPU="1.0"
    ;;
  4)
    # Minimal (64GB+)
    PROFILE_NAME="Minimal/No Limits"
    ARR_MEM="8G"
    ARR_CPU="4.0"
    QBIT_MEM="8G"
    QBIT_CPU="6.0"
    PROWLARR_MEM="4G"
    PROWLARR_CPU="2.0"
    BAZARR_MEM="4G"
    BAZARR_CPU="2.0"
    FLARE_MEM="4G"
    FLARE_CPU="2.0"
    MEDIA_MEM="4G"
    MEDIA_CPU="2.0"
    ;;
esac

echo ""
echo -e "${GREEN}Selected profile: $PROFILE_NAME${NC}"
echo "Resource limits will be configured accordingly."
echo ""

echo "Generating secure passwords..."

# Generate random passwords
QBITTORRENT_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
OMBI_API_KEY=$(openssl rand -hex 16)

# Create .env file
cat > .env << EOF
# Domain Configuration
DOMAIN=${DOMAIN}
EMAIL=${EMAIL}

# qBittorrent
QBITTORRENT_USERNAME=admin
QBITTORRENT_PASSWORD=${QBITTORRENT_PASSWORD}

# Timezone
TZ=America/New_York

# Ombi API Key (generated)
OMBI_API_KEY=${OMBI_API_KEY}
EOF

chmod 600 .env

# Create directory structure
echo ""
echo "Creating directory structure..."

mkdir -p config/{sonarr,radarr,lidarr,readarr,prowlarr,bazarr,qbittorrent,flaresolverr,ombi,navidrome,audiobookshelf}
mkdir -p downloads/{movies,tv,music,audiobooks,incomplete}
mkdir -p media/{movies,tv,music,audiobooks}

echo -e "${GREEN}✓ Directory structure created${NC}"

# Create docker-compose.yml
echo ""
echo "Generating Docker Compose configuration..."

cat > docker-compose.yml << DOCKEREOF
version: '3.8'

networks:
  homelab:
    external: true
  media:
    driver: bridge

services:
  # ============================================
  # MEDIA AUTOMATION SERVICES (*arr stack)
  # ============================================

  sonarr:
    image: lscr.io/linuxserver/sonarr:latest
    container_name: sonarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=${TZ}
    volumes:
      - ./config/sonarr:/config
      - ./media/tv:/tv
      - ./downloads:/downloads
    networks:
      - homelab
      - media
    deploy:
      resources:
        limits:
          memory: $ARR_MEM
          cpus: '$ARR_CPU'
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.sonarr.rule=Host(\`sonarr.${DOMAIN}\`)"
      - "traefik.http.routers.sonarr.entrypoints=websecure"
      - "traefik.http.routers.sonarr.tls.certresolver=letsencrypt"
      - "traefik.http.services.sonarr.loadbalancer.server.port=8989"
    restart: unless-stopped

  radarr:
    image: lscr.io/linuxserver/radarr:latest
    container_name: radarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=${TZ}
    volumes:
      - ./config/radarr:/config
      - ./media/movies:/movies
      - ./downloads:/downloads
    networks:
      - homelab
      - media
    deploy:
      resources:
        limits:
          memory: $ARR_MEM
          cpus: '$ARR_CPU'
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.radarr.rule=Host(\`radarr.${DOMAIN}\`)"
      - "traefik.http.routers.radarr.entrypoints=websecure"
      - "traefik.http.routers.radarr.tls.certresolver=letsencrypt"
      - "traefik.http.services.radarr.loadbalancer.server.port=7878"
    restart: unless-stopped

  lidarr:
    image: lscr.io/linuxserver/lidarr:latest
    container_name: lidarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=${TZ}
    volumes:
      - ./config/lidarr:/config
      - ./media/music:/music
      - ./downloads:/downloads
    networks:
      - homelab
      - media
    deploy:
      resources:
        limits:
          memory: $ARR_MEM
          cpus: '$ARR_CPU'
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.lidarr.rule=Host(\`lidarr.${DOMAIN}\`)"
      - "traefik.http.routers.lidarr.entrypoints=websecure"
      - "traefik.http.routers.lidarr.tls.certresolver=letsencrypt"
      - "traefik.http.services.lidarr.loadbalancer.server.port=8686"
    restart: unless-stopped

  # readarr:
  #   image: lscr.io/linuxserver/readarr:latest
  #   container_name: readarr
  #   environment:
  #     - PUID=1000
  #     - PGID=1000
  #     - TZ=${TZ}
  #   volumes:
  #     - ./config/readarr:/config
  #     - ./media/audiobooks:/audiobooks
  #     - ./downloads:/downloads
  #   networks:
  #     - homelab
  #     - media
  #   deploy:
  #     resources:
  #       limits:
  #         memory: $ARR_MEM
  #         cpus: '$ARR_CPU'
  #   labels:
  #     - "traefik.enable=true"
  #     - "traefik.http.routers.readarr.rule=Host(\`readarr.${DOMAIN}\`)"
  #     - "traefik.http.routers.readarr.entrypoints=websecure"
  #     - "traefik.http.routers.readarr.tls.certresolver=letsencrypt"
  #     - "traefik.http.services.readarr.loadbalancer.server.port=8787"
  #   restart: unless-stopped

  # NOTE: Readarr is disabled due to architecture compatibility issues
  # The linuxserver/readarr images don't currently support linux/amd64 properly
  # You can manually add it later if they fix their builds, or use an alternative image

  prowlarr:
    image: lscr.io/linuxserver/prowlarr:latest
    container_name: prowlarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=${TZ}
    volumes:
      - ./config/prowlarr:/config
    networks:
      - homelab
      - media
    deploy:
      resources:
        limits:
          memory: $PROWLARR_MEM
          cpus: '$PROWLARR_CPU'
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.prowlarr.rule=Host(\`prowlarr.${DOMAIN}\`)"
      - "traefik.http.routers.prowlarr.entrypoints=websecure"
      - "traefik.http.routers.prowlarr.tls.certresolver=letsencrypt"
      - "traefik.http.services.prowlarr.loadbalancer.server.port=9696"
    restart: unless-stopped

  bazarr:
    image: lscr.io/linuxserver/bazarr:latest
    container_name: bazarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=${TZ}
    volumes:
      - ./config/bazarr:/config
      - ./media/movies:/movies
      - ./media/tv:/tv
    networks:
      - homelab
      - media
    deploy:
      resources:
        limits:
          memory: $BAZARR_MEM
          cpus: '$BAZARR_CPU'
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.bazarr.rule=Host(\`bazarr.${DOMAIN}\`)"
      - "traefik.http.routers.bazarr.entrypoints=websecure"
      - "traefik.http.routers.bazarr.tls.certresolver=letsencrypt"
      - "traefik.http.services.bazarr.loadbalancer.server.port=6767"
    restart: unless-stopped

  # ============================================
  # DOWNLOAD CLIENTS
  # ============================================

  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=${TZ}
      - WEBUI_PORT=8080
    volumes:
      - ./config/qbittorrent:/config
      - ./downloads:/downloads
    networks:
      - homelab
      - media
    ports:
      - "6881:6881"
      - "6881:6881/udp"
    deploy:
      resources:
        limits:
          memory: $QBIT_MEM
          cpus: '$QBIT_CPU'
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.qbittorrent.rule=Host(\`qbittorrent.${DOMAIN}\`)"
      - "traefik.http.routers.qbittorrent.entrypoints=websecure"
      - "traefik.http.routers.qbittorrent.tls.certresolver=letsencrypt"
      - "traefik.http.services.qbittorrent.loadbalancer.server.port=8080"
    restart: unless-stopped

  flaresolverr:
    image: ghcr.io/flaresolverr/flaresolverr:latest
    container_name: flaresolverr
    environment:
      - LOG_LEVEL=info
      - TZ=${TZ}
    networks:
      - media
    deploy:
      resources:
        limits:
          memory: $FLARE_MEM
          cpus: '$FLARE_CPU'
    restart: unless-stopped

  # ============================================
  # MEDIA SERVERS
  # ============================================

  navidrome:
    image: deluan/navidrome:latest
    container_name: navidrome
    environment:
      - ND_SCANSCHEDULE=1h
      - ND_LOGLEVEL=info
      - ND_SESSIONTIMEOUT=24h
      - ND_BASEURL=/
    volumes:
      - ./config/navidrome:/data
      - ./media/music:/music:ro
    networks:
      - homelab
    deploy:
      resources:
        limits:
          memory: $MEDIA_MEM
          cpus: '$MEDIA_CPU'
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.navidrome.rule=Host(\`music.${DOMAIN}\`)"
      - "traefik.http.routers.navidrome.entrypoints=websecure"
      - "traefik.http.routers.navidrome.tls.certresolver=letsencrypt"
      - "traefik.http.services.navidrome.loadbalancer.server.port=4533"
    restart: unless-stopped

  audiobookshelf:
    image: ghcr.io/advplyr/audiobookshelf:latest
    container_name: audiobookshelf
    environment:
      - TZ=${TZ}
    volumes:
      - ./config/audiobookshelf:/config
      - ./media/audiobooks:/audiobooks
    networks:
      - homelab
    deploy:
      resources:
        limits:
          memory: $MEDIA_MEM
          cpus: '$MEDIA_CPU'
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.audiobookshelf.rule=Host(\`audiobooks.${DOMAIN}\`)"
      - "traefik.http.routers.audiobookshelf.entrypoints=websecure"
      - "traefik.http.routers.audiobookshelf.tls.certresolver=letsencrypt"
      - "traefik.http.services.audiobookshelf.loadbalancer.server.port=80"
    restart: unless-stopped

  # ============================================
  # REQUEST MANAGEMENT
  # ============================================

  ombi:
    image: lscr.io/linuxserver/ombi:latest
    container_name: ombi
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=${TZ}
    volumes:
      - ./config/ombi:/config
    networks:
      - homelab
      - media
    deploy:
      resources:
        limits:
          memory: $MEDIA_MEM
          cpus: '$MEDIA_CPU'
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.ombi.rule=Host(\`requests.${DOMAIN}\`)"
      - "traefik.http.routers.ombi.entrypoints=websecure"
      - "traefik.http.routers.ombi.tls.certresolver=letsencrypt"
      - "traefik.http.services.ombi.loadbalancer.server.port=3579"
    restart: unless-stopped
DOCKEREOF

echo -e "${GREEN}✓ Docker Compose configuration created${NC}"

# Validate DNS
echo ""
echo "Validating DNS records..."
SERVICES=("sonarr" "radarr" "lidarr" "prowlarr" "bazarr" "qbittorrent" "music" "audiobooks" "requests")
DNS_VALID=true

for service in "${SERVICES[@]}"; do
    if nslookup "${service}.${DOMAIN}" >/dev/null 2>&1 || dig +short "${service}.${DOMAIN}" >/dev/null 2>&1 || host "${service}.${DOMAIN}" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ ${service}.${DOMAIN}${NC}"
    else
        echo -e "${YELLOW}⚠ ${service}.${DOMAIN} - Not found${NC}"
        DNS_VALID=false
    fi
done

if [ "$DNS_VALID" = false ]; then
    echo ""
    echo -e "${YELLOW}Some DNS records are not configured.${NC}"
    echo "SSL certificates will fail without proper DNS."
    read -p "Continue anyway? (yes/no): " CONTINUE
    if [ "$CONTINUE" != "yes" ]; then
        echo "Installation cancelled. Configure DNS and try again."
        exit 0
    fi
fi

# Pull images
echo ""
echo "Pulling Docker images (this may take 10-15 minutes)..."
if ! docker compose pull; then
    echo -e "${YELLOW}Initial pull failed, retrying...${NC}"
    sleep 5
    docker compose pull
fi

# Start services
echo ""
echo "Starting services..."
docker compose up -d

# Wait for services to be healthy
echo ""
echo "Waiting for services to start (30 seconds)..."
sleep 30

# Save installation info
cat > INSTALLATION_INFO.txt << INFOEOF
Media Automation Stack Installation Complete!
============================================

Installation Date: $(date)
Domain: ${DOMAIN}
Resource Profile: ${PROFILE_NAME}

Services & Access URLs:
======================

Media Automation (*arr):
- Sonarr (TV):        https://sonarr.${DOMAIN}
- Radarr (Movies):    https://radarr.${DOMAIN}
- Lidarr (Music):     https://lidarr.${DOMAIN}
- Readarr (Books):    DISABLED - Image compatibility issues with linux/amd64
- Prowlarr (Indexer): https://prowlarr.${DOMAIN}
- Bazarr (Subtitles): https://bazarr.${DOMAIN}

Download Clients:
- qBittorrent:        https://qbittorrent.${DOMAIN}
  Default user: admin
  Default pass: Check qBittorrent logs on first login

Media Servers:
- Navidrome (Music):      https://music.${DOMAIN}
- Audiobookshelf (Books): https://audiobooks.${DOMAIN}

Request Management:
- Ombi: https://requests.${DOMAIN}

qBittorrent Credentials:
Username: ${QBITTORRENT_USERNAME}
Password: ${QBITTORRENT_PASSWORD}

IMPORTANT NEXT STEPS:
====================

1. Configure Prowlarr:
   - Add indexers (torrent sites)
   - Connect to Sonarr, Radarr, Lidarr

2. Configure Download Clients:
   - Add qBittorrent to each *arr app
   - Set download paths

3. Configure Media Paths:
   - Sonarr: /tv
   - Radarr: /movies
   - Lidarr: /music
   - (Readarr disabled due to compatibility issues)

4. Link to Existing Media Servers:
   - Point Jellyfin to ./media/* directories
   - Configure Navidrome music library
   - Configure Audiobookshelf library

5. Setup Ombi:
   - Connect to Sonarr, Radarr, Lidarr
   - Configure user access
   - Setup notifications

Directory Structure:
===================
./config/*       - Application configurations
./downloads/*    - Download staging area
./media/*        - Final media storage (link to Jellyfin)

Resource Configuration:
========================
Profile: ${PROFILE_NAME}
*arr apps (Sonarr/Radarr/Lidarr/Readarr): ${ARR_MEM} RAM, ${ARR_CPU} CPU each
qBittorrent: ${QBIT_MEM} RAM, ${QBIT_CPU} CPU
Prowlarr: ${PROWLARR_MEM} RAM, ${PROWLARR_CPU} CPU
Bazarr: ${BAZARR_MEM} RAM, ${BAZARR_CPU} CPU
FlareSolverr: ${FLARE_MEM} RAM, ${FLARE_CPU} CPU
Media Servers (Navidrome/Audiobookshelf/Ombi): ${MEDIA_MEM} RAM, ${MEDIA_CPU} CPU each

For detailed setup guides, see README.md
INFOEOF

chmod 600 INSTALLATION_INFO.txt

# Display completion message
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "Installation details saved to: INSTALLATION_INFO.txt"
echo ""
echo -e "${YELLOW}NEXT STEPS:${NC}"
echo "1. Configure Prowlarr at https://prowlarr.${DOMAIN}"
echo "2. Add indexers and connect to *arr apps"
echo "3. Configure download clients in each *arr app"
echo "4. Link media directories to Jellyfin"
echo "5. Setup Ombi for request management"
echo ""
echo -e "${GREEN}All services should be accessible now!${NC}"
echo ""
echo "View logs: docker compose logs -f"
echo "Restart: docker compose restart"
echo "Stop: docker compose down"
echo ""
