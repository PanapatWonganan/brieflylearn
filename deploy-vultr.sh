#!/bin/bash
set -euo pipefail

# ============================================================================
# BrieflyLearn — Vultr + Ubuntu Deployment Script
# ============================================================================
# Run this on a fresh Ubuntu 24.04 LTS Vultr VPS as root:
#   curl -sSL https://raw.githubusercontent.com/.../deploy-vultr.sh | bash
#   or: bash deploy-vultr.sh
#
# Prerequisites:
#   1. DNS A records pointing to this VPS IP:
#      - antiparallel.app      → VPS_IP
#      - www.antiparallel.app  → VPS_IP
#      - api.antiparallel.app  → VPS_IP
#   2. GitHub repos accessible (public or with deploy key):
#      - PanapatWonganan/brieflylearn-backend
#      - PanapatWonganan/brieflylearn-frontend
# ============================================================================

# ── Configuration ──────────────────────────────────────────────────────────

DOMAIN="antiparallel.app"
API_DOMAIN="api.antiparallel.app"
WWW_DOMAIN="www.antiparallel.app"

BACKEND_REPO="https://github.com/PanapatWonganan/brieflylearn-backend.git"
FRONTEND_REPO="https://github.com/PanapatWonganan/brieflylearn-frontend.git"

BACKEND_DIR="/var/www/brieflylearn/backend"
FRONTEND_DIR="/var/www/brieflylearn/frontend"

DB_NAME="brieflylearn"
DB_USER="brieflylearn"
DB_PASS="$(openssl rand -base64 24 | tr -dc 'a-zA-Z0-9' | head -c 32)"

PHP_VERSION="8.2"
NODE_VERSION="20"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[✗]${NC} $1"; }
step() { echo -e "\n${CYAN}━━━ $1 ━━━${NC}\n"; }

# ── Pre-flight checks ─────────────────────────────────────────────────────

if [ "$(id -u)" -ne 0 ]; then
    err "This script must be run as root"
    exit 1
fi

VPS_IP=$(curl -4 -s ifconfig.me || hostname -I | awk '{print $1}')
log "VPS IP detected: ${VPS_IP}"

# ══════════════════════════════════════════════════════════════════════════
# STEP 1: System Setup
# ══════════════════════════════════════════════════════════════════════════

step "STEP 1/9: System Packages"

export DEBIAN_FRONTEND=noninteractive

apt-get update -qq
apt-get upgrade -y -qq

# PHP 8.2 repo
apt-get install -y -qq software-properties-common
add-apt-repository -y ppa:ondrej/php

# Node.js 20 repo
curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -

apt-get update -qq
apt-get install -y -qq \
    nginx \
    certbot python3-certbot-nginx \
    mysql-server \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-readline \
    php${PHP_VERSION}-tokenizer \
    nodejs \
    git \
    unzip \
    curl \
    acl \
    ufw

# Composer
if ! command -v composer &>/dev/null; then
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
fi

# PM2 for Node.js process management
npm install -g pm2

log "All packages installed"

# ══════════════════════════════════════════════════════════════════════════
# STEP 2: PHP-FPM Configuration
# ══════════════════════════════════════════════════════════════════════════

step "STEP 2/9: PHP-FPM Configuration"

PHP_FPM_POOL="/etc/php/${PHP_VERSION}/fpm/pool.d/brieflylearn.conf"
PHP_FPM_INI="/etc/php/${PHP_VERSION}/fpm/conf.d/99-brieflylearn.ini"

# Custom pool for BrieflyLearn
cat > "${PHP_FPM_POOL}" << 'POOL'
[brieflylearn]
user = www-data
group = www-data
listen = /run/php/brieflylearn.sock
listen.owner = www-data
listen.group = www-data
listen.mode = 0660

pm = dynamic
pm.max_children = 20
pm.start_servers = 4
pm.min_spare_servers = 2
pm.max_spare_servers = 8
pm.max_requests = 500

; Environment
env[DB_CONNECTION] = mysql

; Slow log
slowlog = /var/log/php-fpm-brieflylearn-slow.log
request_slowlog_timeout = 10s
request_terminate_timeout = 300s
POOL

# PHP settings for video uploads
cat > "${PHP_FPM_INI}" << 'INI'
upload_max_filesize = 500M
post_max_size = 500M
max_execution_time = 300
max_input_time = 300
memory_limit = 256M
INI

# Remove default pool to avoid conflicts
rm -f /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

