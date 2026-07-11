---
name: implement-feature
description: Implement a single well-scoped code change in the Antiparallel monorepo (Next.js frontend or Laravel backend) without breaking the cross-project contract. Use when acting as the coder agent to produce a clean diff for review.
---

# Implement Feature

The coder's repeatable workflow for one scoped task. No scope creep, no self-approval.

## 1. Locate & read context

- Decide which side: `fitness-lms/` (Next.js 15 / React 19 / TS / Tailwind v4) or `fitness-lms-admin/` (Laravel 12 / PHP 8.2+ / Filament).
- Read the relevant per-project `CLAUDE.md` before editing.
- Find the existing pattern to match (search for a sibling component/controller); write code that reads like what's already there.

## 2. Implement

Respect these hard rules:

- **Cross-project contract:** if the change touches the `base64(userId|api_token)` auth format, `/api/v1/` routes, or payment/course-gating gates — update BOTH sides.
- **Main-app design system:** no default Tailwind colors, no gradients, no infinite animations (spinners ok), `rounded-sm` (2px) only. `/sales/*` and `/ai-100m` have their own palettes — don't apply main-app rules there.
- `useAuth()` returns `loading` (not `isLoading`).
- Users table: UUID PKs, `password_hash` not `password`.

If the task is ambiguous, or you'd need to touch payments/auth/course-gating in a way you're unsure about — STOP and flag it for the reviewer instead of guessing.

## 3. Self-check (not self-approve)

- Frontend: `cd fitness-lms && npx tsc --noEmit` (build fails on TS/ESLint errors).
- Re-read your own diff: does it match surrounding style? Any leftover debug code?

## 4. Hand off

Summarize for the reviewer: **what changed, which files, why, and any contract implications or assumptions.** Do not mark the work approved — that's the reviewer's call after the tester verifies. Do not deploy or push.
