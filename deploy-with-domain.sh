#!/bin/bash

# BrieflyLearn - Deployment with Domain Support
# Supports: https://brieflylearn.com/
# Backend API: Will be at https://brieflylearn.com/api or https://api.brieflylearn.com

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  BrieflyLearn - Domain Deployment     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Please run as root (use: sudo bash deploy-with-domain.sh)${NC}"
    exit 1
fi

# Domain Configuration
MAIN_DOMAIN="brieflylearn.com"
WWW_DOMAIN="www.brieflylearn.com"
API_SUBDOMAIN="api.brieflylearn.com"
VPS_IP=$(hostname -I | awk '{print $1}')

echo -e "${YELLOW}📡 VPS IP Address: ${VPS_IP}${NC}"
echo -e "${YELLOW}🌐 Main Domain: ${MAIN_DOMAIN}${NC}"
echo -e "${YELLOW}🔗 API Domain: ${API_SUBDOMAIN}${NC}\n"

# Check if we should use HTTPS or HTTP initially
USE_HTTPS="false"
if [ -f "/etc/letsencrypt/live/${MAIN_DOMAIN}/fullchain.pem" ]; then
    echo -e "${GREEN}✅ SSL Certificate found - will use HTTPS${NC}"
    USE_HTTPS="true"
    PROTOCOL="https"
else
    echo -e "${YELLOW}⚠️  No SSL Certificate found - will use HTTP first${NC}"
    echo -e "${YELLOW}   We'll set up SSL after deployment${NC}"
    PROTOCOL="http"
fi
echo ""

