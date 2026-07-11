#!/bin/bash

# Automated deployment script for Vultr VPS
# This script will SSH to your VPS and deploy the application

set -e

VPS_HOST="${VPS_HOST:-207.148.76.203}"
VPS_USER="${VPS_USER:-root}"
VPS_PASSWORD="${VPS_PASSWORD:-changeme}"
REPO_URL="${REPO_URL:-https://github.com/PanapatWonganan/brieflylearn.git}"
APP_DIR="/var/www/brieflylearn"

echo "🚀 Starting deployment to Vultr VPS..."
echo "📍 VPS: $VPS_HOST"
echo "📦 Repo: $REPO_URL"
echo ""

# Create deployment commands
DEPLOY_COMMANDS=$(cat <<'DEPLOY_EOF'
set -e

echo "🔧 Step 1: Cleaning up old installation..."
rm -rf /var/www/brieflylearn
mkdir -p /var/www/brieflylearn
cd /var/www/brieflylearn

echo "📥 Step 2: Cloning repository..."
git clone https://github.com/PanapatWonganan/brieflylearn.git .

echo "✅ Repository cloned successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Create .env.local file with your environment variables"
echo "2. Run the deployment script: cd /var/www/brieflylearn && chmod +x deploy.sh && ./deploy.sh"
echo ""
echo "Files in directory:"
ls -la

DEPLOY_EOF
)

echo "🔐 Connecting to VPS and deploying..."
echo "    (You may need to enter password manually or use SSH keys)"
echo ""

# SSH and execute commands
ssh -o StrictHostKeyChecking=no $VPS_USER@$VPS_HOST "$DEPLOY_COMMANDS"

echo ""
echo "✅ Repository cloned to VPS successfully!"
echo ""
echo "🔧 Next steps to complete deployment:"
echo ""
echo "1️⃣  SSH to your VPS:"
echo "    ssh $VPS_USER@$VPS_HOST"
echo ""
echo "2️⃣  Create .env.local file:"
echo "    cd /var/www/brieflylearn"
echo "    nano .env.local"
echo ""
echo "3️⃣  Add these environment variables:"
echo "    DATABASE_URL=\"your-supabase-database-url\""
echo "    NEXT_PUBLIC_SUPABASE_URL=\"your-supabase-url\""
echo "    NEXT_PUBLIC_SUPABASE_ANON_KEY=\"your-anon-key\""
echo "    SUPABASE_SERVICE_ROLE_KEY=\"your-service-role-key\""
echo "    NEXTAUTH_URL=\"http://207.148.76.203\""
echo "    NEXTAUTH_SECRET=\"run: openssl rand -base64 32\""
echo "    NEXT_PUBLIC_APP_URL=\"http://207.148.76.203\""
echo ""
echo "4️⃣  Run deployment script:"
echo "    chmod +x deploy.sh"
echo "    ./deploy.sh"
echo ""
echo "5️⃣  Setup database:"
echo "    npx prisma generate"
echo "    npx prisma db push"
echo ""
echo "6️⃣  Check status:"
echo "    pm2 status"
echo "    pm2 logs brieflylearn"
echo ""
echo "🌐 Your app will be available at: http://$VPS_HOST"
