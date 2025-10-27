# 🚀 Manual Deployment Steps - BrieflyLearn

เนื่องจากไม่สามารถ SSH ด้วย password อัตโนมัติได้ ให้คุณทำตามขั้นตอนนี้เอง

---

## ขั้นตอนที่ 1: SSH เข้า VPS

เปิด Terminal แล้วรันคำสั่งนี้:

```bash
ssh root@207.148.76.203
```

**Password**: `2(hVW],PciL[,Z2?`

---

## ขั้นตอนที่ 2: Clone Repository

หลังจาก SSH เข้าไปแล้ว ให้รันคำสั่งนี้:

```bash
# ลบ folder เก่า (ถ้ามี)
rm -rf /var/www/brieflylearn

# สร้าง directory ใหม่
mkdir -p /var/www/brieflylearn
cd /var/www/brieflylearn

# Clone repository
git clone https://github.com/PanapatWonganan/brieflylearn.git .

# ตรวจสอบว่าไฟล์ครบไหม
ls -la
```

คุณควรเห็นไฟล์เหล่านี้:
- ✅ package.json
- ✅ deploy.sh
- ✅ prisma/
- ✅ src/ (ถ้ามี)
- ✅ README.md

---

## ขั้นตอนที่ 3: สร้างไฟล์ .env.local

```bash
nano .env.local
```

วาง environment variables เหล่านี้ (แก้ไขค่าให้ถูกต้อง):

```env
# Database (Supabase PostgreSQL)
DATABASE_URL="postgresql://postgres.[YOUR-PROJECT]:[YOUR-PASSWORD]@aws-0-ap-southeast-1.pooler.supabase.com:6543/postgres?pgbouncer=true"

# Supabase
NEXT_PUBLIC_SUPABASE_URL="https://[YOUR-PROJECT].supabase.co"
NEXT_PUBLIC_SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
SUPABASE_SERVICE_ROLE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# Stripe (ใส่ของจริง หรือ test keys)
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY="pk_test_xxxxx"
STRIPE_SECRET_KEY="sk_test_xxxxx"
STRIPE_WEBHOOK_SECRET="whsec_xxxxx"

# NextAuth
NEXTAUTH_URL="http://207.148.76.203"
NEXTAUTH_SECRET="$(openssl rand -base64 32)"

# App
NEXT_PUBLIC_APP_URL="http://207.148.76.203"
NODE_ENV="production"
```

**บันทึกไฟล์:**
- กด `Ctrl + X`
- กด `Y`
- กด `Enter`

---

## ขั้นตอนที่ 4: รัน Deployment Script

```bash
chmod +x deploy.sh
./deploy.sh
```

Script จะทำอัตโนมัติ:
1. ติดตั้ง Node.js, PM2, Nginx
2. ติดตั้ง dependencies
3. Build application
4. Start ด้วย PM2
5. Config Nginx

**รอประมาณ 5-10 นาที**

---

## ขั้นตอนที่ 5: Setup Database

```bash
cd /var/www/brieflylearn

# Generate Prisma Client
npx prisma generate

# Push schema to database
npx prisma db push

# (Optional) Seed database
npm run seed 2>/dev/null || echo "No seed script"
```

---

## ขั้นตอนที่ 6: Rebuild และ Restart

```bash
# Rebuild application
npm run build

# Restart PM2
pm2 restart brieflylearn

# Check status
pm2 status
```

---

## ขั้นตอนที่ 7: ตรวจสอบ

### ดู Logs
```bash
pm2 logs brieflylearn
```

### ดูสถานะ
```bash
pm2 status
pm2 monit
```

### เปิด browser
ไปที่: **http://207.148.76.203**

---

## 🛠️ Troubleshooting

### ปัญหา: Build ล้มเหลว

```bash
# Clear cache
rm -rf .next node_modules

# Install again
npm install

# Try build
npm run build
```

### ปัญหา: Database connection error

```bash
# ตรวจสอบ DATABASE_URL
cat .env.local | grep DATABASE_URL

# Test connection
npx prisma db pull
```

### ปัญหา: Port 3000 ถูกใช้แล้ว

```bash
# หา process ที่ใช้ port 3000
lsof -i :3000

# Kill process
kill -9 <PID>

# Restart
pm2 restart brieflylearn
```

### ปัญหา: Nginx 502 Bad Gateway

```bash
# Check app status
pm2 status

# Check if app responds
curl http://localhost:3000

# Restart everything
pm2 restart brieflylearn
systemctl restart nginx
```

---

## 📊 Useful Commands

| Command | Description |
|---------|-------------|
| `pm2 status` | ดูสถานะ app |
| `pm2 logs brieflylearn` | ดู logs |
| `pm2 restart brieflylearn` | Restart app |
| `pm2 monit` | Monitor resources |
| `nginx -t` | Test Nginx config |
| `systemctl restart nginx` | Restart Nginx |
| `cd /var/www/brieflylearn && git pull` | Update code |

---

## 🔄 Update Application (ในอนาคต)

```bash
cd /var/www/brieflylearn
git pull origin main
npm install
npm run build
npx prisma generate
npx prisma db push
pm2 restart brieflylearn
```

---

## ✅ Checklist

ตรวจสอบทีละข้อ:

- [ ] SSH เข้า VPS ได้
- [ ] Clone repository สำเร็จ
- [ ] สร้าง .env.local แล้ว
- [ ] รัน deploy.sh สำเร็จ
- [ ] Prisma generate และ db push สำเร็จ
- [ ] Build สำเร็จ
- [ ] PM2 running (pm2 status แสดง "online")
- [ ] เปิด browser ที่ http://207.148.76.203 ได้

---

## 🎉 เมื่อทุกอย่างเสร็จ

คุณควรเห็น:

1. **PM2 Status**: `online`
2. **Browser**: แสดงหน้าเว็บ BrieflyLearn
3. **Logs**: ไม่มี error

---

## 📞 Need Help?

ถ้าติดปัญหา:
1. รัน `pm2 logs brieflylearn` ดู error
2. แชร์ error message มา
3. ตรวจสอบ `.env.local` ว่าถูกต้องไหม

---

**ขอให้โชคดีครับ! 🚀**
