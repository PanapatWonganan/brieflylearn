# Long-Form Sale Page — Design Document

> **Status**: Design approved, awaiting mock review before implementation
> **Author**: Product planning session (2026-04-21)
> **Decisions locked**: Proof-heavy style · Tier bundle upgrade · Hybrid theme · Content blocks CMS with A/B + drag-drop

---

## 0. Context

Current state (pre-change):
- `/sales/[slug]` exists with hardcoded `SALE_PAGES` constant in `fitness-lms/src/app/sales/[slug]/page.tsx`
- `fetchSalePage(slug)` stub in `lib/api/sales.ts` returns `null` — backend API not built
- Payment system via Pay Solutions is **production-ready** (`PaymentController`, `Enrollment` model, `/v1/payments/paysolutions/*`)
- Single CTA button → `/courses/{id}/checkout` — no tier selection
- Dark theme (`#0E0E0E` bg + mint `#00FFBA` accent), entire page dark

Goal: convert `/sales/[slug]` into a fully admin-managed, proof-heavy long-form funnel with tiered bundles and A/B testing capability.

---

## 1. Information Architecture

Proof-heavy long-form (Ramit Sethi / Alex Hormozi school). ~25–35 screens, 6,000–10,000 Thai words.

```
01. Sticky Price Header         (existing — keep)
02. Hero + Stats                (existing — refine copy)              ▸ dark
03. Results-First Strip         NEW — 6-9 case thumbnails              ▸ dark
────── theme transition ──────
04. Pain Points                 (existing)                              ▸ light
05. Why Most AI Courses Fail    NEW — positioning                      ▸ light
06. The System / Framework      NEW — named methodology + diagram      ▸ light
07. Featured Case Study #1      NEW — 800-1200 words long              ▸ light
08. Benefits                    (existing — refine)                     ▸ light
09. Curriculum + outcomes       (existing — add per-module outcome)     ▸ light
10. Featured Case Study #2      NEW — different persona                 ▸ light
11. Testimonial Wall            NEW — masonry, text+screenshot+video   ▸ light
12. Instructor                  (existing)                              ▸ light
13. Comparison Table            NEW — self-study / YT / others / us    ▸ light
────── theme transition ──────
14. Value Stack Breakdown       (existing — moved before tier)         ▸ dark
15. TIER BUNDLE SELECTION       NEW — replaces old PricingSection      ▸ dark
────── theme transition ──────
16. Guarantee / Risk Reversal   (existing — expanded long-form)        ▸ light
17. FAQ                         (existing — 8-12 questions)            ▸ light
18. Founder's Letter / P.S.     NEW — personal closing letter          ▸ light
19. Final CTA                   (existing)                              ▸ dark
20. Social Proof Popup          (existing — should use real data)
21. Sticky Mobile CTA           (existing)
```

Micro-CTA between every 2–3 sections (scroll to tier bundle).

---

## 2. Hybrid Theme Strategy

### Rationale
Long-form on pure dark bg causes reading fatigue (20-30% after 2-3 min), weakens trust signals for education/finance niches, and clashes with real-world screenshots (Facebook, Shopee dashboards, Gmail) that are all light UIs.

### Section theme assignment

| Section | Theme | Purpose |
|---|---|---|
| Hero, Case Strip, Value Stack, Tier Bundle, Final CTA | **Dark** | Wow factor, emotion peak, CTA pop, premium feel |
| All content (pain, benefits, curriculum, cases, testimonials, instructor, comparison, guarantee, FAQ, founder letter) | **Light** | Readability, trust, screenshot-friendly |

### Palette (reuses existing design tokens, no new tokens needed)

**Dark sections**
- bg: `#0E0E0E` (surface-500)
- text: `#F2F2F0` (surface-50)
- accent: mint `#00FFBA`
- CTA: orange `#FF6B35`
- urgency: red `#FF4757`

