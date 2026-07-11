# Business Brain — SaaS Spec (v1)

> "สมองร้าน" — AI ที่เชื่อมแชตลูกค้า (LINE OA / Facebook / IG) ของร้านค้า SME,
> ดูดความจำเข้าระบบอัตโนมัติ, ตอบลูกค้าแทนด้วยน้ำเสียงของร้าน, และสะสม
> โปรไฟล์ลูกค้ารายคนเป็นสินทรัพย์ที่ย้ายออกไม่ได้ (data lock-in moat).

Status: spec draft for build. Built on existing Antiparallel backend (Laravel 12,
`fitness-lms-admin/`) + frontend (Next.js 15, `fitness-lms/`).

---

## 1. The moat thesis (why this, not a chatbot)

คู่แข่งก๊อปปุ่ม "ตอบด้วย AI" ได้ใน 1 สัปดาห์ — **feature ไม่ใช่ moat**. moat ของเราคือ
สิ่งที่อยู่รอบๆ AI:

1. **Data ไหลเข้าเองจากแชตที่ร้านทำอยู่แล้ว** — SME ไม่ต้องป้อนข้อมูล (ถ้าต้องป้อน = ตาย).
2. **ความจำลูกค้ารายคนสะสมขึ้นเรื่อยๆ** — ใช้ 6–12 เดือน = โปรไฟล์ลูกค้าทุกคนอยู่ในนี้.
   ย้ายเจ้าอื่น = เริ่มจำใหม่จากศูนย์. คู่แข่งให้ฟรียังไม่ย้าย.
3. **ฝังในงานประจำวัน** — แชตลูกค้าคือลมหายใจของร้าน เปิดทุกวันอยู่แล้ว.

ด่านที่ spec นี้ต้องผ่านทั้ง 3:
- [x] ยิ่งใช้นาน data ยิ่งมีค่าจนทิ้งไม่ลง → per-customer memory + thread history.
- [x] คู่แข่งก๊อป feature พรุ่งนี้ ลูกค้ายังอยู่ → เพราะ data อยู่ที่เรา ไม่ใช่ที่เขา.
- [x] ฝังในงานประจำวัน → webhook กินแชตจริงทุกวัน ไม่ใช่เปิดเป็นครั้งคราว.

---

## 2. What we reuse vs build (from repo audit)

| Component | Status | Action |
|---|---|---|
| Token auth (`ApiTokenAuth.php`, `AuthController`) | ✅ exists | Reuse; tenant resolves via owner's `user_id` |
| Multi-tenancy | ❌ none (all `user_id`-scoped) | **Build** `businesses` + scope |
| Payments (Paysolutions, one-time) | ✅ exists | **Extend** → recurring subscription |
| Garden gamification (course-coupled events) | ⚠️ coupled | **Refactor** to generic event, fire from chat |
| LINE / Meta webhook ingest | ❌ none (only Meta CAPI outbound) | **Build** from scratch |
| Claude / LLM | ❌ none | **Build** Anthropic integration + memory layer |
| Queue (database driver, `brieflylearn-queue`) | ✅ exists | Reuse; add new Job classes |

Use Claude models per project convention (`claude-opus-4-8` for quality reply,
`claude-haiku-4-5` for cheap extraction/classification — confirm via the `claude-api` skill).

---

## 3. Data model (new tables, UUID PK, follow `HasUuids`)

### `businesses` (the tenant)
```
id (uuid)  owner_id (uuid → users)  name  voice_profile (json: tone, do/don't, signature)
plan (text: trial|starter|pro)  trial_ends_at  subscription_status  created_at
```

### `channels` (one row per connected OA / page)
```
id  business_id (uuid → businesses)  platform (line|facebook|instagram)
external_id (LINE OA id / FB page id / IG id)  access_token (encrypted)  secret (encrypted)
auto_reply_mode (off | suggest | auto)  connected_at  status
```

### `contacts` (the per-customer memory — THE moat asset)
```
id  business_id  channel_id  platform_user_id (LINE userId / PSID)
display_name  avatar_url
memory (json: summary, preferences, allergies/notes, past_purchases, complaints, tags)
last_message_at  message_count  created_at
```
Unique: `[channel_id, platform_user_id]`.

