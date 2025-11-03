# 🔧 BrieflyLearn - Authentication Fix Deployment Guide

## ปัญหาที่พบ
❌ Register และ Login เข้าระบบไม่ได้หลัง deploy ไปที่ VPS

## สาเหตุ

### 1. Backend Configuration ผิด
- ใช้ `php -S` แทน `php artisan serve`
- ไม่มีการตั้งค่า CORS อย่างถูกต้อง
- `.env` ไม่มี `CORS_ALLOWED_ORIGINS`

### 2. Frontend API URL ไม่ตรง
- Frontend พยายามเรียก `https://api.brieflylearn.com` แต่ domain ยังไม่ได้ตั้งค่า
- ควรใช้ `http://VPS_IP:8000/api/v1` แทน

### 3. Services ไม่มี Logging
- ไม่สามารถ debug ปัญหาได้เมื่อเกิด error

## วิธีแก้ไข

### 📦 สิ่งที่แก้ไขใน `deploy-fixed.sh`

#### 1. **Backend .env - เพิ่ม CORS Configuration**
```bash
CORS_ALLOWED_ORIGINS=http://${VPS_IP}:3000,http://localhost:3000
FRONTEND_URL=http://${VPS_IP}:3000
SANCTUM_STATEFUL_DOMAINS=${VPS_IP}:3000,localhost:3000
APP_URL=http://${VPS_IP}:8000
```

#### 2. **Frontend .env.local - ใช้ VPS IP แทน Domain**
```bash
NEXT_PUBLIC_API_URL=http://${VPS_IP}:8000/api/v1
NEXT_PUBLIC_APP_URL=http://${VPS_IP}:3000
```

#### 3. **Systemd Services - เพิ่ม Logging**
- Backend: ใช้ `php artisan serve` แทน `php -S`
- Log files: `/var/log/brieflylearn-backend.log`
- Error logs: `/var/log/brieflylearn-backend-error.log`

#### 4. **Service Health Check**
- เพิ่มการทดสอบ API หลัง deploy
- แสดง logs ทันทีถ้ามีปัญหา

---

## 🚀 วิธี Deploy

### ขั้นตอนที่ 1: อัพโหลด Script ไปยัง VPS

จากเครื่อง Local:
```bash
scp deploy-fixed.sh root@207.148.76.203:/root/
```

### ขั้นตอนที่ 2: SSH เข้า VPS

```bash
ssh root@207.148.76.203
```

### ขั้นตอนที่ 3: รัน Deploy Script

```bash
cd /root
chmod +x deploy-fixed.sh
./deploy-fixed.sh
```

Script จะทำงานอัตโนมัติ:
1. ✅ Deploy Laravel Backend พร้อม CORS config
2. ✅ Import Database
3. ✅ Deploy Next.js Frontend พร้อม API URL ที่ถูกต้อง
4. ✅ สร้าง Systemd Services พร้อม logging
5. ✅ ทดสอบ Services

### ขั้นตอนที่ 4: ตรวจสอบผลลัพธ์

หลัง deploy เสร็จ คุณจะเห็น:

```
✅ Deployment Complete!

🔗 Your Applications:
  Frontend: http://207.148.76.203:3000
  Backend API: http://207.148.76.203:8000
  Health Check: http://207.148.76.203:8000/api/v1/health
```

---

## 🧪 วิธีทดสอบ Authentication

### 1. ทดสอบ Backend API
```bash
curl http://207.148.76.203:8000/api/v1/health
```
ควรได้ response:
```json
{
  "status": "ok",
  "timestamp": "2025-11-03T...",
  "service": "BoostMe Admin API"
}
```

### 2. ทดสอบ Register API
```bash
curl -X POST http://207.148.76.203:8000/api/v1/auth/register \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "full_name": "Test User",
    "phone": "0812345678"
  }'
```

ควรได้ response:
```json
{
  "success": true,
  "message": "Registration successful",
  "user": { ... },
  "token": "..."
}
```

