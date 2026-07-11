# Work Log

Audit trail kept by the `reviewer` agent. One entry per reviewed change.

## 2026-05-25 — Add `formatBaht()` THB currency util (3-agent pipeline test)
- **Scope:** `fitness-lms/src/lib/utils.ts`
- **Coder:** Added `formatBaht(amount: number): string` using `Intl.NumberFormat("th-TH", { style: "currency", currency: "THB" })`. Sparse JSDoc, matches existing `cn()` style. tsc clean.
- **Tester:** `npx tsc --noEmit` PASS; `npm run lint` PASS (warnings present elsewhere, none in utils.ts); behavior check via `node -e` confirmed exact strings — `1234.5 → "฿1,234.50"`, `0 → "฿0.00"`, `1000000 → "฿1,000,000.00"`. Negative renders `-฿50.00` (locale default). No test setup exists for lib utils, so throwaway check only — no permanent test file added.
- **Verdict:** APPROVED — no cross-project-contract or design-system impact; pure util; tester confirmed.
- **Notes:** Negative formatting (`-฿50.00` vs `฿-50.00` vs parentheses) is a deferred product/design decision, not a defect. File still has no trailing newline (pre-existing — coder preserved it). This entry was produced as a test of the reviewer → coder → tester pipeline.

## 2026-05-25 — Rewrite /claude-team sales copy with founder story (copywriter → coder → tester)
- **Scope:** `fitness-lms/src/app/claude-team/SalesLetterClient.tsx` (copy only, +73/-55)
- **Copywriter (Opus):** Rewrote the long-form letter around the founder's real story — used Claude Cowork to *design the system his employees work inside*, scaling the org to ฿100M+ valuation and 5 branches in 1.5 years; the 129 skills reframed as battle-tested from his own org ("ไม่ใช่แค่สอน แต่ทำได้จริง"). Founder-voice first person, generic industry. Section-by-section, structure preserved.
- **Coder:** Swapped copy across eyebrow/headline/subheadline/VSL/story(+1 new `<p>`)/pullquote/hard-truth/bullets/bonus/sign-off/guarantee/FAQ(5)/bumps/P.S. Kept all JSX hooks, classes, prices, slugs, `SKILL_COUNT=129`, `BASE_PRICE=1390`. Signature → literal placeholder `~ [ ใส่ชื่อผู้ก่อตั้ง ]`. tsc clean.
- **Tester:** Live dev render — `/claude-team` 200; new headline, ฿100M story, founder placeholder, and 129 all rendered; no dev-log errors.
- **Verdict:** APPROVED — copy-only, no contract/design-system/price/slug change; real numbers (฿100M, 5 branches, 1.5yr) used per user confirmation; no fabricated testimonials.
- **Notes / user must fill before publish:** (1) `~ [ ใส่ชื่อผู้ก่อตั้ง ]` — replace with the founder's real name (page is now first-person, a team signature would break the voice). (2) Bump proof lines "🔥 84% ของทีมเลือกอันนี้" and "👥 รับแค่ 5 องค์กร/เดือน" left as-is — confirm they're real or replace/remove. NOT yet deployed.

