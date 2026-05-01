# 🚀 Vultr Single Host Deployment - BrieflyLearn

**Server IP**: `207.148.76.203`
**Architecture**: Backend (Laravel) + Frontend (Next.js) บน Vultr host เดียวกัน
**Web Server**: Nginx (Reverse Proxy สำหรับ Next.js + Laravel)

---

## 📋 การวางโครงสร้าง (Architecture)

```
Vultr Server (207.148.76.203)
├── Nginx (Port 80/443)
│   ├── antiparallel.app → Next.js (Port 3000)
│   ├── api.antiparallel.app → Laravel Public (Port 8001)
│   └── api.antiparallel.app → Laravel API (Port 8001)
│
├── Laravel Backend (Port 8001)
│   └── /var/www/brieflylearn/backend
│
├── Next.js Frontend (Port 3000)
│   └── /var/www/brieflylearn/frontend
│
└── MySQL (Port 3306)
    └── fitness_lms database
```

---

## 🎯 Part 1: สร้าง GitHub Repositories

### Step 1.1: สร้าง Repositories บน GitHub

ไปที่ https://github.com/new และสร้าง 2 repositories:

**Repository 1: Backend**
- Repository name: `brieflylearn-backend`
- Description: `BrieflyLearn LMS - Laravel Backend API`
- Visibility: Private (แนะนำ) หรือ Public
- **ไม่ต้อง** initialize with README, .gitignore, license

**Repository 2: Frontend**
- Repository name: `brieflylearn-frontend`
- Description: `BrieflyLearn LMS - Next.js Frontend`
- Visibility: Private (แนะนำ) หรือ Public
- **ไม่ต้อง** initialize with README, .gitignore, license

---

### Step 1.2: Initialize Git และ Push Code

**สำหรับ Backend (Laravel):**

```bash
cd /Users/panapat/brieflylearn/fitness-lms-admin

# Initialize git
git init

# Create .gitignore
cat > .gitignore << 'EOF'
/node_modules
/public/hot
/public/storage
/storage/*.key
/vendor
.env
.env.backup
.phpunit.result.cache
Homestead.json
Homestead.yaml
npm-debug.log
yarn-error.log
/.idea
/.vscode
.DS_Store
EOF

# Add all files
git add .

# Initial commit
git commit -m "Initial commit - BrieflyLearn Laravel Backend"

# Add remote (แทนที่ YOUR_USERNAME ด้วย GitHub username ของคุณ)
git remote add origin https://github.com/YOUR_USERNAME/brieflylearn-backend.git

# Push to main branch
git branch -M main
git push -u origin main
```

**สำหรับ Frontend (Next.js):**

```bash
cd /Users/panapat/brieflylearn/fitness-lms

# Initialize git
git init

# .gitignore should already exist, but verify it has these:
cat > .gitignore << 'EOF'
# dependencies
/node_modules
/.pnp
.pnp.js

# testing
/coverage

# next.js
/.next/
/out/

# production
/build

# misc
.DS_Store
*.pem

# debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# local env files
.env*.local
.env.production

# vercel
.vercel

# typescript
*.tsbuildinfo
next-env.d.ts

# IDE
/.idea
/.vscode
EOF

# Add all files
git add .

# Initial commit
git commit -m "Initial commit - BrieflyLearn Next.js Frontend"

# Add remote (แทนที่ YOUR_USERNAME ด้วย GitHub username ของคุณ)
git remote add origin https://github.com/YOUR_USERNAME/brieflylearn-frontend.git

# Push to main branch
git branch -M main
git push -u origin main
```

**GitHub Credentials:**
- จะถูกถามให้ใส่ username และ password
- สำหรับ password ให้ใช้ **Personal Access Token** แทน (ไม่ใช่รหัส GitHub)
- สร้าง Token ที่: https://github.com/settings/tokens
  - Click "Generate new token (classic)"
  - Select scopes: `repo` (ทั้งหมด)
  - Generate และ copy token
  - ใช้ token นี้แทน password

---

## 🔧 Part 2: Server Setup

### Step 2.1: SSH เข้าสู่ Vultr Server

```bash
ssh root@207.148.76.203
```

---

### Step 2.2: Update System & Install Basic Tools

