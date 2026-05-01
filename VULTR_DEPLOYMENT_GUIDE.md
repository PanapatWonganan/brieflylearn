# 🚀 BrieflyLearn Deployment Guide - Vultr Ubuntu

## 📌 ภาพรวม

**Domain**: antiparallel.app
**Server**: Vultr Ubuntu 22.04 LTS
**Architecture**:
- Frontend (Next.js) → Vercel or Vultr
- Backend (Laravel) → Vultr Ubuntu
- Database → MySQL on Vultr
- Version Control → Git

---

## 🎯 สถาปัตยกรรมระบบ

```
antiparallel.app (Vercel/Vultr)
    ↓
    API Calls
    ↓
api.antiparallel.app (Vultr Ubuntu)
    ├── Laravel Backend (Port 8000)
    ├── Admin Panel (Filament)
    └── MySQL Database (Port 3306)
```

---

## 📋 ขั้นตอนที่ 1: เตรียม Git Repository

### 1.1 สร้าง GitHub/GitLab Repository

```bash
# สร้าง 2 repositories:
# 1. brieflylearn-frontend (Next.js)
# 2. brieflylearn-backend (Laravel)
```

### 1.2 เตรียม Backend Repository

```bash
cd /Users/panapat/brieflylearn/fitness-lms-admin

# Initialize git (ถ้ายังไม่ได้ทำ)
git init

# สร้าง .gitignore
cat > .gitignore << 'EOF'
/node_modules
/public/build
/public/hot
/public/storage
/storage/*.key
/vendor
.env
.env.backup
.env.production
.phpunit.result.cache
Homestead.json
Homestead.yaml
auth.json
npm-debug.log
yarn-error.log
/.fleet
/.idea
/.vscode
*.log
EOF

# Add และ commit
git add .
git commit -m "Initial commit: BrieflyLearn Backend"

# เชื่อมต่อกับ remote repository
git remote add origin https://github.com/YOUR_USERNAME/brieflylearn-backend.git
git branch -M main
git push -u origin main
```

### 1.3 เตรียม Frontend Repository

```bash
cd /Users/panapat/brieflylearn/fitness-lms

# Initialize git (ถ้ายังไม่ได้ทำ)
git init

# สร้าง .gitignore
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
EOF

# Add และ commit
git add .
git commit -m "Initial commit: BrieflyLearn Frontend"

# เชื่อมต่อกับ remote repository
git remote add origin https://github.com/YOUR_USERNAME/brieflylearn-frontend.git
git branch -M main
git push -u origin main
```

---

## 📋 ขั้นตอนที่ 2: เตรียม Vultr Server

### 2.1 สร้าง Vultr Instance

1. Login เข้า Vultr Dashboard
2. คลิก "Deploy New Server"
3. เลือก:
   - **Server Type**: Cloud Compute - Shared CPU
   - **Location**: Singapore (ใกล้ไทยที่สุด)
   - **OS**: Ubuntu 22.04 LTS x64
   - **Plan**: อย่างน้อย 2GB RAM, 1 vCPU ($12/month)
   - **Hostname**: brieflylearn-api

4. เปิดใช้งาน SSH Keys (แนะนำ) หรือใช้ Password

### 2.2 เชื่อมต่อกับ Server

```bash
# จาก Local Machine
ssh root@YOUR_VULTR_IP

# ตัวอย่าง:
# ssh root@45.76.123.45
```

---

## 📋 ขั้นตอนที่ 3: ติดตั้งซอฟต์แวร์บน Ubuntu

### 3.1 อัพเดต System

```bash
apt update && apt upgrade -y
```

### 3.2 ติดตั้ง Nginx

```bash
apt install nginx -y
systemctl start nginx
systemctl enable nginx
```

### 3.3 ติดตั้ง PHP 8.2