**Light sections**
- bg: `#fdfcfa` (sand-50) · alt bg: `#f7f4ee` (sand-100)
- text: `#1a1a1a` (ink) · secondary: `#4a4a4a` (ink-light) · muted: `#8a8a8a`
- accent: brand green `#4a7a5a`
- CTA: keep orange `#FF6B35` (conversion color stays consistent)
- urgency: red `#9b4d4d` (warm minimalism error token)
- borders: `#e8e4dc` (sand-200)

### Theme transitions
- 80-120px height transition zone between opposite themes
- Subtle linear gradient (not hard cut)
- Section numbers / labels use mono font in both themes
- CTA button color (orange) stays consistent throughout — anchor for scroll-based recognition

---

## 3. Tier Bundle System (replaces old PricingSection)

Single section with 3 cards side-by-side + existing order bump + unified CTA.

### Card structure
```
BASIC ฿2,990         PREMIUM ★ ฿5,990        VIP ฿14,990
                     [ยอดนิยม]
─────────────        ─────────────           ─────────────
Core content         Core content            Core content
50 prompts           100 prompts             200 prompts
—                    4 Live Q&A              12 Live Q&A
—                    —                       1:1 coaching
—                    Templates               All templates + WL
Cert                 Cert + role             Cert + WL access
─────────────        ─────────────           ─────────────
[เลือก Basic]       [เลือก Premium] ✓        [เลือก VIP]
```

Premium pre-selected (anchor pricing between Basic and VIP).

### Backend implementation
- Each tier = separate `Course` row in DB (`course_id_basic`, `course_id_premium`, `course_id_vip`)
- Admin maps tier → course_id in tier_bundle section config
- Checkout: frontend POSTs `{ tier, selected_bumps }` → backend resolves to `course_id` → reuses existing `PaymentController::checkout()` logic
- **No changes needed** to Pay Solutions payment flow, Enrollment model, or gating logic

---

## 4. Database Schema

### 4.1 `sale_pages`
```php
uuid id, string slug (unique), string title, bool is_active, bool is_ab_test,
string variant default 'A', string meta_title, text meta_description,
string og_image, string currency default 'THB', string theme default 'hybrid',
string meta_pixel_id nullable, json tracking_config nullable, timestamps
```

### 4.2 `sale_page_variants` (A/B testing)
```php
uuid id, fk sale_page_id, string variant, int traffic_weight default 50,
int view_count default 0, int conversion_count default 0,
decimal revenue(12,2) default 0, timestamps
UNIQUE(sale_page_id, variant)
```

### 4.3 `sale_page_sections` (content + drag-drop order)
```php
uuid id, fk sale_page_id, string variant default 'A',
string type, int order_index, bool is_visible default true,
json content, timestamps
INDEX(sale_page_id, variant, order_index)
```

Valid `type` values (18 blocks):
`hero`, `case_study_strip`, `pain_points`, `why_fail`, `framework`, `featured_case`,
`benefits`, `curriculum`, `testimonial_wall`, `instructor`, `comparison`, `value_stack`,
`tier_bundle`, `guarantee`, `faq`, `founder_letter`, `final_cta`, `custom_html`

### 4.4 `sale_page_order_bumps`
```php
uuid id, fk sale_page_id, string variant default 'A',
string title, text description, decimal price(10,2),
decimal original_price(10,2) nullable, string deliverable_type,
uuid deliverable_id nullable, bool is_active default true,
int order_index default 0, timestamps
```

### 4.5 `sale_page_events` (A/B tracking)
```php
uuid id, fk sale_page_id, string variant, string event_type,
uuid user_id nullable, string session_id(64), json metadata nullable,
timestamp occurred_at, timestamps
INDEX(sale_page_id, variant, event_type, occurred_at)
```

Event types: `view`, `cta_click`, `tier_select`, `purchase`

---

## 5. Content JSON schemas (per section type)

See full schemas in the original planning doc. Key ones:

### `hero`
```json
{ "headline": "...", "subheadline": "...", "cta_text": "...", "cta_subtext": "...",
  "video_url": "...", "image_url": "...",
  "stats": { "students": "5,000+", "rating": "4.9", "completion": "92%" } }
```