```bash
# Update packages
apt update && apt upgrade -y

# Install basic tools
apt install -y curl wget git unzip software-properties-common ufw vim
```

---

### Step 2.3: Setup Firewall

```bash
# Enable UFW
ufw --force enable

# Allow SSH (IMPORTANT!)
ufw allow 22/tcp

# Allow HTTP and HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# Check status
ufw status verbose
```

---

## 🛠️ Part 3: Install Software Stack

### Step 3.1: Install Nginx

```bash
apt install -y nginx
systemctl start nginx
systemctl enable nginx
```

---

### Step 3.2: Install PHP 8.2

```bash
# Add PHP repository
add-apt-repository -y ppa:ondrej/php
apt update

# Install PHP 8.2 and extensions
apt install -y php8.2-fpm php8.2-cli php8.2-common php8.2-mysql \
  php8.2-zip php8.2-gd php8.2-mbstring php8.2-curl php8.2-xml \
  php8.2-bcmath php8.2-intl php8.2-readline

# Verify
php -v

# Start PHP-FPM
systemctl start php8.2-fpm
systemctl enable php8.2-fpm
```

---

### Step 3.3: Install MySQL 8.0

```bash
# Install MySQL
apt install -y mysql-server

# Start MySQL
systemctl start mysql
systemctl enable mysql

# Secure installation
mysql_secure_installation
```

**During setup:**
- Set root password: `[STRONG_PASSWORD]` ⚠️ **บันทึกไว้!**
- Remove anonymous users: `Y`
- Disallow root login remotely: `Y`
- Remove test database: `Y`
- Reload privilege tables: `Y`

**Create Database:**

```bash
mysql -u root -p

# Inside MySQL:
CREATE DATABASE fitness_lms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'brieflylearn'@'localhost' IDENTIFIED BY 'BrieflyLearn2025!Strong';
GRANT ALL PRIVILEGES ON fitness_lms.* TO 'brieflylearn'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

⚠️ **บันทึกข้อมูล Database:**
- Database: `fitness_lms`
- Username: `brieflylearn`
- Password: `BrieflyLearn2025!Strong`

---

### Step 3.4: Install Composer

```bash
curl -sS https://getcomposer.org/installer -o composer-setup.php
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm composer-setup.php
composer --version
```

---

### Step 3.5: Install Node.js 20.x

```bash
# Install Node.js LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

# Verify
node -v
npm -v

# Install PM2 (Process Manager for Next.js)
npm install -g pm2
```

---

## 📦 Part 4: Deploy Backend (Laravel)

### Step 4.1: Create Project Directory

```bash
mkdir -p /var/www/brieflylearn
cd /var/www/brieflylearn
```

---

### Step 4.2: Setup SSH Key for Git

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "server@antiparallel.app"
# Press Enter 3 times (default location, no passphrase)

# Show public key
cat ~/.ssh/id_ed25519.pub
```

**Copy this key และเพิ่มใน GitHub:**
1. ไปที่ https://github.com/YOUR_USERNAME/brieflylearn-backend/settings/keys
2. Click "Add deploy key"
3. Title: `Vultr Production Server`
4. Key: Paste จาก `cat ~/.ssh/id_ed25519.pub`
5. **Check** "Allow write access" (ถ้าต้องการ auto-deploy)
6. Click "Add key"

**ทำซ้ำสำหรับ Frontend repository:**
- https://github.com/YOUR_USERNAME/brieflylearn-frontend/settings/keys
- ใช้ SSH key เดียวกัน

---

### Step 4.3: Clone Backend Repository

```bash
cd /var/www/brieflylearn

# Clone backend (แทนที่ YOUR_USERNAME)
git clone git@github.com:YOUR_USERNAME/brieflylearn-backend.git backend

# If first time using SSH from server:
# Type "yes" when asked about authenticity

cd backend
```

---

### Step 4.4: Install Backend Dependencies

```bash
cd /var/www/brieflylearn/backend

# Install Composer dependencies
composer install --optimize-autoloader --no-dev

# Set permissions
chown -R www-data:www-data /var/www/brieflylearn/backend
chmod -R 755 /var/www/brieflylearn/backend
chmod -R 775 /var/www/brieflylearn/backend/storage
chmod -R 775 /var/www/brieflylearn/backend/bootstrap/cache
```

