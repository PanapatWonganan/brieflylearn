# 🚀 Vultr Deployment - Getting Started Guide

**Server IP**: `207.148.76.203`
**Project**: BrieflyLearn Fitness LMS
**Target Setup**: Ubuntu 22.04 LTS + Nginx + PHP 8.2 + MySQL 8.0

---

## 📋 Phase 1: Server Access & Initial Setup

### Step 1: SSH into Vultr Server

```bash
# Connect to your Vultr server
ssh root@207.148.76.203

# If you have a specific SSH key:
ssh -i ~/.ssh/your_key root@207.148.76.203
```

**Expected Output**: You should see Ubuntu welcome message and command prompt.

---

### Step 2: Update System Packages

```bash
# Update package lists
apt update

# Upgrade all packages
apt upgrade -y

# Install basic utilities
apt install -y curl wget git unzip software-properties-common ufw
```

**Time Estimate**: 5-10 minutes

---

## 🔒 Phase 2: Security Configuration

### Step 3: Setup Firewall (UFW)

```bash
# Enable UFW
ufw --force enable

# Allow SSH (IMPORTANT - do this first!)
ufw allow 22/tcp

# Allow HTTP and HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# Allow MySQL (only from localhost)
ufw allow from 127.0.0.1 to any port 3306

# Check status
ufw status verbose
```

**Expected Output**:
```
Status: active
To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
80/tcp                     ALLOW       Anywhere
443/tcp                    ALLOW       Anywhere
```

---

### Step 4: Create Non-Root User (Optional but Recommended)

```bash
# Create deploy user
adduser deploy

# Add to sudo group
usermod -aG sudo deploy

# Setup SSH for deploy user
mkdir -p /home/deploy/.ssh
cp ~/.ssh/authorized_keys /home/deploy/.ssh/
chown -R deploy:deploy /home/deploy/.ssh
chmod 700 /home/deploy/.ssh
chmod 600 /home/deploy/.ssh/authorized_keys
```

---

## 🛠️ Phase 3: Install Required Software

### Step 5: Install Nginx

```bash
apt install -y nginx

# Start and enable Nginx
systemctl start nginx
systemctl enable nginx

# Check status
systemctl status nginx

# Test: Visit http://207.148.76.203 in browser
# You should see "Welcome to nginx!" page
```

---

### Step 6: Install PHP 8.2 and Extensions

```bash
# Add PHP repository
add-apt-repository -y ppa:ondrej/php
apt update

# Install PHP 8.2 and required extensions
apt install -y php8.2-fpm php8.2-cli php8.2-common php8.2-mysql \
  php8.2-zip php8.2-gd php8.2-mbstring php8.2-curl php8.2-xml \
  php8.2-bcmath php8.2-intl php8.2-readline

# Verify installation
php -v

# Start and enable PHP-FPM
systemctl start php8.2-fpm
systemctl enable php8.2-fpm
```

**Expected Output**: `PHP 8.2.x (cli)...`

---

### Step 7: Install MySQL 8.0

```bash
# Install MySQL Server
apt install -y mysql-server

# Start and enable MySQL
systemctl start mysql
systemctl enable mysql

# Secure MySQL installation
mysql_secure_installation
```

**During `mysql_secure_installation`**:
- VALIDATE PASSWORD COMPONENT: `Y` (Yes)
- Password validation policy: `2` (STRONG)
- New password: `[CREATE STRONG PASSWORD]` ⚠️ **SAVE THIS PASSWORD**
- Remove anonymous users: `Y`
- Disallow root login remotely: `Y`
- Remove test database: `Y`
- Reload privilege tables: `Y`

---

### Step 8: Install Composer

```bash
# Download Composer installer
curl -sS https://getcomposer.org/installer -o composer-setup.php

# Install Composer globally
php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Remove installer
rm composer-setup.php

# Verify installation
composer --version
```

**Expected Output**: `Composer version 2.x.x`

---

### Step 9: Install Node.js and npm (for asset compilation)

```bash
# Install Node.js 20.x LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

# Verify installation
node -v
npm -v
```

**Expected Output**:
```
v20.x.x
10.x.x
```

---

## 📂 Phase 4: Setup Project Directory

### Step 10: Create Project Structure

