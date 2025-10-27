# ✅ BrieflyLearn Deployment Checklist

## 📋 Pre-Deployment Checklist

### 🔧 Local Development (ทำก่อน Deploy)

- [ ] **Test ระบบให้ครบทุก Feature**
  - [ ] Login/Register ทำงานปกติ
  - [ ] Course listing แสดงผลถูกต้อง
  - [ ] Lesson video เล่นได้
  - [ ] Garden system ทำงาน
  - [ ] Achievement system ทำงาน
  - [ ] Admin panel เข้าถึงได้และจัดการข้อมูลได้

- [ ] **Database Migration Ready**
  - [ ] ทดสอบ migration สำเร็จบน local
  - [ ] มี seeder สำหรับข้อมูลเริ่มต้น (ถ้าจำเป็น)
  - [ ] Backup database schema

- [ ] **Environment Files**
  - [ ] สร้าง `.env.production.example` แล้ว
  - [ ] ลบข้อมูลที่เป็น sensitive data ออก
  - [ ] เตรียม password ที่แข็งแรงสำหรับ production

- [ ] **Git Repository**
  - [ ] สร้าง repository บน GitHub/GitLab แล้ว
  - [ ] `.gitignore` ครบถ้วน (ไม่ commit `.env`, `vendor/`, `node_modules/`)
  - [ ] Push code ขึ้น repository แล้ว
  - [ ] Tag version (เช่น v1.0.0)

---

## 🏗️ Server Setup Checklist

### 1. Vultr Instance

- [ ] **สร้าง Vultr Server**
  - [ ] Location: Singapore (ใกล้ไทยที่สุด)
  - [ ] OS: Ubuntu 22.04 LTS
  - [ ] Plan: อย่างน้อย 2GB RAM
  - [ ] เปิดใช้งาน SSH Key

- [ ] **เชื่อมต่อ Server**
  - [ ] SSH เข้าได้แล้ว: `ssh root@YOUR_IP`
  - [ ] เปลี่ยน root password

### 2. Software Installation

- [ ] **Update System**
  ```bash
  apt update && apt upgrade -y
  ```

- [ ] **Install Essential Software**
  - [ ] Nginx
  - [ ] PHP 8.2 + Extensions
  - [ ] Composer
  - [ ] MySQL 8.0
  - [ ] Node.js 20
  - [ ] Git
  - [ ] Certbot (SSL)

- [ ] **ตรวจสอบ Versions**
  - [ ] `php -v` → 8.2.x
  - [ ] `composer --version` → 2.x
  - [ ] `mysql --version` → 8.0.x
  - [ ] `node -v` → v20.x
  - [ ] `nginx -v` → 1.x

### 3. Database Setup

- [ ] **สร้าง Database**
  - [ ] Database: `brieflylearn_production`
  - [ ] User: `brieflylearn_user`
  - [ ] ตั้ง password ที่แข็งแรง
  - [ ] Grant privileges

- [ ] **ทดสอบ Connection**
  ```bash
  mysql -u brieflylearn_user -p brieflylearn_production
  ```

### 4. User Setup

- [ ] **สร้าง Deploy User**
  - [ ] `adduser deploy`
  - [ ] เพิ่มเข้า www-data group
  - [ ] ทดสอบ switch: `su - deploy`

---

## 📦 Backend Deployment Checklist

### 1. Clone Repository

- [ ] **Setup SSH Key**
  - [ ] Generate key บน server: `ssh-keygen`
  - [ ] Add key ไปที่ GitHub
  - [ ] ทดสอบ: `ssh -T git@github.com`

- [ ] **Clone Code**
  ```bash
  cd /var/www
  git clone git@github.com:YOUR_USERNAME/brieflylearn-backend.git brieflylearn
  ```

### 2. Install Dependencies

- [ ] **Composer Install**
  ```bash
  composer install --optimize-autoloader --no-dev
  ```

- [ ] **NPM Install & Build**
  ```bash
  npm install
  npm run build
  ```

### 3. Configuration

- [ ] **Environment File**
  - [ ] Copy `.env.production.example` to `.env`
  - [ ] แก้ไข database credentials
  - [ ] แก้ไข APP_URL
  - [ ] แก้ไข FRONTEND_URL
  - [ ] ตั้งค่า Mail (SMTP)

- [ ] **Generate Key**
  ```bash
  php artisan key:generate
  ```

- [ ] **Set Permissions**
  ```bash
  chown -R deploy:www-data /var/www/brieflylearn
  chmod -R 755 /var/www/brieflylearn
  chmod -R 775 storage bootstrap/cache
  ```

### 4. Database Migration

- [ ] **Run Migrations**
  ```bash
  php artisan migrate --force
  ```