---

### Step 4.5: Configure Backend Environment

```bash
cd /var/www/brieflylearn/backend

# Copy .env
cp .env.example .env

# Edit .env
nano .env
```

**Update these values:**

```env
APP_NAME="BrieflyLearn"
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://api.antiparallel.app

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=fitness_lms
DB_USERNAME=brieflylearn
DB_PASSWORD=BrieflyLearn2025!Strong

SESSION_DRIVER=file
SESSION_LIFETIME=120

# CORS - Allow frontend domain
SANCTUM_STATEFUL_DOMAINS=antiparallel.app,www.antiparallel.app
SESSION_DOMAIN=.antiparallel.app
```

**Save:** `Ctrl+X`, `Y`, `Enter`

---

### Step 4.6: Generate Key & Run Migrations

```bash
cd /var/www/brieflylearn/backend

# Generate app key
php artisan key:generate

# Cache config
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Run migrations
php artisan migrate --force

# Run seeders
php artisan db:seed --force
```

---

## 🎨 Part 5: Deploy Frontend (Next.js)

### Step 5.1: Clone Frontend Repository

```bash
cd /var/www/brieflylearn

# Clone frontend (แทนที่ YOUR_USERNAME)
git clone git@github.com:YOUR_USERNAME/brieflylearn-frontend.git frontend

cd frontend
```

---

### Step 5.2: Configure Frontend Environment

```bash
cd /var/www/brieflylearn/frontend

# Create production environment file
nano .env.production
```

**Add these values:**

```env
NEXT_PUBLIC_API_URL=https://api.antiparallel.app/api/v1
NEXT_PUBLIC_APP_NAME=BrieflyLearn
NEXT_PUBLIC_APP_URL=https://antiparallel.app
NODE_ENV=production
```

**Save:** `Ctrl+X`, `Y`, `Enter`

---

### Step 5.3: Install Frontend Dependencies & Build

```bash
cd /var/www/brieflylearn/frontend

# Install dependencies
npm ci --production=false

# Build for production
npm run build

# Test production build locally
npm run start
# Press Ctrl+C to stop after verifying it works
```

---

### Step 5.4: Setup PM2 for Process Management

```bash
cd /var/www/brieflylearn/frontend

# Create PM2 ecosystem file
cat > ecosystem.config.js << 'EOF'
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
EOF

# Start with PM2
pm2 start ecosystem.config.js

# Save PM2 configuration
pm2 save

# Setup PM2 to start on boot
pm2 startup systemd
# Copy and run the command it shows you

# Check status
pm2 status
pm2 logs brieflylearn-frontend --lines 50
```

---

## 🌐 Part 6: Configure Nginx

### Step 6.1: Create Nginx Configuration

```bash
nano /etc/nginx/sites-available/brieflylearn
```

**Paste this configuration:**

```nginx
# Backend API & Admin
server {
    listen 80;
    server_name api.antiparallel.app api.antiparallel.app;
    root /var/www/brieflylearn/backend/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;
    charset utf-8;

    # API and Admin routes
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
        fastcgi_hide_header X-Powered-By;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}

# Frontend (Next.js)
server {
    listen 80;
    server_name antiparallel.app www.antiparallel.app;

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

    # Next.js static files
    location /_next/static {
        proxy_pass http://localhost:3000;
        proxy_cache_valid 200 60m;
        add_header Cache-Control "public, immutable";
    }
}

# Redirect www to non-www
server {
    listen 80;
    server_name www.antiparallel.app;
    return 301 https://antiparallel.app$request_uri;
}
```

**Save:** `Ctrl+X`, `Y`, `Enter`

---

### Step 6.2: Enable Site & Test

```bash
# Enable site
ln -s /etc/nginx/sites-available/brieflylearn /etc/nginx/sites-enabled/

# Remove default
rm -f /etc/nginx/sites-enabled/default

# Test configuration
nginx -t

# Reload Nginx
systemctl reload nginx
```

---

## 🔐 Part 7: SSL Certificates (Let's Encrypt)

### Step 7.1: Install Certbot

```bash
apt install -y certbot python3-certbot-nginx
```

---

### Step 7.2: Update DNS Records

