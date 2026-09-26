---
id: ARCH
version: 1
status: draft
supersedes: null
built_from: { idea: <sha>, plan: <sha> }
owner: architect
approved_by: []
approved_at: null
changes_from_previous: null
---

# <Product> — Architecture

## 1. Context and constraints
From PLAN; NFR references.

## 2. Runtime split (ADR-0001)
Next.js route handlers / server actions by default; Supabase Edge Functions for …; Railway
for … (or: not used). Connection pooling: Supavisor transaction mode (6543).

## 3. System context and trust boundaries
Vercel web ⇄ Supabase (Postgres/Auth/Storage/Realtime) ⇄ third parties. Boundaries listed.

## 4. Domain model (intent; source of truth is `supabase/migrations/`)
- E-001 `organizations` — fields, invariants
- E-002 `org_members` — …
Generated view: `docs/blackadder/data-model.md`.

## 5. Access control
Auth model; tenancy model; RLS policy per table per operation; public-read tables; operations
that need the service role (server-side only); storage buckets + policies; exposed schemas;
realtime authorization.

## 6. API contract
- API-001 `POST /api/<entity>` — request/response zod, errors, idempotency
Every AC maps to an API or screen path. Unmapped: <list or none>.

## 7. Data flows (top 5 journeys, with failure paths)

## 8. Consistency, concurrency and scaling
Idempotency keys; optimistic concurrency; what is eventually consistent; outbox; caching.

## 9. Threat model and data classification
STRIDE-lite per boundary; PII map; secrets inventory (which live only in GitHub Environments).

## 10. Observability
Structured logs + request ids; error tracking with release tags; `/api/health`; uptime;
key metrics and alerts.

## 11. Environments and deployment
preview (PR) / staging (`main`) / production (promote workflow, required reviewers);
migration strategy (forward-only, expand/contract); rollback contract; feature flags.

## 12. Testing strategy
Which layer verifies each AC; seed/test-data strategy; pgTAP for policies.

## 13. ADR index
- ADR-0001 — runtime split

## 14. Plan impacts (consumed by `/plan --reconcile`)
- …

## 15. Changelog
- v1 — initial
