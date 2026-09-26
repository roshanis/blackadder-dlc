---
name: plan
description: Blackadder phase 1. Turns an accepted Idea doc into docs/blackadder/02-plan.md (stories, Given/When/Then acceptance criteria, NFRs) and slices.md (the ordered tracer-bullet ladder). Also runs bounded plan reconciliation after architecture.
disable-model-invocation: true
---

# /plan — stories, acceptance criteria, and the slice ladder

Input: `docs/blackadder/01-idea.md` with `status: accepted`. If it is not accepted, stop and
say so.

## Procedure

1. **Trace**: every `J-xxx` job in the idea doc maps to ≥ 1 story `ST-xxx`. Report any that
   don't; ask before inventing.
2. **Stories** `ST-001…`: As / I want / So that; priority; persona.
3. **Acceptance criteria** `AC-001…`: Given/When/Then, each observable from the outside
   (browser or HTTP), each machine-testable. Reject any AC that a test could not assert
   against a literal expected value.
4. **NFRs** `NFR-001…` with numbers: p95 latency, availability, a11y level (WCAG 2.2 AA
   default), browser matrix, data retention.
5. **Compliance & legal checklist**: PII collected, retention, jurisdictions, third-party
   processors, dependency license allowlist.
6. **The slice ladder** — `docs/blackadder/slices.md`, one row per slice `INC-NN`:
   - `INC-00` is always the walking skeleton (see `/skeleton`).
   - Each later slice: one user-visible behavior; 1–4 ACs; layers touched (ui/api/db/job);
     dependencies; a one-line tracer-bullet justification ("touches UI→API→DB for X");
     `human-gate: yes` if it touches auth, payments, PII schema, deletion, public API, or spend.
   - Bake in the data-intensive checks as ACs where they belong: migrations pipeline (INC-00),
     RLS cross-tenant test (first tenancy slice), idempotency key on every POST, version
     column + 409 on stale update, soft delete + audit, outbox + idempotent consumer for the
     first async slice.
   - No slice delivers more than ~5 ACs or more than ~500 non-generated lines. Split otherwise.
7. Write `02-plan.md` from `docs/blackadder/templates/plan.md` with front matter, and `slices.md` from
   `docs/blackadder/templates/slices.md`. Bump `version` and fill `changes_from_previous` on rewrites.
8. Open **gate G1** (plan + ladder) in `.blackadder/gates.md` and stop.

## Reconciliation mode: `/plan --reconcile`

Run after `/architect` and `/design --system` produce their "plan impacts" lists. Process ONLY
those impacts: re-sequence, split, or amend slices; produce `02-plan.md` vN+1 with a
changelog by ID. One round. If reconciliation would require changing the architecture,
open a change request (`/change-request`) instead of looping.

## Rules

- The ladder is the single most consequential artifact. Spend the effort here.
- Never let the builder self-decompose; every slice the builder works on must be a row here.
- Ask-and-exit for anything that changes scope; log everything else in `ASSUMPTIONS.md`.
