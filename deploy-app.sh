#!/usr/bin/env bash
# ============================================================
# BrieflyLearn — Application Deployment Script
# ============================================================
# Purpose: Clone + install + configure backend + frontend
# Run after: provision.sh
# Usage:    bash /root/deploy-app.sh
# ============================================================

set -euo pipefail

log() { echo "[$(date +'%H:%M:%S')] $*"; }
section() { echo; echo "========================================"; echo ">>> $*"; echo "========================================"; }

if [ "$(id -u)" -ne 0 ]; then
    echo "Must run as root" >&2
    exit 1
fi

# ============================================================
# Configuration (can be overridden via env vars)
# ============================================================
BACKEND_REPO="${BACKEND_REPO:-https://github.com/PanapatWonganan/brieflylearn-backend.git}"
FRONTEND_REPO="${FRONTEND_REPO:-https://github.com/PanapatWonganan/brieflylearn-frontend.git}"
APP_ROOT="/var/www/brieflylearn"
BACKEND_DIR="$APP_ROOT/backend"
FRONTEND_DIR="$APP_ROOT/frontend"

# Secrets — generate if not provided
DB_NAME="${DB_NAME:-brieflylearn}"
DB_USER="${DB_USER:-brieflylearn_app}"
DB_PASS="${DB_PASS:-$(openssl rand -base64 24 | tr -d '/+=' | cut -c1-24)}"
JWT_SECRET_VAL="${JWT_SECRET_VAL:-$(openssl rand -base64 48 | tr -d '/+=' | cut -c1-48)}"

# Required from user (via env var)
SENDGRID_KEY="${SENDGRID_KEY:-CHANGE_ME_SENDGRID}"
GOOGLE_CLIENT_ID="${GOOGLE_CLIENT_ID:-CHANGE_ME_GOOGLE_ID}"
GOOGLE_CLIENT_SECRET="${GOOGLE_CLIENT_SECRET:-CHANGE_ME_GOOGLE_SECRET}"

# ============================================================
section "1/8  Create MySQL database + user"
# ============================================================
mysql --defaults-file=/etc/mysql/debian.cnf <<EOF
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
DROP USER IF EXISTS '${DB_USER}'@'localhost';
CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF
log "DB '${DB_NAME}' created, user '${DB_USER}'@localhost"

# ============================================================
section "2/8  Clone repositories"
# ============================================================
mkdir -p "$APP_ROOT"
cd "$APP_ROOT"

if [ -d "$BACKEND_DIR/.git" ]; then
    log "Backend repo exists, pulling latest"
    cd "$BACKEND_DIR" && git fetch --all && git reset --hard origin/main
else
    rm -rf "$BACKEND_DIR"
    git clone --depth=1 "$BACKEND_REPO" "$BACKEND_DIR"
fi

if [ -d "$FRONTEND_DIR/.git" ]; then
    log "Frontend repo exists, pulling latest"
    cd "$FRONTEND_DIR" && git fetch --all && git reset --hard origin/main
else
    rm -rf "$FRONTEND_DIR"
    git clone --depth=1 "$FRONTEND_REPO" "$FRONTEND_DIR"
fi

# ============================================================
section "3/8  Backend — composer install + .env"
# ============================================================
cd "$BACKEND_DIR"

# Write .env
cat > .env <<EOF
APP_NAME=BrieflyLearn
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_TIMEZONE=Asia/Bangkok
APP_URL=https://api.antiparallel.app
APP_FRONTEND_URL=https://antiparallel.app

LOG_CHANNEL=stack
LOG_LEVEL=warning

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=${DB_NAME}
DB_USERNAME=${DB_USER}
DB_PASSWORD=${DB_PASS}

CACHE_DRIVER=file
QUEUE_CONNECTION=database
SESSION_DRIVER=file
SESSION_LIFETIME=120

MAIL_MAILER=smtp
MAIL_HOST=smtp.sendgrid.net
MAIL_PORT=587
MAIL_USERNAME=apikey
MAIL_PASSWORD=${SENDGRID_KEY}
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS="no-reply@antiparallel.app"
MAIL_FROM_NAME="BrieflyLearn"

GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID}
GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET}

JWT_SECRET=${JWT_SECRET_VAL}
JWT_TTL=43200

