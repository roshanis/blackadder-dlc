---
id: SLICES
version: 1
status: draft
built_from: { plan: <sha>, architecture: null, design: null }
---

# Slice ladder (tracer bullets)

Each row is one PR, one user-visible behavior, every layer it needs, 1–4 ACs, < ~500
non-generated lines. `INC-00` is always the walking skeleton. States:
`ready | building | verifying | review | done | stale | blocked`.

| id | title | ACs | layers | depends on | human-gate | state | tracer-bullet justification |
|---|---|---|---|---|---|---|---|
| INC-00 | Walking skeleton | AC-000a, AC-000b | ui,api,db,ci,deploy | — | no | ready | empty app live on preview + staging, CI, migration 0001, /api/health |
| INC-01 | Auth: sign up / in / out | AC-001, AC-002 | ui,api,db | INC-00 | **yes** | ready | protected route redirects; API 401 without token |
| INC-02 | Tenancy + first read with RLS | AC-003, AC-004 | ui,api,db | INC-01 | **yes** | ready | org1 user never sees org2 rows via UI or API |
| INC-03 | Create <entity> (idempotent POST) | AC-005, AC-006 | ui,api,db | INC-02 | no | ready | form → POST with Idempotency-Key → list |
| INC-04 | Update with optimistic concurrency | AC-007 | ui,api,db | INC-03 | no | ready | version column; stale write → 409; conflict UI |
| INC-05 | Soft delete + audit log | AC-008 | ui,api,db | INC-04 | **yes** | ready | deleted hidden from lists, present in audit |

## Data-intensive checks baked in
- INC-00: migrations from empty and from main in CI; RLS lint
- first tenancy slice: cross-tenant test with seeded user B
- every POST from INC-03: idempotency key
- INC-04: `version` + 409
- first async slice: outbox table + idempotent consumer, replay does not double-send