## 2026-05-25 — /claude-team: add In-House Training section + 2 copy tweaks (copywriter → coder → tester)
- **Scope:** `fitness-lms/src/app/claude-team/SalesLetterClient.tsx` (per user feedback on the rewrite above)
- **Copywriter (Opus):** Wrote a new premium-tier enterprise callout — founder/team trains the client's whole org in-house, same system that scaled to ฿100M+/5 branches; positioned above the ฿1,390 self-serve course; contact/quote CTA, no price (user: price not set yet).
- **Coder:** (1) Signature reverted `~ [ placeholder ]` → `~ ทีม Antiparallel` (user: keep for now). (2) Workshop bump proof line `👥 รับแค่ 5 องค์กร/เดือน` → `👥 มีบริการ In-House Training ถึงองค์กรด้วย` (user: the "5" wasn't a real cap; reframed as in-house). (3) New In-House Training section inserted after `.seal-wrap`, before FAQ, reusing `.bonus-card` (no new CSS). CTA is an `<a className="btn">` contact action, NOT checkout. tsc clean.
- **Tester:** Live dev render — `/claude-team` 200; in-house section, updated bump proof, reverted signature, and CTA all rendered; no dev-log errors.
- **Verdict:** APPROVED — copy/markup only; no price/slug/SKILL_COUNT/checkout-route change; CTA correctly not routed through checkout; "84%" proof line kept per user (confirmed real).
- **Notes / user must fill before publish:** (1) in-house bullet 4 `[ ระยะเวลาเทรน / จำนวนรอบ / การติดตามผลหลังเทรน ]`. (2) CTA href `[ ใส่ Line/อีเมลติดต่อ ]` — currently a literal placeholder href (renders fine, but clicking goes nowhere useful until filled). NOT yet deployed.

## 2026-05-25 — /claude-team: In-House Training → waiting list + LINE OA CTA (coder → tester)
- **Scope:** `fitness-lms/src/app/claude-team/SalesLetterClient.tsx` (in-house section only)
- **Coder:** Reframed in-house from "request a quote" to a **waiting list** (not open for sale yet). h3 → "เร็วๆ นี้: In-House Training…"; pricing `<p>` → "ยังไม่เปิดขายทั่วไป — เปิดรับเป็นรอบจำกัด ลงชื่อไว้ก่อน"; bullet-4 placeholder → real "ติดตามผลหลังเทรน…"; CTA `<a>` → `https://line.me/R/ti/p/@antiparallel` (target=_blank, rel=noopener noreferrer), label "ลงชื่อรอรอบ In-House Training (LINE @antiparallel) →". tsc clean.
- **Tester:** Live dev — `/claude-team` 200; waiting-list heading, CTA, and LINE OA link all rendered; no dev-log errors.
- **Verdict:** APPROVED — copy/markup only; CTA opens LINE OA in a new tab safely; no price/slug/SKILL_COUNT/checkout change. **All [ … ] placeholders in the file are now gone** — the page is publish-ready (signature kept as `~ ทีม Antiparallel` per user; "84%" proof confirmed real).

## 2026-05-25 — /claude-team: move order bumps off sale page → checkout only (coder → tester)
- **Scope:** `fitness-lms/src/app/claude-team/SalesLetterClient.tsx` (sale page only; checkout untouched)
- **Rationale (user):** Tighter funnel — sale page presents one clean ฿1,390 offer + single CTA; bumps (upsell) live on the checkout page where they convert better.
- **Coder:** Removed the ORDER BUMPS block + the two `.bump` cards; simplified SUMMARY to base-price-only (total = `BASE_PRICE`); removed now-unused `bumps`/`setBumps`/`bumpPrices`/`bumpTotal`/`grandTotal`/`BumpKey`; prefill now writes a constant default `bumps: { playbooks: true, workshop: false }` so checkout still pre-checks playbooks. tsc clean.
- **Reviewer fix:** FAQ + P.P.S. copy still said "เลือก Team Workshop ด้านบน/ด้านล่าง" (pointing at the removed bumps) — reworded both to "ในขั้นตอนชำระเงินจะมีออปชัน Team Workshop ให้เพิ่ม".
- **Tester:** Live dev — sale page has NO bump card; checkout STILL shows bumps (Department Playbooks); corrected pointer copy live; both routes 200; no dev errors. (Initial tester "bump still on sale page" was a false positive — matched the FAQ/P.P.S. text, since fixed.)
- **Verdict:** APPROVED — sale page is single-offer; bumps isolated to checkout; no price/slug/SKILL_COUNT/checkout-flow change.

## 2026-05-25 — /claude-team: fix In-House CTA text overflowing the button
- **Scope:** `fitness-lms/src/app/claude-team/sales-page.css` + `SalesLetterClient.tsx`
- **Issue (user screenshot):** The In-House waiting-list CTA label is much longer than the order button; `.btn` had a fixed `font-size: 22px` with no wrapping, so the text spilled past the button border.
- **Fix:** Added `white-space: normal; overflow-wrap/word-break: break-word; line-height: 1.25` to `.cowork-root .btn` (safe for all buttons), and a `.btn-inhouse` modifier (`font-size: 18px`) applied only to the long In-House CTA anchor.
- **Verify:** tsc clean; dev render 200, `btn btn-inhouse` class present; no errors.
- **Verdict:** APPROVED — scoped CSS only, no other button affected.

## 2026-05-25 — /claude-team: punch up the main headline (copywriter → coder)
- **Scope:** `fitness-lms/src/app/claude-team/SalesLetterClient.tsx` (h1 only)
- **Issue (user):** Old headline ("ผมไม่ได้แค่ เรียนใช้ AI — …ออกแบบ ระบบที่พนักงาน…") felt flat, weak hook.
- **Copywriter (Opus):** Generated 8 candidates across angles (result/curiosity/pain/authority). User picked the **authority** angle.
- **Coder:** h1 → `{SKILL_COUNT} Skills ที่ผมไม่ได้ "สอน" — ผมใช้มันจริงในบริษัทตัวเอง จนได้ [฿100 ล้าน, 5 สาขา, 1 ปีครึ่ง]` (accent span on the numbers; uses `{SKILL_COUNT}` so it stays synced to 129). tsc clean, dev render OK.
- **Verdict:** APPROVED — copy-only h1 swap, attacks the "another guru course" objection up front with battle-tested proof.

## 2026-07-11 — Sales Page CMS feature (backend + frontend, coder×2 → tester → reviewer)
- **Scope:** Backend `fitness-lms-admin`: new `SalesPage` model/controller/`SalesPageResource`(+Pages)/2 migrations/`SalesPageTemplateSeeder`/`SalesPageApiTest`; modified `BumpProduct` model+controller+resource (+4 display cols), `routes/api.php` (public `GET v1/sales-pages/{slug}`), `config/app.php` (`frontend_url` key), SQLite guard on `2026_04_19` enrollments-enum migration. Frontend `fitness-lms`: new dir `src/app/p/[slug]/` (layout, page, SalesLetterRenderer, markup, types, sales-page.css, checkout/{page,CheckoutClient}).
- **Coder:** CMS-driven long-form sales letter rendered at `/p/{slug}` with pixel parity to `/ai-100m` (CSS copied byte-identical, scoped `.ai100m-root`), 17 section block types, inline mini-markup tokenizer (React nodes, no raw HTML), parameterized checkout reusing `startPaysolutionsCheckout` + guest-signup + order bumps. Filament Builder resource with per-block field schemas, Duplicate row action, "view live" link, published-only public API.
- **Tester:** VERDICT PASS on 7 items. Reviewer independently re-verified: `npx tsc --noEmit` exit 0; `npm run lint` no NEW warnings (only pre-existing in blog/Header/video/GardenContext); `php artisan test` 5/5 pass incl. `SalesPageApiTest` (published returns sections+bumps, draft→404, unknown→404); `ai-100m`/`claude-team`/`sales`/`payments.ts` confirmed untouched via `git status --porcelain`; `startPaysolutionsCheckout(courseId, bumpSlugs)` signature intact.
- **Verdict:** APPROVED
- **Notes:** Security clean — no `dangerouslySetInnerHTML`/`innerHTML`/`eval` anywhere under `src/app/p/`; markup renderer is a tokenizer returning React nodes (unclosed markers fall through to literal text); all CMS text (FAQ answers, bump name/description/proof/badge) rendered as escaped children. `base_price` is display-only; backend PaymentController still computes the real total from course + bump slugs. Published-only gating with identical 404 shape for draft vs unknown (no draft leakage). No mass-assignment risk (explicit `$fillable`; controller selects/maps explicit columns). Data-shape consistency verified end-to-end: Filament `Repeater::simple()` flat `string[]` matches seeder, API JSON, and frontend `.map`. Two out-of-scope backend edits are safe: `config/app.php frontend_url` only formalizes an env key already read with fallbacks (no behavior change); SQLite migration guard is a no-op on MySQL/prod (early-return only when driver is sqlite) and unblocks PHPUnit. Follow-up (non-blocking): seeded template `course_id` is null by design, so its checkout shows the "ยังไม่ได้ผูกคอร์ส" error until an admin duplicates and binds a course — expected, documented in seeder + Filament helper text.
