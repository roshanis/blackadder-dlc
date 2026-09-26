---
name: architect
description: Blackadder phase 2a. Produces docs/blackadder/03-architecture.md plus the initial Supabase migration, RLS policies, seed files and ADRs from the accepted plan. Also --onboard for brownfield repos. Runs in parallel with /design-system.
disable-model-invocation: true
---

# /architect — architecture as migrations, policies and ADRs

Input: `02-plan.md` (`status: accepted`) and `01-idea.md`. Output is reviewable code plus a
document, never a diagram alone.

## Procedure

1. **Runtime split decision** (write an ADR): Next.js route handlers / server actions by
   default; Supabase Edge Functions for webhooks and DB-adjacent service-role work; Railway
   ONLY when justified by long-running/CPU-bound work, WebSockets not covered by Realtime,
   background workers/queues beyond pg_cron, or non-Node runtimes. If Railway is used it
   hosts workers, not the primary REST API.
2. **Domain model** `E-001…`: entities, fields, invariants. Then write it as
   `supabase/migrations/0001_init.sql`: tables, indexes, `enable row level security` on every
   table, policies per table per operation using `auth.uid()` / `auth.jwt()` helpers, and a
   comment naming the `E-` id. `seed.sql` (prod-safe reference data) and `seed.dev.sql`
   (two tenants, three roles, fixed test users) alongside.
3. **Access control**: auth model (`@supabase/ssr` cookie sessions default), tenancy model
   (`org_members` pattern), which tables are public-read, which operations require the
   service role and must therefore live server-side, storage buckets and their policies,
   exposed schemas, realtime channel authorization.
4. **API contract** `API-001…`: endpoints/RPCs with zod schemas, error format, versioning.
   Every `AC-` maps to an API or screen path; list the unmapped ones.
5. **Data flows** for the top 5 journeys including failure paths; idempotency keys on writes;
   optimistic concurrency (`version` column → 409); what is eventually consistent; outbox for
   async work. Connection pooling: Supavisor transaction mode (port 6543) for anything
   serverless.
6. **Threat model & data classification**: STRIDE-lite per trust boundary; PII map; secrets
   inventory; which secrets exist only in GitHub Environments.
7. **Observability**: structured logs with request IDs, error tracking with release tags,
   `/api/health` that checks DB connectivity, uptime check, key metrics.
8. **Environments & deployment**: preview per PR (Vercel preview + Supabase branch), staging
   on `main`, production by promote workflow with required reviewers; migration strategy
   (forward-only, expand/contract); rollback contract; feature flags table.
9. **Testing strategy**: which layer verifies each AC; test data strategy; pgTAP for policies.
10. **Plan impacts**: list what the plan assumed that this architecture changes (sequencing,
    feasibility, new slices). `/plan --reconcile` consumes this.
11. Write `03-architecture.md` from `docs/blackadder/templates/architecture.md`, ADRs under
    `docs/blackadder/adr/ADR-NNNN-*.md`, and the migration/seed files. Open **gate G2**
    (jointly with `/design-system`) and stop.

## `/architect --onboard` (brownfield)

Reverse-engineer `03-architecture.md` from the code: data model from `supabase/migrations`,
routes from the router, screens from `app/`. Mark every statement `observed` or `inferred`.
Generate `docs/blackadder/data-model.md` from migrations. A human corrects it; then continue.

## Standing duty

Every slice that touches the schema requires an "Architecture delta" section in its PR
(migration file, tables changed, RLS diff, backfill plan). `/verify` checks it against this
document. Regenerate `data-model.md` from migrations whenever they change so the doc cannot lie.