### `case_study_strip`
```json
{ "title": "ผลลัพธ์จริงจากนักเรียน",
  "items": [
    { "metric_before": "฿120k/เดือน", "metric_after": "฿480k/เดือน",
      "label": "เจ้าของร้านออนไลน์", "name": "สมชาย ก.",
      "case_study_id": "uuid-ref-to-featured-case" }
  ] }
```

### `featured_case`
```json
{ "headline": "...", "subject_name": "...", "subject_role": "...", "subject_avatar": "...",
  "context": "...", "problem": "...", "solution": "...", "result": "...",
  "screenshots": ["url1", "url2"], "quote": "...",
  "metrics": [
    { "label": "รายได้/เดือน", "before": "120,000", "after": "480,000", "change": "+300%" }
  ] }
```

### `framework`
```json
{ "framework_name": "BRIEF Framework",
  "subtitle": "ระบบ 5 ขั้นตอนที่ใช้สอนลูกศิษย์ 5,000+ คน",
  "pillars": [ { "letter": "B", "word": "Brief", "description": "..." } ],
  "diagram_url": "optional.svg" }
```

### `tier_bundle`
```json
{ "title": "เลือก Tier ที่เหมาะกับคุณ", "subtitle": "...",
  "tiers": [
    { "name": "Basic", "slug": "basic", "course_id": "uuid",
      "price": 2990, "original_price": 5900, "is_featured": false,
      "badge_text": null, "short_pitch": "เริ่มต้นเรียน AI",
      "features": [ { "text": "เนื้อหาคอร์สเต็ม", "included": true } ],
      "cta_text": "เลือก Basic" }
  ] }
```

### `comparison`
```json
{ "title": "ทำไมต้องเลือกคอร์สนี้",
  "headers": ["เรียนเอง", "YouTube", "คอร์สทั่วไป", "BrieflyLearn"],
  "rows": [
    { "label": "เวลาที่ใช้", "values": ["6เดือน+", "ไม่แน่นอน", "3เดือน", "30วัน"] }
  ] }
```

### `testimonial_wall`
```json
{ "title": "...", "layout": "masonry",
  "testimonials": [
    { "type": "text", "name": "...", "role": "...", "text": "...", "rating": 5 },
    { "type": "screenshot", "image_url": "...", "caption": "..." },
    { "type": "video", "thumbnail_url": "...", "video_url": "...", "duration": "2:34" }
  ] }
```

### `founder_letter`
```json
{ "greeting": "สวัสดีครับ ผม...", "body": "...markdown...",
  "signature_name": "...", "signature_title": "...", "signature_image": "...",
  "ps": "P.S. ...", "pps": "P.P.S. ..." }
```

---

## 6. API Endpoints

### Public
```
GET  /api/v1/sales-pages/{slug}
     → { sale_page, variant (A|B), sections[], order_bumps[], tier_courses{basic,premium,vip} }

POST /api/v1/sales-pages/{slug}/track
     body: { event_type, session_id, metadata, variant }
     (fire-and-forget, no auth)
```

### Protected (auth.api)
```
POST /api/v1/sales-pages/{slug}/checkout
     body: { tier: 'basic'|'premium'|'vip', selected_bumps: [uuid,...], variant }
     → resolves tier → course_id → reuses PaymentController::checkout()
     → returns { url, fields, order_no }
```

---

## 7. Filament Admin Panel

### `SalePageResource`
Tabs: Settings · Content (A) · Content (B) · Pricing · Order Bumps · Analytics · SEO

### Content editor
Use Filament `Builder` with 18 `Block` types — native support for:
- Drag-drop reordering (`->reorderable()`)
- Collapsible blocks (`->collapsible()`)
- Clone block (`->cloneable()`)
- Conditional schema per block type

Example:
```php
Builder::make('sections')
    ->blocks([
        Block::make('hero')->icon('heroicon-o-star')->schema([...]),
        Block::make('case_study_strip')->schema([...]),
        Block::make('featured_case')->schema([...]),
        Block::make('tier_bundle')->schema([...]),
        // ... 18 total
    ])
    ->collapsible()
    ->reorderable()
    ->cloneable()
    ->blockNumbers()
```