### `messages` (raw chat log — the ingest stream)
```
id  business_id  contact_id  channel_id  direction (in|out)
role (customer|shop|ai)  body (text)  attachments (json)  platform_message_id
ai_generated (bool)  ai_status (suggested|sent|edited)  created_at
```
Index `[contact_id, created_at]`.

### `knowledge_items` (shop facts AI may answer from — FAQ/price/policy)
```
id  business_id  type (faq|price|policy|product)  question  answer
source (manual|extracted)  embedding (json/vector, nullable v1)  confidence  created_at
```

### `subscriptions` (extend payments — recurring)
```
id  business_id  plan  status (trialing|active|past_due|canceled)
current_period_end  paysolutions_ref  amount  created_at
```

> Reuse the existing Paysolutions postback verification; subscription renewal = a scheduled
> charge attempt + postback updates `subscriptions.status`. (Paysolutions has no native
> recurring token in current integration → v1 uses scheduled re-charge / manual renewal link;
> confirm gateway capability before building auto-rebill.)

---

## 4. Core flows

### A. Connect a channel (onboarding — must be < 5 min or SME bails)
1. Owner logs in (existing auth) → creates `business` (auto on first access, like `getOrCreateGarden`).
2. "เชื่อม LINE OA" → guided: paste Channel access token + secret (LINE Developers).
   - FB/IG: Meta OAuth (Pages + pages_messaging scope). v1 may start LINE-only to ship faster.
3. Set webhook URL on the platform → points to `POST /api/v1/webhooks/{platform}/{channel}`.
4. Onboarding wizard scrapes last N messages (if API allows) to seed `contacts` + `memory`
   → so the brain isn't empty on day 1 (kills the "cold start" moat-killer).

### B. Inbound message → memory + reply (the loop)
```
LINE/FB webhook → WebhookController (verify signature, 200 fast)
  → dispatch IngestMessageJob (queue)
      → upsert contact, store message (direction=in)
      → dispatch UpdateContactMemoryJob (Claude haiku: merge new facts into contact.memory)
      → if channel.auto_reply_mode != off:
          dispatch GenerateReplyJob
            → build context: contact.memory + recent messages + matched knowledge_items + business.voice_profile
            → Claude opus → draft reply
            → mode=suggest: store as message(ai_status=suggested), notify owner UI
            → mode=auto: SendReplyJob → platform send API → store message(direction=out, ai_generated=true)
      → fire ChatHandled event → garden reward (see §5)
```

### C. Ask the brain (owner-facing value, drives daily open)
- Dashboard "ถามสมองร้าน": "ลูกค้าคนนี้เคยคุยอะไรไว้" / "เดือนนี้คนถามเรื่องอะไรเยอะ" /
  "ใครยังไม่ได้ตอบ". Backed by `messages` + `contacts.memory` aggregation + Claude.

---

## 5. Gamification reuse (engagement, not moat — keep it lightweight)

Refactor garden events to be generic (currently hardcoded to Lesson/Course):
- New event `ChatHandled` / `MilestoneReached` → new listener → call a refactored
  `ProgressService` that accepts generic `{type, weight}` instead of a `Lesson` model.
- Reward signals that reinforce the habit: streak of "ตอบลูกค้าครบทุกคนวันนี้",
  "AI ช่วยตอบไป N ข้อความเดือนนี้". XP/Seeds optional in v1 — the real hook is the brain itself.

Do NOT over-invest here in v1. moat = data, not points.

---

## 6. API surface (new, under `/api/v1`)

| Method | Route | Auth | Purpose |
|---|---|---|---|
| POST | `/v1/business` | auth.api | create/get business |
| POST | `/v1/channels` | auth.api | connect a channel |
| POST | `/webhooks/{platform}/{channel}` | public (signature-verified) | inbound messages |
| GET | `/v1/contacts` | auth.api | list customers + memory |
| GET | `/v1/contacts/{id}/messages` | auth.api | thread |
| POST | `/v1/contacts/{id}/reply` | auth.api | send/approve a reply |
| POST | `/v1/brain/ask` | auth.api | ask-the-brain query |
| POST | `/v1/knowledge` | auth.api | add FAQ/price/policy |
| POST | `/v1/subscriptions/checkout` | auth.api | start paid plan (reuse Paysolutions) |

Webhook routes are public but MUST verify platform signature (LINE: `X-Line-Signature` HMAC;
Meta: `X-Hub-Signature-256`). Respond 200 fast, do work in queue.

