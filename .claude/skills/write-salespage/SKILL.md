---
name: write-salespage
description: Write or rewrite the long-form Thai copy for an Antiparallel sales funnel (the /ai-100m, /claude-team style open-letter pages). Use when acting as the copywriter agent to produce conversion-grade, section-by-section copy that drops into the existing SalesLetterClient + sales-page.css structure.
---

# Write a Long-Form Sales Page

The copywriter's repeatable workflow for an open-letter funnel. You write the words; the coder wires JSX; the reviewer gates.

## 1. Get the inputs straight first

Before writing a word, pin down (ask the user or read existing funnel files if unsure):
- **Who is the one reader?** (role, pain, what keeps them up at night)
- **What is the one product + the one promise?** Real price, real course facts.
- **What's the mechanism?** The specific "how" that makes the promise believable.
- **Proof available?** Real numbers/testimonials → use them. None yet → mark `[ ใส่ผลลัพธ์จริงที่นี่ ]`, never fabricate.
- **Reference:** read `fitness-lms/src/app/ai-100m/SalesLetterClient.tsx` and `.../claude-team/SalesLetterClient.tsx` for the proven structure + voice.

## 2. Write section by section (proven order)

Letterhead + eyebrow → Headline → Subheadline → VSL framing → **Story** (the engine) → Pullquote → Hard truth → Bullets (fascinations) → Bonus stack → Sign-off + deadline → Guarantee → FAQ → P.S./P.P.S.

Each section: deliver the final Thai copy, labeled, ready to paste.

## 3. Copy craft checklist

- One reader, one promise; lead emotion, justify with logic.
- Specificity over adjectives — real numbers, real scenes.
- Bullets are fascinations (benefit + curiosity + open loop), not features.
- Bonus values stack to dwarf the price; guarantee reverses all risk.
- Native Thai rhythm — punchy + conversational founder voice (ครับ/นะครับ where it fits), no AI cadence, no stiff academic Thai.
- P.S. carries scarcity + final re-hook (it's the 2nd most-read block).

## 4. Stay inside the structure the CSS can render

Reuse the section/class hooks `sales-page.css` already styles (letterhead, hard-truth, pullquote, bonus-card, bump, summary, seal, faq, ps). If a genuinely new section earns its place, flag it for the coder rather than assuming the CSS supports it.

## 5. Hand off

End with a note to the **coder**: which sections are new vs. changed, and every `[ placeholder ]` fact/number the user must fill before publish. Do not write JSX unless asked. Do not invent facts, testimonials, or results.