```bash
# Create web directory
mkdir -p /var/www/brieflylearn

# Set ownership
chown -R www-data:www-data /var/www/brieflylearn

# Create directory for the admin (Laravel backend)
mkdir -p /var/www/brieflylearn/admin
```

---

## 🗄️ Phase 5: Database Setup

### Step 11: Create Production Database

```bash
# Login to MySQL
mysql -u root -p

# Inside MySQL prompt:
CREATE DATABASE fitness_lms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER 'brieflylearn_user'@'localhost' IDENTIFIED BY '[STRONG_PASSWORD]';

GRANT ALL PRIVILEGES ON fitness_lms.* TO 'brieflylearn_user'@'localhost';

FLUSH PRIVILEGES;

EXIT;
```

⚠️ **SAVE THESE CREDENTIALS**:
- Database: `fitness_lms`
- Username: `brieflylearn_user`
- Password: `[YOUR_STRONG_PASSWORD]`

---

## 🔑 Phase 6: Setup SSH Key for Git (if using private repo)

### Step 12: Generate SSH Key

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "deploy@brieflylearn.com"

# Press Enter for default location
# Press Enter twice for no passphrase

# Display public key
cat ~/.ssh/id_ed25519.pub

# Copy this key and add to GitHub/GitLab Deploy Keys
```

---

## 📥 Phase 7: Clone Repository

### Step 13: Clone Backend Repository

```bash
# Navigate to project directory
cd /var/www/brieflylearn

# Clone your repository (replace with your actual repo URL)
git clone [YOUR_REPO_URL] admin

# Navigate into project
cd admin

# Install Composer dependencies
composer install --optimize-autoloader --no-dev

# Set correct permissions
chown -R www-data:www-data /var/www/brieflylearn/admin
chmod -R 755 /var/www/brieflylearn/admin
chmod -R 775 /var/www/brieflylearn/admin/storage
chmod -R 775 /var/www/brieflylearn/admin/bootstrap/cache
```

---

## ⚙️ Phase 8: Environment Configuration

### Step 14: Setup .env File

```bash
# Copy .env.example
cd /var/www/brieflylearn/admin
cp .env.example .env

# Edit .env file
nano .env
```

**Update these values**:

```env
APP_NAME="BrieflyLearn"
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://admin.brieflylearn.com

LOG_CHANNEL=stack
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=fitness_lms
DB_USERNAME=brieflylearn_user
DB_PASSWORD=[YOUR_DATABASE_PASSWORD]

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

# Add your production mail settings if needed
MAIL_MAILER=smtp
MAIL_HOST=mailhog
MAIL_PORT=1025
```

**Save and exit**: `Ctrl + X`, then `Y`, then `Enter`

---

### Step 15: Generate Application Key

```bash
# Generate Laravel application key
php artisan key:generate

# Clear and cache configuration
php artisan config:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

---

### Step 16: Run Database Migrations and Seeders

```bash
# Run migrations
php artisan migrate --force

# Run seeders
php artisan db:seed --force

# Or run specific seeders:
php artisan db:seed --class=AdminUserSeeder --force
php artisan db:seed --class=CategorySeeder --force
php artisan db:seed --class=CourseSeeder --force
```

---

## 🌐 Phase 9: Nginx Configuration

### Step 17: Configure Nginx for Laravel

```bash
# Create Nginx configuration file
nano /etc/nginx/sites-available/brieflylearn-admin
```

**Paste this configuration**:

```nginx
server {
    listen 80;
    server_name admin.brieflylearn.com api.brieflylearn.com 207.148.76.203;
    root /var/www/brieflylearn/admin/public;

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

**Save and exit**: `Ctrl + X`, then `Y`, then `Enter`

---

### Step 18: Enable Site and Test Configuration

```bash
# Create symbolic link to enable site
ln -s /etc/nginx/sites-available/brieflylearn-admin /etc/nginx/sites-enabled/

# Remove default site
rm /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t

# Reload Nginx
systemctl reload nginx
```

**Expected Output**: `nginx: configuration file /etc/nginx/nginx.conf test is successful`

---

## 🔐 Phase 10: SSL Certificate with Let's Encrypt

### Step 19: Install Certbot

```bash
# Install Certbot
apt install -y certbot python3-certbot-nginx
```

---

### Step 20: Obtain SSL Certificate

⚠️ **IMPORTANT**: Before running this, ensure your domain DNS A records point to `207.148.76.203`

```bash
# Obtain certificate for admin domain
certbot --nginx -d admin.brieflylearn.com -d api.brieflylearn.com