⚠️ **IMPORTANT:** ก่อนขอ SSL ต้องตั้งค่า DNS Records ให้ชี้ไปที่ `207.148.76.203`

**ใน DNS Management (ของผู้ให้บริการ domain):**

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | @ | 207.148.76.203 | 3600 |
| A | www | 207.148.76.203 | 3600 |
| A | admin | 207.148.76.203 | 3600 |
| A | api | 207.148.76.203 | 3600 |

**รอ DNS propagate:** ประมาณ 5-30 นาที

**ตรวจสอบ DNS:**
```bash
# บนเครื่อง local
dig antiparallel.app
dig api.antiparallel.app
dig api.antiparallel.app
```

---

### Step 7.3: Obtain SSL Certificates

```bash
# Request certificates for all domains
certbot --nginx -d antiparallel.app -d www.antiparallel.app -d api.antiparallel.app -d api.antiparallel.app

# Follow prompts:
# - Enter email: your-email@example.com
# - Agree to terms: Y
# - Share email with EFF: N (optional)
# - Redirect HTTP to HTTPS: 2 (Yes, redirect)
```

---

### Step 7.4: Test Auto-Renewal

```bash
certbot renew --dry-run
```

**Expected:** `Congratulations, all simulated renewals succeeded`

---

## ✅ Part 8: Verification & Testing

### Step 8.1: Check Services Status

```bash
# Check Nginx
systemctl status nginx

# Check PHP-FPM
systemctl status php8.2-fpm

# Check MySQL
systemctl status mysql

# Check PM2
pm2 status

# Check PM2 logs
pm2 logs brieflylearn-frontend --lines 50
```

---

### Step 8.2: Test Backend API

```bash
# Test courses API
curl https://api.antiparallel.app/api/v1/courses

# Should return JSON with courses data
```

**Browser Test:**
- https://api.antiparallel.app → ควรเห็นหน้า welcome
- https://api.antiparallel.app/admin → ควรเห็น Filament login
- https://api.antiparallel.app/api/v1/courses → ควรได้ JSON data

---

### Step 8.3: Test Frontend

**Browser Test:**
- https://antiparallel.app → ควรเห็นหน้าแรก
- https://antiparallel.app/courses → ควรเห็น courses จาก API
- https://antiparallel.app/garden → ควรเห็น garden feature

---

### Step 8.4: Test Admin Login

1. ไปที่ https://api.antiparallel.app/admin
2. Login:
   - Email: `admin@antiparallel.app`
   - Password: `admin123`
3. ควรเข้าสู่ Filament dashboard ได้

⚠️ **เปลี่ยนรหัสผ่านทันทีหลัง login ครั้งแรก!**

---

## 🔄 Part 9: Deployment Scripts (สำหรับ Update ในอนาคต)

### Step 9.1: Create Update Script for Backend

```bash
nano /root/update-backend.sh
```

**Paste:**

```bash
#!/bin/bash
set -e

echo "🔄 Updating Backend..."

cd /var/www/brieflylearn/backend

# Pull latest code
git pull origin main

# Install dependencies
composer install --optimize-autoloader --no-dev

# Run migrations
php artisan migrate --force

# Clear and cache
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Set permissions
chown -R www-data:www-data /var/www/brieflylearn/backend
chmod -R 775 storage bootstrap/cache

echo "✅ Backend updated successfully!"
```

**Make executable:**
```bash
chmod +x /root/update-backend.sh
```

---

### Step 9.2: Create Update Script for Frontend

```bash
nano /root/update-frontend.sh
```

**Paste:**

```bash
#!/bin/bash
set -e

echo "🔄 Updating Frontend..."

cd /var/www/brieflylearn/frontend

# Pull latest code
git pull origin main

# Install dependencies
npm ci --production=false

# Build
npm run build

# Restart PM2
pm2 restart brieflylearn-frontend

# Wait for startup
sleep 5

# Check status
pm2 status

echo "✅ Frontend updated successfully!"
```

**Make executable:**
```bash
chmod +x /root/update-frontend.sh
```

---

### Step 9.3: Usage

```bash
# Update backend
/root/update-backend.sh

# Update frontend
/root/update-frontend.sh
```

---

