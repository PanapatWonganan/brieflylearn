#!/usr/bin/env bash
# ============================================================
# BrieflyLearn — VPS Provisioning Script (Ubuntu 22.04 LTS)
# ============================================================
# Purpose: Fresh VPS hardening + stack install
# Usage:   scp provision.sh root@<VPS_IP>:/root/
#          ssh root@<VPS_IP> 'bash /root/provision.sh'
# Idempotent: safe to re-run
# ============================================================

set -euo pipefail

log() { echo "[$(date +'%H:%M:%S')] $*"; }
section() { echo; echo "========================================"; echo ">>> $*"; echo "========================================"; }

# Ensure root
if [ "$(id -u)" -ne 0 ]; then
    echo "Must run as root" >&2
    exit 1
fi

# Non-interactive apt
export DEBIAN_FRONTEND=noninteractive

# ============================================================
section "1/10  System update & timezone"
# ============================================================
apt-get update -qq
apt-get upgrade -y -qq
timedatectl set-timezone Asia/Bangkok
log "Timezone: $(timedatectl | grep 'Time zone' | awk '{print $3}')"

# ============================================================
section "2/10  Swap file (2GB) — important for 2GB RAM VPS"
# ============================================================
if ! swapon --show | grep -q '/swapfile'; then
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    grep -q '/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
    log "Swap enabled"
else
    log "Swap already exists"
fi
echo 'vm.swappiness=10' > /etc/sysctl.d/99-swappiness.conf
sysctl -p /etc/sysctl.d/99-swappiness.conf > /dev/null

# ============================================================
section "3/10  Essential packages"
# ============================================================
apt-get install -y -qq \
    curl wget git unzip software-properties-common \
    ca-certificates gnupg lsb-release \
    ufw fail2ban unattended-upgrades \
    htop ncdu jq

# Enable unattended-upgrades for security patches
cat > /etc/apt/apt.conf.d/20auto-upgrades <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF
log "Unattended security upgrades enabled"

# ============================================================
section "4/10  Firewall (UFW) — allow 22, 80, 443"
# ============================================================
ufw --force reset > /dev/null
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp comment 'SSH'
ufw allow 80/tcp comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'
ufw --force enable
log "UFW enabled"

# ============================================================
section "5/10  SSH hardening — disable password auth"
# ============================================================
# Ensure authorized_keys exists first (sanity check)
if [ ! -s /root/.ssh/authorized_keys ]; then
    echo "ERROR: /root/.ssh/authorized_keys is empty — refusing to disable password auth" >&2
    exit 1
fi

cat > /etc/ssh/sshd_config.d/99-hardening.conf <<'EOF'
PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin prohibit-password
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
ClientAliveInterval 300
ClientAliveCountMax 2
MaxAuthTries 3
LoginGraceTime 30
EOF
# Comment out old PasswordAuthentication lines if present
sed -i 's/^PasswordAuthentication .*/#&/' /etc/ssh/sshd_config 2>/dev/null || true
sshd -t  # syntax check
systemctl restart ssh
log "SSH hardened — password auth DISABLED"

# ============================================================
section "6/10  fail2ban — protect SSH from brute-force"
# ============================================================
cat > /etc/fail2ban/jail.local <<'EOF'
[DEFAULT]
bantime = 1h
findtime = 10m
maxretry = 5
ignoreip = 127.0.0.1/8 ::1

[sshd]
enabled = true
port = 22
logpath = %(sshd_log)s
backend = %(sshd_backend)s
EOF
systemctl enable --now fail2ban
systemctl restart fail2ban
log "fail2ban active"

# ============================================================
section "7/10  PHP 8.3 + extensions (ondrej/php PPA)"
# ============================================================
if ! command -v php8.3 > /dev/null; then
    add-apt-repository -y ppa:ondrej/php
    apt-get update -qq
fi
apt-get install -y -qq \
    php8.3-fpm php8.3-cli \
    php8.3-mysql php8.3-mbstring php8.3-xml \
    php8.3-bcmath php8.3-curl php8.3-gd \
    php8.3-zip php8.3-intl php8.3-redis \
    php8.3-opcache php8.3-gmp

# PHP production hardening
PHP_INI=/etc/php/8.3/fpm/php.ini
sed -i 's/^expose_php = .*/expose_php = Off/' "$PHP_INI"
sed -i 's/^;?cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/' "$PHP_INI"
sed -i 's/^memory_limit = .*/memory_limit = 256M/' "$PHP_INI"
sed -i 's/^upload_max_filesize = .*/upload_max_filesize = 512M/' "$PHP_INI"
sed -i 's/^post_max_size = .*/post_max_size = 512M/' "$PHP_INI"
sed -i 's/^max_execution_time = .*/max_execution_time = 600/' "$PHP_INI"
systemctl enable --now php8.3-fpm
log "PHP $(php -r 'echo PHP_VERSION;') installed"

# Composer
if ! command -v composer > /dev/null; then
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
    chmod +x /usr/local/bin/composer
fi
log "Composer $(composer --version | awk '{print $3}')"

# ============================================================
section "8/10  MySQL 8.0 — bind to localhost only"
# ============================================================
if ! command -v mysql > /dev/null; then
    apt-get install -y -qq mysql-server
fi
# Bind to 127.0.0.1 only (no internet access to DB)
sed -i 's/^bind-address.*/bind-address = 127.0.0.1/' /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl enable --now mysql
systemctl restart mysql
log "MySQL $(mysql --version | awk '{print $3}') bound to localhost"

# ============================================================
section "9/10  Nginx + Certbot"
# ============================================================
apt-get install -y -qq nginx certbot python3-certbot-nginx
# Nginx hardening
NGINX_CONF=/etc/nginx/nginx.conf
sed -i 's/^\s*#\?\s*server_tokens.*/\tserver_tokens off;/' "$NGINX_CONF"
grep -q 'server_tokens off' "$NGINX_CONF" || \
    sed -i '/http {/a\\tserver_tokens off;' "$NGINX_CONF"
systemctl enable --now nginx
nginx -t
log "Nginx installed"

# ============================================================
section "10/10  Node.js 20 + PM2"
# ============================================================
if ! command -v node > /dev/null || [ "$(node -v | cut -c2 | head -1)" != "2" ]; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y -qq nodejs
fi
npm install -g pm2 > /dev/null 2>&1
log "Node $(node -v) / npm $(npm -v) / pm2 $(pm2 -v)"

# ============================================================
section "DONE  — System status"
# ============================================================
echo
echo "OS:         $(lsb_release -d | cut -f2)"
echo "Kernel:     $(uname -r)"
echo "Uptime:     $(uptime -p)"
echo "RAM:        $(free -h | awk '/^Mem:/ {print $2" total, "$3" used, "$4" free"}')"
echo "Disk:       $(df -h / | awk 'NR==2 {print $2" total, "$3" used, "$4" free"}')"
echo "Swap:       $(free -h | awk '/^Swap:/ {print $2}')"
echo "Firewall:   $(ufw status | head -1)"
echo "Fail2ban:   $(fail2ban-client status | grep 'Number of jail' | awk -F: '{print $2}') jail(s)"
echo "PHP:        $(php -r 'echo PHP_VERSION;')"
echo "MySQL:      $(mysql --version | awk '{print $3}') @ 127.0.0.1"
echo "Nginx:      $(nginx -v 2>&1 | awk '{print $3}')"
echo "Node:       $(node -v)"
echo
echo "Next: run deploy-app.sh to deploy BrieflyLearn application"
