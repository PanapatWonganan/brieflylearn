# 🚀 BrieflyLearn - Quick Deployment Guide

**Server**: Vultr VPS (207.148.76.203)
**Stack**: Laravel + Next.js บน host เดียวกัน

---

## 📋 Step 1: สร้าง GitHub Repositories (5 นาที)

### 1.1 สร้าง Personal Access Token

1. ไปที่ https://github.com/settings/tokens
2. Click **"Generate new token (classic)"**
3. Token name: `BrieflyLearn Deployment`
4. Expiration: `No expiration` (หรือตามต้องการ)
5. Select scopes: ✅ **repo** (ทั้งหมด)
6. Click **"Generate token"**
7. **Copy token ทันที** (จะไม่แสดงอีก) → บันทึกไว้ใน Notes หรือที่ปลอดภัย

---

### 1.2 สร้าง Repositories (ทำ 2 ครั้ง)

**Repository 1: Backend**
1. ไปที่ https://github.com/new
2. Repository name: `brieflylearn-backend`
3. Description: `BrieflyLearn LMS - Laravel Backend API`
4. Visibility: **Private** (แนะนำ)
5. **❌ ห้าม** check "Add a README file"
6. **❌ ห้าม** เลือก .gitignore หรือ license
7. Click **"Create repository"**

**Repository 2: Frontend**
1. ไปที่ https://github.com/new อีกครั้ง
2. Repository name: `brieflylearn-frontend`
3. Description: `BrieflyLearn LMS - Next.js Frontend`
4. Visibility: **Private** (แนะนำ)
5. **❌ ห้าม** check "Add a README file"
6. **❌ ห้าม** เลือก .gitignore หรือ license
7. Click **"Create repository"**

---

### 1.3 Push Code ไป GitHub

เปิด Terminal แล้วรัน:

```bash
cd /Users/panapat/brieflylearn
./setup-github.sh
```

**จะถูกถามข้อมูล:**
1. GitHub username: `[YOUR_GITHUB_USERNAME]`
2. Have you created both repositories? → Type: `y`
3. Press Enter when ready
4. **ครั้งที่ 1** (Backend):
   - Username: `[YOUR_GITHUB_USERNAME]`
   - Password: `[PASTE_YOUR_TOKEN]` (ที่ copy ไว้ในขั้นตอน 1.1)
5. **ครั้งที่ 2** (Frontend):
   - Username: `[YOUR_GITHUB_USERNAME]`
   - Password: `[PASTE_YOUR_TOKEN]` (เหมือนเดิม)

**ผลลัพธ์ที่ต้องการ:**
```
✅ Backend pushed successfully!
✅ Frontend pushed successfully!
🎉 SUCCESS! Both repositories are now on GitHub
```

---

## 📋 Step 2: Prepare Server Connection (2 นาที)

### 2.1 Test SSH Connection

```bash
ssh root@207.148.76.203
```

**ถ้า connect ได้:**
- เห็น Ubuntu welcome message → ✅ พร้อม deploy
- พิมพ์ `exit` เพื่อออก

**ถ้า connect ไม่ได้:**
- ตรวจสอบ IP address ถูกต้องหรือไม่
- ตรวจสอบว่ามี root password หรือ SSH key หรือไม่
- ตรวจสอบ firewall block port 22 หรือไม่

---

## 📋 Step 3: Deploy to Vultr Server (30-60 นาที)

### 3.1 SSH เข้า Server

```bash
ssh root@207.148.76.203
```

---

### 3.2 Update & Install Software (10 นาที)

```bash
# Update system
apt update && apt upgrade -y

# Install basics
apt install -y curl wget git unzip software-properties-common ufw vim

# Setup firewall
ufw --force enable
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

# Install Nginx
apt install -y nginx
systemctl start nginx
systemctl enable nginx

# Install PHP 8.2
add-apt-repository -y ppa:ondrej/php
apt update
apt install -y php8.2-fpm php8.2-cli php8.2-common php8.2-mysql \
  php8.2-zip php8.2-gd php8.2-mbstring php8.2-curl php8.2-xml \
  php8.2-bcmath php8.2-intl php8.2-readline
systemctl start php8.2-fpm
systemctl enable php8.2-fpm

# Install MySQL
apt install -y mysql-server
systemctl start mysql
systemctl enable mysql

# Install Composer
curl -sS https://getcomposer.org/installer -o composer-setup.php
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm composer-setup.php

# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

# Install PM2
npm install -g pm2
```

**Verify installations:**
```bash
php -v          # Should show PHP 8.2.x
composer -V     # Should show Composer version
node -v         # Should show v20.x.x
npm -v          # Should show 10.x.x
pm2 -v          # Should show PM2 version
```

---

### 3.3 Setup Database (3 นาที)

```bash
# Secure MySQL
mysql_secure_installation
```

