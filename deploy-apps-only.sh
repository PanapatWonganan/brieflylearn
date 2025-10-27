#!/bin/bash

# BrieflyLearn - Deploy Applications Only (Skip Software Installation)
# Starts from Step 4: Deploy Backend & Frontend

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  BrieflyLearn - Deploy Apps Only      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Please run as root${NC}"
    exit 1
fi

# ============================================
# Step 4: Deploy Laravel Backend
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🔥 Step 4: Deploying Laravel Backend${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

mkdir -p /var/www
cd /var/www

if [ -d "backend" ]; then
    echo -e "${YELLOW}Removing old backend...${NC}"
    rm -rf backend
fi

echo -e "${YELLOW}Cloning backend repository...${NC}"
git clone https://github.com/PanapatWonganan/brieflylearn-backend.git backend

cd /var/www/backend

echo -e "${YELLOW}Installing Composer dependencies...${NC}"
composer install --optimize-autoloader --no-dev --no-interaction

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

php artisan storage:link
chown -R www-data:www-data /var/www/backend
chmod -R 755 /var/www/backend
chmod -R 775 /var/www/backend/storage
chmod -R 775 /var/www/backend/bootstrap/cache

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

echo -e "${YELLOW}Downloading database backup...${NC}"
cd /tmp
if wget -q https://raw.githubusercontent.com/PanapatWonganan/brieflylearn/main/database_backup.sql; then
    echo -e "${YELLOW}Importing database...${NC}"
    mysql -u brieflyuser -pbrieflypass_2024 brieflylearn < /tmp/database_backup.sql
    echo -e "${GREEN}✅ Database imported successfully!${NC}"
else
    echo -e "${YELLOW}⚠️  Could not download database backup. Skip for now.${NC}"
fi

# ============================================
# Step 6: Deploy Next.js Frontend
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}⚛️  Step 6: Deploying Next.js Frontend${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

cd /var/www

if [ -d "frontend" ]; then
    echo -e "${YELLOW}Removing old frontend...${NC}"
    rm -rf frontend
fi

echo -e "${YELLOW}Cloning frontend repository...${NC}"
git clone https://github.com/PanapatWonganan/brieflylearn-frontend.git frontend
cd frontend

cat > .env.local << 'FRONTENVEOF'
NEXT_PUBLIC_API_URL=https://api.brieflylearn.com
NEXT_PUBLIC_APP_URL=https://brieflylearn.com
NODE_ENV=production
PORT=3000
FRONTENVEOF

echo -e "${YELLOW}Installing npm dependencies...${NC}"
npm install

echo -e "${YELLOW}Building Next.js application...${NC}"
npm run build

chown -R www-data:www-data /var/www/frontend

echo -e "${GREEN}✅ Next.js frontend deployed!${NC}"

# ============================================
# Step 7: Create/Update Systemd Services
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}⚙️  Step 7: Setting up Systemd Services${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Stop existing services if running
systemctl stop laravel-backend 2>/dev/null || true
systemctl stop nextjs-frontend 2>/dev/null || true

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

ln -sf /etc/nginx/sites-available/backend /etc/nginx/sites-enabled/
ln -sf /etc/nginx/sites-available/frontend /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

nginx -t
systemctl restart nginx

echo -e "${GREEN}✅ Nginx configured!${NC}"

# ============================================
# Final Status
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Deployment Complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "${YELLOW}📊 Service Status:${NC}"
systemctl status laravel-backend --no-pager -l | head -3
echo ""
systemctl status nextjs-frontend --no-pager -l | head -3
echo ""

echo -e "${YELLOW}🔗 Your Applications:${NC}"
echo -e "  Frontend: ${GREEN}https://brieflylearn.com${NC}"
echo -e "  Backend API: ${GREEN}https://api.brieflylearn.com${NC}"
echo -e "  Admin Panel: ${GREEN}https://api.brieflylearn.com/admin${NC}"

echo -e "\n${YELLOW}📝 Test Commands:${NC}"
echo "  curl http://localhost:3000"
echo "  curl http://localhost:8000/api/v1/health"

echo -e "\n${YELLOW}📋 View Logs:${NC}"
echo "  journalctl -u laravel-backend -f"
echo "  journalctl -u nextjs-frontend -f"

echo -e "\n${GREEN}🎉 Done!${NC}\n"
