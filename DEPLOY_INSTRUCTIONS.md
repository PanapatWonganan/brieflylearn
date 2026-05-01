# 🚀 BrieflyLearn - Complete Deployment Instructions

## 📋 Overview

คุณมี domain: `https://antiparallel.app/` และ `api.antiparallel.app`
ระบบจะ deploy แบบ production-ready พร้อม SSL certificate

---

## ✅ Pre-requisites Checklist

ก่อน deploy ตรวจสอบให้แน่ใจว่า:

- [ ] Domain `antiparallel.app` ชี้ไปที่ VPS IP: `207.148.76.203` (A Record)
- [ ] Domain `www.antiparallel.app` ชี้ไปที่ VPS IP: `207.148.76.203` (A Record)
- [ ] Domain `api.antiparallel.app` ชี้ไปที่ VPS IP: `207.148.76.203` (A Record)
- [ ] SSH access ไปยัง `root@207.148.76.203` ทำงานได้
- [ ] VPS มี MySQL, PHP 8.2, Node.js, Nginx ติดตั้งแล้ว
- [ ] MySQL database `brieflylearn` และ user `brieflyuser` สร้างไว้แล้ว

### ตรวจสอบ DNS:
```bash
# จากเครื่องคุณ
dig antiparallel.app
dig www.antiparallel.app
dig api.antiparallel.app

# ควรแสดง IP: 207.148.76.203 ทั้ง 3 domain
```

---

## 🚀 Deployment Steps

### Step 1: อัพโหลด Scripts ไปยัง VPS

จากเครื่องคุณ:
```bash
cd /Users/panapat/brieflylearn

# อัพโหลด deployment scripts
scp deploy-with-domain.sh root@207.148.76.203:/root/
scp setup-ssl.sh root@207.148.76.203:/root/
```

---

### Step 2: SSH เข้า VPS

```bash
ssh root@207.148.76.203
```

---

### Step 3: Deploy Applications

```bash
cd /root
chmod +x deploy-with-domain.sh setup-ssl.sh

# รัน deployment script
bash deploy-with-domain.sh
```

#### สิ่งที่ Script จะทำ:

1. ✅ Deploy Laravel Backend ไปที่ `/var/www/backend`
   - Clone จาก GitHub
   - Install dependencies
   - สร้าง `.env` พร้อม CORS config
   - Cache config

2. ✅ Import Database
   - Download database backup
   - Import ลง MySQL

3. ✅ Deploy Next.js Frontend ไปที่ `/var/www/frontend`
   - Clone จาก GitHub
   - Install dependencies
   - Build production
   - สร้าง `.env.local` ที่ชี้ไปยัง `api.antiparallel.app`

4. ✅ Setup Systemd Services
   - `brieflylearn-backend.service` (Port 8000)
   - `brieflylearn-frontend.service` (Port 3000)
   - Auto-start on boot

5. ✅ Configure Nginx
   - `antiparallel.app` → Frontend (Port 3000)
   - `api.antiparallel.app` → Backend (Port 8000)
   - CORS headers

6. ✅ Test Services
   - Backend API health check
   - Frontend accessibility

---

### Step 4: Setup SSL Certificate (HTTPS)

หลังจาก deploy สำเร็จ รัน SSL setup:

```bash
bash setup-ssl.sh
```

#### สิ่งที่ Script จะทำ:

1. ✅ Install Certbot
2. ✅ Obtain Let's Encrypt SSL certificates สำหรับ:
   - `antiparallel.app`
   - `www.antiparallel.app`
   - `api.antiparallel.app`
3. ✅ Update Backend `.env` เป็น HTTPS
4. ✅ Update Frontend `.env.local` เป็น HTTPS
5. ✅ Rebuild Frontend
6. ✅ Restart Services
7. ✅ Setup Auto-renewal

---

## 🧪 Testing After Deployment

### 1. Test Backend API

```bash
# Health Check
curl https://api.antiparallel.app/api/v1/health

# Expected response:
# {"status":"ok","timestamp":"...","service":"BoostMe Admin API"}
```

### 2. Test Register API

```bash
curl -X POST https://api.antiparallel.app/api/v1/auth/register \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "full_name": "Test User",
    "phone": "0812345678"
  }'

# Expected response:
# {"success":true,"message":"Registration successful","user":{...},"token":"..."}
```

### 3. Test Login API

```bash
curl -X POST https://api.antiparallel.app/api/v1/auth/login \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'

# Expected response:
# {"success":true,"message":"Login successful","user":{...},"token":"..."}
```

### 4. Test Frontend

เปิดเบราว์เซอร์:
```
https://antiparallel.app
```