```bash
# เพิ่ม Repository
apt install software-properties-common -y
add-apt-repository ppa:ondrej/php -y
apt update

# ติดตั้ง PHP และ Extensions
apt install php8.2 php8.2-fpm php8.2-cli php8.2-mysql php8.2-xml php8.2-mbstring php8.2-curl php8.2-zip php8.2-gd php8.2-bcmath php8.2-intl -y

# ตรวจสอบ
php -v
```

### 3.4 ติดตั้ง Composer

```bash
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer

# ตรวจสอบ
composer --version
```

### 3.5 ติดตั้ง MySQL 8.0

```bash
apt install mysql-server -y
systemctl start mysql
systemctl enable mysql

# รัน secure installation
mysql_secure_installation
# ตอบ: Y สำหรับทุกคำถาม
# ตั้ง root password ที่แข็งแรง
```

### 3.6 ติดตั้ง Git

```bash
apt install git -y

# ตรวจสอบ
git --version
```

### 3.7 ติดตั้ง Node.js (สำหรับ build assets)

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install nodejs -y

# ตรวจสอบ
node -v
npm -v
```

### 3.8 ติดตั้ง Certbot (สำหรับ SSL)

```bash
apt install certbot python3-certbot-nginx -y
```

---

## 📋 ขั้นตอนที่ 4: ตั้งค่า Database

### 4.1 สร้าง Database และ User

```bash
mysql -u root -p
```

```sql
-- สร้าง database
CREATE DATABASE brieflylearn_production CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- สร้าง user
CREATE USER 'brieflylearn_user'@'localhost' IDENTIFIED BY 'YOUR_SECURE_PASSWORD_HERE';

-- ให้สิทธิ์
GRANT ALL PRIVILEGES ON brieflylearn_production.* TO 'brieflylearn_user'@'localhost';
FLUSH PRIVILEGES;

-- ตรวจสอบ
SHOW DATABASES;
SELECT User, Host FROM mysql.user;

EXIT;
```

### 4.2 ทดสอบ Connection

```bash
mysql -u brieflylearn_user -p brieflylearn_production
# ใส่ password แล้ว EXIT;
```

---

## 📋 ขั้นตอนที่ 5: Deploy Backend (Laravel)

### 5.1 สร้าง Directory Structure

```bash
# สร้าง directory สำหรับเก็บ web applications
mkdir -p /var/www
cd /var/www

# สร้าง user สำหรับ deployment
adduser --disabled-password --gecos "" deploy
usermod -aG www-data deploy
```

### 5.2 Clone Repository

```bash
# เปลี่ยนเป็น deploy user
su - deploy

# Clone backend repository
cd /var/www
git clone https://github.com/YOUR_USERNAME/brieflylearn-backend.git brieflylearn
cd brieflylearn

# กลับไปเป็น root
exit
```

### 5.3 ตั้งค่า Permissions

```bash
cd /var/www/brieflylearn

# ตั้งค่า ownership
chown -R deploy:www-data /var/www/brieflylearn
chmod -R 755 /var/www/brieflylearn

# ตั้งค่า storage และ cache directories
chmod -R 775 storage bootstrap/cache
chown -R deploy:www-data storage bootstrap/cache
```

### 5.4 ติดตั้ง Dependencies

```bash
# เป็น deploy user
su - deploy
cd /var/www/brieflylearn

# ติดตั้ง PHP dependencies
composer install --optimize-autoloader --no-dev

# ติดตั้ง npm dependencies (สำหรับ Filament assets)
npm install
npm run build

exit
```

### 5.5 สร้าง Environment File

```bash
cd /var/www/brieflylearn

# Copy .env.example
cp .env.example .env

# แก้ไข .env
nano .env
```

```env
APP_NAME="BrieflyLearn"
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://api.antiparallel.app

LOG_CHANNEL=stack
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=brieflylearn_production
DB_USERNAME=brieflylearn_user
DB_PASSWORD=YOUR_SECURE_PASSWORD_HERE

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=database
SESSION_DRIVER=file
SESSION_LIFETIME=120

