# 🚂 Railway Deployment Guide - BoostMe

## 📌 Prerequisites
- สมัคร Account Railway: https://railway.app
- ติดตั้ง Railway CLI (Optional): `npm install -g @railway/cli`
- GitHub Account ที่มี repository

---

## 🔧 Part 1: Setup บน Railway Dashboard

### Step 1: สร้าง Project ใหม่
1. Login Railway → **New Project**
2. เลือก **Empty Project**
3. ตั้งชื่อ Project: `boostme-backend`

### Step 2: เพิ่ม MySQL Database
1. ใน Project → Click **+ New**
2. เลือก **Database** → **MySQL**
3. รอ MySQL provision เสร็จ (2-3 นาที)
4. Click เข้า MySQL service → Tab **Variables**
5. Copy ค่าเหล่านี้เก็บไว้:
   - `MYSQL_HOST` → ใช้เป็น DB_HOST
   - `MYSQL_PORT` → ใช้เป็น DB_PORT
   - `MYSQL_DATABASE` → ใช้เป็น DB_DATABASE
   - `MYSQL_USER` → ใช้เป็น DB_USERNAME
   - `MYSQL_PASSWORD` → ใช้เป็น DB_PASSWORD

### Step 3: Import Database
1. ใน MySQL service → Tab **Data**
2. Click **Connect** → เลือก **Railway CLI**
3. Run คำสั่ง:
```bash
railway link
railway run mysql -u root -p$MYSQL_ROOT_PASSWORD fitness_lms < database_backup.sql
```

หรือใช้ MySQL client:
```bash
mysql -h [MYSQL_HOST] -P [MYSQL_PORT] -u [MYSQL_USER] -p[MYSQL_PASSWORD] [MYSQL_DATABASE] < database_backup.sql
```

---

## 🚀 Part 2: Deploy Laravel API

### Step 1: Push Code ขึ้น GitHub
```bash
cd fitness-lms-admin
git init
git add .
git commit -m "Initial commit for Railway deployment"
git remote add origin https://github.com/YOUR_USERNAME/boostme-backend.git
git push -u origin main
```

### Step 2: Connect GitHub กับ Railway
1. ใน Railway Project → Click **+ New**
2. เลือก **GitHub Repo**
3. Authorize Railway เข้า GitHub
4. เลือก Repository: `boostme-backend`
5. Branch: `main`

### Step 3: ตั้งค่า Environment Variables
Click เข้า Laravel service → Tab **Variables** → **RAW Editor**:

```env
# App Settings
APP_NAME=BoostMe
APP_ENV=production
APP_KEY=base64:YOUR_GENERATED_KEY_HERE
APP_DEBUG=false
APP_URL=https://boostme-backend-production.up.railway.app

# Database (ใช้ค่าจาก MySQL service)
DB_CONNECTION=mysql
DB_HOST=${{MySQL.MYSQL_HOST}}
DB_PORT=${{MySQL.MYSQL_PORT}}
DB_DATABASE=${{MySQL.MYSQL_DATABASE}}
DB_USERNAME=${{MySQL.MYSQL_USER}}
DB_PASSWORD=${{MySQL.MYSQL_PASSWORD}}

# CORS Settings (เปลี่ยนเป็น URL Vercel ของคุณ)
CORS_ALLOWED_ORIGINS=https://your-app.vercel.app,http://localhost:3000

# Session
SESSION_DRIVER=file
SESSION_LIFETIME=120

# Cache
CACHE_DRIVER=file
QUEUE_CONNECTION=sync

# Storage
FILESYSTEM_DISK=local

# Admin Credentials
ADMIN_EMAIL=admin@boostme.com
ADMIN_PASSWORD=YourSecurePassword123!
```

### Step 4: Generate APP_KEY
```bash
# ใน terminal local
php artisan key:generate --show
# Copy key ที่ได้ (base64:xxxxx) ไปใส่ใน APP_KEY
```

### Step 5: Deploy
1. Railway จะ auto-deploy เมื่อ push code
2. ดู Logs ใน Tab **Deployments**
3. รอจนกว่า Status เป็น **Success**

### Step 6: Get Public URL
1. ใน Laravel service → Tab **Settings**
2. Section **Networking** → Click **Generate Domain**
3. Copy URL ที่ได้ เช่น: `boostme-backend-production.up.railway.app`

---

## 🎨 Part 3: Update Frontend (Vercel)

### Step 1: Update Environment Variables ใน Vercel
1. Login Vercel Dashboard
2. เข้า Project → Settings → Environment Variables
3. Update:
```env
NEXT_PUBLIC_API_URL=https://boostme-backend-production.up.railway.app
```

### Step 2: Redeploy Frontend
```bash
cd fitness-lms
git add .
git commit -m "Update API URL for production"
git push
# Vercel จะ auto-deploy
```

หรือ Manual redeploy:
1. Vercel Dashboard → Project
2. Tab **Deployments**
3. Click **...** → **Redeploy**

---

## ✅ Part 4: Testing & Verification

### Test Checklist:
- [ ] API Health Check: `https://your-api.railway.app/api/v1/health`
- [ ] Database Connection: Check logs ไม่มี error
- [ ] CORS: Frontend เรียก API ได้
- [ ] Authentication: Login/Register ทำงาน
- [ ] Garden API: `/api/v1/garden/my-garden`
- [ ] File Upload: ทดสอบ upload รูป
- [ ] Admin Panel: `https://your-api.railway.app/admin`

### Debug Commands:
```bash
# ดู Logs
railway logs

# Run artisan commands
railway run php artisan migrate:status
railway run php artisan config:clear
railway run php artisan cache:clear
```

---

## 🔧 Part 5: Common Issues & Solutions

### Issue 1: Database Connection Error
```
Solution:
- ตรวจสอบ DB credentials ถูกต้อง
- ใช้ Reference variables: ${{MySQL.MYSQL_HOST}}
```

### Issue 2: CORS Error
```
Solution:
- เพิ่ม Vercel URL ใน CORS_ALLOWED_ORIGINS
- Clear cache: railway run php artisan config:cache
```

### Issue 3: 500 Server Error
```
Solution:
- Set APP_DEBUG=true ชั่วคราวเพื่อดู error
- Check logs: railway logs --tail
```

### Issue 4: Storage Link Error
```
Solution:
railway run php artisan storage:link
```

---

## 💰 Cost Estimation

### Railway Pricing:
- **Hobby Plan**: $5/month (includes)
  - $5 usage credit
  - 8GB RAM
  - 100GB bandwidth
- **MySQL**: ~$5-10/month (based on usage)
- **Total**: ~$10-15/month

### Vercel (Frontend):
- **Hobby**: Free
- **Pro**: $20/month (ถ้าต้องการ features เพิ่ม)

---

## 🚀 Next Steps

1. **Setup Monitoring**:
   - Railway Metrics
   - Sentry for error tracking
   - UptimeRobot for uptime monitoring

2. **Backup Strategy**:
   - Daily database backups
   - Setup Railway backup automation

3. **Security**:
   - Enable 2FA on Railway
   - Rotate APP_KEY regularly
   - Use secrets management

4. **Performance**:
   - Enable Redis caching (add Redis service)
   - Setup CDN for static assets
   - Optimize database queries

---

## 📞 Support Resources

- Railway Docs: https://docs.railway.app
- Railway Discord: https://discord.gg/railway
- Laravel Deploy Guide: https://docs.railway.app/guides/laravel
- Vercel Docs: https://vercel.com/docs

---

**Last Updated**: August 2024
**Project**: BoostMe - Fitness LMS Platform