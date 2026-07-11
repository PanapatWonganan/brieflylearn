# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Layout

**Antiparallel** (formerly BrieflyLearn, formerly BoostMe) — LMS platform targeting AI users and business people. Thai-first UI, English code. Rebranded to `antiparallel.app` on 2026-05-01; old domains (`brieflylearn.com`, `antiparallel.co`, `antiparallel.com`) fully retired.

Monorepo with two sub-projects, each an independent git repo with its own deploy target:
- `fitness-lms/` — Next.js 15 frontend (React 19, TypeScript, Tailwind CSS v4) → `https://antiparallel.app`
- `fitness-lms-admin/` — Laravel 12 backend API (PHP 8.2+, MySQL 8.0+, Filament 3.3 admin) → `https://api.antiparallel.app`

Each sub-project has its own `CLAUDE.md` with detailed, trusted architecture notes. This root file only covers what crosses the boundary between them.

Everything else at the repo root (`deploy-*.sh`, `RAILWAY_*.md`, `Dockerfile`, `docker-compose.yml`, `nginx-configs/`, `provision.sh`, `backup-script/`, `setup-*.sh`) is infra tooling. Most `.md` files at the root are stale — trust `deploy.sh` and the per-project CLAUDE.md files over them.

## Production Deployment

**VPS**: Vultr Ubuntu — `45.32.125.76` (the IP in `deploy.sh` is authoritative; some older docs/CLAUDE.md versions say `207.148.76.203` — that's stale).
**SSH key**: `~/.ssh/brieflylearn_ed25519` (kept the old name — internal-only, no reason to migrate)
**URLs**: `https://antiparallel.app` (frontend) / `https://api.antiparallel.app` (backend)
**Admin**: `https://api.antiparallel.app/admin` — `admin@example.com` / `password123`
**Cloudflare Origin Cert**: `/etc/ssl/antiparallel-origin.{pem,key}` (15-year, SAN: `antiparallel.app, *.antiparallel.app`)

> **Internal names that intentionally still say "brieflylearn"** (do not rename — they're VPS-internal only and migrating them is risky for zero gain):
> - VPS paths: `/var/www/brieflylearn/{backend,frontend}`
> - PM2 process: `brieflylearn-frontend`
> - systemd service: `brieflylearn-queue`
> - PHP-FPM pool: `brieflylearn.conf`
> - SSH key filename: `brieflylearn_ed25519`
> - Filament admin brand name: `BrieflyLearn` (in `AdminPanelProvider.php` — only seen by admins)

### One-Click Deploy (run from repo root on Mac)
```bash
bash deploy.sh                    # Push + deploy both backend & frontend
bash deploy.sh backend            # Backend only
bash deploy.sh frontend           # Frontend only
bash deploy.sh "commit message"   # Both with custom commit message
bash deploy.sh backend "message"  # Backend with custom message
```

What `deploy.sh` does:
1. `git add` + `commit` + `push` to GitHub (each sub-repo separately)
2. SSH to VPS, `git pull` + install deps + build + restart services
3. Print service status when done

### Hot-Patch (single file to prod without git)
```bash
scp -i ~/.ssh/brieflylearn_ed25519 fitness-lms/src/<path> \
  root@45.32.125.76:/var/www/brieflylearn/frontend/src/<path>
ssh -i ~/.ssh/brieflylearn_ed25519 root@45.32.125.76 \
  'cd /var/www/brieflylearn/frontend && npm run build && pm2 restart brieflylearn-frontend'
```

### VPS Stack
- PHP 8.3-FPM + Nginx + MySQL 8.0 (backend)
- Node.js 20 + PM2 (`brieflylearn-frontend`) + Nginx reverse proxy (frontend)
- Cloudflare Origin SSL (`/etc/ssl/brieflylearn-origin.pem`)
- systemd queue worker (`brieflylearn-queue`)
- Cron: `* * * * * php artisan schedule:run` (required for email automation)

### VPS Paths
```
/var/www/brieflylearn/backend              # Laravel app
/var/www/brieflylearn/frontend             # Next.js app
/etc/nginx/sites-available/brieflylearn    # Nginx vhost
/etc/php/8.3/fpm/pool.d/brieflylearn.conf  # PHP-FPM pool
```

## Local Dev

```bash
./start-dev.sh              # Starts backend (:8001) and frontend (:3000)
./stop-dev.sh               # Stop both
```

The script checks for MySQL availability first; if MySQL isn't running locally, fix that before touching anything else.

### Per-project commands
```bash
# Frontend
cd fitness-lms && npm run dev          # Turbopack dev server :3000
cd fitness-lms && npm run build        # Production build (fails on TS/ESLint errors — see fitness-lms/CLAUDE.md)
cd fitness-lms && npx tsc --noEmit     # Type-check before deploy
cd fitness-lms && npm run lint         # ESLint 9

# Backend
cd fitness-lms-admin && php artisan serve --port=8001
cd fitness-lms-admin && php artisan migrate
cd fitness-lms-admin && php artisan db:seed                                # Only seeds 2 users (admin + test)
cd fitness-lms-admin && php artisan db:seed --class=CourseSeeder           # Other seeders must be run individually
cd fitness-lms-admin && php artisan db:seed --class=WellnessGardenSeeder   # Required for garden features
cd fitness-lms-admin && php artisan test                                   # PHPUnit, SQLite :memory:
cd fitness-lms-admin && php artisan route:list
cd fitness-lms-admin && php artisan make:filament-user
```

## The Cross-Project Contract

The two sub-projects are coupled in three places. Any change to one of these breaks the other silently unless you update both.

### 1. Auth token format (custom — NOT Sanctum, NOT JWT for session)
1. Login returns `base64(userId|api_token)` — `userId` is a UUID, `api_token` is a 60-char random string stored server-side
2. Frontend stores this in `localStorage` under **both** `auth_token` (canonical) and `boostme_token` (legacy) — reads must check both
3. Requests send `Authorization: Bearer <token>`
4. Backend middleware `auth.api` (`ApiTokenAuth.php`) decodes the base64, splits by `|`, finds user by UUID, verifies `api_token`, checks `token_expires_at` (30 days)
5. On each authenticated request, `last_active_at` is updated (throttled to every 5 minutes) and `updateStreak()` is called

### 2. API route versioning
All API routes live under `/api/v1/`. Public route groups are throttled `60/min`, auth routes have stricter limits (login: 5/min, register: 3/min). Full table:

| Group | Prefix | Auth | Throttle |
|-------|--------|------|----------|
| Auth public | `v1/auth` | No | login: 5/min, register: 3/min |
| Auth protected | `v1/auth` | `auth.api` | -- |
| Public API | `v1` | No | 60/min |
| Protected API | `v1` | `auth.api` | 60/min |
| Garden | `v1/garden` | `auth.api` | 60/min |
| Exams | `v1/exams` (+ protected subset) | mixed | -- |
| Blog | `v1/blog` | No | -- |
| Video upload | `video/upload` | `auth.api` | 10/hr |
| Contact | `v1/contact` | No | -- |
| Payments | `v1/payments/paysolutions` | mixed (postback/return public) | -- |

### 3. Payment / course-gating gates
The `/courses/[id]` page, `/courses/[id]/checkout`, `/payments/success`, `/payments/failed` form one unit. Gating depends on three backend-computed fields (`user_has_paid_access` + `locked` + `can_watch`). Full contract is in `fitness-lms/CLAUDE.md` — read it before touching the course or payment flow, this is the most failure-prone surface.

### Paysolutions integration
- Backend: `PaymentController` at `/api/v1/payments/paysolutions/*` (checkout/status auth'd, postback/return public)
- Frontend: auto-submits a hidden form to the gateway after calling the authenticated checkout endpoint
- The `/ai-100m/checkout` funnel uses a `POST /api/v1/auth/guest-signup` endpoint (new — creates or finds user by email, rotates api_token) to avoid forcing signup before payment

## Database

- **UUID primary keys** on all tables (`HasUuids` trait, `$incrementing = false`)
- Users table uses `password_hash` (not `password`); `getAuthIdentifierName()` returns `'email'`
- JSON columns: `growth_stages`, `care_requirements`, `criteria`, `garden_layout`, `progress_data`, `goals`, `interests`, `options`, `answers`, `activity_data`, `requirements`, `tags`
- Unique constraints to be aware of: `[user_id, course_id]` on enrollments, `[user_id, lesson_id]` on lesson_progress, `[user_id, achievement_id]` on user_achievements, `[user_id, challenge_id]` on user_challenge_progress

## Environment

### Frontend (`fitness-lms/.env.local`)
```
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_API_URL=http://localhost:8001/api/v1
NEXT_PUBLIC_GOOGLE_CLIENT_ID=<google_oauth_client_id>
NEXT_PUBLIC_META_PIXEL_ID=<meta_pixel_id>
NEXT_PUBLIC_AI100M_COURSE_ID=<uuid>     # Fallback when public /courses API is down
```

### Backend (`fitness-lms-admin/.env`)
```
APP_URL=http://localhost:8001
APP_FRONTEND_URL=http://localhost:3000
DB_CONNECTION=mysql / DB_HOST / DB_PORT / DB_DATABASE / DB_USERNAME / DB_PASSWORD
MAIL_HOST=smtp.sendgrid.net / MAIL_PASSWORD=SG.xxxxx
GOOGLE_CLIENT_ID / GOOGLE_CLIENT_SECRET
JWT_SECRET=<required>
PAYSOLUTIONS_*   # Gateway credentials
```

## Design Systems (two, deliberately different)

The main app and the sale funnel use different palettes on purpose.

**Main app (`fitness-lms/src/app/globals.css` @theme block, Tailwind v4 tokens):** dark theme, mint accent `#00FFBA`, surface scale. Rules: no default Tailwind colors (red-500 etc.), no gradients, no infinite animations (spinners excepted), `rounded-sm` (2px) only.

**Sale funnel (`/sales/[slug]`):** 3-color conversion palette — Mint `#00FFBA` (trust), Orange `#FF6B35` (CTA), Red `#FF4757` (urgency). Intentionally breaks the main app's color rules.

**AI ฿100M sales page (`/ai-100m`):** own scoped CSS under `.ai100m-root` (paper bg, warm accents) — does not follow either of the above and is self-contained. Hides global header/footer via DOM manipulation in its own `layout.tsx` (same pattern as `/sales/layout.tsx`).

The per-project `CLAUDE.md` has the full token/class list — don't invent new tokens without checking there.

## AI Lab (Garden Gamification, backend-side)

- Thai UI: "ห้องปฏิบัติการ AI"; XP is shown as "Impact Points"; Star Seeds as "AI Credits"
- Plant stages: แนวคิด → ต้นแบบ → ทดสอบ → พร้อมใช้ → ขยายผล
- Watering cooldown: 4 hours. XP per level: `level * 1000`
- Garden auto-created on first access (`getOrCreateGarden()`) with theme `'tropical'` + 100 star seeds
- Course/lesson completion events fire `LessonCompleted` / `CourseCompleted` → `AwardGardenRewardsForLesson` listener → `CourseProgressService` awards XP + Seeds + checks achievements

## Test Credentials
- **User**: test@example.com / password123
- **Admin panel**: /admin (user role must be `admin`)

## Production Gotchas (learned the hard way)

1. **`.env.production` hijacks `.env` when `APP_ENV=production`.** Laravel's dotenv loader prefers `.env.{APP_ENV}` over `.env`. If a stale `.env.production` sits in the backend dir with empty DB values, every DB-hitting endpoint returns 500 `SQLSTATE[HY000] [2002] No such file or directory (Connection: mysql)` even though `mysql` CLI works and `.env` is correct. Fix: rename it to `.env.production.disabled-<ts>`, then `php artisan config:clear && php artisan config:cache && systemctl restart php8.3-fpm`.

2. **Config cache + PHP-FPM.** After `.env` changes on VPS: always `php artisan config:clear && php artisan config:cache && systemctl restart php8.3-fpm`. Clearing without restarting PHP-FPM leaves stale opcached bytecode in memory.

3. **Cloudflare chunk cache.** After a frontend deploy, `/_next/static/chunks/...` may be cached up to 5 min at Cloudflare. `Cmd-Shift-R` or purge cache to verify.

4. **Next.js "Internal Server Error" on a clean build** — stale `.next/`. `rm -rf fitness-lms/.next && npm run dev`.

5. **Turbopack hangs on `<style jsx>`.** Put keyframes in `globals.css`; inline `style={{ animation: '...' }}` is fine.

6. **`DatabaseSeeder` only makes 2 users.** Don't assume `php artisan db:seed` seeds anything else — Category/Course/WellnessGarden seeders must be run individually (see commands above).

7. **First MySQL request ~500ms on VPS** (connection overhead), subsequent fast. Don't chase this as a perf bug.

8. **Two auth state names.** `useAuth()` returns `loading` (not `isLoading`). Many component-local hooks use `isLoading`. Don't conflate: `const { loading: authLoading } = useAuth()`.

9. **The `/courses` public API has been flaky in prod.** If you need a specific course ID client-side, use an env var fallback (see `NEXT_PUBLIC_AI100M_COURSE_ID`). Fix the backend properly, don't paper over with try/catch.

10. **`growth_stages` in PlantType is `number | Record<string, any>`.** Frontend handles both; don't normalize in one place without checking the other.