# Frontend URL
FRONTEND_URL=https://antiparallel.app
SANCTUM_STATEFUL_DOMAINS=antiparallel.app,www.antiparallel.app

# Mail Configuration (ตั้งค่าตาม SMTP ที่ใช้)
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@antiparallel.app
MAIL_FROM_NAME="BrieflyLearn"
```

### 5.6 Generate Application Key

```bash
su - deploy
cd /var/www/brieflylearn

php artisan key:generate
php artisan config:cache
php artisan route:cache
php artisan view:cache

exit
```

### 5.7 Run Migrations

```bash
su - deploy
cd /var/www/brieflylearn

# รัน migrations
php artisan migrate --force

# รัน seeders (ถ้ามี)
php artisan db:seed --force

exit
```

---

## 📋 ขั้นตอนที่ 6: ตั้งค่า Nginx

### 6.1 สร้าง Nginx Configuration สำหรับ API

```bash
nano /etc/nginx/sites-available/api.antiparallel.app
```

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name api.antiparallel.app;
    root /var/www/brieflylearn/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

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
```

### 6.2 สร้าง Nginx Configuration สำหรับ Admin Panel

```bash
nano /etc/nginx/sites-available/api.antiparallel.app
```

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name api.antiparallel.app;
    root /var/www/brieflylearn/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

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
```

### 6.3 Enable Sites

```bash
# สร้าง symbolic links
ln -s /etc/nginx/sites-available/api.antiparallel.app /etc/nginx/sites-enabled/
ln -s /etc/nginx/sites-available/api.antiparallel.app /etc/nginx/sites-enabled/

# ลบ default site
rm /etc/nginx/sites-enabled/default

# ทดสอบ configuration
nginx -t

# Restart Nginx
systemctl restart nginx
```

---

## 📋 ขั้นตอนที่ 7: ตั้งค่า DNS

### 7.1 ตั้งค่า DNS Records ที่ Domain Registrar

เข้าไปที่ Domain Registrar (GoDaddy, Namecheap, etc.) และเพิ่ม DNS Records:

```
Type    Name    Value                   TTL
A       @       YOUR_VULTR_IP          3600
A       www     YOUR_VULTR_IP          3600
A       api     YOUR_VULTR_IP          3600
A       admin   YOUR_VULTR_IP          3600
```

**ตัวอย่าง:**
```
A       @       45.76.123.45
A       www     45.76.123.45
A       api     45.76.123.45
A       admin   45.76.123.45
```

### 7.2 รอ DNS Propagation

```bash
# ทดสอบ DNS (จาก Local machine)
nslookup api.antiparallel.app
nslookup api.antiparallel.app

# หรือ
dig api.antiparallel.app
dig api.antiparallel.app
```

---

## 📋 ขั้นตอนที่ 8: ติดตั้ง SSL Certificate

### 8.1 ติดตั้ง SSL ด้วย Let's Encrypt

```bash
# สำหรับ api.antiparallel.app
certbot --nginx -d api.antiparallel.app

# สำหรับ api.antiparallel.app
certbot --nginx -d api.antiparallel.app

# ตอบคำถาม:
# - Email: your-email@example.com
# - Agree to Terms: Y
# - Share email: N (ถ้าไม่อยากแชร์)
# - Redirect HTTP to HTTPS: 2 (เลือก redirect)
```

### 8.2 ทดสอบ Auto-renewal

```bash
certbot renew --dry-run
```

### 8.3 ตรวจสอบ Cron Job

```bash
systemctl status certbot.timer
```

---

## 📋 ขั้นตอนที่ 9: Deploy Frontend

### Option A: Deploy บน Vercel (แนะนำ)

```bash
# จาก Local machine
cd /Users/panapat/brieflylearn/fitness-lms

