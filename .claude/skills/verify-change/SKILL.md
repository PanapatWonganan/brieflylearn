---
name: verify-change
description: Verify a code change in the Antiparallel monorepo actually works — type-check, lint, run PHPUnit, and confirm runtime behavior — then report PASS/FAIL with evidence. Use when acting as the tester agent after the coder makes a change.
---

# Verify Change

The tester's repeatable workflow. Confirm the change works; report evidence to the reviewer. Don't edit feature code.

## 1. Static checks (frontend)

```bash
cd fitness-lms && npx tsc --noEmit     # type errors fail the prod build
cd fitness-lms && npm run lint         # ESLint 9
```

## 2. Backend tests

```bash
cd fitness-lms-admin && php artisan test    # PHPUnit, SQLite :memory:
```

Write a focused test for new backend behavior if none covers it. If the test needs data, remember `db:seed` only makes 2 users — run `CourseSeeder` / `WellnessGardenSeeder` individually as needed.

## 3. Behavior verification (when it's a runtime flow)

If the change affects auth, payments, course gating, or garden rewards, confirm actual behavior — not just that it compiles. Use the `verify` or `run` skill, or hit the API directly. Verify both sides agree if the change touches the cross-project contract.

## 4. Report to the reviewer

For each check report:
- **Command run** + actual output (paste failures verbatim — don't paraphrase).
- **PASS / FAIL.**
- For failures: exact error + the `file:line` it points to, so the coder can fix precisely.

Watch for known gotchas that fake a failure: stale `.next/` ("Internal Server Error"), config cache needing a PHP-FPM restart after `.env` changes, the flaky public `/courses` API.