**Prompts:**
- VALIDATE PASSWORD: `Y`
- Password level: `2` (STRONG)
- New password: `BrieflyLearn2025!@#` (หรือรหัสที่แข็งแรงกว่า) → **บันทึกไว้!**
- Remove anonymous: `Y`
- Disallow root remote: `Y`
- Remove test: `Y`
- Reload: `Y`

**Create database:**
```bash
mysql -u root -p
# Enter password ที่ตั้งไว้
```

**Inside MySQL:**
```sql
CREATE DATABASE fitness_lms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'brieflylearn'@'localhost' IDENTIFIED BY 'BrieflyDB2025!Strong';
GRANT ALL PRIVILEGES ON fitness_lms.* TO 'brieflylearn'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

⚠️ **บันทึกข้อมูลนี้:**
- Database: `fitness_lms`
- User: `brieflylearn`
- Password: `BrieflyDB2025!Strong`

---

### 3.4 Setup SSH Key for GitHub (3 นาที)

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "deploy@brieflylearn.com"
# Press Enter 3 times (default location, no passphrase)

# Show public key
cat ~/.ssh/id_ed25519.pub
```

**Copy output (starts with `ssh-ed25519`)**

**Add to GitHub - Backend:**
1. ไปที่ https://github.com/YOUR_USERNAME/brieflylearn-backend/settings/keys
2. Click **"Add deploy key"**
3. Title: `Vultr Production Server`
4. Key: **Paste ที่ copy มา**
5. ✅ Check **"Allow write access"** (ถ้าต้องการ auto-deploy ภายหลัง)
6. Click **"Add key"**

**Add to GitHub - Frontend:**
1. ไปที่ https://github.com/YOUR_USERNAME/brieflylearn-frontend/settings/keys
2. Click **"Add deploy key"**
3. Title: `Vultr Production Server`
4. Key: **Paste SSH key เดิม**
5. ✅ Check **"Allow write access"**
6. Click **"Add key"**

---

### 3.5 Clone & Setup Backend (10 นาที)

```bash
# Create directory
mkdir -p /var/www/brieflylearn
cd /var/www/brieflylearn

# Clone backend (แทน YOUR_USERNAME ด้วย GitHub username ของคุณ)
git clone git@github.com:YOUR_USERNAME/brieflylearn-backend.git backend

# If first SSH from server, type: yes

cd backend

# Install dependencies
composer install --optimize-autoloader --no-dev

# Setup .env
cp .env.example .env
nano .env
```

**Edit .env (กด ลูกศรเลื่อนเคอร์เซอร์, พิมพ์แก้ไข):**

```env
APP_NAME="BrieflyLearn"
APP_ENV=production
APP_DEBUG=false
APP_URL=https://admin.brieflylearn.com

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=fitness_lms
DB_USERNAME=brieflylearn
DB_PASSWORD=BrieflyDB2025!Strong

SESSION_DRIVER=file
SESSION_LIFETIME=120
```

**Save:** `Ctrl+X` → `Y` → `Enter`

**Continue setup:**
```bash
# Generate key
php artisan key:generate

# Set permissions
chown -R www-data:www-data /var/www/brieflylearn/backend
chmod -R 755 /var/www/brieflylearn/backend
chmod -R 775 /var/www/brieflylearn/backend/storage
chmod -R 775 /var/www/brieflylearn/backend/bootstrap/cache

# Run migrations
php artisan migrate --force

# Seed data
php artisan db:seed --force

# Cache config
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

---

### 3.6 Clone & Setup Frontend (10 นาที)

```bash
cd /var/www/brieflylearn

# Clone frontend (แทน YOUR_USERNAME)
git clone git@github.com:YOUR_USERNAME/brieflylearn-frontend.git frontend

cd frontend

# Create .env.production
cat > .env.production << 'EOF'
NEXT_PUBLIC_API_URL=https://api.brieflylearn.com/api/v1
NEXT_PUBLIC_APP_NAME=BrieflyLearn
NEXT_PUBLIC_APP_URL=https://brieflylearn.com
NODE_ENV=production
EOF

# Install dependencies
npm ci --production=false

# Build
npm run build

# Setup PM2
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

# Start PM2
pm2 start ecosystem.config.js
pm2 save
pm2 startup systemd
# ⚠️ Copy command ที่แสดง และรันมัน

# Check status
pm2 status
```

---

### 3.7 Configure Nginx (5 นาที)

```bash
# Create Nginx config
nano /etc/nginx/sites-available/brieflylearn
```

**Paste (ทั้งหมด):**

```nginx
# Backend API & Admin
server {
    listen 80;
    server_name admin.brieflylearn.com api.brieflylearn.com 207.148.76.203;
    root /var/www/brieflylearn/backend/public;

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
        fastcgi_hide_header X-Powered-By;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}