systemctl restart php${PHP_VERSION}-fpm
systemctl enable php${PHP_VERSION}-fpm

log "PHP-FPM configured with custom pool"

# ══════════════════════════════════════════════════════════════════════════
# STEP 3: MySQL Setup
# ══════════════════════════════════════════════════════════════════════════

step "STEP 3/9: MySQL Database"

systemctl start mysql
systemctl enable mysql

# Create database and user
mysql -u root << EOSQL
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EOSQL

log "MySQL database '${DB_NAME}' created"
log "MySQL user '${DB_USER}' created"

# Save credentials
CREDS_FILE="/root/.brieflylearn-credentials"
cat > "${CREDS_FILE}" << EOF
# BrieflyLearn Database Credentials (generated $(date))
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASS=${DB_PASS}
EOF
chmod 600 "${CREDS_FILE}"
log "Credentials saved to ${CREDS_FILE}"

# ══════════════════════════════════════════════════════════════════════════
# STEP 4: Deploy Laravel Backend
# ══════════════════════════════════════════════════════════════════════════

step "STEP 4/9: Laravel Backend"

mkdir -p /var/www/brieflylearn

if [ -d "${BACKEND_DIR}" ]; then
    warn "Backend directory exists, pulling latest..."
    cd "${BACKEND_DIR}"
    git pull origin main
else
    git clone "${BACKEND_REPO}" "${BACKEND_DIR}"
    cd "${BACKEND_DIR}"
fi

# Generate APP_KEY if needed
APP_KEY="base64:$(openssl rand -base64 32)"

# Create .env
cat > "${BACKEND_DIR}/.env" << ENV
APP_NAME="BrieflyLearn"
APP_ENV=production
APP_KEY=${APP_KEY}
APP_DEBUG=false
APP_URL=https://${API_DOMAIN}
APP_FRONTEND_URL=https://${DOMAIN}

LOG_CHANNEL=stack
LOG_LEVEL=warning

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=${DB_NAME}
DB_USERNAME=${DB_USER}
DB_PASSWORD=${DB_PASS}

BROADCAST_CONNECTION=log
FILESYSTEM_DISK=local
QUEUE_CONNECTION=database
CACHE_STORE=file
SESSION_DRIVER=file
SESSION_LIFETIME=120

MAIL_MAILER=smtp
MAIL_HOST=smtp.sendgrid.net
MAIL_PORT=587
MAIL_USERNAME=apikey
MAIL_PASSWORD=REPLACE_WITH_SENDGRID_API_KEY
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@antiparallel.app
MAIL_FROM_NAME="BrieflyLearn"

GOOGLE_CLIENT_ID=REPLACE_WITH_GOOGLE_CLIENT_ID
GOOGLE_CLIENT_SECRET=REPLACE_WITH_GOOGLE_CLIENT_SECRET
ENV

# Install dependencies
composer install --no-dev --optimize-autoloader --no-interaction

# Storage setup
php artisan storage:link 2>/dev/null || true
mkdir -p storage/app/private/videos
mkdir -p storage/framework/{cache,sessions,views}
mkdir -p bootstrap/cache

# Run migrations
php artisan migrate --force

# Production caching
php artisan config:cache
php artisan route:cache
php artisan view:cache

# File permissions
chown -R www-data:www-data "${BACKEND_DIR}"
chmod -R 755 "${BACKEND_DIR}"
chmod -R 775 "${BACKEND_DIR}/storage"
chmod -R 775 "${BACKEND_DIR}/bootstrap/cache"

log "Laravel backend deployed and optimized"

# ══════════════════════════════════════════════════════════════════════════
# STEP 5: Deploy Next.js Frontend
# ══════════════════════════════════════════════════════════════════════════

step "STEP 5/9: Next.js Frontend"

if [ -d "${FRONTEND_DIR}" ]; then
    warn "Frontend directory exists, pulling latest..."
    cd "${FRONTEND_DIR}"
    git pull origin main
else
    git clone "${FRONTEND_REPO}" "${FRONTEND_DIR}"
    cd "${FRONTEND_DIR}"
fi

# Create .env.local
cat > "${FRONTEND_DIR}/.env.local" << ENV
NEXT_PUBLIC_APP_URL=https://${DOMAIN}
NEXT_PUBLIC_API_URL=https://${API_DOMAIN}/api/v1
NEXT_PUBLIC_GOOGLE_CLIENT_ID=REPLACE_WITH_GOOGLE_CLIENT_ID
ENV