ทดสอบ:
1. ✅ หน้าเว็บโหลดได้
2. ✅ คลิก "สมัครสมาชิก"
3. ✅ กรอกข้อมูลและส่งฟอร์ม
4. ✅ ตรวจสอบว่า register สำเร็จ
5. ✅ ทดสอบ Login

---

## 📊 Monitoring & Logs

### ดู Service Status

```bash
# Backend status
systemctl status brieflylearn-backend

# Frontend status
systemctl status brieflylearn-frontend

# Nginx status
systemctl status nginx
```

### ดู Logs

```bash
# Backend logs (real-time)
tail -f /var/log/brieflylearn-backend.log

# Backend error logs
tail -f /var/log/brieflylearn-backend-error.log

# Frontend logs (real-time)
tail -f /var/log/brieflylearn-frontend.log

# Frontend error logs
tail -f /var/log/brieflylearn-frontend-error.log

# Laravel logs
tail -f /var/www/backend/storage/logs/laravel.log

# Nginx access logs
tail -f /var/log/nginx/access.log

# Nginx error logs
tail -f /var/log/nginx/error.log
```

### ดู Logs ทั้งหมดพร้อมกัน

```bash
tail -f /var/log/brieflylearn-*.log
```

---

## 🔧 Troubleshooting

### ปัญหา: Backend ไม่ทำงาน

```bash
# ดู error logs
tail -50 /var/log/brieflylearn-backend-error.log

# ตรวจสอบ service
systemctl status brieflylearn-backend

# Restart service
systemctl restart brieflylearn-backend

# ตรวจสอบว่า port 8000 เปิดอยู่
netstat -tlnp | grep 8000
```

### ปัญหา: Frontend ไม่ทำงาน

```bash
# ดู error logs
tail -50 /var/log/brieflylearn-frontend-error.log

# ตรวจสอบ service
systemctl status brieflylearn-frontend

# Restart service
systemctl restart brieflylearn-frontend

# ตรวจสอบว่า port 3000 เปิดอยู่
netstat -tlnp | grep 3000
```

### ปัญหา: CORS Error

```bash
# ตรวจสอบ Backend .env
cat /var/www/backend/.env | grep CORS

# ควรเห็น:
# CORS_ALLOWED_ORIGINS=https://antiparallel.app,https://www.antiparallel.app,...

# ถ้าผิด แก้แล้ว restart
nano /var/www/backend/.env
systemctl restart brieflylearn-backend
```

### ปัญหา: SSL Certificate Error

```bash
# ตรวจสอบ certificate
certbot certificates

# Test renewal
certbot renew --dry-run

# Force renew
certbot renew --force-renewal
```

### ปัญหา: Database Connection Error

```bash
# ทดสอบ MySQL connection
mysql -u brieflyuser -pbrieflypass_2024 brieflylearn

# ตรวจสอบ tables
mysql -u brieflyuser -pbrieflypass_2024 brieflylearn -e "SHOW TABLES;"

# ตรวจสอบ users table
mysql -u brieflyuser -pbrieflypass_2024 brieflylearn -e "DESCRIBE users;"
```

### ปัญหา: Domain ไม่ชี้มา

```bash
# ตรวจสอบ DNS จาก VPS
dig antiparallel.app @8.8.8.8
dig api.antiparallel.app @8.8.8.8

# ตรวจสอบ Nginx config
nginx -t

# ดู Nginx error log
tail -f /var/log/nginx/error.log
```

---

## 🔄 Redeploy / Update Code

### อัพเดทเฉพาะ Backend

```bash
cd /var/www/backend
git pull origin main
composer install --optimize-autoloader --no-dev
php artisan config:cache
php artisan route:cache
systemctl restart brieflylearn-backend
```

### อัพเดทเฉพาะ Frontend

```bash
cd /var/www/frontend
git pull origin main
npm install
npm run build
systemctl restart brieflylearn-frontend
```

### Redeploy ทั้งหมด

```bash
cd /root
bash deploy-with-domain.sh
```

---

## 🔐 Security Checklist

- [x] SSL/HTTPS enabled
- [x] HTTP → HTTPS redirect
- [x] Environment variables secured (.env files)
- [x] Database credentials secured
- [ ] Firewall configured (UFW)
- [ ] SSH key-based authentication
- [ ] Fail2ban installed
- [ ] Regular backups configured

### Setup Firewall (Recommended)

```bash
# อนุญาตเฉพาะ port ที่จำเป็น
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw allow 3306/tcp  # MySQL (เฉพาะถ้าต้องการ remote access)
ufw enable
ufw status
```

---

## 📦 Backup Strategy

### สร้าง Database Backup