---

## 7. Pricing (recurring — the point of the SaaS)

| Plan | ฿/เดือน | Limits |
|---|---|---|
| Trial | 0 (14 วัน) | 1 channel, 200 AI replies |
| Starter | 590 | 1 channel, 1,000 AI replies/เดือน, brain memory ไม่จำกัด |
| Pro | 1,490 | 3 channels, 5,000 replies, ask-the-brain ไม่จำกัด, ทีมหลายคน |

Lock-in framing in marketing: "ยิ่งใช้ AI ยิ่งจำลูกค้าคุณได้แม่นขึ้น" — แต่ moat ของจริงคือถ้าเลิก
ใช้ = เสียความจำลูกค้าทั้งหมด. Export อนุญาต (อย่าขังลูกค้าด้วยกำแพง) — moat มาจากความสะดวก+ความจำที่สดทุกวัน ไม่ใช่การขังข้อมูล.

---

## 8. Biggest risks (de-risk these first)

1. **LINE/Meta API approval + rate limits** — Messaging API ต้องผ่าน review, มี quota.
   → De-risk: build LINE OA first (Thai SME ใช้ LINE มากสุด), validate with 1 real shop.
2. **Cold start (empty brain)** — แก้ด้วยการ seed จากแชตเก่า + onboarding ที่ดูดข้อมูลให้.
3. **AI ตอบผิดต่อหน้าลูกค้าจริง** — default `mode=suggest` (คนกดส่ง) ก่อน, ค่อยปลดเป็น `auto`
   เมื่อ owner เชื่อใจ. ลด churn จากความกลัว.
4. **ค่า LLM ต่อข้อความ** — haiku สำหรับ extraction, opus เฉพาะตอน generate reply.
   ตั้ง quota ต่อ plan. ตรวจต้นทุนจริงก่อนตั้งราคาให้ตาย.
5. **PDPA / ความยินยอม** — เก็บแชตลูกค้า = ข้อมูลส่วนบุคคล. ต้องมี consent + นโยบายชัด
   (ไทยมี PDPA). อย่าข้าม — เป็นทั้งความเสี่ยงทางกฎหมายและจุดขายความน่าเชื่อถือ.

---

## 9. Build plan (phased — ship the moat loop first)

**Phase 0 — Spike / de-risk (เล็กแต่สำคัญ)**
- Anthropic API integration spike (1 prompt: extract facts from a Thai chat → JSON).
- LINE OA webhook spike: receive a real message in local dev (ngrok) → log it.
- Confirm Paysolutions recurring capability (or design scheduled re-charge fallback).

**Phase 1 — The core loop (LINE only, suggest-mode)**
- Migrations: `businesses`, `channels`, `contacts`, `messages`, `knowledge_items`.
- `getOrCreateBusiness()` (mirror `getOrCreateGarden`).
- Webhook controller (LINE signature verify) + `IngestMessageJob`.
- `UpdateContactMemoryJob` (Claude haiku) + `GenerateReplyJob` (Claude opus, suggest only).
- Owner UI: inbox + per-contact memory panel + approve/send reply.

**Phase 2 — Monetize + lock-in deepen**
- `subscriptions` + Paysolutions recurring/renewal.
- Trial gating (200 replies), plan limits enforcement.
- Auto-reply mode toggle (suggest → auto).
- "ถามสมองร้าน" dashboard query.

**Phase 3 — Expand moat surface**
- Facebook + IG channels (Meta OAuth).
- Knowledge extraction (auto-build FAQ from repeated questions).
- Light gamification (refactor garden events to generic).
- Team seats (Pro plan) — needs `business_users` pivot.

**Phase 4 — Sales funnel**
- New `/sales/business-brain` funnel page (reuse SalesLetterClient + copywriter agent).
- Upsell placement inside existing course dashboard for warm list.

---

## 10. Cross-project contract notes (do not break)

- New webhook routes are PUBLIC but signature-verified — keep them OUT of `auth.api`.
- All new tables UUID PK + `HasUuids`, follow JSON-column + unique-constraint conventions.
- Frontend stores token under both `auth_token` + `boostme_token` (existing rule).
- Owner-facing pages follow main-app design tokens (dark, mint `#00FFBA`, `rounded-sm`);
  the funnel page may break those rules like `/ai-100m` does.