# Install and build
npm ci --production=false
npm run build

# PM2 ecosystem config
cat > "${FRONTEND_DIR}/ecosystem.config.cjs" << 'PM2'
module.exports = {
  apps: [{
    name: 'brieflylearn-frontend',
    cwd: '/var/www/brieflylearn/frontend',
    script: 'node_modules/.bin/next',
    args: 'start -p 3000',
    instances: 1,
    exec_mode: 'fork',
    autorestart: true,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 3000,
    },
    error_file: '/var/log/brieflylearn-frontend-error.log',
    out_file: '/var/log/brieflylearn-frontend-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
  }]
};
PM2

# Start with PM2
pm2 delete brieflylearn-frontend 2>/dev/null || true
pm2 start "${FRONTEND_DIR}/ecosystem.config.cjs"
pm2 save
pm2 startup systemd -u root --hp /root 2>/dev/null || true

chown -R www-data:www-data "${FRONTEND_DIR}"

log "Next.js frontend built and started via PM2"

# ══════════════════════════════════════════════════════════════════════════
# STEP 6: Nginx Configuration
# ══════════════════════════════════════════════════════════════════════════

step "STEP 6/9: Nginx Configuration"

# Remove default site
rm -f /etc/nginx/sites-enabled/default

# ── Frontend: antiparallel.app ──

cat > /etc/nginx/sites-available/brieflylearn-frontend << 'NGINX_FE'
server {
    listen 80;
    listen [::]:80;
    server_name antiparallel.app www.antiparallel.app;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Gzip
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript image/svg+xml;
    gzip_min_length 256;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 60s;
        proxy_send_timeout 60s;
    }

    # Next.js static assets — long cache
    location /_next/static/ {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        expires 365d;
        add_header Cache-Control "public, immutable";
    }
}
NGINX_FE

# ── Backend API: api.antiparallel.app ──

cat > /etc/nginx/sites-available/brieflylearn-api << NGINX_API
server {
    listen 80;
    listen [::]:80;
    server_name ${API_DOMAIN};

    root ${BACKEND_DIR}/public;
    index index.php;

    # Security headers
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Max upload size for videos (500MB)
    client_max_body_size 500M;

    # Gzip
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
    gzip_min_length 256;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        fastcgi_pass unix:/run/php/brieflylearn.sock;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_read_timeout 300;
        fastcgi_send_timeout 300;
    }

    # Deny .env and hidden files
    location ~ /\. {
        deny all;
    }

    # Video streaming — allow large range requests
    location ~ ^/api/video/stream/ {
        try_files \$uri /index.php?\$query_string;
        proxy_buffering off;
    }

    # Filament admin assets
    location /admin {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
}
NGINX_API

# Enable sites
ln -sf /etc/nginx/sites-available/brieflylearn-frontend /etc/nginx/sites-enabled/
ln -sf /etc/nginx/sites-available/brieflylearn-api /etc/nginx/sites-enabled/

# Test and reload
nginx -t
systemctl reload nginx
systemctl enable nginx

log "Nginx configured for frontend and API"

# ══════════════════════════════════════════════════════════════════════════
# STEP 7: SSL via Let's Encrypt
# ══════════════════════════════════════════════════════════════════════════

step "STEP 7/9: SSL Certificate"

echo ""
warn "SSL requires DNS A records to be pointing to ${VPS_IP} already."
echo ""
read -p "Install SSL now? (y/n): " INSTALL_SSL

if [ "${INSTALL_SSL}" = "y" ] || [ "${INSTALL_SSL}" = "Y" ]; then
    certbot --nginx \
        -d "${DOMAIN}" \
        -d "${WWW_DOMAIN}" \
        -d "${API_DOMAIN}" \
        --non-interactive \
        --agree-tos \
        --email "admin@${DOMAIN}" \
        --redirect

    # Auto-renewal
    systemctl enable certbot.timer
    log "SSL installed and auto-renewal enabled"
else
    warn "Skipping SSL. Run later with:"
    echo "  certbot --nginx -d ${DOMAIN} -d ${WWW_DOMAIN} -d ${API_DOMAIN} --redirect"
fi

# ══════════════════════════════════════════════════════════════════════════
# STEP 8: Cron & Scheduler
# ══════════════════════════════════════════════════════════════════════════

step "STEP 8/9: Laravel Scheduler & Queue"

