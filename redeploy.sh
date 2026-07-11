#!/bin/bash
set -euo pipefail

# ============================================================================
# BrieflyLearn — Quick Redeploy (code updates only, no infrastructure)
# ============================================================================
# Usage:
#   bash redeploy.sh              # Redeploy both backend + frontend
#   bash redeploy.sh backend      # Redeploy backend only
#   bash redeploy.sh frontend     # Redeploy frontend only
# ============================================================================

BACKEND_DIR="/var/www/brieflylearn/backend"
FRONTEND_DIR="/var/www/brieflylearn/frontend"
PHP_VERSION="8.3"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[✗]${NC} $1"; }
step() { echo -e "\n${CYAN}━━━ $1 ━━━${NC}\n"; }

TARGET="${1:-all}"

# ── Backend Redeploy ───────────────────────────────────────────────────────

deploy_backend() {
    step "Redeploying Laravel Backend"

    cd "${BACKEND_DIR}"

    # Maintenance mode on
    php artisan down --retry=30 || true

    # Pull latest code
    git pull origin main
    log "Code pulled"

    # Install dependencies
    composer install --no-dev --optimize-autoloader --no-interaction
    log "Composer dependencies installed"

    # Run migrations
    php artisan migrate --force
    log "Migrations complete"

    # Clear and rebuild caches
    php artisan config:clear
    php artisan route:clear
    php artisan view:clear
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
    log "Caches rebuilt"

    # Fix permissions
    chown -R www-data:www-data "${BACKEND_DIR}"
    chmod -R 775 "${BACKEND_DIR}/storage"
    chmod -R 775 "${BACKEND_DIR}/bootstrap/cache"

    # Restart PHP-FPM
    systemctl restart php${PHP_VERSION}-fpm
    log "PHP-FPM restarted"

    # Restart queue worker
    php artisan queue:restart
    systemctl restart brieflylearn-queue
    log "Queue worker restarted"

    # Maintenance mode off
    php artisan up
    log "Backend is live"
}

# ── Frontend Redeploy ──────────────────────────────────────────────────────

deploy_frontend() {
    step "Redeploying Next.js Frontend"

    cd "${FRONTEND_DIR}"

    # Pull latest code
    git pull origin main
    log "Code pulled"

    # Install dependencies
    npm ci --production=false
    log "npm dependencies installed"

    # Build
    npm run build
    log "Next.js built"

    # Fix permissions
    chown -R www-data:www-data "${FRONTEND_DIR}"

    # Restart PM2
    pm2 restart brieflylearn-frontend
    log "PM2 restarted"

    # Wait for startup
    sleep 3

    # Health check
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3000/ 2>/dev/null || echo "000")
    if [ "${HTTP_CODE}" = "200" ]; then
        log "Frontend health check: OK (${HTTP_CODE})"
    else
        warn "Frontend health check: ${HTTP_CODE} (may still be starting)"
    fi
}

# ── Execute ────────────────────────────────────────────────────────────────

case "${TARGET}" in
    backend)
        deploy_backend
        ;;
    frontend)
        deploy_frontend
        ;;
    all)
        deploy_backend
        deploy_frontend
        ;;
    *)
        err "Unknown target: ${TARGET}"
        echo "Usage: bash redeploy.sh [all|backend|frontend]"
        exit 1
        ;;
esac

step "Redeploy Complete"

# Status summary
echo "Service Status:"
echo "─────────────────"
systemctl is-active --quiet nginx && echo -e "  Nginx:       ${GREEN}running${NC}" || echo -e "  Nginx:       ${RED}stopped${NC}"
systemctl is-active --quiet php${PHP_VERSION}-fpm && echo -e "  PHP-FPM:     ${GREEN}running${NC}" || echo -e "  PHP-FPM:     ${RED}stopped${NC}"
systemctl is-active --quiet mysql && echo -e "  MySQL:       ${GREEN}running${NC}" || echo -e "  MySQL:       ${RED}stopped${NC}"
systemctl is-active --quiet brieflylearn-queue && echo -e "  Queue:       ${GREEN}running${NC}" || echo -e "  Queue:       ${RED}stopped${NC}"
pm2 describe brieflylearn-frontend &>/dev/null && echo -e "  Next.js:     ${GREEN}running${NC}" || echo -e "  Next.js:     ${RED}stopped${NC}"
echo ""
