#!/usr/bin/env bash
# ============================================================
# BrieflyLearn — Nginx + SSL Setup Script
# ============================================================
# Purpose: Configure Nginx vhosts + Cloudflare Origin SSL
# Run after: provision.sh + deploy-app.sh + Cloudflare DNS updated
# Usage:    bash /root/setup-nginx.sh
#
# Prerequisites (must be done MANUALLY before running):
#   1. Update Cloudflare DNS A records to this VPS IP
#   2. Create Cloudflare Origin Certificate at:
#      dash.cloudflare.com > SSL/TLS > Origin Server > Create Cert
#      Hostnames: antiparallel.app, *.antiparallel.app
#      Save to: /etc/ssl/brieflylearn-origin.pem (cert)
#               /etc/ssl/brieflylearn-origin-key.pem (private key)
# ============================================================

set -euo pipefail

log() { echo "[$(date +'%H:%M:%S')] $*"; }
section() { echo; echo "========================================"; echo ">>> $*"; echo "========================================"; }

if [ "$(id -u)" -ne 0 ]; then
    echo "Must run as root" >&2
    exit 1
fi

# ============================================================
# Check prerequisites
# ============================================================
SSL_CERT="/etc/ssl/brieflylearn-origin.pem"
SSL_KEY="/etc/ssl/brieflylearn-origin-key.pem"

if [ ! -f "$SSL_CERT" ] || [ ! -f "$SSL_KEY" ]; then
    cat <<EOF >&2
ERROR: Cloudflare Origin SSL certs not found!

Please create them at Cloudflare:
  1. dash.cloudflare.com > antiparallel.app > SSL/TLS > Origin Server
  2. Click 'Create Certificate'
  3. Hostnames: antiparallel.app, *.antiparallel.app
  4. Validity: 15 years
  5. Save:
     - Origin Certificate  -> $SSL_CERT
     - Private Key         -> $SSL_KEY
  6. chmod 600 $SSL_KEY

Then re-run this script.
EOF
    exit 1
fi

chmod 644 "$SSL_CERT"
chmod 600 "$SSL_KEY"

# ============================================================
section "1/4  Frontend vhost — antiparallel.app"
# ============================================================
cat > /etc/nginx/sites-available/antiparallel.app <<'EOF'
# Frontend — Next.js via PM2 on :3000
server {
    listen 80;
    listen [::]:80;
    server_name antiparallel.app www.antiparallel.app;
    return 301 https://antiparallel.app$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name www.antiparallel.app;

    ssl_certificate     /etc/ssl/brieflylearn-origin.pem;
    ssl_certificate_key /etc/ssl/brieflylearn-origin-key.pem;

    return 301 https://antiparallel.app$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name antiparallel.app;

    ssl_certificate     /etc/ssl/brieflylearn-origin.pem;
    ssl_certificate_key /etc/ssl/brieflylearn-origin-key.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Strict-Transport-Security "max-age=63072000" always;

    access_log /var/log/nginx/antiparallel.app-access.log;
    error_log  /var/log/nginx/antiparallel.app-error.log;

    client_max_body_size 20M;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 60s;
    }
}
EOF

# ============================================================
section "2/4  API vhost — api.antiparallel.app"
# ============================================================
cat > /etc/nginx/sites-available/api.antiparallel.app <<'EOF'
# Backend — Laravel via PHP-FPM
server {
    listen 80;
    listen [::]:80;
    server_name api.antiparallel.app;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name api.antiparallel.app;

    root /var/www/brieflylearn/backend/public;
    index index.php;

    ssl_certificate     /etc/ssl/brieflylearn-origin.pem;
    ssl_certificate_key /etc/ssl/brieflylearn-origin-key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Strict-Transport-Security "max-age=63072000" always;

    # CORS
    add_header Access-Control-Allow-Origin "https://antiparallel.app" always;
    add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
    add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Requested-With" always;
    add_header Access-Control-Allow-Credentials "true" always;

    if ($request_method = 'OPTIONS') {
        add_header Access-Control-Allow-Origin "https://antiparallel.app" always;
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Requested-With" always;
        add_header Access-Control-Allow-Credentials "true" always;
        add_header Content-Length 0;
        add_header Content-Type text/plain;
        return 204;
    }

    charset utf-8;
    access_log /var/log/nginx/api.antiparallel.app-access.log;
    error_log  /var/log/nginx/api.antiparallel.app-error.log;

    client_max_body_size 512M;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }
    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_read_timeout 600;
        fastcgi_send_timeout 600;
        fastcgi_buffering off;
        fastcgi_hide_header X-Powered-By;
    }

    location ~ /\.(?!well-known).* { deny all; }
    location ~ /\.(env|git|composer\.json|composer\.lock|package\.json|package-lock\.json)$ {
        deny all;
        return 404;
    }

    location ~* \.(jpg|jpeg|gif|png|css|js|ico|xml|svg|woff|woff2|ttf|eot)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# ============================================================
section "3/4  Enable sites + remove default"
# ============================================================
ln -sf /etc/nginx/sites-available/antiparallel.app     /etc/nginx/sites-enabled/antiparallel.app
ln -sf /etc/nginx/sites-available/api.antiparallel.app /etc/nginx/sites-enabled/api.antiparallel.app
rm -f /etc/nginx/sites-enabled/default

nginx -t
systemctl reload nginx
log "Nginx reloaded"

# ============================================================
section "4/4  Block direct IP access — only allow via Cloudflare"
# ============================================================
# Get current Cloudflare IP list and whitelist only them on 80/443
# (SSH port 22 remains open to all, protected by key auth + fail2ban)
TMPFILE=$(mktemp)
{
    curl -fsS https://www.cloudflare.com/ips-v4
    echo
    curl -fsS https://www.cloudflare.com/ips-v6
} > "$TMPFILE" || { log "Warning: could not fetch Cloudflare IP list, skipping"; rm -f "$TMPFILE"; exit 0; }

# Reset ufw rules for 80/443 and allow only Cloudflare
ufw delete allow 80/tcp 2>/dev/null || true
ufw delete allow 443/tcp 2>/dev/null || true
while IFS= read -r cfip; do
    [ -z "$cfip" ] && continue
    ufw allow from "$cfip" to any port 80 proto tcp comment 'Cloudflare'
    ufw allow from "$cfip" to any port 443 proto tcp comment 'Cloudflare'
done < "$TMPFILE"
rm -f "$TMPFILE"
ufw reload
log "UFW: 80/443 restricted to Cloudflare IPs only"

# ============================================================
section "DONE"
# ============================================================
echo
echo "Nginx vhosts enabled:"
echo "  - https://antiparallel.app          -> Next.js @ :3000"
echo "  - https://api.antiparallel.app      -> Laravel /public"
echo
echo "Verify from VPS:"
echo "  curl -I https://antiparallel.app -H 'Host: antiparallel.app' --resolve antiparallel.app:443:127.0.0.1 -k"
echo
echo "Verify public (after Cloudflare DNS points here):"
echo "  curl -I https://antiparallel.app"
echo "  curl -I https://api.antiparallel.app"