### On save
`SalePage::saving()` observer explodes Builder JSON into normalized rows in `sale_page_sections` for efficient queries on frontend fetch.

### Analytics tab (read-only widgets)
- Line chart: views A vs B per day
- Conversion funnel (view → CTA → tier_select → purchase)
- Revenue A vs B
- "Declare A winner" / "Declare B winner" action (copies winning sections to A, disables test)

---

## 8. Frontend Architecture

### File structure
```
src/app/sales/[slug]/
├── page.tsx                    # Section dispatcher
├── sections/
│   ├── Hero.tsx / CaseStudyStrip.tsx / PainPoints.tsx / WhyMostFail.tsx
│   ├── Framework.tsx / FeaturedCase.tsx / Benefits.tsx / Curriculum.tsx
│   ├── TestimonialWall.tsx / Instructor.tsx / Comparison.tsx / ValueStack.tsx
│   ├── TierBundle.tsx / Guarantee.tsx / FAQ.tsx / FounderLetter.tsx
│   ├── FinalCTA.tsx / CustomHTML.tsx
├── components/
│   ├── StickyPriceHeader.tsx / StickyMobileCTA.tsx
│   ├── SocialProofPopup.tsx / MicroCTA.tsx / ThemeTransition.tsx
├── hooks/
│   ├── useSalePageData.ts / useTierSelection.ts / useSessionId.ts
└── layout.tsx
```

### Section dispatcher pattern
```tsx
const sectionRegistry: Record<string, ComponentType<SectionProps>> = {
  hero: Hero, case_study_strip: CaseStudyStrip, pain_points: PainPoints,
  why_fail: WhyMostFail, framework: Framework, featured_case: FeaturedCase,
  // ...
}

export default function SalePage() {
  const { data } = useSalePageData(slug)
  const tierState = useTierSelection(data?.tier_courses, data?.order_bumps)

  return (
    <main>
      <StickyPriceHeader ... />
      {data.sections.map(section => {
        const C = sectionRegistry[section.type] ?? CustomHTML
        return <C key={section.id} content={section.content} ctx={tierState} />
      })}
      <StickyMobileCTA ... />
      <SocialProofPopup ... />
    </main>
  )
}
```

### A/B variant (sticky per user)
```typescript
function getOrAssignVariant(slug: string, weights: {A: number, B: number}): 'A' | 'B' {
  const key = `sale_variant_${slug}`
  const existing = localStorage.getItem(key)
  if (existing === 'A' || existing === 'B') return existing
  const chosen = Math.random() * 100 < weights.A ? 'A' : 'B'
  localStorage.setItem(key, chosen)
  return chosen
}
```

---

## 9. Implementation Plan

### Phase 1 — Backend foundation
1. Migrations: `sale_pages`, `sale_page_sections`, `sale_page_order_bumps`, `sale_page_variants`, `sale_page_events`
2. Models with UUID + JSON casts
3. `SalePageSeeder` importing current `SALE_PAGES` hardcoded data
4. `SalePageController`: `show`, `track`, `checkout` (delegates to PaymentController)
5. Routes under `v1/sales-pages`
6. Tests: `php artisan test --filter=SalePage`

### Phase 2 — Filament admin
7. `make:filament-resource SalePage --generate`
8. Builder with 18 block types + schemas
9. Analytics tab (chart + funnel + revenue widgets)
10. Duplicate sale page action
11. Variant traffic split + validation (A+B=100)
12. Declare winner action
13. Navigation group "การขาย / Sales"

### Phase 3 — Frontend refactor (functional, no design change)
14. Update `lib/api/sales.ts`: real `fetchSalePage`, add `trackSalePageEvent`, `startTierCheckout`
15. New hooks: `useSessionId`, `useSalePageData`, `useTierSelection`
16. Extract existing sections to `sections/*.tsx`
17. Section dispatcher in `page.tsx`
18. Remove `SALE_PAGES` constant
19. `npx tsc --noEmit` + `npm run lint` pass

