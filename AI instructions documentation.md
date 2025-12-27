# AI Instructions for homelab-stack-media-automation

## Project Overview

This repository provides a media automation stack add-on for [homelab-stack](https://github.com/cph911/homelab-stack). It includes:
- Media automation services (*arr stack): Sonarr, Radarr, Lidarr
- Media servers: Navidrome, Audiobookshelf
- Download infrastructure: qBittorrent, Prowlarr, Bazarr, FlareSolverr, Ombi

## Critical Prerequisites

**IMPORTANT**: This stack is an add-on and **requires homelab-stack to be installed first**.

1. **homelab-stack dependency**: The base homelab-stack must be running before installing this
2. **Network dependency**: This stack connects to the `homelab` network created by homelab-stack
3. **Traefik dependency**: SSL/TLS termination is handled by Traefik from homelab-stack

## Known Issues & Solutions

### 1. Readarr Architecture Compatibility (CRITICAL)

**Issue**: All Readarr images from linuxserver.io fail on linux/amd64 with:
```
Error response from daemon: no matching manifest for linux/amd64 in the manifest list entries
```

**Affected tags**: `latest`, `nightly`, `develop` - ALL fail

**Solution**: Readarr is **disabled by default** in the installation script
- Service is commented out in docker-compose template (lines 315-340)
- Removed from DNS validation checks
- Documented in user-facing messages

**Do NOT**:
- Try to re-enable Readarr without verifying linuxserver.io has fixed their builds
- Suggest using different tags (they all fail)
- Remove the explanatory comments

### 2. Network Configuration (CRITICAL)

**Issue**: The stack must connect to the `homelab` network, NOT `traefik`

**Correct configuration**:
```yaml
networks:
  homelab:
    external: true
  media:
    driver: bridge

services:
  sonarr:
    networks:
      - homelab
      - media
```

**Why**: The homelab-stack creates a network called `homelab` where Traefik runs. Using `traefik` as the network name will fail with:
```
network traefik declared as external, but could not be found
```

**Verification command**: `docker network ls` should show `homelab` network

### 3. Bash Heredoc Variable Substitution (CRITICAL)

**Issue**: Quoted heredoc delimiters prevent variable substitution

**WRONG**:
```bash
cat > docker-compose.yml << 'DOCKEREOF'
  memory: $ARR_MEM  # This becomes literal "$ARR_MEM"
DOCKEREOF
```

**CORRECT**:
```bash
cat > docker-compose.yml << DOCKEREOF
  memory: $ARR_MEM  # This substitutes the actual value
DOCKEREOF
```

**Line**: install-media-automation.sh:220

**Why**: Quoted delimiters cause bash to treat content as literal text, resulting in YAML with literal `$VAR_NAME` strings, which docker-compose can't parse (causes "unknown escape character" errors)

### 4. Resource Limit Variables

The installation script uses these variables for docker-compose resource limits:
- `$ARR_MEM`, `$ARR_CPU` - For Sonarr, Radarr, Lidarr
- `$QBIT_MEM`, `$QBIT_CPU` - For qBittorrent
- `$PROWLARR_MEM`, `$PROWLARR_CPU` - For Prowlarr
- `$BAZARR_MEM`, `$BAZARR_CPU` - For Bazarr
- `$FLARE_MEM`, `$FLARE_CPU` - For FlareSolverr
- `$MEDIA_MEM`, `$MEDIA_CPU` - For Navidrome, Audiobookshelf, Ombi

These are set based on user's RAM profile selection and MUST be substituted during docker-compose.yml generation.

### 5. Certificate Resolver Configuration (CRITICAL)

**Issue**: Traefik certificate resolver name must match homelab-stack configuration

**Context**: The homelab-stack's Traefik instance uses `letsencrypt` as the certificate resolver name. All services must reference this exact name.

**WRONG**:
```yaml
- "traefik.http.routers.prowlarr.tls.certresolver=myresolver"
```

**CORRECT**:
```yaml
- "traefik.http.routers.prowlarr.tls.certresolver=letsencrypt"
```

**Symptoms if misconfigured**:
- Error: "Router prowlarr@docker uses a nonexistent resolver: myresolver"
- Services accessible but without SSL/TLS
- Certificate issuance fails silently

**Verification command**:
```bash
docker inspect traefik | grep certresolver
```

**Fixed lines**: All Traefik labels in docker-compose template use `certresolver=letsencrypt`

### 6. Empty DOMAIN Variable (CRITICAL)

**Issue**: Installation script could create .env with empty DOMAIN value

**Root cause**: Script attempted to read DOMAIN from homelab-stack .env file, but if that value was empty or missing, it would create the media automation .env with `DOMAIN=` (no value).

**Impact**:
- Traefik sees incomplete host rules like `Host('prowlarr.')` instead of `Host('prowlarr.example.com')`
- Services become inaccessible
- SSL certificate issuance fails
- Error difficult to diagnose (no clear error message)

**Solution implemented** (lines 77-85):
```bash
# Validate DOMAIN is not empty, prompt if needed
if [ -z "$DOMAIN" ]; then
    read -p "Enter your domain name (e.g., example.com): " DOMAIN
    # Validate user actually entered something
    while [ -z "$DOMAIN" ]; do
        echo -e "${RED}Domain cannot be empty!${NC}"
        read -p "Enter your domain name (e.g., example.com): " DOMAIN
    done
fi
```

**Similar validation** added for EMAIL (lines 88-92) to prevent empty email addresses.

**How to verify**: After installation, check:
```bash
cat .env | grep DOMAIN=
# Should show: DOMAIN=example.com (not DOMAIN=)
```

### 7. DNS Validation False Positive (MINOR)

**Issue**: DNS validation may show success even when DNS records don't exist

**Root cause**: Commands like `nslookup`, `dig`, and `host` return exit code 0 for both successful lookups AND NXDOMAIN responses. They only fail (non-zero exit) on network errors or command failures.

**Current behavior** (line 552):
```bash
if nslookup "${service}.${DOMAIN}" >/dev/null 2>&1 || dig +short "${service}.${DOMAIN}" >/dev/null 2>&1 || host "${service}.${DOMAIN}" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ ${service}.${DOMAIN}${NC}"
```

This will show ✓ even if DNS returns NXDOMAIN because the command itself succeeded.

**Impact**:
- User may think DNS is configured when it's not
- Installation proceeds but SSL certificate issuance fails later
- Not critical since user is prompted to continue anyway if validation fails

**Status**: Known limitation, documented for future improvement

**Potential fix**: Check command output instead of exit code:
```bash
if dig +short "${service}.${DOMAIN}" 2>/dev/null | grep -q .; then
    echo -e "${GREEN}✓ ${service}.${DOMAIN}${NC}"
else
    echo -e "${YELLOW}⚠ ${service}.${DOMAIN} - Not found${NC}"
    DNS_VALID=false
fi
```

## Testing Protocol

When testing changes to this repository:

### 1. Prerequisites Check
```bash
# Verify homelab-stack is running
docker ps | grep traefik

# Verify homelab network exists
docker network ls | grep homelab
```

### 2. Clean Slate Testing
```bash
cd ~/homelab-stack-media-automation

# Stop any running containers
docker compose down 2>/dev/null || true

# Remove generated files
rm -f docker-compose.yml .env INSTALLATION_INFO.txt

# Optional: Clean directories for fresh start
rm -rf config/ downloads/ media/

# Clean up Docker images
docker image prune -a -f
```

### 3. Installation Testing
```bash
# Make script executable
chmod +x install-media-automation.sh

# Run installer
./install-media-automation.sh

# Expected prompts:
# - Accept warnings: yes
# - Email for SSL
# - RAM profile: 1-4
```

### 4. Verification
```bash
# Check all services started
docker compose ps

# Expected services (10 total):
# - sonarr, radarr, lidarr (TV, Movies, Music)
# - prowlarr, bazarr (Indexer, Subtitles)
# - qbittorrent (Downloads)
# - flaresolverr (Cloudflare bypass)
# - navidrome, audiobookshelf (Media servers)
# - ombi (Request management)

# Verify network connectivity
docker inspect sonarr | grep -A 5 "Networks"
# Should show: "homelab" and "media" networks
```

### 5. Common Test Failures

**"network traefik not found"**
- Cause: Using wrong network name
- Fix: Verify install script uses `homelab` not `traefik`

**"no matching manifest for linux/amd64"**
- Cause: Readarr is not commented out
- Fix: Ensure Readarr service is fully commented in template

**"unknown escape character"**
- Cause: Heredoc delimiter is quoted
- Fix: Remove quotes from `<< DOCKEREOF`

**"version is obsolete" warning**
- This is just a warning, safe to ignore
- Docker Compose 3.8 format still works, version field is deprecated

## Development Guidelines

### When Modifying install-media-automation.sh

1. **Never uncomment Readarr** without first verifying linuxserver.io has fixed their image builds
2. **Always test variable substitution** after modifying heredoc sections
3. **Keep network name as `homelab`** - this matches homelab-stack
4. **Preserve resource limit variables** - users depend on RAM profile selection
5. **Update all three locations** when changing service lists:
   - Installation warnings/service list (lines 48-61)
   - DNS validation array (line 531)
   - INSTALLATION_INFO.txt template (lines 585-595)

### When Adding New Services

1. Connect to both networks:
   ```yaml
   networks:
     - homelab  # For Traefik access
     - media    # For inter-service communication
   ```

2. Add appropriate resource limits using existing variables or create new ones

3. Update DNS validation array if service has a public endpoint

4. Document in INSTALLATION_INFO.txt template

## Architecture Notes

### Directory Structure
```
./config/*       - Application configurations (persistent)
./downloads/*    - Download staging area
./media/*        - Final media storage (to be linked to Jellyfin)
```

### Network Design
- `homelab` (external): Shared with homelab-stack, where Traefik runs
- `media` (internal): Private network for *arr apps to communicate with download clients

### Why Two Networks?
- Media automation apps need to talk to each other (media network)
- But only selected services need public HTTPS access (homelab network with Traefik)
- FlareSolverr is internal-only (only on media network)

## Debugging Tips

### Service won't start
```bash
docker compose logs <service-name>
```

### Network issues
```bash
# Check what networks exist
docker network ls

# Inspect service network config
docker inspect <service-name> | grep -A 10 "Networks"

# Check Traefik connectivity
docker exec traefik ping -c 1 sonarr
```

### Resource limit errors
```bash
# View generated docker-compose.yml
cat docker-compose.yml | grep -A 5 "resources:"

# Should show actual values, not "$ARR_MEM"
```

## Git Workflow

This repository uses feature branches:
- Main development branch: `claude/test-repo-server-PKQeW`
- Bugfix branches: `claude/fix-<issue>-PKQeW`

When making fixes:
1. Create a new branch from main/current working branch
2. Test thoroughly on actual server (not just locally)
3. Commit with descriptive messages explaining WHY, not just what
4. Push and verify installation works end-to-end

## Contact & Support

Issues should be reported at: https://github.com/cph911/homelab-stack-media-automation/issues

For questions about the base stack: https://github.com/cph911/homelab-stack