- [ ] **Run Seeders** (ถ้ามี)
  ```bash
  php artisan db:seed --force
  ```

- [ ] **สร้าง Admin User**
  ```bash
  php artisan tinker
  # สร้าง admin user ตามคำสั่งใน README
  ```

### 5. Optimization

- [ ] **Cache Configs**
  ```bash
  php artisan config:cache
  php artisan route:cache
  php artisan view:cache
  ```

---

## 🌐 Nginx & SSL Setup Checklist

### 1. Nginx Configuration

- [ ] **Upload Nginx Configs**
  - [ ] `/etc/nginx/sites-available/api.brieflylearn.com`
  - [ ] `/etc/nginx/sites-available/admin.brieflylearn.com`

- [ ] **Enable Sites**
  ```bash
  ln -s /etc/nginx/sites-available/api.brieflylearn.com /etc/nginx/sites-enabled/
  ln -s /etc/nginx/sites-available/admin.brieflylearn.com /etc/nginx/sites-enabled/
  rm /etc/nginx/sites-enabled/default
  ```

- [ ] **Test Config**
  ```bash
  nginx -t
  ```

- [ ] **Restart Nginx**
  ```bash
  systemctl restart nginx
  ```

### 2. DNS Configuration

- [ ] **Add DNS Records**
  - [ ] A record: `@` → YOUR_VULTR_IP
  - [ ] A record: `www` → YOUR_VULTR_IP
  - [ ] A record: `api` → YOUR_VULTR_IP
  - [ ] A record: `admin` → YOUR_VULTR_IP

- [ ] **รอ DNS Propagate** (15-30 นาที)
  ```bash
  nslookup api.brieflylearn.com
  nslookup admin.brieflylearn.com
  ```

### 3. SSL Certificates

- [ ] **Install SSL สำหรับ API**
  ```bash
  certbot --nginx -d api.brieflylearn.com
  ```

- [ ] **Install SSL สำหรับ Admin**
  ```bash
  certbot --nginx -d admin.brieflylearn.com
  ```

- [ ] **ทดสอบ Auto-renewal**
  ```bash
  certbot renew --dry-run
  ```

---

## 🖥️ Frontend Deployment Checklist (Vercel)

### 1. Vercel Setup

- [ ] **Install Vercel CLI**
  ```bash
  npm install -g vercel
  ```

- [ ] **Login Vercel**
  ```bash
  vercel login
  ```

### 2. Deploy

- [ ] **Deploy to Production**
  ```bash
  cd fitness-lms
  vercel --prod
  ```

### 3. Environment Variables

- [ ] **Add Environment Variables บน Vercel Dashboard**
  - [ ] `NEXT_PUBLIC_APP_URL=https://brieflylearn.com`
  - [ ] `NEXT_PUBLIC_API_URL=https://api.brieflylearn.com/api/v1`
  - [ ] `NODE_ENV=production`

### 4. Domain Setup

- [ ] **Add Domain บน Vercel**
  - [ ] `brieflylearn.com`
  - [ ] `www.brieflylearn.com`
  - [ ] ทำตาม DNS instructions

---

## 🔒 Security Checklist

### 1. Firewall

- [ ] **Setup UFW**
  ```bash
  ufw allow OpenSSH
  ufw allow 'Nginx Full'
  ufw enable
  ```

- [ ] **ตรวจสอบ Status**
  ```bash
  ufw status verbose
  ```

### 2. SSH Security

- [ ] **Disable Root Login**
  - [ ] Edit `/etc/ssh/sshd_config`
  - [ ] Set `PermitRootLogin no`
  - [ ] Set `PasswordAuthentication no`
  - [ ] Restart: `systemctl restart sshd`

- [ ] **Install Fail2Ban**
  ```bash
  apt install fail2ban -y
  systemctl enable fail2ban
  ```

### 3. Application Security

- [ ] **Environment Variables**
  - [ ] `APP_DEBUG=false`
  - [ ] `APP_ENV=production`
  - [ ] Strong passwords everywhere

- [ ] **Change Default Credentials**
  - [ ] Admin panel password เปลี่ยนจาก `admin123`
  - [ ] Database password ที่แข็งแรง

---

## 💾 Backup Setup Checklist

### 1. Backup Script

- [ ] **Upload Backup Script**
  - [ ] `/var/backups/brieflylearn/backup.sh`
  - [ ] แก้ไข DB password ใน script
  - [ ] `chmod +x backup.sh`

### 2. Cron Job

- [ ] **Setup Cron**
  ```bash
  crontab -e
  # เพิ่ม: 0 2 * * * /var/backups/brieflylearn/backup.sh
  ```

### 3. Test Backup

- [ ] **Run Manual Backup**
  ```bash
  /var/backups/brieflylearn/backup.sh
  ```