# ============================================
# Step 1: Deploy Laravel Backend
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🔥 Step 1: Deploying Laravel Backend${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

mkdir -p /var/www
cd /var/www

if [ -d "backend" ]; then
    echo -e "${YELLOW}Backing up old backend...${NC}"
    mv backend backend-backup-$(date +%Y%m%d-%H%M%S)
fi

echo -e "${YELLOW}Cloning backend repository...${NC}"
git clone https://github.com/PanapatWonganan/brieflylearn-backend.git backend

cd /var/www/backend

echo -e "${YELLOW}Installing Composer dependencies...${NC}"
composer install --optimize-autoloader --no-dev --no-interaction

echo -e "${YELLOW}Configuring environment with domain...${NC}"
cat > .env << ENVEOF
APP_NAME="BrieflyLearn API"
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=${PROTOCOL}://${API_SUBDOMAIN}

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=brieflylearn
DB_USERNAME=brieflyuser
DB_PASSWORD=brieflypass_2024

CACHE_DRIVER=file
QUEUE_CONNECTION=database
SESSION_DRIVER=file

# CORS Configuration - Allow frontend domain
CORS_ALLOWED_ORIGINS=${PROTOCOL}://${MAIN_DOMAIN},${PROTOCOL}://${WWW_DOMAIN},http://${MAIN_DOMAIN},http://${WWW_DOMAIN},http://${VPS_IP}:3000,http://localhost:3000
FRONTEND_URL=${PROTOCOL}://${MAIN_DOMAIN}
SANCTUM_STATEFUL_DOMAINS=${MAIN_DOMAIN},${WWW_DOMAIN},localhost:3000

FILAMENT_DOMAIN=${API_SUBDOMAIN}
ENVEOF

php artisan key:generate --force

php artisan storage:link || true
chown -R www-data:www-data /var/www/backend
chmod -R 755 /var/www/backend
chmod -R 775 /var/www/backend/storage
chmod -R 775 /var/www/backend/bootstrap/cache

php artisan config:cache
php artisan route:cache
php artisan view:cache

echo -e "${GREEN}✅ Laravel backend deployed!${NC}"

# ============================================
# Step 2: Import Database
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📥 Step 2: Importing Database${NC}"
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
    echo -e "${YELLOW}⚠️  Could not download database backup. Running migrations instead...${NC}"
    cd /var/www/backend
    php artisan migrate --force
fi

# ============================================
# Step 3: Deploy Next.js Frontend
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}⚛️  Step 3: Deploying Next.js Frontend${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

cd /var/www

if [ -d "frontend" ]; then
    echo -e "${YELLOW}Backing up old frontend...${NC}"
    mv frontend frontend-backup-$(date +%Y%m%d-%H%M%S)
fi

echo -e "${YELLOW}Cloning frontend repository...${NC}"
git clone https://github.com/PanapatWonganan/brieflylearn-frontend.git frontend
cd frontend

# Create .env.local with domain configuration
cat > .env.local << FRONTENVEOF
# API Configuration - Using domain
NEXT_PUBLIC_API_URL=${PROTOCOL}://${API_SUBDOMAIN}/api/v1
NEXT_PUBLIC_APP_URL=${PROTOCOL}://${MAIN_DOMAIN}
NODE_ENV=production
PORT=3000

# Database (for Next.js API routes if needed)
DATABASE_URL="mysql://brieflyuser:brieflypass_2024@localhost:3306/brieflylearn"
DB_HOST=localhost
DB_PORT=3306
DB_NAME=brieflylearn
DB_USER=brieflyuser
DB_PASSWORD=brieflypass_2024

JWT_SECRET=your-super-secret-jwt-key-production-2024
FRONTENVEOF

echo -e "${YELLOW}Installing npm dependencies...${NC}"
npm install

echo -e "${YELLOW}Building Next.js application...${NC}"
npm run build

chown -R www-data:www-data /var/www/frontend

echo -e "${GREEN}✅ Next.js frontend deployed!${NC}"

# ============================================
# Step 4: Setup Systemd Services
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}⚙️  Step 4: Setting up Systemd Services${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Stop existing services if running
systemctl stop brieflylearn-backend 2>/dev/null || true
systemctl stop brieflylearn-frontend 2>/dev/null || true

# Backend service using php artisan serve
cat > /etc/systemd/system/brieflylearn-backend.service << 'LARAVELEOF'
[Unit]
Description=BrieflyLearn Laravel Backend API
After=network.target mysql.service
Requires=mysql.service

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/var/www/backend
ExecStart=/usr/bin/php artisan serve --host=0.0.0.0 --port=8000
Restart=always
RestartSec=3
StandardOutput=append:/var/log/brieflylearn-backend.log
StandardError=append:/var/log/brieflylearn-backend-error.log

[Install]
WantedBy=multi-user.target
LARAVELEOF

# Frontend service
cat > /etc/systemd/system/brieflylearn-frontend.service << 'NEXTEOF'
[Unit]
Description=BrieflyLearn Next.js Frontend
After=network.target brieflylearn-backend.service

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
StandardOutput=append:/var/log/brieflylearn-frontend.log
StandardError=append:/var/log/brieflylearn-frontend-error.log

[Install]
WantedBy=multi-user.target
NEXTEOF

# Create log files
touch /var/log/brieflylearn-backend.log
touch /var/log/brieflylearn-backend-error.log
touch /var/log/brieflylearn-frontend.log
touch /var/log/brieflylearn-frontend-error.log
chown www-data:www-data /var/log/brieflylearn-*.log

systemctl daemon-reload
systemctl enable brieflylearn-backend
systemctl enable brieflylearn-frontend
systemctl start brieflylearn-backend
systemctl start brieflylearn-frontend

# Wait for services to start
sleep 5

echo -e "${GREEN}✅ Services created and started!${NC}"

# ============================================
# Step 5: Configure Nginx
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🌐 Step 5: Configuring Nginx${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Backend Nginx Config (api.brieflylearn.com)
cat > /etc/nginx/sites-available/brieflylearn-backend << 'BACKENDNGINX'
server {
    listen 80;
    server_name api.brieflylearn.com;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # CORS headers
        add_header Access-Control-Allow-Origin * always;
        add_header Access-Control-Allow-Methods 'GET, POST, PUT, DELETE, OPTIONS' always;
        add_header Access-Control-Allow-Headers 'Authorization, Content-Type, Accept' always;

        if ($request_method = 'OPTIONS') {
            return 204;
        }
    }
}
BACKENDNGINX

# Frontend Nginx Config (brieflylearn.com)
cat > /etc/nginx/sites-available/brieflylearn-frontend << 'FRONTENDNGINX'
server {
    listen 80;
    server_name brieflylearn.com www.brieflylearn.com;

    location / {
        proxy_pass http://127.0.0.1:3000;
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
ln -sf /etc/nginx/sites-available/brieflylearn-backend /etc/nginx/sites-enabled/
ln -sf /etc/nginx/sites-available/brieflylearn-frontend /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test and reload nginx
nginx -t
systemctl reload nginx

echo -e "${GREEN}✅ Nginx configured!${NC}"

# ============================================
# Step 6: Test Services
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🧪 Step 6: Testing Services${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "${YELLOW}Testing Backend API (local)...${NC}"
if curl -s http://localhost:8000/api/v1/health | grep -q "ok"; then
    echo -e "${GREEN}✅ Backend API is responding!${NC}"
else
    echo -e "${RED}❌ Backend API is not responding${NC}"
    echo -e "${YELLOW}Backend error logs:${NC}"
    tail -20 /var/log/brieflylearn-backend-error.log
fi

echo -e "\n${YELLOW}Testing Frontend (local)...${NC}"
if curl -s http://localhost:3000 | grep -q "html"; then
    echo -e "${GREEN}✅ Frontend is responding!${NC}"
else
    echo -e "${RED}❌ Frontend is not responding${NC}"
    echo -e "${YELLOW}Frontend error logs:${NC}"
    tail -20 /var/log/brieflylearn-frontend-error.log
fi

# ============================================
# Final Status
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Deployment Complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "${YELLOW}📊 Service Status:${NC}"
systemctl status brieflylearn-backend --no-pager -l | head -5
echo ""
systemctl status brieflylearn-frontend --no-pager -l | head -5
echo ""

echo -e "${YELLOW}🔗 Your Applications:${NC}"
if [ "$USE_HTTPS" = "true" ]; then
    echo -e "  Frontend: ${GREEN}https://${MAIN_DOMAIN}${NC}"
    echo -e "  Backend API: ${GREEN}https://${API_SUBDOMAIN}${NC}"
    echo -e "  Health Check: ${GREEN}https://${API_SUBDOMAIN}/api/v1/health${NC}"
else
    echo -e "  Frontend: ${GREEN}http://${MAIN_DOMAIN}${NC}"
    echo -e "  Backend API: ${GREEN}http://${API_SUBDOMAIN}${NC}"
    echo -e "  Health Check: ${GREEN}http://${API_SUBDOMAIN}/api/v1/health${NC}"
    echo -e "\n${YELLOW}⚠️  SSL NOT YET CONFIGURED${NC}"
    echo -e "${YELLOW}   Run this command to set up SSL:${NC}"
    echo -e "   ${BLUE}bash setup-ssl.sh${NC}"
fi

echo -e "\n${YELLOW}📝 Test Authentication:${NC}"
echo -e "  curl -X POST ${PROTOCOL}://${API_SUBDOMAIN}/api/v1/auth/register \\"
echo -e "    -H 'Content-Type: application/json' \\"
echo -e "    -d '{\"email\":\"test@test.com\",\"password\":\"test1234\",\"full_name\":\"Test User\"}'"

echo -e "\n${YELLOW}📋 View Logs:${NC}"
echo "  tail -f /var/log/brieflylearn-backend.log"
echo "  tail -f /var/log/brieflylearn-frontend.log"

echo -e "\n${GREEN}🎉 Done! Visit ${PROTOCOL}://${MAIN_DOMAIN} to test${NC}\n"
