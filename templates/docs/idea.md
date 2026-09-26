---
id: IDEA
version: 1
status: draft            # draft | accepted | superseded
supersedes: null
owner: ideate
approved_by: []
approved_at: null
autonomy: balanced       # supervised | balanced | autopilot
design_source: [agent]   # any of: agent | claude-design | figma | stitch
design_review: annotate  # annotate (findings never block) | block (rubric categories B may be major)
budget_usd_per_slice: 8
budget_usd_project: 150
changes_from_previous: null
---

# <Product or feature name> — Idea

## 1. Problem statement
One paragraph. No solution words. What happens today without this, and for whom.

## 2. Target users and personas
- P-001 — <persona>: <who, context, what they do today>

## 3. Jobs to be done
- J-001 — When <situation>, I want to <motivation>, so I can <outcome>.

## 4. Proposed solution
One paragraph.

## 5. Scope
**MUST**
- R-001 — …

**SHOULD**
- R-010 — …

**WON'T (this release)** — at least three
- W-001 — …

## 6. Build vs buy
| Capability | Decision | Product/service | Why |
|---|---|---|---|
| Auth | buy | Supabase Auth | … |
| Payments | buy | Stripe | … |
| Email | buy | Resend | … |

## 7. Kill criteria
What evidence would stop this project.

## 8. Success metrics (numbers)
- M-001 — <metric> ≥ <value> by <date>

## 9. Constraints
Stack: Next.js on Vercel + Supabase (Railway only if the architect justifies it). Budget,
timeline, compliance (PII, jurisdictions), existing systems.

## 10. Assumptions and open questions
See `ASSUMPTIONS.md`. Open questions:
- Q-001 — <question> (owner: <human|architect|planner>, blocks gate: G1)

## 11. Risks
- RK-001 — <risk>: likelihood, impact, mitigation

## 12. Glossary
Domain terms downstream agents must use exactly.