# Laravel scheduler cron
CRON_LINE="* * * * * cd ${BACKEND_DIR} && php artisan schedule:run >> /dev/null 2>&1"
(crontab -u www-data -l 2>/dev/null | grep -v "schedule:run"; echo "${CRON_LINE}") | crontab -u www-data -

# Queue worker via systemd
cat > /etc/systemd/system/brieflylearn-queue.service << QUEUE
[Unit]
Description=BrieflyLearn Queue Worker
After=network.target mysql.service

[Service]
User=www-data
Group=www-data
WorkingDirectory=${BACKEND_DIR}
ExecStart=/usr/bin/php artisan queue:work database --sleep=3 --tries=3 --max-time=3600
Restart=always
RestartSec=5
StandardOutput=append:/var/log/brieflylearn-queue.log
StandardError=append:/var/log/brieflylearn-queue-error.log

[Install]
WantedBy=multi-user.target
QUEUE

systemctl daemon-reload
systemctl enable brieflylearn-queue
systemctl start brieflylearn-queue

log "Laravel scheduler (cron) and queue worker configured"

# ══════════════════════════════════════════════════════════════════════════
# STEP 9: Firewall
# ══════════════════════════════════════════════════════════════════════════

step "STEP 9/9: Firewall (UFW)"

ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw --force enable

log "UFW firewall enabled (SSH, HTTP, HTTPS only)"

# ══════════════════════════════════════════════════════════════════════════
# VERIFICATION
# ══════════════════════════════════════════════════════════════════════════

step "DEPLOYMENT COMPLETE"

echo ""
echo "┌─────────────────────────────────────────────────────────────┐"
echo "│                   BrieflyLearn Deployed                     │"
echo "├─────────────────────────────────────────────────────────────┤"
echo "│                                                             │"
echo "│  Frontend:  https://${DOMAIN}                       │"
echo "│  API:       https://${API_DOMAIN}/api/v1            │"
echo "│  Admin:     https://${API_DOMAIN}/admin             │"
echo "│  Health:    https://${API_DOMAIN}/api/v1/health     │"
echo "│                                                             │"
echo "├─────────────────────────────────────────────────────────────┤"
echo "│  DB Credentials: /root/.brieflylearn-credentials            │"
echo "│  Backend .env:   ${BACKEND_DIR}/.env          │"
echo "│  Frontend .env:  ${FRONTEND_DIR}/.env.local  │"
echo "├─────────────────────────────────────────────────────────────┤"
echo "│                                                             │"
echo "│  REQUIRED: Edit these files and replace placeholders:       │"
echo "│   - REPLACE_WITH_SENDGRID_API_KEY                           │"
echo "│   - REPLACE_WITH_GOOGLE_CLIENT_ID                           │"
echo "│   - REPLACE_WITH_GOOGLE_CLIENT_SECRET                       │"
echo "│                                                             │"
echo "│  Then run:                                                  │"
echo "│   cd ${BACKEND_DIR} && php artisan config:cache   │"
echo "│   pm2 restart brieflylearn-frontend                         │"
echo "│                                                             │"
echo "└─────────────────────────────────────────────────────────────┘"
echo ""

# Service status check
echo "Service Status:"
echo "─────────────────"
systemctl is-active --quiet nginx && echo -e "  Nginx:       ${GREEN}running${NC}" || echo -e "  Nginx:       ${RED}stopped${NC}"
systemctl is-active --quiet php${PHP_VERSION}-fpm && echo -e "  PHP-FPM:     ${GREEN}running${NC}" || echo -e "  PHP-FPM:     ${RED}stopped${NC}"
systemctl is-active --quiet mysql && echo -e "  MySQL:       ${GREEN}running${NC}" || echo -e "  MySQL:       ${RED}stopped${NC}"
systemctl is-active --quiet brieflylearn-queue && echo -e "  Queue:       ${GREEN}running${NC}" || echo -e "  Queue:       ${RED}stopped${NC}"
pm2 describe brieflylearn-frontend &>/dev/null && echo -e "  Next.js:     ${GREEN}running${NC}" || echo -e "  Next.js:     ${RED}stopped${NC}"
echo ""

# Quick health checks
echo "Quick Health Checks:"
echo "─────────────────────"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3000/ 2>/dev/null || echo "000")
echo -e "  Frontend (localhost:3000): ${HTTP_CODE}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1/api/v1/health" --header "Host: ${API_DOMAIN}" 2>/dev/null || echo "000")
echo -e "  API health (via Nginx):   ${HTTP_CODE}"
echo ""

log "Deployment complete. Check the TODO items above."