### Phase 4 — New sections + hybrid theme
20. `CaseStudyStrip.tsx` (dark)
21. `WhyMostFail.tsx` (light)
22. `Framework.tsx` (light, with diagram)
23. `FeaturedCase.tsx` (light, screenshot + metric table)
24. `TestimonialWall.tsx` (light, masonry + screenshot + video)
25. `Comparison.tsx` (light)
26. `TierBundle.tsx` (dark, replaces PricingSection)
27. `FounderLetter.tsx` (light, markdown render)
28. `MicroCTA.tsx` (inline scroll-to-tier)
29. `CustomHTML.tsx` (DOMPurify sanitized)
30. `ThemeTransition.tsx` (80-120px gradient zone)

### Phase 5 — Content migration + first A/B
31. Write 2 featured case studies (800-1200 Thai words + screenshots)
32. Write framework pillars (5 pillars)
33. Write founder letter
34. Create 3 tier Course records (Basic / Premium / VIP)
35. Fill comparison table copy
36. Launch A = short (current sections) vs B = full long-form
37. Monitor 2 weeks, declare winner

### Phase 6 — Polish
38. SSR meta tags via `generateMetadata()`
39. Sitemap `/sales/[slug]`
40. Lazy-load below-fold images
41. Update `fitness-lms/CLAUDE.md` sale funnel section

### Non-goals (excluded from this phase)
- Multi-step OTO funnel (tier bundle replaces it)
- Self-hosted VSL (use YouTube/Vimeo embed)
- Heatmap integration (use external tool)
- Post-purchase email drip (already exists in Laravel mail system)

---

## 10. Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Filament Builder JSON not normalized → slow queries | `SalePage::saving()` observer explodes JSON into rows |
| A/B variant flip after user visit breaks funnel | Sticky variant in localStorage + cookie fallback |
| Admin edits cached by Cloudflare | Use `revalidateTag('sale-page-{slug}')` or SSR per-request (low traffic OK) |
| Tier selection → guest 401 | Guard guest state, redirect `/login?redirect=/sales/{slug}?tier=premium` |
| `custom_html` XSS | DOMPurify frontend + Filament validation |
| 6000+ Thai words = slow LCP | Stream sections by viewport; hero + case strip eager, rest lazy |

---

## 11. Open Questions

1. **Tier → Course mapping**: 3 separate Course records (Basic/Premium/VIP) or 1 Course + tier metadata on enrollment?
2. **A/B scope**: Test at section level (A has founder_letter, B doesn't) or only headline/price?
3. **Case study content**: Use fictional-with-disclaimer initially, or wait until 2 real cases are collected?
4. **Framework naming**: "BRIEF Framework" was a placeholder — what's the actual methodology name for BrieflyLearn?

---

## 12. Ethics note on current implementation

The existing `/sales/[slug]/page.tsx` contains:
- `SocialProofPopup` with hardcoded fake names (`SOCIAL_PROOF_NAMES` array, lines 223–227) creating fake "just enrolled" notifications
- `urgency` copy "ราคาพิเศษนี้มีจำนวนจำกัด" with no backend-enforced limit

Recommendation for the new version:
- Social proof popup should pull from real `sale_page_events` with `event_type = 'purchase'`
- Urgency should be backend-enforceable (e.g., first-100-students discount code with real count)

Both options convert better long-term AND avoid Thai consumer protection law risks (พ.ร.บ. คุ้มครองผู้บริโภค — misleading claims).

---

## 13. References

- Unbounce Conversion Benchmark Report 2023 — light-bg long-form convert 12-18% higher in education/coaching
- ClickFunnels top 100 templates — 87 use light/cream bg
- Long-form exemplars: Alex Hormozi, Ramit Sethi, Sam Ovens, Russell Brunson, Copyhackers case studies
- Internal: `fitness-lms/CLAUDE.md` § Sale funnel system, § Design System
- Internal: `fitness-lms-admin/CLAUDE.md` § Payment flow
