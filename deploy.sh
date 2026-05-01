#!/bin/bash
set -euo pipefail

# ============================================================================
# BrieflyLearn — One-Click Deploy (run from Mac)
# ============================================================================
# Commits, pushes both repos to GitHub, then SSH to VPS to redeploy.
#
# Usage:
#   bash deploy.sh                    # Deploy both backend + frontend
#   bash deploy.sh backend            # Deploy backend only
#   bash deploy.sh frontend           # Deploy frontend only
#   bash deploy.sh "commit message"   # Deploy both with custom commit message
#   bash deploy.sh backend "message"  # Deploy backend with custom message
#   bash deploy.sh frontend "message" # Deploy frontend with custom message
# ============================================================================

VPS_IP="45.32.125.76"
VPS_USER="root"
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKEND_DIR="${BASE_DIR}/fitness-lms-admin"
FRONTEND_DIR="${BASE_DIR}/fitness-lms"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[X]${NC} $1"; exit 1; }
step() { echo -e "\n${CYAN}=== $1 ===${NC}\n"; }

# Parse arguments
TARGET="all"
COMMIT_MSG=""

if [ $# -ge 1 ]; then
    case "$1" in
        backend|frontend|all)
            TARGET="$1"
            COMMIT_MSG="${2:-}"
            ;;
        *)
            COMMIT_MSG="$1"
            ;;
    esac
fi

if [ -z "${COMMIT_MSG}" ]; then
    COMMIT_MSG="Update $(date '+%Y-%m-%d %H:%M')"
fi

echo -e "${CYAN}================================${NC}"
echo -e "${CYAN} BrieflyLearn Deploy${NC}"
echo -e "${CYAN}================================${NC}"
echo -e "  Target:  ${GREEN}${TARGET}${NC}"
echo -e "  Commit:  ${GREEN}${COMMIT_MSG}${NC}"
echo -e "  VPS:     ${GREEN}${VPS_USER}@${VPS_IP}${NC}"
echo ""

# ── Push Backend ──────────────────────────────────────────────────────────

push_backend() {
    step "Pushing Backend to GitHub"

    cd "${BACKEND_DIR}"

    if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
        warn "No changes in backend — skipping push"
        return 0
    fi

    git add -A
    git commit -m "${COMMIT_MSG}" || true
    git push origin main
    log "Backend pushed to GitHub"
}

# ── Push Frontend ─────────────────────────────────────────────────────────

push_frontend() {
    step "Pushing Frontend to GitHub"

    cd "${FRONTEND_DIR}"

    if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
        warn "No changes in frontend — skipping push"
        return 0
    fi

    git add -A
    git commit -m "${COMMIT_MSG}" || true
    git push origin main
    log "Frontend pushed to GitHub"
}

# ── Deploy on VPS ─────────────────────────────────────────────────────────

deploy_vps() {
    step "Deploying on VPS (${VPS_IP})"

    ssh -i ~/.ssh/brieflylearn_ed25519 -o IdentitiesOnly=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=no "${VPS_USER}@${VPS_IP}" bash <<REMOTE
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "\${GREEN}[OK]\${NC} \$1"; }
warn() { echo -e "\${YELLOW}[!]\${NC} \$1"; }
step() { echo -e "\n\${CYAN}=== \$1 ===\${NC}\n"; }

TARGET="${TARGET}"
PHP_VERSION="8.3"
BACKEND_DIR="/var/www/brieflylearn/backend"
FRONTEND_DIR="/var/www/brieflylearn/frontend"