- [ ] **ตรวจสอบ Backup Files**
  ```bash
  ls -lh /var/backups/brieflylearn/database/
  ls -lh /var/backups/brieflylearn/files/
  ```

---

## 🧪 Testing Checklist

### 1. Backend Testing

- [ ] **API Health Check**
  ```bash
  curl https://api.brieflylearn.com/api/v1/courses
  ```

- [ ] **Admin Panel Login**
  - [ ] เข้า https://admin.brieflylearn.com/admin
  - [ ] Login ด้วย admin credentials
  - [ ] ทดสอบสร้าง/แก้ไข/ลบข้อมูล

### 2. Frontend Testing

- [ ] **Homepage Load**
  - [ ] เข้า https://brieflylearn.com
  - [ ] ตรวจสอบ design ถูกต้อง (สีส้ม)

- [ ] **User Journey**
  - [ ] Register account
  - [ ] Login
  - [ ] Browse courses
  - [ ] View lesson
  - [ ] Check garden system
  - [ ] Logout

### 3. Integration Testing

- [ ] **Frontend ↔ Backend**
  - [ ] Login จาก frontend ได้
  - [ ] Load courses จาก API
  - [ ] Submit form ส่งข้อมูลไปยัง backend
  - [ ] CORS ทำงานถูกต้อง

---

## 📊 Monitoring Setup Checklist

### 1. Logs

- [ ] **Laravel Logs**
  ```bash
  tail -f /var/www/brieflylearn/storage/logs/laravel.log
  ```

- [ ] **Nginx Logs**
  ```bash
  tail -f /var/log/nginx/api.brieflylearn.com-access.log
  tail -f /var/log/nginx/api.brieflylearn.com-error.log
  ```

### 2. Performance Monitoring

- [ ] **Install htop**
  ```bash
  apt install htop -y
  ```

- [ ] **Monitor Resources**
  - [ ] CPU usage
  - [ ] Memory usage
  - [ ] Disk space: `df -h`

---

## 📝 Documentation Checklist

- [ ] **Update README**
  - [ ] Production URLs
  - [ ] API documentation
  - [ ] Deployment instructions

- [ ] **Create CHANGELOG**
  - [ ] Version 1.0.0
  - [ ] Initial release features

- [ ] **Team Handover**
  - [ ] Document credentials (ใน password manager)
  - [ ] Server access details
  - [ ] Emergency contact

---

## 🎉 Go-Live Checklist

### Final Steps Before Launch

- [ ] **Announcement Preparation**
  - [ ] Social media posts
  - [ ] Email template
  - [ ] Press release (ถ้ามี)

- [ ] **Support Preparation**
  - [ ] FAQ page
  - [ ] Contact form ทำงาน
  - [ ] Support email setup

- [ ] **Performance Check**
  - [ ] Page load time < 3 seconds
  - [ ] Mobile responsive
  - [ ] Cross-browser testing

### Launch Day

- [ ] **Monitor Everything**
  - [ ] Server resources
  - [ ] Error logs
  - [ ] User signups
  - [ ] Payment transactions (ถ้ามี)

- [ ] **Be Ready**
  - [ ] Deploy user on standby
  - [ ] Rollback plan ready
  - [ ] Emergency contact list

---

## 🔄 Post-Launch Checklist

### Week 1

- [ ] **Daily Monitoring**
  - [ ] Check error logs
  - [ ] Monitor server resources
  - [ ] Review user feedback

- [ ] **Backup Verification**
  - [ ] Verify daily backups run successfully
  - [ ] Test restore from backup

### Week 2-4

- [ ] **Performance Optimization**
  - [ ] Analyze slow queries
  - [ ] Optimize images
  - [ ] Enable caching (Redis/Memcached)

- [ ] **Security Audit**
  - [ ] Review access logs
  - [ ] Check for suspicious activity
  - [ ] Update dependencies

---

## 📞 Emergency Contacts

- **Server Provider**: Vultr Support
- **Domain Registrar**: [Your Registrar]
- **SSL**: Let's Encrypt (auto-renewal)
- **Email**: [Your Email Provider]

---

## 📚 Quick Reference

### Important URLs
- Frontend: https://brieflylearn.com
- API: https://api.brieflylearn.com/api/v1
- Admin: https://admin.brieflylearn.com/admin

### Server Access
```bash
ssh deploy@YOUR_VULTR_IP
```

### Quick Deploy
```bash
cd /var/www/brieflylearn
./deploy.sh
```

### View Logs
```bash
tail -f storage/logs/laravel.log
```

### Clear Caches
```bash
php artisan cache:clear
php artisan config:clear
```

---

**Last Updated**: 2025-10-25
**Version**: 1.0.0

**Status**: ⏳ Ready to Deploy
