# First Time Deployment - BrieflyLearn

ปัญหาที่เจอ: ไม่มีไฟล์โปรเจคบน VPS เลย

## ขั้นตอนการ Deploy ครั้งแรก

### Step 1: เตรียม GitHub Repository

ก่อนอื่น ต้องมั่นใจว่าโปรเจคอยู่บน GitHub แล้ว

**ถ้ายังไม่ได้ push ไป GitHub:**

```bash
# ใน local machine (Mac ของคุณ)
cd /Users/panapat/brieflylearn

# Initialize git (ถ้ายังไม่ได้ทำ)
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit - BrieflyLearn project"

# Add remote (แทน YOUR_USERNAME ด้วย GitHub username ของคุณ)
git remote add origin https://github.com/YOUR_USERNAME/brieflylearn.git

# Push to GitHub
git push -u origin main
```

หรือถ้า push แล้วแต่ branch ชื่ออื่น:
```bash
git push -u origin master
```

---

### Step 2: SSH เข้า VPS และเริ่ม Deploy

```bash
# จาก local machine
ssh root@207.148.76.203
```

เมื่อเข้าไปแล้ว รันคำสั่งนี้:

```bash
# ลบ folder เก่าออก (ถ้ามี)
rm -rf /var/www/brieflylearn

# สร้างใหม่
mkdir -p /var/www/brieflylearn
cd /var/www/brieflylearn

# Clone repository (แทน YOUR_USERNAME และ YOUR_REPO)
git clone https://github.com/YOUR_USERNAME/brieflylearn.git .

# หรือถ้าใช้ SSH
# git clone git@github.com:YOUR_USERNAME/brieflylearn.git .
```

---

### Step 3: ตรวจสอบว่าไฟล์ครบหรือไม่

```bash
# เช็คว่ามีไฟล์สำคัญครบไหม
ls -la

# ควรเห็น:
# - package.json
# - prisma/
# - src/
# - next.config.mjs
# - .env.local (ต้องสร้างเอง)
```

ถ้าไม่มี `package.json` แสดงว่า clone ผิดที่ หรือ repo ว่างเปล่า

---

### Step 4: สร้าง .env.local

```bash
# สร้างไฟล์ .env.local
nano .env.local
```

วาง environment variables เหล่านี้:

```env
# Database (Supabase)
DATABASE_URL="postgresql://postgres.YOUR_PROJECT:YOUR_PASSWORD@aws-0-ap-southeast-1.pooler.supabase.com:6543/postgres?pgbouncer=true&connection_limit=1"

# Supabase
NEXT_PUBLIC_SUPABASE_URL="https://YOUR_PROJECT.supabase.co"
NEXT_PUBLIC_SUPABASE_ANON_KEY="your-anon-key"
SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"

# Stripe
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY="pk_test_xxxxx"
STRIPE_SECRET_KEY="sk_test_xxxxx"
STRIPE_WEBHOOK_SECRET="whsec_xxxxx"

# NextAuth
NEXTAUTH_URL="http://207.148.76.203"
NEXTAUTH_SECRET="run: openssl rand -base64 32"

# App
NEXT_PUBLIC_APP_URL="http://207.148.76.203"
NODE_ENV="production"
```

**บันทึกไฟล์:** กด `Ctrl + X`, แล้ว `Y`, แล้ว `Enter`

---

### Step 5: Run Deployment Script

```bash
# ทำให้ script executable
chmod +x deploy.sh

# รัน deployment
./deploy.sh
```

Script จะทำทุกอย่างให้อัตโนมัติ:
- ติดตั้ง Node.js, PM2, Nginx
- ติดตั้ง dependencies
- Build application
- Start with PM2
- Configure Nginx

---

### Step 6: Setup Database

หลังจาก deploy เสร็จ ให้ setup database:

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

### Step 7: Restart Application

```bash
# Rebuild
npm run build

# Restart PM2
pm2 restart brieflylearn

# Check status
pm2 status

# View logs
pm2 logs brieflylearn
```

---

## ถ้าไม่มี GitHub Repository

ถ้าคุณไม่ได้ใช้ Git สามารถ copy files จาก local ไป VPS ได้:

```bash
# จาก local machine (Mac)
cd /Users/panapat/brieflylearn

# Copy ไฟล์ไป VPS (ไม่ copy node_modules)
rsync -avz --exclude 'node_modules' --exclude '.next' --exclude '.git' \
  -e "ssh" \
  . root@207.148.76.203:/var/www/brieflylearn/
```

แล้วค่อย SSH เข้าไปรัน:
```bash
ssh root@207.148.76.203
cd /var/www/brieflylearn
./deploy.sh
```

---

## Common Issues

### Issue 1: Git clone ไม่ได้

```bash
# ถ้า repo เป็น private ต้อง authenticate
# Option A: ใช้ Personal Access Token
git clone https://YOUR_TOKEN@github.com/YOUR_USERNAME/brieflylearn.git .

# Option B: Setup SSH key
ssh-keygen -t ed25519 -C "your-email@example.com"
cat ~/.ssh/id_ed25519.pub
# Copy key ไปใส่ใน GitHub Settings > SSH Keys
```

### Issue 2: Permission denied

```bash
# เปลี่ยน owner ของ folder
chown -R root:root /var/www/brieflylearn
chmod -R 755 /var/www/brieflylearn
```

### Issue 3: npm install ล้มเหลว

```bash
# Update npm
npm install -g npm@latest

# Clear cache
npm cache clean --force

# Try again
npm install
```

---

## Quick Summary

```bash
# 1. SSH to VPS
ssh root@207.148.76.203

# 2. Clean and clone
rm -rf /var/www/brieflylearn
mkdir -p /var/www/brieflylearn
cd /var/www/brieflylearn
git clone YOUR_REPO_URL .

# 3. Create .env.local
nano .env.local
# (paste environment variables)

# 4. Deploy
chmod +x deploy.sh
./deploy.sh

# 5. Setup database
npx prisma generate
npx prisma db push

# 6. Done!
pm2 logs brieflylearn
```

---

## Next Steps After Deployment

1. เข้าดูเว็บที่: http://207.148.76.203
2. ถ้าใช้งานได้ ค่อย setup domain และ SSL
3. Setup GitHub Actions สำหรับ auto-deploy

---

## Need Help?

ถ้ายังติดปัญหา บอกผมว่า:
1. ใช้ GitHub หรือไม่?
2. Repo URL คืออะไร?
3. Error message ที่เจอคืออะไร?