# Frontend (Next.js)
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
```

**Save:** `Ctrl+X` → `Y` → `Enter`

**Enable site:**
```bash
# Enable
ln -s /etc/nginx/sites-available/brieflylearn /etc/nginx/sites-enabled/

# Remove default
rm -f /etc/nginx/sites-enabled/default

# Test
nginx -t

# Reload
systemctl reload nginx
```

---

### 3.8 Test without SSL (ก่อนตั้ง domain)

```bash
# Test backend API
curl http://207.148.76.203/api/v1/courses

# Should return JSON with courses
```

**เปิด browser:**
- http://207.148.76.203 → ควรเห็นหน้า welcome
- http://207.148.76.203/admin → ควรเห็น Filament login

**ถ้าเห็นทั้ง 2 หน้า = Backend สำเร็จ! ✅**

---

## 📋 Step 4: Setup Domain & SSL (15 นาที)

### 4.1 Configure DNS

ไปที่ DNS Management ของ domain provider (Namecheap, GoDaddy, etc.)

**เพิ่ม DNS Records:**

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | @ | 207.148.76.203 | 3600 |
| A | www | 207.148.76.203 | 3600 |
| A | admin | 207.148.76.203 | 3600 |
| A | api | 207.148.76.203 | 3600 |

**บันทึก** และรอ DNS propagate (5-30 นาที)

**Check DNS:**
```bash
# บนเครื่อง local
dig brieflylearn.com
dig admin.brieflylearn.com
dig api.brieflylearn.com

# ควรได้ IP: 207.148.76.203
```

---

### 4.2 Install SSL Certificate

**บน server (SSH):**

```bash
# Install Certbot
apt install -y certbot python3-certbot-nginx

# Get certificates (แทน brieflylearn.com ด้วย domain จริง)
certbot --nginx -d brieflylearn.com -d www.brieflylearn.com -d admin.brieflylearn.com -d api.brieflylearn.com

# Prompts:
# Email: your-email@example.com
# Terms: Y
# Share email: N
# Redirect HTTP to HTTPS: 2

# Test auto-renewal
certbot renew --dry-run
```

---

## 📋 Step 5: Final Testing

### 5.1 Test All URLs

**Browser:**
- ✅ https://brieflylearn.com → หน้าแรก Frontend
- ✅ https://brieflylearn.com/courses → Courses page
- ✅ https://admin.brieflylearn.com → Welcome page
- ✅ https://admin.brieflylearn.com/admin → Filament login
- ✅ https://api.brieflylearn.com/api/v1/courses → JSON data

---

### 5.2 Test Admin Login

1. ไปที่ https://admin.brieflylearn.com/admin
2. Login:
   - Email: `admin@brieflylearn.com`
   - Password: `admin123`
3. ควรเข้าได้ → Dashboard

⚠️ **เปลี่ยนรหัสผ่าน admin ทันที!**

---

### 5.3 Test Frontend-Backend Connection

1. ไปที่ https://brieflylearn.com/courses
2. ควรเห็น courses จาก backend API
3. ถ้าเห็น = เชื่อมต่อสำเร็จ! ✅

---

## 🎉 Deployment Complete!

### สิ่งที่ควรทำต่อ:

1. **เปลี่ยนรหัสผ่าน admin** ที่ `/admin`
2. **Setup backup script:**
   ```bash
   # See VULTR_SINGLE_HOST_DEPLOYMENT.md Part 11
   ```
3. **Monitor logs:**
   ```bash
   pm2 logs brieflylearn-frontend
   tail -f /var/www/brieflylearn/backend/storage/logs/laravel.log
   ```

---

## 🔄 Update Code ภายหลัง

**บน local machine - Push updates:**
```bash
# Backend
cd /Users/panapat/brieflylearn/fitness-lms-admin
git add .
git commit -m "Your update message"
git push origin main

# Frontend
cd /Users/panapat/brieflylearn/fitness-lms
git add .
git commit -m "Your update message"
git push origin main
```

**บน server - Pull updates:**
```bash
# Backend
cd /var/www/brieflylearn/backend
git pull origin main
composer install --no-dev
php artisan migrate --force
php artisan config:cache

# Frontend
cd /var/www/brieflylearn/frontend
git pull origin main
npm ci --production=false
npm run build
pm2 restart brieflylearn-frontend
```

---

## 🆘 Troubleshooting

**Problem: Next.js ไม่ทำงาน**
```bash
pm2 logs brieflylearn-frontend
pm2 restart brieflylearn-frontend
```

**Problem: Laravel 500 Error**
```bash
tail -f /var/www/brieflylearn/backend/storage/logs/laravel.log
```

**Problem: Database connection error**
```bash
mysql -u brieflylearn -p fitness_lms
# ถ้า login ได้ = database OK
```

---

**หากมีปัญหา ให้ดูคู่มือเต็มที่ `VULTR_SINGLE_HOST_DEPLOYMENT.md`**
