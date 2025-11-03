#!/bin/bash

# BrieflyLearn - Fixed Deployment Script
# Fixes authentication issues on VPS

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  BrieflyLearn - Fixed Deployment      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Please run as root (use: sudo bash deploy-fixed.sh)${NC}"
    exit 1
fi

# Get VPS IP Address
VPS_IP=$(hostname -I | awk '{print $1}')
echo -e "${YELLOW}📡 VPS IP Address: ${VPS_IP}${NC}\n"

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

echo -e "${YELLOW}Configuring environment with CORS...${NC}"
cat > .env << ENVEOF
APP_NAME="BrieflyLearn API"
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=http://${VPS_IP}:8000

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=brieflylearn
DB_USERNAME=brieflyuser
DB_PASSWORD=brieflypass_2024

CACHE_DRIVER=file
QUEUE_CONNECTION=database
SESSION_DRIVER=file

# CORS Configuration - Allow frontend to connect
CORS_ALLOWED_ORIGINS=http://${VPS_IP}:3000,http://localhost:3000,http://${VPS_IP},https://brieflylearn.com,https://www.brieflylearn.com
FRONTEND_URL=http://${VPS_IP}:3000
SANCTUM_STATEFUL_DOMAINS=${VPS_IP}:3000,localhost:3000

FILAMENT_DOMAIN=${VPS_IP}
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

# Create .env.local with correct API URL
cat > .env.local << FRONTENVEOF
# API Configuration - Using VPS IP and port
NEXT_PUBLIC_API_URL=http://${VPS_IP}:8000/api/v1
NEXT_PUBLIC_APP_URL=http://${VPS_IP}:3000
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
# Step 4: Setup Systemd Services (FIXED)
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}⚙️  Step 4: Setting up Systemd Services${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Stop existing services if running
systemctl stop brieflylearn-backend 2>/dev/null || true
systemctl stop brieflylearn-frontend 2>/dev/null || true

# Backend service using php artisan serve (better than php -S)
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
# Step 5: Test Services
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🧪 Step 5: Testing Services${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "${YELLOW}Testing Backend API...${NC}"
if curl -s http://localhost:8000/api/v1/health | grep -q "ok"; then
    echo -e "${GREEN}✅ Backend API is responding!${NC}"
else
    echo -e "${RED}❌ Backend API is not responding${NC}"
    echo -e "${YELLOW}Backend logs:${NC}"
    tail -20 /var/log/brieflylearn-backend-error.log
fi

echo -e "\n${YELLOW}Testing Frontend...${NC}"
if curl -s http://localhost:3000 | grep -q "html"; then
    echo -e "${GREEN}✅ Frontend is responding!${NC}"
else
    echo -e "${RED}❌ Frontend is not responding${NC}"
    echo -e "${YELLOW}Frontend logs:${NC}"
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
echo -e "  Frontend: ${GREEN}http://${VPS_IP}:3000${NC}"
echo -e "  Backend API: ${GREEN}http://${VPS_IP}:8000${NC}"
echo -e "  Admin Panel: ${GREEN}http://${VPS_IP}:8000/admin${NC}"
echo -e "  Health Check: ${GREEN}http://${VPS_IP}:8000/api/v1/health${NC}"

echo -e "\n${YELLOW}📝 Test Authentication:${NC}"
echo -e "  curl -X POST http://${VPS_IP}:8000/api/v1/auth/register \\"
echo -e "    -H 'Content-Type: application/json' \\"
echo -e "    -d '{\"email\":\"test@test.com\",\"password\":\"test1234\",\"full_name\":\"Test User\"}'"

echo -e "\n${YELLOW}📋 View Logs:${NC}"
echo "  tail -f /var/log/brieflylearn-backend.log"
echo "  tail -f /var/log/brieflylearn-frontend.log"
echo "  journalctl -u brieflylearn-backend -f"
echo "  journalctl -u brieflylearn-frontend -f"

echo -e "\n${YELLOW}🔄 Restart Services:${NC}"
echo "  systemctl restart brieflylearn-backend"
echo "  systemctl restart brieflylearn-frontend"

echo -e "\n${GREEN}🎉 Done! Try accessing the frontend and test register/login${NC}\n"