# Follow prompts:
# - Enter email address
# - Agree to terms
# - Decide on sharing email with EFF
# - Choose to redirect HTTP to HTTPS (option 2)
```

---

### Step 21: Test SSL Auto-Renewal

```bash
# Dry run renewal
certbot renew --dry-run
```

**Expected Output**: `Congratulations, all simulated renewals succeeded`

---

## ✅ Phase 11: Verification

### Step 22: Test Backend

```bash
# Test from command line
curl http://localhost/api/v1/courses

# Visit in browser:
# http://207.148.76.203 (should work)
# https://admin.brieflylearn.com (should work after DNS setup)
# https://api.brieflylearn.com/api/v1/courses (should return course data)
```

---

### Step 23: Test Admin Panel

Visit: `https://admin.brieflylearn.com/admin`

**Login Credentials**:
- Email: `admin@brieflylearn.com`
- Password: `admin123` (as per your local seeder)

⚠️ **IMPORTANT**: Change this password immediately after first login!

---

## 📱 Phase 12: Frontend Deployment (Vercel)

### Step 24: Prepare Frontend for Deployment

On your **local machine**:

```bash
cd /Users/panapat/brieflylearn/fitness-lms

# Create production environment file
nano .env.production
```

**Add these values**:

```env
NEXT_PUBLIC_API_URL=https://api.brieflylearn.com/api/v1
NEXT_PUBLIC_APP_NAME=BrieflyLearn
NEXT_PUBLIC_APP_URL=https://brieflylearn.com
```

---

### Step 25: Deploy to Vercel

```bash
# Install Vercel CLI (if not already installed)
npm install -g vercel

# Login to Vercel
vercel login

# Deploy
vercel --prod
```

**During deployment**:
- Choose project name: `brieflylearn`
- Link to existing project or create new
- Set production environment variables from `.env.production`
- Confirm deployment

---

## 🎉 Final Checklist

- [ ] Backend accessible at `https://api.brieflylearn.com`
- [ ] Admin panel accessible at `https://admin.brieflylearn.com/admin`
- [ ] Frontend accessible at `https://brieflylearn.com`
- [ ] SSL certificates installed and working
- [ ] Database migrations completed
- [ ] Admin user can login
- [ ] API returns course data
- [ ] Frontend can communicate with backend API

---

## 🔧 Troubleshooting Common Issues

### Issue 1: Permission Denied Errors

```bash
# Fix storage permissions
cd /var/www/brieflylearn/admin
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache
```

### Issue 2: 500 Internal Server Error

```bash
# Check Laravel logs
tail -f /var/www/brieflylearn/admin/storage/logs/laravel.log

# Check Nginx logs
tail -f /var/nginx/error.log
```

### Issue 3: Database Connection Failed

```bash
# Test MySQL connection
mysql -u brieflylearn_user -p fitness_lms

# Check .env database credentials
cat /var/www/brieflylearn/admin/.env | grep DB_
```

### Issue 4: CORS Errors from Frontend

Edit `/var/www/brieflylearn/admin/config/cors.php`:

```php
'allowed_origins' => ['https://brieflylearn.com'],
'allowed_origins_patterns' => [],
'allowed_headers' => ['*'],
'allowed_methods' => ['*'],
```

Then:
```bash
php artisan config:cache
```

---

## 📞 Next Steps After Deployment

1. **Monitor Logs**: Setup log monitoring for errors
2. **Backup Strategy**: Implement automated database backups
3. **Performance**: Setup Redis for caching
4. **Monitoring**: Install monitoring tools (Uptime Robot, etc.)
5. **Security**: Regular security updates with `apt update && apt upgrade`

---

## 🎯 Current Status

- **Local Development**: ✅ Working (Port 8001 backend, Port 3000 frontend)
- **Vultr Server**: 🟡 Ready to deploy (IP: 207.148.76.203)
- **DNS Configuration**: ❌ Not yet configured
- **SSL Certificates**: ❌ Not yet installed
- **Frontend (Vercel)**: ❌ Not yet deployed

---

**Start with Step 1 and work through each phase systematically. Good luck! 🚀**
