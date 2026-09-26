---
id: PLAN
version: 1
status: draft            # draft | accepted | superseded
supersedes: null
built_from: { idea: <sha> }
owner: plan
approved_by: []
approved_at: null
changes_from_previous: null
---

# <Product or feature name> — Plan

## 1. Traceability
| Job | Stories |
|---|---|
| J-001 | ST-001, ST-002 |

## 2. User stories
- ST-001 (P-001, MUST) — As a …, I want …, so that …

## 3. Acceptance criteria (Given / When / Then; externally observable; literal expected values)
- AC-001 (ST-001) — Given …, When …, Then … (`expect(status).toBe(201)`)

## 4. Non-functional requirements
- NFR-001 — p95 API latency ≤ 200 ms on seeded 10k rows
- NFR-002 — WCAG 2.2 AA
- NFR-003 — browsers: last 2 Chrome/Safari/Firefox, iOS Safari
- NFR-004 — availability / RPO / RTO

## 5. Compliance and legal checklist
PII collected; retention; jurisdictions; processors (Vercel, Supabase, Stripe…); dependency
license allowlist (MIT/Apache-2.0/BSD/ISC); privacy + terms pages required: yes/no.

## 6. Milestones / release candidates
- RC1 = INC-00 … INC-05

## 7. Risks and mitigations
Carried from IDEA plus planning risks.

## 8. Open questions
- Q-00N — … (owner, blocking gate)

## 9. Changelog
- v1 — initial