# Login Vercel
npx vercel login

# Deploy
npx vercel --prod
```

**Environment Variables บน Vercel:**
```env
NEXT_PUBLIC_APP_URL=https://antiparallel.app
NEXT_PUBLIC_API_URL=https://api.antiparallel.app/api/v1
NODE_ENV=production
```

**Domain Settings บน Vercel:**
- Add domain: `antiparallel.app`
- Add domain: `www.antiparallel.app`

### Option B: Deploy บน Vultr (เครื่องเดียวกับ Backend)

```bash
# บน Vultr Server
cd /var/www
git clone https://github.com/YOUR_USERNAME/brieflylearn-frontend.git frontend
cd frontend

# ติดตั้ง dependencies
npm install

# สร้าง .env.production
cat > .env.production << 'EOF'
NEXT_PUBLIC_APP_URL=https://antiparallel.app
NEXT_PUBLIC_API_URL=https://api.antiparallel.app/api/v1
NODE_ENV=production
EOF

# Build
npm run build

# ติดตั้ง PM2
npm install -g pm2

# Start application
pm2 start npm --name "brieflylearn-frontend" -- start
pm2 save
pm2 startup
```

**Nginx Configuration สำหรับ Frontend (ถ้า deploy บน Vultr):**

```bash
nano /etc/nginx/sites-available/antiparallel.app
```

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name antiparallel.app www.antiparallel.app;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
ln -s /etc/nginx/sites-available/antiparallel.app /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx

# ติดตั้ง SSL
certbot --nginx -d antiparallel.app -d www.antiparallel.app
```

---

## 📋 ขั้นตอนที่ 10: ตั้งค่า Firewall

```bash
# ติดตั้ง UFW
apt install ufw -y

# อนุญาต SSH, HTTP, HTTPS
ufw allow OpenSSH
ufw allow 'Nginx Full'

# อนุญาต MySQL (เฉพาะ localhost)
# ไม่ต้อง allow จาก outside

# Enable firewall
ufw enable

# ตรวจสอบ status
ufw status verbose
```

---

## 📋 ขั้นตอนที่ 11: สร้าง Deployment Script

### 11.1 สร้าง Deployment Script บน Server

```bash
nano /var/www/brieflylearn/deploy.sh
```

```bash
#!/bin/bash

# BrieflyLearn Backend Deployment Script
echo "🚀 Starting deployment..."

# Navigate to project directory
cd /var/www/brieflylearn

# Put application in maintenance mode
php artisan down

# Pull latest changes
git pull origin main

# Install/update dependencies
composer install --optimize-autoloader --no-dev

# Install npm dependencies and build assets
npm install
npm run build

# Run migrations
php artisan migrate --force

# Clear and cache config
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Clear application cache
php artisan cache:clear

# Bring application back up
php artisan up

echo "✅ Deployment completed!"
```

```bash
# ให้สิทธิ์ execute
chmod +x /var/www/brieflylearn/deploy.sh
chown deploy:www-data /var/www/brieflylearn/deploy.sh
```

### 11.2 วิธีใช้งาน Deployment Script

```bash
su - deploy
cd /var/www/brieflylearn
./deploy.sh
```

---

## 📋 ขั้นตอนที่ 12: ตั้งค่า Automated Backups

### 12.1 สร้าง Backup Script

```bash
mkdir -p /var/backups/brieflylearn
nano /var/backups/brieflylearn/backup.sh
```

