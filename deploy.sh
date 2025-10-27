#!/bin/bash

# BrieflyLearn Deployment Script for Vultr VPS
# Usage: ./deploy.sh

set -e  # Exit on error

echo "🚀 Starting BrieflyLearn Deployment..."

# Configuration
APP_DIR="/var/www/brieflylearn"
APP_NAME="brieflylearn"
NODE_ENV="production"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Please run as root (use sudo)${NC}"
    exit 1
fi

echo -e "${YELLOW}📦 Step 1: Installing system dependencies...${NC}"
apt-get update
apt-get install -y curl git nginx certbot python3-certbot-nginx

# Install Node.js 20.x if not installed
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}📦 Installing Node.js 20.x...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs
else
    echo -e "${GREEN}✅ Node.js already installed: $(node --version)${NC}"
fi

# Install PM2 globally if not installed
if ! command -v pm2 &> /dev/null; then
    echo -e "${YELLOW}📦 Installing PM2...${NC}"
    npm install -g pm2
else
    echo -e "${GREEN}✅ PM2 already installed: $(pm2 --version)${NC}"
fi

echo -e "${YELLOW}📂 Step 2: Setting up application directory...${NC}"
# Create app directory if doesn't exist
if [ ! -d "$APP_DIR" ]; then
    mkdir -p $APP_DIR
    echo -e "${GREEN}✅ Created directory: $APP_DIR${NC}"
fi

cd $APP_DIR

# Clone or pull repository
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}📥 Cloning repository...${NC}"
    read -p "Enter your GitHub repository URL: " REPO_URL
    git clone $REPO_URL .
else
    echo -e "${YELLOW}📥 Pulling latest changes...${NC}"
    git pull origin main || git pull origin master
fi

echo -e "${YELLOW}📦 Step 3: Installing dependencies...${NC}"
npm install --production=false

echo -e "${YELLOW}🔧 Step 4: Checking environment variables...${NC}"
if [ ! -f ".env.local" ]; then
    echo -e "${RED}⚠️  .env.local not found!${NC}"
    echo -e "${YELLOW}Creating template .env.local file...${NC}"
    cat > .env.local << 'EOF'
# Database
DATABASE_URL="postgresql://user:password@localhost:5432/brieflylearn"

# Supabase
NEXT_PUBLIC_SUPABASE_URL="your-supabase-url"
NEXT_PUBLIC_SUPABASE_ANON_KEY="your-supabase-anon-key"
SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"

# Stripe
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY="your-stripe-publishable-key"
STRIPE_SECRET_KEY="your-stripe-secret-key"
STRIPE_WEBHOOK_SECRET="your-stripe-webhook-secret"

# NextAuth
NEXTAUTH_URL="https://yourdomain.com"
NEXTAUTH_SECRET="your-nextauth-secret"

# App
NEXT_PUBLIC_APP_URL="https://yourdomain.com"
EOF
    echo -e "${YELLOW}⚠️  Please edit .env.local with your actual values!${NC}"
    exit 1
else
    echo -e "${GREEN}✅ .env.local found${NC}"
fi

echo -e "${YELLOW}🏗️  Step 5: Building application...${NC}"
npm run build

echo -e "${YELLOW}🔄 Step 6: Managing PM2 process...${NC}"
# Stop existing process if running
pm2 stop $APP_NAME 2>/dev/null || true
pm2 delete $APP_NAME 2>/dev/null || true

# Start with PM2
pm2 start npm --name $APP_NAME -- start
pm2 save
pm2 startup systemd -u root --hp /root

echo -e "${YELLOW}🌐 Step 7: Configuring Nginx...${NC}"
# Create Nginx configuration
cat > /etc/nginx/sites-available/$APP_NAME << 'NGINX_EOF'
server {
    listen 80;
    server_name _;  # Replace with your domain

    client_max_body_size 100M;

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
NGINX_EOF

# Enable site
ln -sf /etc/nginx/sites-available/$APP_NAME /etc/nginx/sites-enabled/$APP_NAME

# Remove default site if exists
rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t

# Restart Nginx
systemctl restart nginx
systemctl enable nginx

echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo ""
echo -e "${YELLOW}📊 Application Status:${NC}"
pm2 status

echo ""
echo -e "${YELLOW}🔍 Useful Commands:${NC}"
echo "  View logs:        pm2 logs $APP_NAME"
echo "  Restart app:      pm2 restart $APP_NAME"
echo "  Stop app:         pm2 stop $APP_NAME"
echo "  Monitor:          pm2 monit"
echo ""
echo -e "${YELLOW}🌐 Next Steps:${NC}"
echo "  1. Point your domain to this server IP: $(curl -s ifconfig.me)"
echo "  2. Update Nginx config with your domain: nano /etc/nginx/sites-available/$APP_NAME"
echo "  3. Setup SSL: certbot --nginx -d yourdomain.com"
echo "  4. Edit environment variables: nano $APP_DIR/.env.local"
echo ""
echo -e "${GREEN}🎉 Your app should be running at http://$(curl -s ifconfig.me)${NC}"
