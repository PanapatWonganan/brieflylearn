# แก้ปัญหา Database Import - BrieflyLearn

## ปัญหาที่พบบ่อย

### 1. Prisma Client ไม่ตรงกับ Database Schema

**อาการ:**
- Error: "Invalid `prisma.xxx.findMany()` invocation"
- "Table doesn't exist"
- "Column not found"

**วิธีแก้:**

```bash
cd /var/www/brieflylearn

# Step 1: Generate Prisma Client ใหม่
npx prisma generate

# Step 2: Push schema ไปยัง database
npx prisma db push

# Step 3: Rebuild application
npm run build

# Step 4: Restart PM2
pm2 restart brieflylearn
```

---

### 2. Database Connection ไม่ติด

**อาการ:**
- "Can't reach database server"
- "Connection timeout"
- "Authentication failed"

**วิธีแก้:**

```bash
# ตรวจสอบ DATABASE_URL ใน .env.local
cat .env.local | grep DATABASE_URL

# ทดสอบ connection
npx prisma db pull
```

**ตรวจสอบ DATABASE_URL format:**

```env
# Supabase (PostgreSQL)
DATABASE_URL="postgresql://postgres:[YOUR-PASSWORD]@db.[YOUR-PROJECT-REF].supabase.co:5432/postgres"

# หรือ Supabase Connection Pooling (แนะนำ)
DATABASE_URL="postgresql://postgres:[YOUR-PASSWORD]@db.[YOUR-PROJECT-REF].supabase.co:6543/postgres?pgbouncer=true"
```

---

### 3. Migration Conflicts

**อาการ:**
- "Migration failed"
- "Schema drift detected"
- "Conflicting migrations"

**วิธีแก้:**

```bash
cd /var/www/brieflylearn

# Option A: ใช้ db push (แนะนำสำหรับ development)
npx prisma db push --force-reset  # ⚠️ จะลบข้อมูลทั้งหมด

# Option B: Deploy migrations (แนะนำสำหรับ production)
npx prisma migrate deploy

# Option C: Reset migrations (ถ้าติดหนัก)
rm -rf prisma/migrations
npx prisma migrate dev --name init
```

---

## วิธีแก้ปัญหาแบบไม่ต้องทำใหม่หมด

### ขั้นตอนที่ 1: ตรวจสอบปัญหา

SSH เข้า VPS:
```bash
ssh root@207.148.76.203
cd /var/www/brieflylearn
```

ดู logs:
```bash
pm2 logs brieflylearn --lines 50
```

### ขั้นตอนที่ 2: แก้ไข Database

เลือกวิธีที่เหมาะสม:

**วิธีที่ 1: ใช้ Script อัตโนมัติ (แนะนำ)**
```bash
chmod +x scripts/setup-database.sh
./scripts/setup-database.sh
```

**วิธีที่ 2: Manual Fix**

```bash
# 1. สำรองข้อมูล (ถ้ามีข้อมูลสำคัญ)
npx prisma db pull  # ดึง schema จาก database มาดู

# 2. Generate Prisma Client
npx prisma generate

# 3. Push Schema ไป database
npx prisma db push

# 4. เช็คว่าผ่านหรือไม่
npx prisma studio  # เปิดดู database ใน browser
```

### ขั้นตอนที่ 3: Rebuild และ Restart

```bash
# 1. Clear cache
rm -rf .next

# 2. Rebuild
npm run build

# 3. Restart application
pm2 restart brieflylearn

# 4. ดู logs
pm2 logs brieflylearn
```

---

## แก้ปัญหาเฉพาะ: Supabase

### ปัญหา: SSL Connection

เพิ่มใน `DATABASE_URL`:
```env
DATABASE_URL="postgresql://...?sslmode=require"
```

### ปัญหา: Connection Pooling

ใช้ port 6543 แทน 5432:
```env
DATABASE_URL="postgresql://postgres:password@db.xxx.supabase.co:6543/postgres?pgbouncer=true"
```

### ปัญหา: Row Level Security (RLS)

ปิด RLS ชั่วคราวเพื่อทดสอบ:
```sql
-- ใน Supabase SQL Editor
ALTER TABLE "User" DISABLE ROW LEVEL SECURITY;
ALTER TABLE "Lesson" DISABLE ROW LEVEL SECURITY;
-- ทำกับทุก table
```

---

## Quick Fix Commands

### ทำให้ Database ตรงกับ Schema (ไม่ลบข้อมูล)
```bash
cd /var/www/brieflylearn
npx prisma db push
npx prisma generate
npm run build
pm2 restart brieflylearn
```

### Reset Database (ลบข้อมูลทั้งหมด - ระวัง!)
```bash
cd /var/www/brieflylearn
npx prisma db push --force-reset
npm run seed  # ถ้ามี seed script
npm run build
pm2 restart brieflylearn
```

### ดูสถานะ Database
```bash
# เปิด Prisma Studio
npx prisma studio
# จะเปิด browser ที่ http://localhost:5555

# หรือดูผ่าน command line
npx prisma db pull
```

---

## Debug Checklist

เช็คตามลำดับ:

- [ ] DATABASE_URL ถูกต้องใน `.env.local`
- [ ] เชื่อมต่อ database ได้ (`npx prisma db pull`)
- [ ] Prisma Client generate แล้ว (`npx prisma generate`)
- [ ] Schema sync แล้ว (`npx prisma db push`)
- [ ] Application build ผ่าน (`npm run build`)
- [ ] PM2 restart แล้ว (`pm2 restart brieflylearn`)
- [ ] ไม่มี error ใน logs (`pm2 logs brieflylearn`)

---

## ตัวอย่างการแก้ปัญหาจริง

### ปัญหา: "Table User doesn't exist"

```bash
# 1. เช็คว่า schema file มีหรือไม่
cat prisma/schema.prisma

# 2. Push schema ไป database
npx prisma db push

# 3. Generate client
npx prisma generate

# 4. Rebuild
npm run build && pm2 restart brieflylearn
```

### ปัญหา: "Invalid Prisma Client"

```bash
# 1. ลบ Prisma Client เก่า
rm -rf node_modules/.prisma
rm -rf node_modules/@prisma

# 2. ติดตั้งใหม่
npm install

# 3. Generate ใหม่
npx prisma generate

# 4. Rebuild
npm run build && pm2 restart brieflylearn
```

---

## เมื่อไหร่ควร "ทำใหม่หมด"

ทำใหม่หมด **เฉพาะเมื่อ:**

1. ❌ Database structure เปลี่ยนแปลงมากเกินไป
2. ❌ Migration conflicts ที่แก้ไม่ได้
3. ❌ ไม่มีข้อมูลสำคัญใน database
4. ❌ ต้องการเริ่มต้นใหม่ทั้งหมด

**อย่าทำใหม่หมด ถ้า:**

1. ✅ แค่ Prisma Client ไม่ sync → ใช้ `npx prisma generate`
2. ✅ แค่ schema drift → ใช้ `npx prisma db push`
3. ✅ แค่ build error → ใช้ `npm run build`
4. ✅ มีข้อมูลสำคัญอยู่แล้ว

---

## ติดต่อผม

ถ้ายังแก้ไม่ได้ ให้:

1. ดู error logs: `pm2 logs brieflylearn`
2. แชร์ error message มา
3. ตรวจสอบ `DATABASE_URL` ว่าถูกต้องไหม

**ส่วนใหญ่แล้ว การรัน:**
```bash
npx prisma generate && npx prisma db push && npm run build && pm2 restart brieflylearn
```
**จะแก้ปัญหาได้ครับ!**