```bash
#!/bin/bash

# Backup Configuration
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="/var/backups/brieflylearn"
DB_NAME="brieflylearn_production"
DB_USER="brieflylearn_user"
DB_PASS="YOUR_SECURE_PASSWORD_HERE"

# Create backup directory
mkdir -p $BACKUP_DIR/database
mkdir -p $BACKUP_DIR/files

# Backup database
mysqldump -u $DB_USER -p$DB_PASS $DB_NAME | gzip > $BACKUP_DIR/database/db_$TIMESTAMP.sql.gz

# Backup uploaded files (storage)
tar -czf $BACKUP_DIR/files/storage_$TIMESTAMP.tar.gz /var/www/brieflylearn/storage/app

# Keep only last 7 days of backups
find $BACKUP_DIR/database -name "db_*.sql.gz" -mtime +7 -delete
find $BACKUP_DIR/files -name "storage_*.tar.gz" -mtime +7 -delete

echo "✅ Backup completed: $TIMESTAMP"
```

```bash
chmod +x /var/backups/brieflylearn/backup.sh
```

### 12.2 ตั้งค่า Cron Job

```bash
crontab -e
```

```cron
# Backup ทุกวัน เวลา 2:00 AM
0 2 * * * /var/backups/brieflylearn/backup.sh >> /var/backups/brieflylearn/backup.log 2>&1
```

---

## 📋 ขั้นตอนที่ 13: Monitoring และ Logging

### 13.1 ตั้งค่า Laravel Log

```bash
# ตรวจสอบ logs
tail -f /var/www/brieflylearn/storage/logs/laravel.log
```

### 13.2 ตั้งค่า Nginx Logs

```bash
# Access log
tail -f /var/log/nginx/access.log

# Error log
tail -f /var/log/nginx/error.log
```

### 13.3 ติดตั้ง Monitoring Tools (Optional)

```bash
# ติดตั้ง htop
apt install htop -y

# ดู resource usage
htop
```

---

## 📋 ขั้นตอนที่ 14: Security Best Practices

### 14.1 Disable Root Login

```bash
nano /etc/ssh/sshd_config
```

```
PermitRootLogin no
PasswordAuthentication no
```

```bash
systemctl restart sshd
```

### 14.2 ติดตั้ง Fail2Ban

```bash
apt install fail2ban -y
systemctl start fail2ban
systemctl enable fail2ban
```

### 14.3 ตั้งค่า Rate Limiting

ใน `/var/www/brieflylearn/app/Http/Kernel.php` ตรวจสอบว่ามี:

```php
'throttle:api' => \Illuminate\Routing\Middleware\ThrottleRequests::class.':60,1',
```

---

## 🎯 สรุป URLs หลังจาก Deploy

| Service | URL | Purpose |
|---------|-----|---------|
| Frontend | https://antiparallel.app | เว็บไซต์หลัก |
| API | https://api.antiparallel.app/api/v1 | Backend API |
| Admin Panel | https://api.antiparallel.app/admin | Filament Admin |

---

## ✅ Checklist สำหรับ Production

- [ ] Database backups automated
- [ ] SSL certificates installed
- [ ] Firewall configured
- [ ] DNS records set correctly
- [ ] Environment variables set
- [ ] Logs monitoring configured
- [ ] Error tracking setup
- [ ] Rate limiting enabled
- [ ] CORS configured correctly
- [ ] Email sending tested
- [ ] Payment gateway tested (if applicable)

---

## 🔧 Maintenance Commands

### Update Code

```bash
su - deploy
cd /var/www/brieflylearn
./deploy.sh
```

### Clear Cache

```bash
php artisan cache:clear
php artisan config:clear
php artisan view:clear
```

### View Logs

```bash
tail -f storage/logs/laravel.log
```

### Restart Services

```bash
# Nginx
systemctl restart nginx

# PHP-FPM
systemctl restart php8.2-fpm

# MySQL
systemctl restart mysql
```

---

## 📞 Support

สำหรับการแก้ไขปัญหา:

1. ตรวจสอบ logs: `/var/www/brieflylearn/storage/logs/laravel.log`
2. ตรวจสอบ Nginx: `/var/log/nginx/error.log`
3. ตรวจสอบ PHP: `journalctl -u php8.2-fpm`

---

**Last Updated**: 2025-10-25
**Version**: 1.0.0
