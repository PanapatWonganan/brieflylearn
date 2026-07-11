---
name: review-and-log
description: Review a change against the Antiparallel cross-project contract and project conventions, then record the verdict to docs/work-log.md and (for durable findings) memory. Use when acting as the reviewer agent to gate work from the coder/tester and keep the audit trail.
---

# Review & Log

The reviewer's repeatable workflow: judge a change, then record it. Run this after the coder implements and the tester verifies.

## 1. Gather the change

```bash
git -C fitness-lms diff           # frontend changes
git -C fitness-lms-admin diff     # backend changes
git -C fitness-lms status; git -C fitness-lms-admin status
```

Read the coder's summary and the tester's report. If the tester reported FAIL, the verdict is CHANGES REQUESTED — skip to step 4.

## 2. Check against the contract & conventions

Walk this checklist (cite `file:line` for any finding):

- **Cross-project contract** (root `CLAUDE.md`): auth `base64(userId|api_token)` format, `/api/v1/` route versioning, payment/course-gating gates (`user_has_paid_access` + `locked` + `can_watch`). Did a one-sided change break the other side?
- **Per-project conventions:** `fitness-lms/CLAUDE.md`, `fitness-lms-admin/CLAUDE.md`.
- **Design system:** no default Tailwind colors / gradients / infinite animations, `rounded-sm` only (main app); `/sales/*` and `/ai-100m` exempt.
- **Production Gotchas list:** did the change reintroduce a known footgun (stale `.next/`, config cache, `.env.production` hijack, seeder assumptions, auth-state naming)?

## 3. Decide the verdict

- **APPROVED** — meets contract + conventions, tester confirmed.
- **CHANGES REQUESTED** — list each issue `file:line — problem — required fix`, ordered by severity; hand back to coder.
- **BLOCKED** — needs a user decision; state the question.

## 4. Record (always do both)

**Work log** — append to `docs/work-log.md` (create if missing):

```markdown
## <ISO date> — <short title>
- **Scope:** <files / area>
- **Coder:** <what was implemented>
- **Tester:** <what was verified + results>
- **Verdict:** APPROVED | CHANGES REQUESTED | BLOCKED
- **Notes:** <follow-ups / risks / deferred items>
```

**Memory** — if the review surfaced something durable (a project decision, a recurring coder mistake, a new gotcha), write one fact file to `/Users/panapat/.claude/projects/-Users-panapat-Brieflylearn-brieflylearn/memory/` and add a pointer line to `MEMORY.md`. Don't duplicate what `CLAUDE.md` or git already records.