SANCTUM_STATEFUL_DOMAINS=antiparallel.app
SESSION_DOMAIN=.antiparallel.app
EOF

composer install --no-dev --optimize-autoloader --no-interaction
php artisan key:generate --force

# Migrate
php artisan migrate --force

# Seed (only if DB is empty — check users count)
USER_COUNT=$(php artisan tinker --execute='echo \App\Models\User::count();' 2>/dev/null | tail -1 | tr -dc '0-9' || echo 0)
if [ "${USER_COUNT:-0}" = "0" ]; then
    log "Empty DB detected, seeding defaults"
    php artisan db:seed --force || true
    php artisan db:seed --class=CategorySeeder --force || true
    php artisan db:seed --class=WellnessGardenSeeder --force || true
else
    log "DB has ${USER_COUNT} users, skipping seed"
fi

# Optimize
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan filament:optimize || true

# Storage permissions
chown -R www-data:www-data "$BACKEND_DIR/storage" "$BACKEND_DIR/bootstrap/cache"
chmod -R 775 "$BACKEND_DIR/storage" "$BACKEND_DIR/bootstrap/cache"
php artisan storage:link || true

# ============================================================
section "4/8  Frontend — npm ci + build"
# ============================================================
cd "$FRONTEND_DIR"

cat > .env.production <<EOF
NEXT_PUBLIC_APP_URL=https://antiparallel.app
NEXT_PUBLIC_API_URL=https://api.antiparallel.app/api/v1
NEXT_PUBLIC_GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID}
EOF

npm ci --no-audit --no-fund
npm run build

# ============================================================
section "5/8  PM2 — frontend process manager"
# ============================================================
cd "$FRONTEND_DIR"
pm2 delete brieflylearn-frontend 2>/dev/null || true
pm2 start npm --name brieflylearn-frontend -- start
pm2 save
pm2 startup systemd -u root --hp /root > /dev/null || true
log "Frontend running via PM2"

# ============================================================
section "6/8  Laravel queue worker (systemd)"
# ============================================================
cat > /etc/systemd/system/brieflylearn-queue.service <<EOF
[Unit]
Description=BrieflyLearn Laravel Queue Worker
After=network.target mysql.service

[Service]
User=www-data
Group=www-data
Restart=always
RestartSec=5
WorkingDirectory=${BACKEND_DIR}
ExecStart=/usr/bin/php ${BACKEND_DIR}/artisan queue:work --sleep=3 --tries=3 --max-time=3600
StandardOutput=append:/var/log/brieflylearn-queue.log
StandardError=append:/var/log/brieflylearn-queue.log

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now brieflylearn-queue
log "Queue worker started"

# ============================================================
section "7/8  Laravel scheduler (cron)"
# ============================================================
CRON_LINE="* * * * * cd ${BACKEND_DIR} && php artisan schedule:run >> /dev/null 2>&1"
(crontab -l 2>/dev/null | grep -v 'artisan schedule:run'; echo "$CRON_LINE") | crontab -
log "Cron scheduler installed"

# ============================================================
section "8/8  Write credentials file (save these!)"
# ============================================================
CREDS_FILE="/root/brieflylearn-credentials.txt"
cat > "$CREDS_FILE" <<EOF
# ===== BrieflyLearn Deploy Credentials =====
# Generated: $(date)
# KEEP THIS FILE SAFE — chmod 600

DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASS=${DB_PASS}

JWT_SECRET=${JWT_SECRET_VAL}

# --- From user env vars ---
SENDGRID_KEY=${SENDGRID_KEY}
GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID}
GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET}
EOF
chmod 600 "$CREDS_FILE"
log "Credentials saved to $CREDS_FILE"

# ============================================================
section "DONE — application deployed"
# ============================================================
echo
echo "Backend:    $BACKEND_DIR"
echo "Frontend:   $FRONTEND_DIR"
echo "Database:   $DB_NAME (user: $DB_USER)"
echo "PM2:        $(pm2 list | grep brieflylearn-frontend | head -1)"
echo "Queue:      $(systemctl is-active brieflylearn-queue)"
echo
echo "Next steps:"
echo "  1. Setup Nginx vhosts (setup-nginx.sh)"
echo "  2. Update Cloudflare DNS to point to this VPS"
echo "  3. Install Cloudflare Origin SSL certs"
echo "  4. Rotate admin user password"
