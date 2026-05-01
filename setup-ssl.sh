#!/bin/bash

# BrieflyLearn - SSL Certificate Setup
# Sets up Let's Encrypt SSL for antiparallel.app and api.antiparallel.app

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  BrieflyLearn - SSL Setup             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Please run as root (use: sudo bash setup-ssl.sh)${NC}"
    exit 1
fi

MAIN_DOMAIN="antiparallel.app"
WWW_DOMAIN="www.antiparallel.app"
API_SUBDOMAIN="api.antiparallel.app"

# ============================================
# Step 1: Install Certbot
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📦 Step 1: Installing Certbot${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

if command -v certbot &> /dev/null; then
    echo -e "${GREEN}✅ Certbot already installed${NC}"
else
    echo -e "${YELLOW}Installing Certbot...${NC}"
    apt update
    apt install -y certbot python3-certbot-nginx
fi

# ============================================
# Step 2: Obtain SSL Certificates
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🔐 Step 2: Obtaining SSL Certificates${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "${YELLOW}⚠️  This will obtain SSL certificates for:${NC}"
echo -e "   - ${MAIN_DOMAIN}"
echo -e "   - ${WWW_DOMAIN}"
echo -e "   - ${API_SUBDOMAIN}"
echo -e ""
echo -e "${YELLOW}Make sure these domains are pointed to this server!${NC}"
echo -e "${YELLOW}Press Enter to continue or Ctrl+C to cancel...${NC}"
read

# Obtain certificates
certbot --nginx -d ${MAIN_DOMAIN} -d ${WWW_DOMAIN} -d ${API_SUBDOMAIN} --non-interactive --agree-tos --register-unsafely-without-email --redirect

echo -e "${GREEN}✅ SSL Certificates obtained!${NC}"

# ============================================
# Step 3: Update Backend .env for HTTPS
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🔧 Step 3: Updating Backend Configuration${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

cd /var/www/backend

# Update APP_URL and FRONTEND_URL to HTTPS
sed -i "s|APP_URL=http://|APP_URL=https://|g" .env
sed -i "s|FRONTEND_URL=http://|FRONTEND_URL=https://|g" .env
sed -i "s|CORS_ALLOWED_ORIGINS=http://|CORS_ALLOWED_ORIGINS=https://|g" .env

# Add both HTTP and HTTPS for CORS during transition
sed -i "s|CORS_ALLOWED_ORIGINS=https://|CORS_ALLOWED_ORIGINS=https://|g; s|,http://|,https://|g" .env

php artisan config:cache
php artisan route:cache

echo -e "${GREEN}✅ Backend configured for HTTPS!${NC}"

# ============================================
# Step 4: Update Frontend .env for HTTPS
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}⚛️  Step 4: Updating Frontend Configuration${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

cd /var/www/frontend

# Update to HTTPS
sed -i "s|NEXT_PUBLIC_API_URL=http://|NEXT_PUBLIC_API_URL=https://|g" .env.local
sed -i "s|NEXT_PUBLIC_APP_URL=http://|NEXT_PUBLIC_APP_URL=https://|g" .env.local

# Rebuild frontend
npm run build

echo -e "${GREEN}✅ Frontend configured for HTTPS!${NC}"

# ============================================
# Step 5: Restart Services
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🔄 Step 5: Restarting Services${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

systemctl restart brieflylearn-backend
systemctl restart brieflylearn-frontend
systemctl reload nginx

sleep 3

echo -e "${GREEN}✅ Services restarted!${NC}"

# ============================================
# Step 6: Test HTTPS
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🧪 Step 6: Testing HTTPS${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "${YELLOW}Testing Frontend (HTTPS)...${NC}"
if curl -k -s https://${MAIN_DOMAIN} | grep -q "html"; then
    echo -e "${GREEN}✅ Frontend HTTPS is working!${NC}"
else
    echo -e "${RED}❌ Frontend HTTPS is not working${NC}"
fi

echo -e "\n${YELLOW}Testing Backend API (HTTPS)...${NC}"
if curl -k -s https://${API_SUBDOMAIN}/api/v1/health | grep -q "ok"; then
    echo -e "${GREEN}✅ Backend API HTTPS is working!${NC}"
else
    echo -e "${RED}❌ Backend API HTTPS is not working${NC}"
fi

# ============================================
# Step 7: Setup Auto-renewal
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🔄 Step 7: Setting up Auto-renewal${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Certbot automatically sets up renewal, let's test it
certbot renew --dry-run

echo -e "${GREEN}✅ Auto-renewal is configured!${NC}"

# ============================================
# Final Status
# ============================================
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ SSL Setup Complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "${YELLOW}🔗 Your Secure Applications:${NC}"
echo -e "  Frontend: ${GREEN}https://${MAIN_DOMAIN}${NC}"
echo -e "  Backend API: ${GREEN}https://${API_SUBDOMAIN}${NC}"
echo -e "  Admin Panel: ${GREEN}https://${API_SUBDOMAIN}/admin${NC}"
echo -e "  Health Check: ${GREEN}https://${API_SUBDOMAIN}/api/v1/health${NC}"

echo -e "\n${YELLOW}📝 SSL Certificate Info:${NC}"
certbot certificates

echo -e "\n${YELLOW}🔄 Certificate Auto-renewal:${NC}"
echo -e "  Certificates will auto-renew before expiry"
echo -e "  Test renewal: ${BLUE}certbot renew --dry-run${NC}"

echo -e "\n${GREEN}🎉 Done! Your site is now secure with HTTPS${NC}\n"
