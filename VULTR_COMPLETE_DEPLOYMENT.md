# 🚀 BrieflyLearn - Complete Vultr Deployment Guide

**Server IP**: `207.148.76.203`
**Frontend**: `brieflylearn.com`
**Backend API**: `api.brieflylearn.com` (optional subdomain)

---

## 📋 Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                    Cloudflare                        │
│            (SSL + CDN + DDoS Protection)            │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│              Nginx (Reverse Proxy)                   │
│  Port 80/443 → Frontend & Backend                   │
└────────┬─────────────────────────┬──────────────────┘
         │                         │
         ▼                         ▼
┌──────────────────┐      ┌──────────────────┐
│   Next.js        │      │   Laravel API     │
│   Frontend       │◄────►│   + Admin Panel   │
│   Port 3000      │      │   Port 8000       │
└──────────────────┘      └────────┬──────────┘
                                   │
                                   ▼
                          ┌──────────────────┐
                          │   MySQL DB       │
                          │   Port 3306      │
                          └──────────────────┘
```

---

## 🔧 Step 1: Fresh Server Setup

### 1.1 SSH into Server

```bash
ssh root@207.148.76.203
```

### 1.2 Update System

```bash
apt update && apt upgrade -y
```

### 1.3 Install Required Software

```bash
# Install essential tools
apt install -y curl git unzip nginx certbot python3-certbot-nginx

# Install PHP 8.2 and extensions
apt install -y software-properties-common
add-apt-repository ppa:ondrej/php -y
apt update
apt install -y php8.2 php8.2-cli php8.2-fpm php8.2-mysql php8.2-xml php8.2-mbstring \
  php8.2-curl php8.2-zip php8.2-gd php8.2-intl php8.2-bcmath php8.2-soap

# Install Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer

# Install MySQL
apt install -y mysql-server

# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

# Verify installations
php -v
composer -V
mysql --version
node -v
npm -v
```

---

## 🗄️ Step 2: Setup MySQL Database

### 2.1 Secure MySQL Installation

```bash
mysql_secure_installation
```

**Answer prompts:**
- Set root password: `brieflylearn_root_2024`
- Remove anonymous users: `Y`
- Disallow root login remotely: `Y`
- Remove test database: `Y`
- Reload privilege tables: `Y`

### 2.2 Create Database and User

```bash
mysql -u root -p
```

**Run these SQL commands:**

```sql
CREATE DATABASE brieflylearn CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER 'brieflyuser'@'localhost' IDENTIFIED BY 'brieflypass_2024';

GRANT ALL PRIVILEGES ON brieflylearn.* TO 'brieflyuser'@'localhost';

FLUSH PRIVILEGES;

EXIT;
```

### 2.3 Import Database

```bash
# Download database backup from GitHub
cd /tmp
wget https://raw.githubusercontent.com/PanapatWonganan/brieflylearn/main/database_backup.sql

# Import
mysql -u brieflyuser -p brieflylearn < /tmp/database_backup.sql

# Verify
mysql -u brieflyuser -p brieflylearn -e "SHOW TABLES;"
```

---

## 🔥 Step 3: Deploy Laravel Backend

### 3.1 Clone Backend Repository

```bash
mkdir -p /var/www
cd /var/www

# Clone backend
git clone https://github.com/PanapatWonganan/brieflylearn.git brieflylearn-repo
cp -r brieflylearn-repo/fitness-lms-admin /var/www/backend
rm -rf brieflylearn-repo

cd /var/www/backend
```

### 3.2 Install Dependencies

```bash
composer install --optimize-autoloader --no-dev
```

### 3.3 Configure Environment

```bash
cp .env.example .env
nano .env
```

**Edit `.env` file:**

```env
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
```

**Generate APP_KEY:**

```bash
php artisan key:generate
```

### 3.4 Setup Storage and Permissions

```bash
php artisan storage:link

chown -R www-data:www-data /var/www/backend
chmod -R 755 /var/www/backend
chmod -R 775 /var/www/backend/storage
chmod -R 775 /var/www/backend/bootstrap/cache
```

### 3.5 Run Migrations (if needed)

```bash
php artisan migrate --force
```

### 3.6 Cache Configuration

```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### 3.7 Create Systemd Service

```bash
cat > /etc/systemd/system/laravel-backend.service << 'EOF'
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
EOF
```

**Start service:**

```bash
systemctl daemon-reload
systemctl enable laravel-backend
systemctl start laravel-backend
systemctl status laravel-backend
```

**Test API:**

```bash
curl http://localhost:8000/api/v1/health
```

---

## ⚛️ Step 4: Deploy Next.js Frontend

### 4.1 Clone Frontend

```bash
cd /var/www
git clone https://github.com/PanapatWonganan/brieflylms.git frontend
cd frontend
```

### 4.2 Configure Environment

```bash
cat > .env.local << 'EOF'
# API Backend
NEXT_PUBLIC_API_URL=https://api.brieflylearn.com
NEXT_PUBLIC_APP_URL=https://brieflylearn.com

# App Settings
NODE_ENV=production
PORT=3000
EOF
```

