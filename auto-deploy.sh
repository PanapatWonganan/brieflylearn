#!/bin/bash

# BrieflyLearn Complete Auto-Deployment Script
# For Fresh Vultr VPS (Ubuntu 22.04)

set -e  # Exit on error

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  BrieflyLearn Auto-Deployment Script  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Please run as root (use sudo)${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 This script will:${NC}"
echo "  1. Install PHP 8.2, MySQL, Node.js 20, Nginx"
echo "  2. Setup MySQL database"
echo "  3. Deploy Laravel Backend"
echo "  4. Deploy Next.js Frontend"
echo "  5. Configure Nginx"
echo ""
read -p "Continue? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# ============================================
# Step 1: Update System
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📦 Step 1: Updating System${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

apt update
apt upgrade -y

# ============================================
# Step 2: Install Software
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📦 Step 2: Installing Required Software${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Essential tools
apt install -y curl git unzip nginx certbot python3-certbot-nginx

# PHP 8.2
echo -e "${YELLOW}Installing PHP 8.2...${NC}"
apt install -y software-properties-common
add-apt-repository ppa:ondrej/php -y
apt update
apt install -y php8.2 php8.2-cli php8.2-fpm php8.2-mysql php8.2-xml php8.2-mbstring \
  php8.2-curl php8.2-zip php8.2-gd php8.2-intl php8.2-bcmath php8.2-soap

# Composer
echo -e "${YELLOW}Installing Composer...${NC}"
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer

# MySQL
echo -e "${YELLOW}Installing MySQL...${NC}"
apt install -y mysql-server

# Node.js 20
echo -e "${YELLOW}Installing Node.js 20...${NC}"
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

echo -e "${GREEN}✅ Software installation complete!${NC}"

# ============================================
# Step 3: Setup MySQL
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🗄️  Step 3: Setting up MySQL Database${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Start MySQL
systemctl start mysql
systemctl enable mysql

# Create database and user
echo -e "${YELLOW}Creating database and user...${NC}"
mysql -e "CREATE DATABASE IF NOT EXISTS brieflylearn CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "CREATE USER IF NOT EXISTS 'brieflyuser'@'localhost' IDENTIFIED BY 'brieflypass_2024';"
mysql -e "GRANT ALL PRIVILEGES ON brieflylearn.* TO 'brieflyuser'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

echo -e "${GREEN}✅ MySQL setup complete!${NC}"

# ============================================
# Step 4: Deploy Laravel Backend
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🔥 Step 4: Deploying Laravel Backend${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

mkdir -p /var/www
cd /var/www

# Clone backend repository
if [ -d "backend" ]; then
    rm -rf backend
fi

echo -e "${YELLOW}Cloning backend repository...${NC}"
git clone https://github.com/PanapatWonganan/brieflylearn-backend.git backend

cd /var/www/backend

# Install dependencies
echo -e "${YELLOW}Installing Composer dependencies...${NC}"
composer install --optimize-autoloader --no-dev --no-interaction

# Configure environment
echo -e "${YELLOW}Configuring environment...${NC}"
cat > .env << 'ENVEOF'
APP_NAME="BrieflyLearn API"
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://api.brieflylearn.com

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=brieflylearn
DB_USERNAME=brieflyuser
DB_PASSWORD=brieflypass_2024

CACHE_DRIVER=file
QUEUE_CONNECTION=database
SESSION_DRIVER=file

FILAMENT_DOMAIN=api.brieflylearn.com
ENVEOF

php artisan key:generate --force

# Setup storage
php artisan storage:link
chown -R www-data:www-data /var/www/backend
chmod -R 755 /var/www/backend
chmod -R 775 /var/www/backend/storage
chmod -R 775 /var/www/backend/bootstrap/cache

# Cache config
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo -e "${GREEN}✅ Laravel backend deployed!${NC}"

# ============================================
# Step 5: Import Database
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📥 Step 5: Importing Database${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

if [ -f "/tmp/database_backup.sql" ]; then
    rm /tmp/database_backup.sql
fi

# Try to download from GitHub
echo -e "${YELLOW}Downloading database backup...${NC}"
cd /tmp
if wget -q https://raw.githubusercontent.com/PanapatWonganan/brieflylearn/main/database_backup.sql; then
    echo -e "${YELLOW}Importing database...${NC}"
    mysql -u brieflyuser -pbrieflypass_2024 brieflylearn < /tmp/database_backup.sql
    echo -e "${GREEN}✅ Database imported successfully!${NC}"
else
    echo -e "${YELLOW}⚠️  Could not download database backup. You'll need to import manually.${NC}"
fi

# ============================================
# Step 6: Deploy Next.js Frontend
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}⚛️  Step 6: Deploying Next.js Frontend${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

cd /var/www

if [ -d "frontend" ]; then
    rm -rf frontend
fi

echo -e "${YELLOW}Cloning frontend repository...${NC}"
git clone https://github.com/PanapatWonganan/brieflylearn-frontend.git frontend
cd frontend

# Configure environment
cat > .env.local << 'FRONTENVEOF'
NEXT_PUBLIC_API_URL=https://api.brieflylearn.com
NEXT_PUBLIC_APP_URL=https://brieflylearn.com
NODE_ENV=production
PORT=3000
FRONTENVEOF

# Install and build
echo -e "${YELLOW}Installing npm dependencies...${NC}"
npm install

echo -e "${YELLOW}Building Next.js application...${NC}"
npm run build

chown -R www-data:www-data /var/www/frontend

echo -e "${GREEN}✅ Next.js frontend deployed!${NC}"

# ============================================
# Step 7: Create Systemd Services
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}⚙️  Step 7: Creating Systemd Services${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Laravel Backend Service
cat > /etc/systemd/system/laravel-backend.service << 'LARAVELEOF'
[Unit]
Description=Laravel Backend API
After=network.target

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/var/www/backend
ExecStart=/usr/bin/php -S 0.0.0.0:8000 -t public
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
LARAVELEOF

# Next.js Frontend Service
cat > /etc/systemd/system/nextjs-frontend.service << 'NEXTEOF'
[Unit]
Description=Next.js Frontend
After=network.target

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/var/www/frontend
Environment=NODE_ENV=production
Environment=PORT=3000
ExecStart=/usr/bin/npm start
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
NEXTEOF

# Reload and start services
systemctl daemon-reload
systemctl enable laravel-backend
systemctl enable nextjs-frontend
systemctl start laravel-backend
systemctl start nextjs-frontend

echo -e "${GREEN}✅ Services created and started!${NC}"

# ============================================
# Step 8: Configure Nginx
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🌐 Step 8: Configuring Nginx${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Backend config
cat > /etc/nginx/sites-available/backend << 'BACKENDNGINX'
server {
    listen 80;
    server_name api.brieflylearn.com;

    root /var/www/backend/public;
    index index.php;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
BACKENDNGINX

# Frontend config
cat > /etc/nginx/sites-available/frontend << 'FRONTENDNGINX'
server {
    listen 80;
    server_name brieflylearn.com www.brieflylearn.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
FRONTENDNGINX

# Enable sites
ln -sf /etc/nginx/sites-available/backend /etc/nginx/sites-enabled/
ln -sf /etc/nginx/sites-available/frontend /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test and restart Nginx
nginx -t
systemctl restart nginx

echo -e "${GREEN}✅ Nginx configured!${NC}"

# ============================================
# Step 9: Configure Firewall
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🔥 Step 9: Configuring Firewall${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

ufw --force enable
ufw allow 22
ufw allow 80
ufw allow 443
ufw status

# ============================================
# Final Status Check
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Deployment Complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "${YELLOW}📊 Service Status:${NC}"
systemctl status laravel-backend --no-pager | head -5
systemctl status nextjs-frontend --no-pager | head -5
systemctl status nginx --no-pager | head -5

echo -e "\n${YELLOW}🔗 Your Application URLs:${NC}"
echo -e "  Frontend: ${GREEN}https://brieflylearn.com${NC}"
echo -e "  Backend API: ${GREEN}https://api.brieflylearn.com${NC}"
echo -e "  Admin Panel: ${GREEN}https://api.brieflylearn.com/admin${NC}"

echo -e "\n${YELLOW}📝 Next Steps:${NC}"
echo "  1. Configure Cloudflare DNS:"
echo "     - brieflylearn.com → 207.148.76.203"
echo "     - api.brieflylearn.com → 207.148.76.203"
echo "  2. Set Cloudflare SSL/TLS to 'Flexible'"
echo "  3. Test your application"

echo -e "\n${YELLOW}🛠️  Useful Commands:${NC}"
echo "  View Laravel logs: journalctl -u laravel-backend -f"
echo "  View Next.js logs: journalctl -u nextjs-frontend -f"
echo "  Restart services: systemctl restart laravel-backend nextjs-frontend"

echo -e "\n${GREEN}🎉 Deployment successful!${NC}\n"
