# 🚀 BrieflyLearn - Quick Start (5 นาที)

## 🎯 ขั้นตอนสั้น ๆ สำหรับ Deploy

### 1️⃣ อัพโหลด Scripts (30 วินาที)

จากเครื่องคุณ:
```bash
cd /Users/panapat/brieflylearn
scp deploy-with-domain.sh setup-ssl.sh root@207.148.76.203:/root/
```

---

### 2️⃣ Deploy แอพพลิเคชัน (3-5 นาที)

SSH เข้า VPS:
```bash
ssh root@207.148.76.203
cd /root
bash deploy-with-domain.sh
```

รอจนเสร็จ... ☕

---

### 3️⃣ Setup SSL (1-2 นาที)

```bash
bash setup-ssl.sh
```

---

### 4️⃣ ทดสอบ (30 วินาที)

เปิดเบราว์เซอร์:
```
https://antiparallel.app
```

ทดสอบ Register และ Login!

---

## ✅ เสร็จแล้ว!

เว็บคุณพร้อมใช้งานที่:
- **Frontend**: https://antiparallel.app
- **Backend API**: https://api.antiparallel.app
- **Admin**: https://api.antiparallel.app/admin

---

## 🧪 คำสั่งทดสอบด่วน

### ทดสอบ Backend API:
```bash
curl https://api.antiparallel.app/api/v1/health
```

### ทดสอบ Register:
```bash
curl -X POST https://api.antiparallel.app/api/v1/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"email":"test@test.com","password":"test1234","full_name":"Test User"}'
```

### ทดสอบ Login:
```bash
curl -X POST https://api.antiparallel.app/api/v1/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"test@test.com","password":"test1234"}'
```

---

## 🔧 คำสั่งที่ใช้บ่อย

### ดู Logs:
```bash
tail -f /var/log/brieflylearn-backend.log
tail -f /var/log/brieflylearn-frontend.log
```

### Restart Services:
```bash
systemctl restart brieflylearn-backend
systemctl restart brieflylearn-frontend
```

### ตรวจสอบ Status:
```bash
systemctl status brieflylearn-backend
systemctl status brieflylearn-frontend
```

---

## ❓ มีปัญหา?

ดูคู่มือเต็ม: **DEPLOY_INSTRUCTIONS.md**

หรือสร้าง debug info:
```bash
cd /root
bash -c 'tail -50 /var/log/brieflylearn-*.log'
```

---

## 📞 Support Checklist

หากต้องการความช่วยเหลือ ส่งข้อมูลเหล่านี้มา:

```bash
# 1. Service status
systemctl status brieflylearn-backend brieflylearn-frontend

# 2. Error logs
tail -50 /var/log/brieflylearn-backend-error.log
tail -50 /var/log/brieflylearn-frontend-error.log

# 3. Test API
curl https://api.antiparallel.app/api/v1/health

# 4. Check DNS
dig antiparallel.app +short
dig api.antiparallel.app +short
```

---

**🎉 Happy Deploying!**
