# BrieflyLearn - Vultr Deployment Guide

This guide will help you deploy BrieflyLearn to your Vultr VPS.

## Server Information

- **IP Address**: 207.148.76.203
- **Username**: root
- **OS**: Ubuntu (recommended)

## Prerequisites

- Vultr VPS with Ubuntu 20.04 or later
- Domain name pointed to your VPS IP (optional but recommended)
- GitHub repository access
- SSH access to your VPS

---

## Method 1: Automated Deployment (Recommended)

### Step 1: Connect to Your VPS

```bash
ssh root@207.148.76.203
```

### Step 2: Create Application Directory

```bash
mkdir -p /var/www/brieflylearn
cd /var/www/brieflylearn
```

### Step 3: Clone Repository

```bash
# Clone your repository
git clone https://github.com/YOUR_USERNAME/brieflylearn.git .

# Or if using SSH
git clone git@github.com:YOUR_USERNAME/brieflylearn.git .
```

### Step 4: Configure Environment Variables

```bash
# Create .env.local file
nano .env.local
```

Add your environment variables:

```env
# Database
DATABASE_URL="postgresql://user:password@localhost:5432/brieflylearn"

# Supabase
NEXT_PUBLIC_SUPABASE_URL="your-supabase-url"
NEXT_PUBLIC_SUPABASE_ANON_KEY="your-supabase-anon-key"
SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"

# Stripe
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY="your-stripe-publishable-key"
STRIPE_SECRET_KEY="your-stripe-secret-key"
STRIPE_WEBHOOK_SECRET="your-stripe-webhook-secret"

# NextAuth
NEXTAUTH_URL="https://yourdomain.com"
NEXTAUTH_SECRET="your-nextauth-secret"

# App
NEXT_PUBLIC_APP_URL="https://yourdomain.com"
```

Save and exit (Ctrl + X, then Y, then Enter)

### Step 5: Run Deployment Script

```bash
# Make script executable
chmod +x deploy.sh

# Run deployment
./deploy.sh
```

The script will:
- Install Node.js, PM2, and Nginx
- Install dependencies
- Build the application
- Start the app with PM2
- Configure Nginx
- Display status and next steps

### Step 6: Setup Domain and SSL (Optional but Recommended)

```bash
# Update Nginx config with your domain
nano /etc/nginx/sites-available/brieflylearn

# Change "server_name _;" to "server_name yourdomain.com www.yourdomain.com;"

# Test Nginx config
nginx -t

# Reload Nginx
systemctl reload nginx

# Install SSL certificate
certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

---

## Method 2: Docker Deployment

### Step 1: Install Docker

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
apt-get install docker-compose-plugin
```

### Step 2: Clone Repository

```bash
mkdir -p /var/www/brieflylearn
cd /var/www/brieflylearn
git clone https://github.com/YOUR_USERNAME/brieflylearn.git .
```

### Step 3: Configure Environment

```bash
# Create .env.local
nano .env.local
# Add your environment variables (same as Method 1)
```

### Step 4: Build and Run with Docker

```bash
# Build and start containers
docker compose up -d --build

# Check status
docker compose ps

# View logs
docker compose logs -f
```

---

## Method 3: GitHub Actions Auto-Deploy

### Step 1: Add GitHub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions

Add these secrets:
- `VPS_HOST`: 207.148.76.203
- `VPS_USERNAME`: root
- `VPS_PASSWORD`: your-password

### Step 2: Setup VPS (One-time)

Connect to your VPS and run:

```bash
# Clone repository
mkdir -p /var/www/brieflylearn
cd /var/www/brieflylearn
git clone https://github.com/YOUR_USERNAME/brieflylearn.git .

# Run initial deployment
chmod +x deploy.sh
./deploy.sh
```

### Step 3: Push to GitHub

Every time you push to the `main` branch, GitHub Actions will automatically:
- Pull latest code on VPS
- Install dependencies
- Build the application
- Restart PM2 process

---

## Useful Commands

### PM2 Commands

```bash
# View application status
pm2 status

# View logs
pm2 logs brieflylearn

# Restart application
pm2 restart brieflylearn

# Stop application
pm2 stop brieflylearn

# Monitor resources
pm2 monit
```

### Nginx Commands

```bash
# Test configuration
nginx -t

# Reload Nginx
systemctl reload nginx

# Restart Nginx
systemctl restart nginx

# View error logs
tail -f /var/log/nginx/error.log
```

### Application Logs

```bash
# View PM2 logs
pm2 logs brieflylearn --lines 100

# View system logs
journalctl -u nginx -f
```

### Update Application

```bash
cd /var/www/brieflylearn
git pull origin main
npm install
npm run build
pm2 restart brieflylearn
```

---

## Troubleshooting

### Application Won't Start

1. Check PM2 logs:
   ```bash
   pm2 logs brieflylearn
   ```

2. Check environment variables:
   ```bash
   cat /var/www/brieflylearn/.env.local
   ```

3. Try manual start:
   ```bash
   cd /var/www/brieflylearn
   npm run build
   npm start
   ```

### Port 3000 Already in Use

```bash
# Find process using port 3000
lsof -i :3000

# Kill the process
kill -9 <PID>

# Restart application
pm2 restart brieflylearn
```

### Nginx 502 Bad Gateway

1. Check if app is running:
   ```bash
   pm2 status
   curl http://localhost:3000
   ```

2. Check Nginx config:
   ```bash
   nginx -t
   ```

3. Check logs:
   ```bash
   tail -f /var/log/nginx/error.log
   ```

### Build Fails

1. Clear cache:
   ```bash
   rm -rf .next node_modules
   npm install
   npm run build
   ```

2. Check Node.js version:
   ```bash
   node --version  # Should be 20.x or higher
   ```

---

## Security Recommendations

1. **Firewall Setup**:
   ```bash
   ufw allow 22
   ufw allow 80
   ufw allow 443
   ufw enable
   ```

2. **SSH Key Authentication**:
   - Disable password authentication
   - Use SSH keys instead

3. **Regular Updates**:
   ```bash
   apt-get update && apt-get upgrade -y
   ```

4. **Backup Database**:
   - Setup regular backups for Supabase/PostgreSQL

5. **Monitor Resources**:
   ```bash
   pm2 monit
   htop
   ```

---

## Performance Optimization

1. **Enable Caching**:
   - Configure Nginx caching
   - Use CDN for static assets

2. **Database Optimization**:
   - Add indexes to frequently queried fields
   - Use connection pooling

3. **PM2 Cluster Mode**:
   ```bash
   pm2 start npm --name brieflylearn -i max -- start
   ```

---

## Support

If you encounter issues:
1. Check logs: `pm2 logs brieflylearn`
2. Check Nginx logs: `tail -f /var/log/nginx/error.log`
3. Verify environment variables
4. Ensure all services are running

For more help, check the Next.js documentation or open an issue on GitHub.

---

## Quick Reference

| Task | Command |
|------|---------|
| View app status | `pm2 status` |
| Restart app | `pm2 restart brieflylearn` |
| View logs | `pm2 logs brieflylearn` |
| Update code | `cd /var/www/brieflylearn && git pull && npm install && npm run build && pm2 restart brieflylearn` |
| Test Nginx | `nginx -t` |
| Reload Nginx | `systemctl reload nginx` |
| Setup SSL | `certbot --nginx -d yourdomain.com` |

---

**Your application should now be running at**: http://207.148.76.203

Once you setup a domain and SSL, it will be available at: https://yourdomain.com