## 🔧 Part 10: Troubleshooting

### Issue 1: Next.js ไม่ทำงาน

```bash
# Check PM2 logs
pm2 logs brieflylearn-frontend

# Restart PM2
pm2 restart brieflylearn-frontend

# Check if port 3000 is in use
netstat -tulpn | grep 3000
```

---

### Issue 2: Laravel 500 Error

```bash
# Check Laravel logs
tail -f /var/www/brieflylearn/backend/storage/logs/laravel.log

# Check Nginx error logs
tail -f /var/log/nginx/error.log

# Check permissions
ls -la /var/www/brieflylearn/backend/storage
```

---

### Issue 3: Database Connection Error

```bash
# Test database connection
mysql -u brieflylearn -p fitness_lms

# Check .env file
cat /var/www/brieflylearn/backend/.env | grep DB_
```

---

### Issue 4: SSL Certificate Issues

```bash
# Check certificate status
certbot certificates

# Renew certificates
certbot renew

# Test Nginx config
nginx -t
```

---

## 📊 Part 11: Monitoring & Maintenance

### Daily Tasks

```bash
# Check PM2 status
pm2 status

# Check disk space
df -h

# Check memory usage
free -m

# Check logs for errors
pm2 logs brieflylearn-frontend --lines 100 --err
```

---

### Weekly Tasks

```bash
# Update system packages
apt update && apt upgrade -y

# Check SSL expiration
certbot certificates

# Backup database
mysqldump -u brieflylearn -p fitness_lms > backup_$(date +%Y%m%d).sql
```

---

### Setup Automatic Backups

```bash
# Create backup script
nano /root/backup-database.sh
```

**Paste:**

```bash
#!/bin/bash
BACKUP_DIR="/root/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup database
mysqldump -u brieflylearn -pBrieflyLearn2025!Strong fitness_lms > $BACKUP_DIR/fitness_lms_$DATE.sql

# Compress
gzip $BACKUP_DIR/fitness_lms_$DATE.sql

# Keep only last 7 days
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete

echo "Backup completed: fitness_lms_$DATE.sql.gz"
```

**Make executable:**
```bash
chmod +x /root/backup-database.sh
```

**Setup cron:**
```bash
crontab -e

# Add this line (daily backup at 2 AM):
0 2 * * * /root/backup-database.sh >> /var/log/backup.log 2>&1
```

---

## 🎉 Final Checklist

- [ ] GitHub repositories created and code pushed
- [ ] Server updated and software installed
- [ ] Firewall configured
- [ ] Backend cloned and configured
- [ ] Frontend cloned and built
- [ ] PM2 running Next.js
- [ ] Nginx configured for all domains
- [ ] DNS records pointing to server
- [ ] SSL certificates installed
- [ ] Backend accessible at https://api.antiparallel.app
- [ ] API accessible at https://api.antiparallel.app/api/v1/courses
- [ ] Frontend accessible at https://antiparallel.app
- [ ] Admin panel login working
- [ ] Update scripts created
- [ ] Backup script setup

---

## 🚀 Quick Deployment Commands Summary

```bash
# On Local Machine - Push code
cd /Users/panapat/brieflylearn/fitness-lms-admin
git init && git add . && git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/brieflylearn-backend.git
git push -u origin main

cd /Users/panapat/brieflylearn/fitness-lms
git init && git add . && git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/brieflylearn-frontend.git
git push -u origin main

# On Server - Deploy
ssh root@207.148.76.203
apt update && apt upgrade -y
apt install -y nginx php8.2-fpm mysql-server nodejs npm git
npm install -g pm2
git clone git@github.com:YOUR_USERNAME/brieflylearn-backend.git /var/www/brieflylearn/backend
git clone git@github.com:YOUR_USERNAME/brieflylearn-frontend.git /var/www/brieflylearn/frontend
cd /var/www/brieflylearn/backend && composer install && php artisan key:generate && php artisan migrate --force
cd /var/www/brieflylearn/frontend && npm ci && npm run build && pm2 start npm --name brieflylearn-frontend -- start
```

---

**คู่มือนี้ครอบคลุมทุกขั้นตอนตั้งแต่เริ่มต้นจนถึงการ deploy สมบูรณ์!** 🎯