```bash
# Backup database
mysqldump -u brieflyuser -pbrieflypass_2024 brieflylearn > /root/backup-$(date +%Y%m%d).sql

# Compress
gzip /root/backup-$(date +%Y%m%d).sql
```

### Backup ทั้งระบบ

```bash
# Backup backend
tar -czf /root/backend-backup-$(date +%Y%m%d).tar.gz /var/www/backend

# Backup frontend
tar -czf /root/frontend-backup-$(date +%Y%m%d).tar.gz /var/www/frontend

# Backup database
mysqldump -u brieflyuser -pbrieflypass_2024 brieflylearn | gzip > /root/db-backup-$(date +%Y%m%d).sql.gz
```

---

## 📞 Quick Reference Commands

```bash
# View all logs
tail -f /var/log/brieflylearn-*.log

# Restart all services
systemctl restart brieflylearn-backend brieflylearn-frontend nginx

# Check service status
systemctl status brieflylearn-backend brieflylearn-frontend nginx

# Test backend locally
curl http://localhost:8000/api/v1/health

# Test frontend locally
curl http://localhost:3000

# View running processes
ps aux | grep -E "php|node"

# Check open ports
netstat -tlnp | grep -E "3000|8000|80|443"

# View disk usage
df -h

# View memory usage
free -h
```

---

## 🎯 Expected Final State

หลังจาก deploy สำเร็จ:

### URLs:
- ✅ **Frontend**: https://antiparallel.app
- ✅ **WWW Redirect**: https://www.antiparallel.app → https://antiparallel.app
- ✅ **Backend API**: https://api.antiparallel.app
- ✅ **Admin Panel**: https://api.antiparallel.app/admin
- ✅ **Health Check**: https://api.antiparallel.app/api/v1/health

### Services Running:
```
● brieflylearn-backend.service - Active (running)
● brieflylearn-frontend.service - Active (running)
● nginx.service - Active (running)
● mysql.service - Active (running)
```

### SSL Certificates:
```
Certificate Name: antiparallel.app
  Domains: antiparallel.app www.antiparallel.app api.antiparallel.app
  Expiry Date: (90 days from installation)
  Certificate Path: /etc/letsencrypt/live/antiparallel.app/fullchain.pem
  Private Key Path: /etc/letsencrypt/live/antiparallel.app/privkey.pem
```

---

## ✅ Post-Deployment Checklist

- [ ] All services are running
- [ ] Frontend accessible via https://antiparallel.app
- [ ] Backend API responding at https://api.antiparallel.app/api/v1/health
- [ ] Register function working (test via curl)
- [ ] Login function working (test via curl)
- [ ] Register via frontend working
- [ ] Login via frontend working
- [ ] SSL certificate valid (green padlock in browser)
- [ ] HTTP redirects to HTTPS
- [ ] No CORS errors in browser console
- [ ] Logs are being written
- [ ] Services auto-start on reboot (test with `reboot`)

---

## 🎉 Success!

หาก checklist ข้างบนผ่านหมด แสดงว่า deployment สำเร็จแล้วครับ!

ระบบพร้อมใช้งานที่:
- **https://antiparallel.app**
- **https://api.antiparallel.app**

---

## 📞 Need Help?

หากพบปัญหา รวบรวมข้อมูลเหล่านี้:

```bash
# สร้างไฟล์ debug info
cd /root
cat > debug-info.txt << 'EOF'
=== System Info ===
$(uname -a)
$(free -h)
$(df -h)

=== Services Status ===
$(systemctl status brieflylearn-backend --no-pager)
$(systemctl status brieflylearn-frontend --no-pager)
$(systemctl status nginx --no-pager)

=== Backend Logs ===
$(tail -50 /var/log/brieflylearn-backend-error.log)

=== Frontend Logs ===
$(tail -50 /var/log/brieflylearn-frontend-error.log)

=== Nginx Error Log ===
$(tail -50 /var/log/nginx/error.log)

=== Laravel Log ===
$(tail -50 /var/www/backend/storage/logs/laravel.log 2>/dev/null || echo "No Laravel logs")

=== Environment Check ===
Backend .env CORS:
$(grep CORS /var/www/backend/.env)

Frontend .env API URL:
$(grep NEXT_PUBLIC_API_URL /var/www/frontend/.env.local)

=== Network Tests ===
Backend Health (local): $(curl -s http://localhost:8000/api/v1/health)
Frontend (local): $(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000)
Backend Health (domain): $(curl -s https://api.antiparallel.app/api/v1/health)

=== SSL Certificate ===
$(certbot certificates)

=== DNS Check ===
$(dig antiparallel.app +short)
$(dig api.antiparallel.app +short)
EOF

cat debug-info.txt
```

แล้วส่ง `debug-info.txt` มาให้ดูครับ!
