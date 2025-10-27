# 🎓 BrieflyLearn - Personal Development Platform

A modern online learning platform focused on personal development, featuring courses on leadership, mindfulness, communication, productivity, and personal finance.

![Version](https://img.shields.io/badge/version-1.0.0-orange)
![Next.js](https://img.shields.io/badge/Next.js-15.4.4-black)
![Laravel](https://img.shields.io/badge/Laravel-11-red)
![License](https://img.shields.io/badge/license-MIT-green)

---

## ✨ Features

### 🎨 Modern Design
- **Minimalist Luxury UI** with Claude Orange theme (#f97316)
- **Responsive Design** optimized for all devices
- **Glass Morphism** effects and premium gradients
- **Smooth Animations** with Framer Motion

### 📚 Learning Features
- **Course Catalog** with categories (Leadership, Mindfulness, Communication, etc.)
- **Video Lessons** with progress tracking
- **Assessments** to test knowledge
- **Results Dashboard** to view your progress
- **Garden System** gamification with achievements

### 🔐 User Management
- **Authentication** with JWT tokens
- **User Profiles** with personalized content
- **Admin Panel** for content management (Filament)
- **Role-based Access Control**

---

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ or 20+
- PHP 8.2+
- MySQL 8.0+
- Composer 2.x

### One-Command Start

```bash
cd /Users/panapat/brieflylearn
./start-dev.sh
```

This will:
- ✅ Check all prerequisites
- ✅ Start MySQL service
- ✅ Start Laravel backend on port 8001
- ✅ Start Next.js frontend on port 3000
- ✅ Monitor both servers

### Access URLs
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8001/api/v1
- **Admin Panel**: http://localhost:8001/admin

### Stop Servers
```bash
./stop-dev.sh
```

---

## 📦 Manual Setup

### Backend Setup (Laravel)

```bash
cd fitness-lms-admin

# Install dependencies
composer install

# Setup database
mysql -u root -p -e "CREATE DATABASE fitness_lms;"
mysql -u root -p -e "CREATE USER 'fitness_user'@'localhost' IDENTIFIED BY 'fitness_pass_2024';"
mysql -u root -p -e "GRANT ALL PRIVILEGES ON fitness_lms.* TO 'fitness_user'@'localhost';"

# Run migrations
php artisan migrate:fresh --seed

# Create admin user
php artisan make:filament-user

# Start server
php artisan serve --host=0.0.0.0 --port=8001
```

### Frontend Setup (Next.js)

```bash
cd fitness-lms

# Install dependencies
npm install

# Start development server
npm run dev
```

---

## 🗂️ Project Structure

```
/Users/panapat/brieflylearn/
├── fitness-lms/                    # Next.js Frontend
│   ├── src/
│   │   ├── app/                    # Next.js App Router pages
│   │   │   ├── page.tsx           # Homepage (Minimalist luxury)
│   │   │   ├── courses/           # Course pages
│   │   │   ├── exams/             # Assessment pages
│   │   │   ├── results/           # Results dashboard
│   │   │   └── garden/            # Gamification system
│   │   ├── components/            # React components
│   │   │   ├── Header.tsx
│   │   │   ├── Footer.tsx
│   │   │   └── ...
│   │   ├── contexts/              # React Context providers
│   │   ├── lib/                   # API clients and utilities
│   │   └── styles/
│   ├── public/
│   ├── .env.local                 # Frontend environment variables
│   └── package.json
│
├── fitness-lms-admin/              # Laravel Backend
│   ├── app/
│   │   ├── Http/Controllers/      # API Controllers
│   │   ├── Models/                # Eloquent Models
│   │   └── Filament/              # Admin panel resources
│   ├── database/
│   │   ├── migrations/            # Database migrations
│   │   └── seeders/               # Data seeders
│   ├── routes/
│   │   ├── api.php               # API routes
│   │   └── web.php               # Web routes
│   ├── .env                       # Backend environment variables
│   └── composer.json
│
├── start-dev.sh                    # Quick start script
├── stop-dev.sh                     # Stop servers script
├── DEPLOYMENT_GUIDE.md             # Detailed deployment guide
└── README.md                       # This file
```

---

## 🛠️ Tech Stack

### Frontend
- **Framework**: Next.js 15.4.4 with App Router
- **Language**: TypeScript 5.x
- **Styling**: Tailwind CSS 4.x
- **Animation**: Framer Motion
- **Icons**: Lucide React
- **Font**: Kanit (Thai + Latin)
- **State Management**: React Context API

### Backend
- **Framework**: Laravel 11.x
- **Admin Panel**: Filament 3.x
- **Database**: MySQL 8.0
- **Authentication**: Laravel Sanctum
- **API**: RESTful with JSON responses

### Development Tools
- **Package Managers**: npm, Composer
- **Version Control**: Git
- **Code Editor**: VS Code (recommended)

---

## 📝 Environment Variables

### Frontend (.env.local)
```env
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_API_URL=http://localhost:8001/api/v1
NODE_ENV=development
```

### Backend (.env)
```env
APP_NAME="BrieflyLearn Admin"
APP_URL=http://localhost:8001
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=fitness_lms
DB_USERNAME=fitness_user
DB_PASSWORD=fitness_pass_2024
FRONTEND_URL=http://localhost:3000
```

---

## 🎨 Design System

### Colors
- **Primary**: Orange 500 (#f97316) - Claude Orange
- **Secondary**: Orange 600 (#ea580c)
- **Text**: Gray 900 (#111827)
- **Background**: White (#ffffff)
- **Accents**: Orange gradients

### Typography
- **Font Family**: Kanit (Thai + Latin support)
- **Weights**: 300, 400, 500, 600, 700
- **Scale**: Responsive with Tailwind

### Components
- **Glass Morphism**: backdrop-blur with semi-transparent backgrounds
- **Shadows**: Multi-layer shadows for depth
- **Rounded**: rounded-2xl to rounded-3xl for premium feel
- **Animations**: Smooth transitions with hover effects

---

## 📚 API Documentation

### Authentication
```bash
# Login
POST /api/v1/login
{
  "email": "user@example.com",
  "password": "password"
}

# Register
POST /api/v1/register
{
  "name": "John Doe",
  "email": "user@example.com",
  "password": "password"
}
```

### Courses
```bash
# Get all courses
GET /api/v1/courses

# Get single course with lessons
GET /api/v1/courses/{id}/lessons

# Get lesson detail
GET /api/v1/lessons/{id}
Authorization: Bearer {token}
```

### Garden System
```bash
# Get my garden
GET /api/v1/garden/my-garden
Authorization: Bearer {token}

# Water garden
PUT /api/v1/garden/water-garden
Authorization: Bearer {token}

# Plant seed
POST /api/v1/garden/plant/{plantTypeId}
Authorization: Bearer {token}
```

---

## 🐛 Troubleshooting

### Port Already in Use
```bash
# Kill process on port 8001 (backend)
kill -9 $(lsof -ti:8001)

# Kill process on port 3000 (frontend)
kill -9 $(lsof -ti:3000)
```

### Database Connection Failed
```bash
# Check MySQL is running
brew services list | grep mysql

# Start MySQL
brew services start mysql

# Test connection
mysql -u fitness_user -p fitness_lms
```

### CORS Errors
Make sure backend `.env` has:
```env
FRONTEND_URL=http://localhost:3000
SANCTUM_STATEFUL_DOMAINS=localhost:3000
```

Then restart backend:
```bash
cd fitness-lms-admin
php artisan config:clear
php artisan serve --host=0.0.0.0 --port=8001
```

---

## 📖 Documentation

- [Deployment Guide](./DEPLOYMENT_GUIDE.md) - Detailed setup and deployment instructions
- [Next.js Docs](https://nextjs.org/docs) - Next.js framework documentation
- [Laravel Docs](https://laravel.com/docs/11.x) - Laravel framework documentation
- [Filament Docs](https://filamentphp.com/docs) - Admin panel documentation

---

## 🚢 Deployment

### Production Deployment

**Frontend (Vercel)**:
```bash
cd fitness-lms
git push origin main
# Auto-deploys to Vercel
```

**Backend (Railway)**:
```bash
cd fitness-lms-admin
git push origin main
# Auto-deploys to Railway
```

See [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) for detailed instructions.

---

## 📄 License

This project is licensed under the MIT License.

---

## 👥 Team

**BrieflyLearn Team**
- Email: support@brieflylearn.com
- Website: https://brieflylearn.com

---

## 🙏 Acknowledgments

- Design inspired by Claude's minimalist aesthetic
- Built with modern web technologies
- Powered by Next.js and Laravel

---

**Last Updated**: 2025-10-25
**Version**: 1.0.0