### 3. ทดสอบ Login API
```bash
curl -X POST http://207.148.76.203:8000/api/v1/auth/login \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### 4. ทดสอบผ่าน Frontend
เปิดเบราว์เซอร์:
```
http://207.148.76.203:3000
```

ทดสอบ:
1. คลิก "สมัครสมาชิก"
2. กรอกข้อมูล
3. ตรวจสอบว่า register สำเร็จ
4. ทดสอบ Login

---

## 📋 Troubleshooting

### ถ้า Backend ไม่ทำงาน

#### ดู Logs:
```bash
tail -f /var/log/brieflylearn-backend-error.log
```

#### ตรวจสอบ Service Status:
```bash
systemctl status brieflylearn-backend
```

#### Restart Service:
```bash
systemctl restart brieflylearn-backend
```

#### ดู Laravel Logs:
```bash
tail -f /var/www/backend/storage/logs/laravel.log
```

### ถ้า Frontend ไม่ทำงาน

#### ดู Logs:
```bash
tail -f /var/log/brieflylearn-frontend-error.log
```

#### ตรวจสอบ Service Status:
```bash
systemctl status brieflylearn-frontend
```

#### Restart Service:
```bash
systemctl restart brieflylearn-frontend
```

### ถ้า Authentication ยังไม่ทำงาน

#### 1. เช็ค CORS Headers
```bash
curl -I http://207.148.76.203:8000/api/v1/health
```
ต้องมี header:
```
Access-Control-Allow-Origin: *
```

#### 2. เช็ค Database Connection
```bash
cd /var/www/backend
php artisan tinker
>>> DB::connection()->getPdo();
```

#### 3. เช็คว่า Users Table มีอยู่
```bash
mysql -u brieflyuser -pbrieflypass_2024 brieflylearn -e "SHOW TABLES;"
mysql -u brieflyuser -pbrieflypass_2024 brieflylearn -e "DESCRIBE users;"
```

#### 4. ทดสอบสร้าง User ผ่าน Backend
```bash
cd /var/www/backend
php artisan tinker
>>> $user = App\Models\User::create([
...   'id' => \Str::uuid(),
...   'email' => 'admin@test.com',
...   'password_hash' => \Hash::make('admin123'),
...   'full_name' => 'Admin User',
...   'role' => 'admin',
...   'email_verified' => true
... ]);
>>> $user->id;
```

### ถ้ามี Network Error

#### เช็ค Firewall
```bash
# อนุญาต port 3000 และ 8000
ufw allow 3000
ufw allow 8000
ufw status
```

#### เช็ค Nginx (ถ้ามี)
```bash
nginx -t
systemctl status nginx
```

---

## 🔄 วิธี Redeploy หลังแก้โค้ด

### แบบเร็ว (อัพเดทเฉพาะ Backend)
```bash
cd /var/www/backend
git pull
composer install --optimize-autoloader --no-dev
php artisan config:cache
php artisan route:cache
systemctl restart brieflylearn-backend
```

### แบบเร็ว (อัพเดทเฉพาะ Frontend)
```bash
cd /var/www/frontend
git pull
npm install
npm run build
systemctl restart brieflylearn-frontend
```

### แบบเต็ม (Redeploy ทั้งหมด)
```bash
cd /root
./deploy-fixed.sh
```

---

## 📊 การ Monitor Services

### ดู Logs แบบ Real-time
```bash
# Backend
tail -f /var/log/brieflylearn-backend.log

# Frontend
tail -f /var/log/brieflylearn-frontend.log

# ทั้งสอง
tail -f /var/log/brieflylearn-*.log
```

### ดู System Journal
```bash
journalctl -u brieflylearn-backend -f
journalctl -u brieflylearn-frontend -f
```

### ดู Process
```bash
ps aux | grep php
ps aux | grep node
```

---

## ✅ Checklist หลัง Deploy

- [ ] Backend API ตอบกลับที่ `/api/v1/health`
- [ ] Frontend แสดงหน้าเว็บได้
- [ ] Register API ทำงาน (ทดสอบด้วย curl)
- [ ] Login API ทำงาน (ทดสอบด้วย curl)
- [ ] Register ผ่าน Frontend ทำงาน
- [ ] Login ผ่าน Frontend ทำงาน
- [ ] CORS headers ถูกต้อง
- [ ] Database มี users table
- [ ] Services รันอัตโนมัติตอน reboot

---

## 🎯 Next Steps หลังจากแก้ปัญหา

1. **ตั้งค่า Domain**
   - ชี้ `brieflylearn.com` → VPS IP
   - ชี้ `api.brieflylearn.com` → VPS IP

2. **ติดตั้ง SSL Certificate**
   ```bash
   apt install certbot python3-certbot-nginx
   certbot --nginx -d brieflylearn.com -d api.brieflylearn.com
   ```

3. **อัพเดท .env ให้ใช้ HTTPS**
   ```bash
   # Backend
   APP_URL=https://api.brieflylearn.com
   FRONTEND_URL=https://brieflylearn.com

   # Frontend
   NEXT_PUBLIC_API_URL=https://api.brieflylearn.com/api/v1
   NEXT_PUBLIC_APP_URL=https://brieflylearn.com
   ```

4. **ตั้งค่า Nginx Reverse Proxy**
   - Frontend: Port 443 → 3000
   - Backend: Port 443 → 8000

---

## 📞 Support

หากพบปัญหา กรุณาเก็บ logs มาด้วย:
```bash
# สร้างไฟล์ logs สำหรับ debug
cd /root
cat > debug-info.txt << EOF
=== Backend Status ===
$(systemctl status brieflylearn-backend --no-pager)

=== Frontend Status ===
$(systemctl status brieflylearn-frontend --no-pager)

=== Backend Logs ===
$(tail -50 /var/log/brieflylearn-backend-error.log)

=== Frontend Logs ===
$(tail -50 /var/log/brieflylearn-frontend-error.log)

=== Laravel Logs ===
$(tail -50 /var/www/backend/storage/logs/laravel.log 2>/dev/null || echo "No Laravel logs")

=== Curl Tests ===
Backend Health: $(curl -s http://localhost:8000/api/v1/health)
Frontend: $(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000)
EOF

cat debug-info.txt
```

แล้วส่ง `debug-info.txt` มาให้ดูครับ
