# Meta Pixel & Conversions API (CAPI) — Implementation Plan

> เอกสารนี้อธิบายแผนการติดตั้ง Meta Pixel + Conversions API สำหรับ BrieflyLearn
> เพื่อให้ทีมสามารถประสานงาน, ตั้งค่า Meta Business Manager, และเตรียม creative ได้พร้อมกัน

**Last Updated**: 2026-04-12
**Status**: Implementation Ready
**Codebase**: fitness-lms (Next.js 15) + fitness-lms-admin (Laravel 12)

---

## Table of Contents

1. [Overview & Why](#1-overview--why)
2. [Architecture](#2-architecture)
3. [Prerequisites (ทีมต้องเตรียม)](#3-prerequisites-ทีมต้องเตรียม)
4. [Event Map — Events ที่ติดตั้ง](#4-event-map--events-ที่ติดตั้ง)
5. [Frontend Implementation (Next.js)](#5-frontend-implementation-nextjs)
6. [Backend Implementation (Laravel)](#6-backend-implementation-laravel)
7. [Deduplication — กันนับซ้ำ](#7-deduplication--กันนับซ้ำ)
8. [Environment Variables](#8-environment-variables)
9. [Testing & Validation](#9-testing--validation)
10. [Ads Strategy สำหรับ Andromeda](#10-ads-strategy-สำหรับ-andromeda)
11. [Campaign Structure](#11-campaign-structure)
12. [Creative Strategy](#12-creative-strategy)
13. [Budget & Bidding](#13-budget--bidding)
14. [KPIs & Metrics](#14-kpis--metrics)
15. [Timeline & Checklist](#15-timeline--checklist)

---

## 1. Overview & Why

### ปัญหาของ Pixel อย่างเดียว

Meta Pixel (browser-side) พลาด 30-40% ของ conversions เนื่องจาก:

| สาเหตุ | ผลกระทบ |
|--------|---------|
| Ad Blockers | 20-40% ของ users บล็อก fbq() |
| Safari ITP | ลบ cookie ภายใน 7 วัน |
| iOS 14+ ATT | User กด "Ask App Not to Track" |
| Browser crash/close | Event ยิงไม่ทัน |

### ทำไมต้อง Pixel + CAPI คู่กัน

- **Pixel (Frontend)**: จับ behavior — user เลื่อนดูหน้า course, ดู video preview, กลับมาเข้าเว็บกี่ครั้ง
- **CAPI (Backend)**: จับ conversion แน่นอน — register, enroll, complete course → ส่ง server-to-server ไม่ผ่าน browser → ไม่ถูกบล็อก 100%
- **ผลลัพธ์**: Meta เห็นข้อมูลครบ → Andromeda optimize ได้ดีขึ้น → ค่า ads ถูกลง, ROAS ดีขึ้น

### ประโยชน์ที่ได้

- Event Match Quality (EMQ) สูงขึ้น → เป้าหมาย > 6.0
- Meta รายงาน: ใช้ CAPI คู่ Pixel ได้ CPA ต่ำกว่าเฉลี่ย 9%
- Advertisers ที่ใช้ Andromeda + data ครบรายงาน ROAS ดีขึ้น 20-35%

---

## 2. Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  User Browser                                               │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Next.js Frontend (Port 3000)                       │    │
│  │                                                     │    │
│  │  layout.tsx:                                        │    │
│  │    <MetaPixelProvider pixelId={PIXEL_ID}>           │    │
│  │      <MetaPixelScript />   ← โหลด fbevents.js     │    │
│  │      {children}                                     │    │
│  │    </MetaPixelProvider>                             │    │
│  │                                                     │    │
│  │  Events fired from browser:                         │    │
│  │    PageView      → ทุกหน้า (auto)                  │    │
│  │    ViewContent   → /courses/:id                     │    │
│  │    CompleteRegistration → register/Google sign-in   │    │
│  │    AddToCart      → กดลงทะเบียนคอร์ส               │    │
│  │                                                     │    │
│  │  ทุก event สร้าง event_id (UUID) ส่งไป backend ──┐ │    │
│  └──────────────────────────────────────────────────┼──┘    │
│                                                     │       │
│  fbq('track', 'X', data, {eventID: uuid}) ───────── │ ──→ Meta  (browser-side)
│                                                     │       │
└─────────────────────────────────────────────────────┼───────┘
                                                      │
                                                      ▼
┌─────────────────────────────────────────────────────────────┐
│  Laravel Backend (Port 8001)                                │
│                                                             │
│  Controllers ที่ hook เข้า:                                 │
│    AuthController::register()          → CompleteRegistration│
│    AuthController::googleLogin()       → CompleteRegistration│
│    EnrollmentController::enroll()      → AddToCart          │
│    CourseIntegrationController::       → Purchase           │
│      completeLessonWithRewards()                            │
│                                                             │
│  MetaConversionsService::sendEvent()                        │
│    ↓                                                        │
│    HTTP POST → https://graph.facebook.com/v25.0/            │
│                {pixel_id}/events                            │
│    ↓                                                        │
│    ส่ง event_id เดียวกับ Pixel ──────────────────────→ Meta  (server-side)
│                                                             │
│  Meta ได้รับทั้ง 2 event → Deduplication ด้วย event_id     │
│  → นับแค่ครั้งเดียว                                         │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow สำหรับแต่ละ Event

```
1. User กดลงทะเบียนคอร์ส
2. Frontend: fbq('track', 'AddToCart', {content_ids: ['course-123'], value: 0, currency: 'THB'}, {eventID: 'abc-123'})
3. Frontend: POST /api/v1/enrollments {course_id: 'xxx', meta_event_id: 'abc-123'}
4. Backend: EnrollmentController สร้าง enrollment → เรียก MetaConversionsService
5. MetaConversionsService: POST https://graph.facebook.com/v25.0/{pixel_id}/events
   {
     event_name: "AddToCart",
     event_id: "abc-123",          ← เดียวกับ step 2
     event_time: 1712908800,
     user_data: { em: sha256(email), ph: sha256(phone) },
     custom_data: { content_ids: ["course-123"], value: 0, currency: "THB" }
   }
6. Meta: เห็น event_id ซ้ำจาก Pixel + CAPI → นับแค่ 1 ครั้ง (Deduplicated)
```

---

## 3. Prerequisites (ทีมต้องเตรียม)

### 3.1 Meta Business Manager Setup

| Task | ใครทำ | รายละเอียด |
|------|-------|-----------|
| สร้าง Meta Business Manager | Marketing | business.facebook.com |
| สร้าง Ad Account | Marketing | ใน Business Manager |
| สร้าง Meta Pixel (Dataset) | Marketing | Events Manager > Data Sources > Add > Web |
| จด **Pixel ID** (15 หลัก) | Marketing | ส่งให้ Dev ใส่ env |
| Generate **Access Token** สำหรับ CAPI | Marketing (Developer role) | Events Manager > Settings > Conversions API > Generate Access Token |
| Verify Domain | Marketing + Dev | ใน Business Manager > Brand Safety > Domains |
| ตั้ง Aggregated Event Measurement (AEM) | Marketing | จัด priority ของ events (สำหรับ iOS) |

### 3.2 AEM Event Priority (iOS 14+)

จัดลำดับ events จาก priority สูงสุด → ต่ำสุด (Meta อนุญาตสูงสุด 8 events):

| Priority | Event | เหตุผล |
|----------|-------|--------|
| 1 (สูงสุด) | Purchase | Revenue event |
| 2 | CompleteRegistration | สมัครสมาชิก |
| 3 | AddToCart | ลงทะเบียนคอร์ส |
| 4 | Lead | กรอกฟอร์ม/สนใจ |
| 5 | ViewContent | ดูหน้า course |
| 6 | PageView | ดูหน้าเว็บทั่วไป |
| 7 | LessonComplete (Custom) | เรียนจบบทเรียน |
| 8 | ExamComplete (Custom) | ทำข้อสอบเสร็จ |

### 3.3 Environment Variables ที่ต้องได้จาก Marketing

```
META_PIXEL_ID=1234567890123456         ← จาก Events Manager
META_CONVERSIONS_API_TOKEN=EAAxxxxxxx  ← จาก Events Manager > Settings
```

**ความปลอดภัย**:
- Access Token ปลอดภัยเทียบเท่า database password → ห้าม commit ลง git
- Rotate ทุก 90 วัน
- เก็บใน .env เท่านั้น

---

## 4. Event Map — Events ที่ติดตั้ง

### Standard Events

| Event Name | Trigger Point | Pixel (Browser) | CAPI (Server) | Parameters |
|------------|--------------|-----------------|---------------|------------|
| **PageView** | ทุกหน้า auto | YES | NO | - |
| **ViewContent** | เข้าหน้า course detail | YES | NO | `content_type: 'product', content_ids: [courseId], content_name: courseTitle, content_category: category` |
| **ViewContent** | อ่าน blog post | YES | NO | `content_type: 'article', content_ids: [postId], content_name: postTitle` |
| **CompleteRegistration** | สมัครสมาชิกสำเร็จ (email/Google) | YES | YES | `value: 0, currency: 'THB', content_name: 'registration', status: 'complete'` |
| **AddToCart** | กดลงทะเบียนคอร์ส (enroll) | YES | YES | `content_type: 'product', content_ids: [courseId], content_name: courseTitle, value: coursePrice, currency: 'THB'` |
| **Purchase** | จบคอร์สทั้งหมด (course complete) | YES | YES | `content_type: 'product', content_ids: [courseId], content_name: courseTitle, value: coursePrice, currency: 'THB', num_items: 1` |

### Custom Events (เสริม)

| Event Name | Trigger Point | Pixel | CAPI | Parameters |
|------------|--------------|-------|------|------------|
| **LessonComplete** | เรียนจบ 1 lesson | YES | YES | `lesson_id, lesson_title, course_id, xp_earned, star_seeds_earned` |
| **ExamComplete** | ส่งข้อสอบ | YES | NO | `exam_id, exam_title, score, passed` |
| **GardenAction** | ปลูก/รดน้ำใน AI Lab | YES | NO | `action_type: 'plant'/'water', plant_name` |

### จุด Hook ใน Codebase

#### Frontend (fitness-lms/src/)

| Event | ไฟล์ | ตำแหน่ง |
|-------|------|---------|
| PageView | `app/layout.tsx` | MetaPixelScript component auto-fires |
| ViewContent (course) | `app/courses/[id]/page.tsx` | useEffect on mount |
| ViewContent (blog) | `app/blog/[slug]/page.tsx` | useEffect on mount |
| CompleteRegistration | `contexts/AuthContextNew.tsx` | หลัง `setUser()` ใน `register()` (line ~136) |
| CompleteRegistration | `contexts/AuthContextNew.tsx` | หลัง `setUser()` ใน `loginWithGoogle()` (line ~174) เฉพาะ new user |
| AddToCart | Component ที่เรียก enroll API | หลัง API response success |
| LessonComplete | Component ที่เรียก completeLessonWithRewards | หลัง API response success |
| ExamComplete | `app/exams/[id]/page.tsx` | หลัง submit exam success |

#### Backend (fitness-lms-admin/app/)

| Event | ไฟล์ | Method | ตำแหน่ง |
|-------|------|--------|---------|
| CompleteRegistration | `Http/Controllers/Api/AuthController.php` | `register()` | หลัง `$user->save()` (line ~46) |
| CompleteRegistration | `Http/Controllers/Api/AuthController.php` | `googleLogin()` | ใน block `if ($user->wasRecentlyCreated)` (line ~291) |
| AddToCart | `Http/Controllers/Api/EnrollmentController.php` | `enrollInCourse()` | หลัง enrollment สร้างเสร็จ (line ~115) |
| LessonComplete | `Http/Controllers/Api/CourseIntegrationController.php` | `completeLessonWithRewards()` | หลัง `DB::commit()` (line ~103) |
| Purchase | `Http/Controllers/Api/CourseIntegrationController.php` | `checkCourseCompletion()` | หลัง `event(new CourseCompleted(...))` (line ~248) |

---

## 5. Frontend Implementation (Next.js)

### 5.1 ไฟล์ที่สร้าง/แก้ไข

```
fitness-lms/src/
├── lib/
│   └── meta-pixel.ts              ← NEW: Pixel utility functions
├── components/
│   └── MetaPixel.tsx              ← NEW: Script loader + Provider
├── contexts/
│   └── AuthContextNew.tsx         ← MODIFY: เพิ่ม event fire
├── app/
│   └── layout.tsx                 ← MODIFY: เพิ่ม MetaPixel component
```

### 5.2 Meta Pixel Utility (lib/meta-pixel.ts)

```typescript
// ฟังก์ชันหลักที่ใช้

// 1. สร้าง event_id สำหรับ deduplication
generateEventId(): string
// return crypto.randomUUID()

// 2. Fire standard event
trackEvent(eventName: string, params?: object, eventId?: string): void
// fbq('track', eventName, params, {eventID: eventId})

// 3. Fire custom event
trackCustomEvent(eventName: string, params?: object): void
// fbq('trackCustom', eventName, params)

// 4. Hash user data (SHA-256) สำหรับ Advanced Matching
hashUserData(email: string): string
```

### 5.3 MetaPixel Component (components/MetaPixel.tsx)

```typescript
// Client component ('use client')
// ใช้ next/script strategy="afterInteractive" โหลด fbevents.js
// Auto-fire PageView on route change
// ส่ง Advanced Matching data ถ้า user logged in (hashed email)
```

### 5.4 layout.tsx Changes

```tsx
// เพิ่ม MetaPixel ใน provider hierarchy:
// SmoothScroll → MetaPixel → GoogleAuthWrapper → NotificationProvider → AuthProvider → ...
```

### 5.5 AuthContextNew.tsx Changes

```typescript
// ใน register() — หลัง setUser():
trackEvent('CompleteRegistration', {
  value: 0,
  currency: 'THB',
  content_name: 'email_registration'
}, generateEventId())

// ใน loginWithGoogle() — หลัง setUser() (ถ้า new user):
// Backend response จะมี field `is_new_user: true`
if (response.is_new_user) {
  trackEvent('CompleteRegistration', {
    value: 0,
    currency: 'THB',
    content_name: 'google_registration'
  }, generateEventId())
}
```

---

## 6. Backend Implementation (Laravel)

### 6.1 ไฟล์ที่สร้าง/แก้ไข

```
fitness-lms-admin/
├── app/
│   └── Services/
│       └── MetaConversionsService.php    ← NEW: CAPI helper class
├── config/
│   └── services.php                      ← MODIFY: เพิ่ม meta config
├── app/Http/Controllers/Api/
│   ├── AuthController.php                ← MODIFY: เพิ่ม CAPI calls
│   ├── EnrollmentController.php          ← MODIFY: เพิ่ม CAPI calls
│   └── CourseIntegrationController.php   ← MODIFY: เพิ่ม CAPI calls
```

### 6.2 MetaConversionsService

```php
namespace App\Services;

class MetaConversionsService
{
    private string $pixelId;
    private string $accessToken;
    private string $apiVersion = 'v25.0';

    // ส่ง event ไป Meta Graph API
    public function sendEvent(
        string $eventName,       // 'CompleteRegistration', 'AddToCart', 'Purchase'
        array $userData,         // ['em' => hash, 'ph' => hash, 'client_ip_address' => ip]
        array $customData = [],  // ['value' => 0, 'currency' => 'THB', 'content_ids' => [...]]
        ?string $eventId = null, // UUID สำหรับ deduplication (จาก frontend)
        ?string $sourceUrl = null
    ): void

    // Hash user data ตามข้อกำหนด Meta (SHA-256, lowercase, trim)
    private function hashUserData(string $value): string
    // return hash('sha256', strtolower(trim($value)))

    // Build user_data payload
    private function buildUserData(User $user, Request $request): array
    // return [
    //     'em' => [hashUserData($user->email)],
    //     'ph' => [$user->phone ? hashUserData($user->phone) : null],
    //     'fn' => [hashUserData($user->full_name)],
    //     'client_ip_address' => $request->ip(),
    //     'client_user_agent' => $request->userAgent(),
    //     'fbc' => $request->cookie('_fbc'),    // Facebook click ID
    //     'fbp' => $request->cookie('_fbp'),    // Facebook browser ID
    // ]
}
```

### 6.3 API Endpoint ที่ call

```
POST https://graph.facebook.com/{api_version}/{pixel_id}/events
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "data": [
    {
      "event_name": "CompleteRegistration",
      "event_time": 1712908800,
      "event_id": "abc-123-uuid",
      "action_source": "website",
      "event_source_url": "https://antiparallel.app/auth",
      "user_data": {
        "em": ["a1b2c3...sha256hash"],
        "ph": ["d4e5f6...sha256hash"],
        "fn": ["g7h8i9...sha256hash"],
        "client_ip_address": "203.0.113.1",
        "client_user_agent": "Mozilla/5.0...",
        "fbc": "fb.1.1712908800.AbCdEf",
        "fbp": "fb.1.1712908800.1234567890"
      },
      "custom_data": {
        "value": 0,
        "currency": "THB",
        "content_name": "email_registration"
      }
    }
  ]
}
```

### 6.4 Controller Changes

#### AuthController::register()

```php
// หลัง $user->save() (line ~46):
try {
    $this->metaConversions->sendEvent(
        eventName: 'CompleteRegistration',
        userData: $this->metaConversions->buildUserData($user, $request),
        customData: [
            'value' => 0,
            'currency' => 'THB',
            'content_name' => 'email_registration',
        ],
        eventId: $request->input('meta_event_id'),
        sourceUrl: config('app.frontend_url') . '/auth'
    );
} catch (\Exception $e) {
    Log::warning('Meta CAPI failed', ['error' => $e->getMessage()]);
    // ห้าม throw — ไม่ให้ tracking failure ทำ registration พัง
}
```

#### AuthController::googleLogin()

```php
// ใน block if ($user->wasRecentlyCreated) (line ~291):
// เหมือน register() แต่ content_name = 'google_registration'
```

#### EnrollmentController::enrollInCourse()

```php
// หลัง enrollment สร้างเสร็จ:
// eventName: 'AddToCart'
// customData: content_type, content_ids, content_name, value, currency
```

#### CourseIntegrationController

```php
// completeLessonWithRewards() หลัง DB::commit():
// eventName: 'LessonComplete' (Custom Event)
// customData: lesson_id, lesson_title, course_id, xp_earned

// checkCourseCompletion() เมื่อจบคอร์ส:
// eventName: 'Purchase'
// customData: content_type, content_ids, value, currency, num_items
```

### 6.5 Error Handling Pattern

**สำคัญมาก**: ทุก CAPI call ต้อง wrap ด้วย try-catch เหมือน email sends

```php
// Pattern เดียวกับที่ใช้กับ Mail ใน codebase:
try {
    $this->metaConversions->sendEvent(...);
} catch (\Exception $e) {
    Log::warning('Meta CAPI: ' . $eventName . ' failed', [
        'error' => $e->getMessage(),
        'user_id' => $user->id,
    ]);
    // NEVER throw — tracking failure must not break main flow
}
```

### 6.6 HTTP Client

ใช้ Laravel HTTP Client (Illuminate\Support\Facades\Http):

```php
$response = Http::post(
    "https://graph.facebook.com/{$this->apiVersion}/{$this->pixelId}/events",
    [
        'data' => [json_encode([$eventPayload])],
        'access_token' => $this->accessToken,
    ]
);
```

**Timeout**: 5 วินาที (ไม่ให้ถ่วง response หลักของ user)

```php
Http::timeout(5)->post(...);
```

---

## 7. Deduplication — กันนับซ้ำ

### หลักการ

เมื่อ Pixel + CAPI ส่ง event เดียวกัน Meta จะนับ 2 ครั้ง **ยกเว้น** ส่ง `event_id` เดียวกัน

```
Browser Pixel:  fbq('track', 'AddToCart', data, {eventID: 'abc-123'})
Server CAPI:    {"event_name": "AddToCart", "event_id": "abc-123", ...}

Meta เห็น event_id ตรงกัน → นับแค่ 1 ครั้ง → badge "Deduplicated" ใน Events Manager
```

### วิธี implement

1. **Frontend สร้าง UUID** ก่อน fire event:
   ```typescript
   const eventId = crypto.randomUUID()  // e.g. "550e8400-e29b-41d4-a716-446655440000"
   ```

2. **Frontend ส่ง eventId ไปกับ API request**:
   ```typescript
   // fire Pixel ทันที
   fbq('track', 'AddToCart', params, {eventID: eventId})

   // ส่ง eventId ไป backend ใน request body
   await api.post('/enrollments', {
     course_id: courseId,
     meta_event_id: eventId   // ← เพิ่ม field นี้
   })
   ```

3. **Backend ใช้ eventId เดียวกัน**:
   ```php
   $this->metaConversions->sendEvent(
       eventId: $request->input('meta_event_id'),
       // ...
   );
   ```

### Events ที่ต้อง Deduplicate

| Event | ส่งจาก Pixel? | ส่งจาก CAPI? | ต้อง Dedup? |
|-------|:---:|:---:|:---:|
| PageView | YES | NO | NO |
| ViewContent | YES | NO | NO |
| CompleteRegistration | YES | YES | **YES** |
| AddToCart | YES | YES | **YES** |
| Purchase | YES | YES | **YES** |
| LessonComplete | YES | YES | **YES** |
| ExamComplete | YES | NO | NO |

### Events ที่ Backend ส่งอย่างเดียว (ไม่ต้อง Dedup)

บาง events เกิดขึ้นใน backend โดย user ไม่ได้ trigger จาก frontend โดยตรง:

- Course completion ถูก detect ใน `checkCourseCompletion()` — ไม่มี frontend trigger ตรง ๆ
- กรณีนี้ backend สร้าง `event_id` เอง (UUID) ได้เลย

---

## 8. Environment Variables

### Frontend (.env.local)

```env
# Meta Pixel
NEXT_PUBLIC_META_PIXEL_ID=1234567890123456
```

- ใช้ `NEXT_PUBLIC_` prefix เพราะต้อง access ใน browser
- Pixel ID ไม่เป็น secret (มันอยู่ใน HTML source อยู่แล้ว)

### Backend (.env)

```env
# Meta Conversions API
META_PIXEL_ID=1234567890123456
META_CONVERSIONS_API_TOKEN=EAAxxxxxxxxxxxxxxxxxxxxxxxxx
META_API_VERSION=v25.0
META_TEST_EVENT_CODE=TEST12345
```

- `META_CONVERSIONS_API_TOKEN` **เป็น secret** — ห้าม commit ลง git
- `META_TEST_EVENT_CODE` — ใช้ตอน test เท่านั้น, ลบออกก่อน production
- `META_API_VERSION` — ใช้ v25.0 (Graph API February 2026)

### config/services.php (Laravel)

```php
'meta' => [
    'pixel_id' => env('META_PIXEL_ID'),
    'access_token' => env('META_CONVERSIONS_API_TOKEN'),
    'api_version' => env('META_API_VERSION', 'v25.0'),
    'test_event_code' => env('META_TEST_EVENT_CODE'),
],
```

---

## 9. Testing & Validation

### Step 1: ทดสอบ Pixel (Browser-side)

1. ติดตั้ง **Meta Pixel Helper** Chrome Extension
2. เปิดเว็บ BrieflyLearn
3. ตรวจสอบว่า:
   - PageView ยิงทุกหน้า (ดูจาก extension badge count)
   - ViewContent ยิงเมื่อเข้าหน้า course detail
   - CompleteRegistration ยิงเมื่อสมัครสำเร็จ
   - Parameters ถูกต้อง (content_ids, value, currency)

### Step 2: ทดสอบ CAPI (Server-side)

1. เข้า **Events Manager** > **Test Events** tab
2. ใส่ Test Event Code ลงใน .env: `META_TEST_EVENT_CODE=TEST12345`
3. ทำ action บนเว็บ (register, enroll)
4. ดูใน Test Events tab ว่า server events ขึ้น
5. ตรวจสอบว่ามี badge **"Deduplicated"** — หมายความว่า event_id match กัน

### Step 3: ตรวจสอบ Event Match Quality

1. Events Manager > Data Sources > เลือก Pixel
2. ดูแต่ละ event → EMQ Score
3. เป้าหมาย: EMQ > 6.0 (ดี), > 8.0 (ดีมาก)
4. ถ้า EMQ ต่ำ → เพิ่ม user data parameters (phone, first_name)

### Step 4: ตรวจสอบ Diagnostics

1. Events Manager > Diagnostics tab
2. แก้ไข warnings ทั้งหมด:
   - Missing value parameter
   - Currency mismatch
   - Deduplication issues
   - Event frequency anomalies

### Checklist ก่อนเปิด Ads

- [ ] Pixel Helper แสดง events ถูกต้องทุกหน้า
- [ ] Test Events tab แสดง server events
- [ ] Badge "Deduplicated" ปรากฏบน server events
- [ ] EMQ Score > 6.0 สำหรับ CompleteRegistration, AddToCart, Purchase
- [ ] Diagnostics ไม่มี error (warnings อาจมีบ้างได้)
- [ ] ลบ META_TEST_EVENT_CODE ออกแล้ว
- [ ] Domain verified ใน Business Manager

---

## 10. Ads Strategy สำหรับ Andromeda

### Andromeda คืออะไร?

Meta Andromeda คือ AI engine ตัวใหม่ที่ **เปลี่ยนวิธีทำ ads อย่างสิ้นเชิง** (rollout เสร็จ October 2025):

| เดิม | Andromeda (ตอนนี้) |
|------|-------------------|
| คนเลือก targeting → Meta ส่ง ads | Meta เลือก targeting เอง → ใช้ **creative** เป็นตัวตัดสิน |
| ยิ่ง targeting ละเอียดยิ่งดี | **Broad targeting ดีกว่า** — ให้ AI จัดการ |
| แยก campaign Prospecting / Retargeting | **รวม campaign เดียว** — Andromeda รู้เองว่าใครต้อง retarget |
| Creative 2-3 ตัวก็พอ | ต้องมี **15-20 creative ที่ต่างกันจริง ๆ** |
| ปรับ campaign ทุกวัน | **ห้ามแตะ 14-21 วัน** (learning phase) |
| Budget สำคัญที่สุด | **Creative สำคัญที่สุด** |

### หลักการสำคัญ 3 ข้อ

1. **Creative = Targeting** — Andromeda อ่าน creative เพื่อตัดสินว่าจะส่งให้ใคร ไม่ใช่ interest settings
2. **ยิ่ง data ครบ ยิ่งดี** — Pixel + CAPI + connected Instagram/Threads = exit learning phase เร็วขึ้น
3. **Simplify ทุกอย่าง** — 1 campaign, 1-2 ad sets, 15-20 creatives ดีกว่า 10 campaigns กระจัดกระจาย

---

## 11. Campaign Structure

### แนะนำ: 2 Campaigns

```
📦 Campaign 1: "BrieflyLearn — Leads"
│   Objective: Leads
│   Budget: 300-500 ฿/วัน (เริ่มต้น)
│
├── Ad Set 1: Broad Targeting
│   │   Audience: 18-55, Thailand, ทุก interest
│   │   Optimization: CompleteRegistration event
│   │   Placements: Advantage+ (ทุก placement)
│   │
│   ├── Ad 1: Short video (< 15s) — Hook: "AI เปลี่ยนการทำงานยังไง"
│   ├── Ad 2: Carousel — 4 คอร์สยอดนิยม
│   ├── Ad 3: UGC-style — รีวิวจาก user จริง
│   ├── Ad 4: Static — Pain point + CTA
│   ├── Ad 5: Reels — สอนสั้น ๆ 1 concept
│   ├── Ad 6: Video — สาธิต AI Lab (ปลูกต้นไม้)
│   ├── Ad 7: Static — Social proof (จำนวน user)
│   ├── Ad 8: Video — Before/After ใช้ AI ทำงาน
│   ├── Ad 9: Carousel — "5 ทักษะ AI ที่ต้องมีในปี 2026"
│   ├── Ad 10: Reels — เบื้องหลังทีม BrieflyLearn
│   ├── ... (15-20 ตัว)
│   └── ทุก ad มี caption ภาษาไทย + CTA ชัดเจน
│
└── NOTE: ไม่ต้องแยก Retargeting ad set
    Andromeda จะ retarget คนที่เห็น ad แล้วอัตโนมัติ


📦 Campaign 2: "BrieflyLearn — Enrollment" (เปิดทีหลัง เมื่อมี data เพียงพอ)
│   Objective: Sales/Conversions
│   Budget: 500-1,000 ฿/วัน
│
├── Ad Set 1: Advantage+ Audience
│   │   Optimization: AddToCart event (enroll)
│   │   Placements: Advantage+
│   │
│   ├── Creative mix ใหม่ที่เน้น conversion
│   └── ...
```

### ทำไม Broad Targeting?

Meta report: Advantage+ Audience (broad) ให้ ROAS ดีกว่า interest-based targeting ในยุค Andromeda เพราะ:
- AI มี data มากพอจะหาคนที่สนใจเอง
- Targeting settings ตอนนี้เป็นแค่ **"suggestion"** ไม่ใช่ hard parameter
- ยิ่งให้ pool กว้าง Andromeda ยิ่งหาคนดีได้เยอะ

### เมื่อไหร่ควรเปิด Campaign 2?

- เมื่อ Campaign 1 สะสม CompleteRegistration ได้ 50+ ต่อสัปดาห์
- เมื่อ Pixel มี data อย่างน้อย 7-14 วัน
- เมื่อ AddToCart events มีเพียงพอให้ optimize (50+ ต่อสัปดาห์)

---

## 12. Creative Strategy

### หลักการ: Genuine Diversity

Andromeda ใช้ visual recognition ตรวจจับว่า creative ซ้ำกันหรือไม่ — ถ้าเปลี่ยนแค่สีหรือ text overlay จะถูกมองว่า **เป็นตัวเดิม** → CPM แพงขึ้น

ต้อง **ต่างกันจริง** ใน 4 มิติ:

| มิติ | ตัวอย่าง |
|------|---------|
| **Format** | Static image, Carousel, Short video (< 15s), Reels, Story |
| **Angle** | Pain point, Benefit, Social proof, Curiosity, Urgency |
| **Tone** | Professional, Casual, Humorous, Inspirational, Educational |
| **Audience motivation** | เรียนเพิ่มทักษะ, ใช้ AI ทำงาน, ก้าวหน้าในอาชีพ, ลดเวลาทำงาน |

### ตัวอย่าง Creative Angles สำหรับ BrieflyLearn

| # | Format | Angle | ตัวอย่าง Message |
|---|--------|-------|-----------------|
| 1 | Video < 15s | Pain point | "ยังทำงานแบบเดิม ๆ อยู่? AI ทำแทนได้แล้ว — เรียนฟรี" |
| 2 | Carousel | Benefit | "5 คอร์สที่จะเปลี่ยนวิธีทำงานของคุณ" (โชว์ 5 คอร์ส) |
| 3 | UGC Video | Social proof | "ผมใช้สิ่งที่เรียนไปเพิ่มยอดขาย 3 เท่า" (ถ่ายเอง/จ้าง) |
| 4 | Static | Curiosity | "คนใช้ AI ทำงาน ได้เงินเดือนสูงกว่า 40%" + CTA |
| 5 | Reels | Educational | สอน 1 concept สั้น ๆ → "เรียนต่อเต็ม ๆ ที่ BrieflyLearn" |
| 6 | Video | Product demo | สาธิต AI Lab — ปลูกต้นไม้ ได้ Impact Points |
| 7 | Static | Urgency | "เหลืออีก X ที่นั่ง" / "คอร์สใหม่เปิดแล้ว" |
| 8 | Carousel | Authority | "สอนโดยผู้เชี่ยวชาญ AI จาก..." + โปรไฟล์ |
| 9 | Video | Before/After | "ก่อนเรียน vs หลังเรียน" — process improvement |
| 10 | Reels | Behind the scenes | เบื้องหลังทีม BrieflyLearn / ทำแพลตฟอร์มยังไง |

### Video Best Practices (Andromeda ชอบ video)

- **Hook ใน 2 วินาทีแรก** — ถ้าไม่จับตาได้ Andromeda จะลด reach
- **< 15 วินาที** สำหรับ Reels/Stories
- **มี caption เสมอ** — 80% ของ user ดู video แบบปิดเสียง
- **Vertical (9:16)** สำหรับ Reels/Stories, Square (1:1) สำหรับ Feed

### Creative Refresh Cycle

```
Week 1-2:   Launch 15-20 creatives
Week 3-4:   วิเคราะห์ → 3-5 ตัวจะได้ reach เยอะ (ปกติ)
             เตรียม creative batch ใหม่ 10-15 ตัว
Week 5-6:   เพิ่ม creative ใหม่เข้า ad set
             ปิด creative ที่ CTR ต่ำ / frequency สูง
Week 7-8:   ทำซ้ำ cycle

Rule of thumb: Refresh ทุก 2-4 สัปดาห์
```

---

## 13. Budget & Bidding

### Phase 1: Testing (สัปดาห์ที่ 1-2)

| Parameter | ค่า |
|-----------|-----|
| Budget | 200-500 ฿/วัน |
| Bidding | Lowest Cost (Highest Volume) |
| Objective | Leads → CompleteRegistration |
| ดูอะไร | Hook Rate, CTR, CPR (Cost per Registration) |
| ห้ามทำ | ห้ามปรับ campaign, ห้ามเพิ่ม/ลด budget, ห้ามเปลี่ยน creative |

### Phase 2: Validation (สัปดาห์ที่ 3-4)

| Parameter | ค่า |
|-----------|-----|
| Budget | 500-1,000 ฿/วัน |
| Bidding | Cost Cap (ตั้ง cap ที่ CPR เป้าหมาย) |
| ทำอะไร | ดู creative ตัวไหนชนะ, เตรียม batch ใหม่ |
| Scale | เพิ่ม budget ครั้งละ 20-30% ต่อสัปดาห์ |

### Phase 3: Scaling (สัปดาห์ที่ 5+)

| Parameter | ค่า |
|-----------|-----|
| Budget | 1,000+ ฿/วัน (ตาม ROAS) |
| Bidding | Lowest Cost สำหรับ Advantage+ |
| ทำอะไร | Scale creative ที่ชนะ + refresh creative ใหม่ |
| เปิด Campaign 2 | ถ้ามี data เพียงพอ (50+ events/week) |

### กฎเหล็ก

- **ห้ามแตะ campaign 14-21 วัน** หลังเปิด (learning phase)
- **Scale ขึ้นครั้งละ 20-30%** ต่อสัปดาห์ (ไม่ใช่ 2x ทันที)
- **Creative budget สำคัญกว่า media budget** — $100/วัน + creative ดี ชนะ $200/วัน + creative แย่
- **อย่า duplicate campaign** เพื่อ test — ใส่ creative ใหม่ใน ad set เดิม

---

## 14. KPIs & Metrics

### Primary Metrics

| Metric | คำอธิบาย | เป้าหมาย |
|--------|---------|----------|
| **CPR** (Cost per Registration) | ค่าใช้จ่ายต่อ 1 สมัคร | ตั้งเป้าตาม budget |
| **ROAS** | Revenue / Ad Spend | > 2x (ขึ้นอยู่กับ model) |
| **EMQ Score** | Event Match Quality | > 6.0 |

### Creative Performance Metrics

| Metric | คำอธิบาย | เป้าหมาย |
|--------|---------|----------|
| **Hook Rate** | 3-second video views / impressions | > 25% |
| **Hold Rate** | ThruPlay / 3-second views | > 30% |
| **CTR** (Click-Through Rate) | Link clicks / impressions | > 1.5% |
| **CPC** (Cost per Click) | Cost / link clicks | ต่ำกว่า benchmark อุตสาหกรรม |

### Funnel Metrics (วัดผล Pixel)

| Stage | Event | Metric |
|-------|-------|--------|
| เห็น | Impression | Reach, Frequency |
| สนใจ | ViewContent | Cost per View |
| สมัคร | CompleteRegistration | CPR |
| เรียน | AddToCart (Enroll) | Cost per Enrollment |
| จบคอร์ส | Purchase | Cost per Completion |

### Report Frequency

- **Daily**: ดู spend, CPR, frequency (ดูเฉย ๆ — ห้ามปรับ!)
- **Weekly**: วิเคราะห์ creative performance, เตรียม batch ใหม่
- **Bi-weekly**: ตัดสินใจ scale/pause, refresh creative
- **Monthly**: สรุป ROAS, วางแผนเดือนถัดไป

---

## 15. Timeline & Checklist

### Phase A: Setup (ก่อนรัน ads)

- [ ] **Marketing**: สร้าง Meta Business Manager + Ad Account
- [ ] **Marketing**: สร้าง Pixel (Dataset) ใน Events Manager
- [ ] **Marketing**: Generate CAPI Access Token
- [ ] **Marketing**: ส่ง Pixel ID + Access Token ให้ Dev
- [ ] **Marketing**: Verify domain ใน Business Manager
- [ ] **Marketing**: ตั้ง AEM priority (8 events)
- [ ] **Dev**: ใส่ env variables (frontend + backend)
- [ ] **Dev**: Deploy Pixel + CAPI code
- [ ] **Dev**: Test ด้วย Meta Pixel Helper
- [ ] **Dev**: Test ด้วย Events Manager > Test Events
- [ ] **Dev**: ยืนยัน Deduplication badge
- [ ] **Dev**: ตรวจสอบ EMQ Score > 6.0
- [ ] **Dev**: ลบ META_TEST_EVENT_CODE

### Phase B: Data Collection (ปล่อย Pixel เก็บ data)

- [ ] ปล่อย Pixel ทำงาน 7-14 วัน **ก่อนเปิด ads**
- [ ] ตรวจสอบ Diagnostics ไม่มี error
- [ ] ดู event volume — ต้องมี data เพียงพอ

### Phase C: Creative Production

- [ ] เตรียม creative 15-20 ตัวที่ต่างกันจริง ๆ (4 มิติ)
- [ ] Short-form video < 15s อย่างน้อย 5 ตัว
- [ ] Static image อย่างน้อย 5 ตัว
- [ ] Carousel อย่างน้อย 3 ตัว
- [ ] Reels format อย่างน้อย 3 ตัว
- [ ] ทุกตัวมี caption ภาษาไทย + CTA ชัดเจน

### Phase D: Campaign Launch

- [ ] สร้าง Campaign 1 (Leads) ตาม structure ข้างบน
- [ ] Broad targeting, Advantage+ placements
- [ ] Budget เริ่มต้น 200-500 ฿/วัน
- [ ] **ห้ามแตะ 14-21 วัน**

### Phase E: Optimization (ต่อเนื่อง)

- [ ] วิเคราะห์ creative performance ทุกสัปดาห์
- [ ] Refresh creative ทุก 2-4 สัปดาห์
- [ ] Scale budget ครั้งละ 20-30%
- [ ] เปิด Campaign 2 (Enrollment) เมื่อ data เพียงพอ

---

## Appendix: Quick Reference

### Meta Graph API Endpoint

```
POST https://graph.facebook.com/v25.0/{PIXEL_ID}/events
```

### Standard Event Names (ที่ใช้)

```
PageView, ViewContent, CompleteRegistration, AddToCart, Purchase
```

### User Data Parameters (ต้อง hash SHA-256)

```
em = email (lowercase, trim)
ph = phone (digits only, country code included)
fn = first name (lowercase, trim)
ln = last name (lowercase, trim)
```

### Parameters ที่ไม่ต้อง hash

```
client_ip_address, client_user_agent, fbc, fbp
```

### Useful Links

- Events Manager: https://business.facebook.com/events_manager
- Pixel Helper Extension: Chrome Web Store → "Meta Pixel Helper"
- Conversions API Docs: https://developers.facebook.com/docs/marketing-api/conversions-api/
- Graph API v25.0: https://developers.facebook.com/docs/graph-api/changelog/version25.0
