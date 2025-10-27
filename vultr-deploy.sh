#!/bin/bash

# BrieflyLearn Vultr Deployment Script
# Server: 207.148.76.203

set -e

echo "🚀 BrieflyLearn Deployment to Vultr"
echo "===================================="

# Server credentials
SERVER_IP="207.148.76.203"
SERVER_USER="root"
GITHUB_USER="PanapatWonganan"

echo ""
echo "📡 Connecting to server: $SERVER_IP"
echo ""

# Create deployment script that will run on server
cat > /tmp/deploy-server.sh << 'DEPLOY_SCRIPT'
#!/bin/bash
set -e

echo "🔧 Step 1: Update System Packages"
apt update && apt upgrade -y

echo "📦 Step 2: Install Basic Tools"
apt install -y curl wget git unzip software-properties-common ufw vim

echo "🔥 Step 3: Setup Firewall"
ufw --force enable
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
echo "✅ Firewall configured"

echo "🌐 Step 4: Install Nginx"
apt install -y nginx
systemctl start nginx
systemctl enable nginx
echo "✅ Nginx installed"

echo "🐘 Step 5: Install PHP 8.2"
add-apt-repository -y ppa:ondrej/php
apt update
apt install -y php8.2-fpm php8.2-cli php8.2-common php8.2-mysql \
  php8.2-zip php8.2-gd php8.2-mbstring php8.2-curl php8.2-xml \
  php8.2-bcmath php8.2-intl php8.2-readline
systemctl start php8.2-fpm
systemctl enable php8.2-fpm
echo "✅ PHP 8.2 installed"

echo "🗄️  Step 6: Install MySQL"
export DEBIAN_FRONTEND=noninteractive
apt install -y mysql-server
systemctl start mysql
systemctl enable mysql
echo "✅ MySQL installed"

echo "🎼 Step 7: Install Composer"
curl -sS https://getcomposer.org/installer -o composer-setup.php
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm composer-setup.php
echo "✅ Composer installed"

echo "📗 Step 8: Install Node.js 20"
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs
npm install -g pm2
echo "✅ Node.js and PM2 installed"

echo "🔐 Step 9: Setup MySQL Database"
mysql -e "CREATE DATABASE IF NOT EXISTS fitness_lms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "CREATE USER IF NOT EXISTS 'brieflylearn'@'localhost' IDENTIFIED BY 'BrieflyDB2025!Strong';"
mysql -e "GRANT ALL PRIVILEGES ON fitness_lms.* TO 'brieflylearn'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"
echo "✅ Database created"

echo "🔑 Step 10: Generate SSH Key for GitHub"
if [ ! -f ~/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -C "deploy@brieflylearn.com" -f ~/.ssh/id_ed25519 -N ""
fi
echo ""
echo "=========================================="
echo "📝 IMPORTANT: Add this SSH key to GitHub"
echo "=========================================="
cat ~/.ssh/id_ed25519.pub
echo "=========================================="
echo ""
echo "Add this key to BOTH repositories:"
echo "1. https://github.com/PanapatWonganan/brieflylearn-backend/settings/keys"
echo "2. https://github.com/PanapatWonganan/brieflylearn-frontend/settings/keys"
echo ""
read -p "Press Enter after adding SSH keys to GitHub..."

echo "📂 Step 11: Create Project Directory"
mkdir -p /var/www/brieflylearn
cd /var/www/brieflylearn

echo "📥 Step 12: Clone Backend Repository"
ssh-keyscan github.com >> ~/.ssh/known_hosts
git clone git@github.com:PanapatWonganan/brieflylearn-backend.git backend
cd backend

echo "📦 Step 13: Install Backend Dependencies"
composer install --optimize-autoloader --no-dev

echo "⚙️  Step 14: Configure Backend Environment"
cp .env.example .env
cat > .env << 'ENV'
APP_NAME="BrieflyLearn"
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=http://207.148.76.203

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=fitness_lms
DB_USERNAME=brieflylearn
DB_PASSWORD=BrieflyDB2025!Strong

SESSION_DRIVER=file
SESSION_LIFETIME=120
ENV

php artisan key:generate

echo "🔒 Step 15: Set Permissions"
chown -R www-data:www-data /var/www/brieflylearn/backend
chmod -R 755 /var/www/brieflylearn/backend
chmod -R 775 /var/www/brieflylearn/backend/storage
chmod -R 775 /var/www/brieflylearn/backend/bootstrap/cache

echo "🗃️  Step 16: Run Migrations and Seeders"
php artisan migrate --force
php artisan db:seed --force

echo "⚡ Step 17: Cache Configuration"
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "📥 Step 18: Clone Frontend Repository"
cd /var/www/brieflylearn
git clone git@github.com:PanapatWonganan/brieflylearn-frontend.git frontend
cd frontend

echo "📦 Step 19: Install Frontend Dependencies"
npm ci --production=false

echo "⚙️  Step 20: Configure Frontend Environment"
cat > .env.production << 'ENV'
NEXT_PUBLIC_API_URL=http://207.148.76.203/api/v1
NEXT_PUBLIC_APP_NAME=BrieflyLearn
NEXT_PUBLIC_APP_URL=http://207.148.76.203
NODE_ENV=production
ENV

echo "🏗️  Step 21: Build Frontend"
npm run build

echo "🚀 Step 22: Setup PM2"
cat > ecosystem.config.js << 'PM2'
module.exports = {
  apps: [{
    name: 'brieflylearn-frontend',
    script: 'npm',
    args: 'start',
    cwd: '/var/www/brieflylearn/frontend',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    }
  }]
}
PM2

pm2 start ecosystem.config.js
pm2 save
pm2 startup systemd -u root --hp /root | tail -n 1 | bash

echo "🌐 Step 23: Configure Nginx"
cat > /etc/nginx/sites-available/brieflylearn << 'NGINX'
# Backend API & Admin
server {
    listen 80 default_server;
    server_name 207.148.76.203;
    root /var/www/brieflylearn/backend/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;
    charset utf-8;

    # API routes
    location /api {
        try_files $uri $uri/ /index.php?$query_string;
    }

    # Admin routes
    location /admin {
        try_files $uri $uri/ /index.php?$query_string;
    }

    # Root serves Laravel welcome
    location = / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }

    # Proxy all other requests to Next.js
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
NGINX

ln -sf /etc/nginx/sites-available/brieflylearn /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl reload nginx

echo ""
echo "🎉 =========================================="
echo "🎉 DEPLOYMENT COMPLETED SUCCESSFULLY!"
echo "🎉 =========================================="
echo ""
echo "✅ Backend API: http://207.148.76.203/api/v1/courses"
echo "✅ Admin Panel: http://207.148.76.203/admin"
echo "✅ Frontend: http://207.148.76.203"
echo ""
echo "🔑 Admin Login:"
echo "   Email: admin@brieflylearn.com"
echo "   Password: admin123"
echo ""
echo "📊 Check Services:"
echo "   pm2 status"
echo "   systemctl status nginx"
echo "   systemctl status php8.2-fpm"
echo "   systemctl status mysql"
echo ""
DEPLOY_SCRIPT

chmod +x /tmp/deploy-server.sh

echo "📤 Uploading deployment script to server..."
sshpass -p '2(hVW],PciL[,Z2?' scp -o StrictHostKeyChecking=no /tmp/deploy-server.sh root@207.148.76.203:/root/

echo "🚀 Running deployment on server..."
sshpass -p '2(hVW],PciL[,Z2?' ssh -o StrictHostKeyChecking=no root@207.148.76.203 'bash /root/deploy-server.sh'

echo ""
echo "✅ Deployment script completed!"