if [ "\${TARGET}" = "all" ] || [ "\${TARGET}" = "backend" ]; then
    step "Redeploying Backend"

    cd "\${BACKEND_DIR}"
    php artisan down --retry=30 || true

    git pull origin main
    log "Code pulled"

    composer install --no-dev --optimize-autoloader --no-interaction
    log "Composer done"

    php artisan migrate --force
    log "Migrations done"

    php artisan config:clear
    php artisan route:clear
    php artisan view:clear
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
    log "Caches rebuilt"

    chown -R www-data:www-data "\${BACKEND_DIR}"
    chmod -R 775 "\${BACKEND_DIR}/storage"
    chmod -R 775 "\${BACKEND_DIR}/bootstrap/cache"

    # Ensure PHP upload limits are set for video uploads
    PHP_INI_DIR="/etc/php/\${PHP_VERSION}/fpm/conf.d"
    cat > "\${PHP_INI_DIR}/99-brieflylearn-uploads.ini" <<'PHPINI'
upload_max_filesize = 512M
post_max_size = 512M
max_execution_time = 600
max_input_time = 600
memory_limit = 512M
PHPINI
    log "PHP upload limits configured"

    # Sync nginx config from repo
    if [ -f "\${BACKEND_DIR}/../nginx-configs/api.antiparallel.app.conf" ]; then
        cp "\${BACKEND_DIR}/../nginx-configs/api.antiparallel.app.conf" /etc/nginx/sites-available/api.antiparallel.app
        nginx -t && systemctl reload nginx
        log "Nginx config updated"
    fi

    systemctl restart php\${PHP_VERSION}-fpm
    log "PHP-FPM restarted"

    php artisan queue:restart
    systemctl restart brieflylearn-queue || true
    log "Queue restarted"

    php artisan up
    log "Backend is live"
fi

if [ "\${TARGET}" = "all" ] || [ "\${TARGET}" = "frontend" ]; then
    step "Redeploying Frontend"

    cd "\${FRONTEND_DIR}"

    git pull origin main
    log "Code pulled"

    npm ci --production=false
    log "npm done"

    npm run build
    log "Build done"

    chown -R www-data:www-data "\${FRONTEND_DIR}"

    pm2 restart brieflylearn-frontend
    log "PM2 restarted"

    sleep 3
    HTTP_CODE=\$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3000/ 2>/dev/null || echo "000")
    if [ "\${HTTP_CODE}" = "200" ]; then
        log "Frontend health check: OK"
    else
        warn "Frontend health check: \${HTTP_CODE} (may still be starting)"
    fi
fi

step "Deploy Complete"

echo "Service Status:"
echo "-------------------"
systemctl is-active --quiet nginx && echo -e "  Nginx:       \${GREEN}running\${NC}" || echo -e "  Nginx:       \${RED}stopped\${NC}"
systemctl is-active --quiet php\${PHP_VERSION}-fpm && echo -e "  PHP-FPM:     \${GREEN}running\${NC}" || echo -e "  PHP-FPM:     \${RED}stopped\${NC}"
systemctl is-active --quiet mysql && echo -e "  MySQL:       \${GREEN}running\${NC}" || echo -e "  MySQL:       \${RED}stopped\${NC}"
systemctl is-active --quiet brieflylearn-queue && echo -e "  Queue:       \${GREEN}running\${NC}" || echo -e "  Queue:       \${RED}stopped\${NC}"
pm2 describe brieflylearn-frontend &>/dev/null && echo -e "  Next.js:     \${GREEN}running\${NC}" || echo -e "  Next.js:     \${RED}stopped\${NC}"
echo ""
REMOTE

    log "VPS deployment complete"
}

# ── Execute ───────────────────────────────────────────────────────────────

# Step 1: Push to GitHub
case "${TARGET}" in
    backend)
        push_backend
        ;;
    frontend)
        push_frontend
        ;;
    all)
        push_backend
        push_frontend
        ;;
esac

# Step 2: Deploy on VPS
deploy_vps

step "All Done"
echo -e "  Frontend: ${GREEN}https://antiparallel.app${NC}"
echo -e "  API:      ${GREEN}https://api.antiparallel.app${NC}"
echo -e "  Admin:    ${GREEN}https://api.antiparallel.app/admin${NC}"
echo ""