### 4.3 Install and Build

```bash
npm install
npm run build
```

### 4.4 Create Systemd Service

```bash
cat > /etc/systemd/system/nextjs-frontend.service << 'EOF'
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
EOF
```

**Start service:**

```bash
chown -R www-data:www-data /var/www/frontend

systemctl daemon-reload
systemctl enable nextjs-frontend
systemctl start nextjs-frontend
systemctl status nextjs-frontend
```

**Test:**

```bash
curl http://localhost:3000
```

---

## 🌐 Step 5: Configure Nginx

### 5.1 Create Backend Config

```bash
cat > /etc/nginx/sites-available/backend << 'EOF'
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
EOF
```

### 5.2 Create Frontend Config

```bash
cat > /etc/nginx/sites-available/frontend << 'EOF'
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
EOF
```

### 5.3 Enable Sites

```bash
ln -s /etc/nginx/sites-available/backend /etc/nginx/sites-enabled/
ln -s /etc/nginx/sites-available/frontend /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

nginx -t
systemctl restart nginx
```

---

## 🔒 Step 6: Setup SSL with Certbot

### 6.1 Configure Cloudflare DNS First

**Go to Cloudflare Dashboard:**

1. Add A Record: `brieflylearn.com` → `207.148.76.203` (Proxied 🟠)
2. Add A Record: `www.brieflylearn.com` → `207.148.76.203` (Proxied 🟠)
3. Add A Record: `api.brieflylearn.com` → `207.148.76.203` (Proxied 🟠)

### 6.2 Set Cloudflare SSL Mode

**SSL/TLS → Overview:**
- Set to **Flexible** (easiest) or **Full** (if you install SSL on server)

### 6.3 Install SSL Certificates (Optional if using Cloudflare)

```bash
# For brieflylearn.com
certbot --nginx -d brieflylearn.com -d www.brieflylearn.com

# For api.brieflylearn.com
certbot --nginx -d api.brieflylearn.com
```

---

## 🔥 Step 7: Configure Firewall

```bash
ufw allow 22
ufw allow 80
ufw allow 443
ufw enable
ufw status
```

---

## ✅ Step 8: Verify Deployment

### 8.1 Check Services

```bash
systemctl status laravel-backend
systemctl status nextjs-frontend
systemctl status nginx
systemctl status mysql
```

### 8.2 Check Logs

```bash
# Laravel logs
tail -f /var/www/backend/storage/logs/laravel.log

# Nginx logs
tail -f /var/log/nginx/error.log

# Systemd logs
journalctl -u laravel-backend -f
journalctl -u nextjs-frontend -f
```

### 8.3 Test URLs

```bash
curl http://localhost:8000/api/v1/health
curl http://localhost:3000
```

### 8.4 Test in Browser

- Frontend: https://brieflylearn.com
- Backend API: https://api.brieflylearn.com/api/v1/health
- Admin Panel: https://api.brieflylearn.com/admin

---

## 🛠️ Maintenance Commands

### Restart Services

```bash
systemctl restart laravel-backend
systemctl restart nextjs-frontend
systemctl restart nginx
```

### Update Code

```bash
# Backend
cd /var/www/backend
git pull
composer install --no-dev
php artisan migrate --force
php artisan config:cache
systemctl restart laravel-backend

# Frontend
cd /var/www/frontend
git pull
npm install
npm run build
systemctl restart nextjs-frontend
```

### View Logs

```bash
# Laravel
tail -f /var/www/backend/storage/logs/laravel.log

# Next.js
journalctl -u nextjs-frontend -f

# Nginx
tail -f /var/log/nginx/error.log
```

---

## 🆘 Troubleshooting

### Laravel API Not Working

```bash
# Check service
systemctl status laravel-backend

# Check PHP-FPM
systemctl status php8.2-fpm

# Check permissions
chown -R www-data:www-data /var/www/backend
chmod -R 775 /var/www/backend/storage

# Clear cache
cd /var/www/backend
php artisan config:clear
php artisan cache:clear
```

### Frontend Not Loading

```bash
# Check service
systemctl status nextjs-frontend

# Rebuild
cd /var/www/frontend
npm run build
systemctl restart nextjs-frontend
```

### Database Connection Issues

```bash
# Test connection
mysql -u brieflyuser -p brieflylearn

# Check Laravel config
cd /var/www/backend
cat .env | grep DB_
```

---

## 📝 Quick Reference

| Service | Port | Status Command |
|---------|------|----------------|
| Laravel API | 8000 | `systemctl status laravel-backend` |
| Next.js | 3000 | `systemctl status nextjs-frontend` |
| MySQL | 3306 | `systemctl status mysql` |
| Nginx | 80/443 | `systemctl status nginx` |
| PHP-FPM | socket | `systemctl status php8.2-fpm` |

---

**🎉 Deployment Complete!**

Your application should now be accessible at:
- **Frontend**: https://brieflylearn.com
- **API**: https://api.brieflylearn.com
- **Admin**: https://api.brieflylearn.com/admin
