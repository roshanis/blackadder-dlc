---
name: release
description: Blackadder phase 5. Release verification on staging (cross-slice journeys, NFRs, security checklist, a11y/UX pass), release notes with migration risk class, and the human-gated promote to production. Usage /release, then /release --promote.
disable-model-invocation: true
---

# /release — release candidate to production

Input: all slices in the milestone `done`, staging deployed from `main`.

## `/release` (release verify)

Run in a fresh context, against **staging**, not a preview:

1. Full `tests/acceptance/` suite + cross-slice user journeys (the top 5 from
   `03-architecture.md` data flows) end to end.
2. NFRs from `02-plan.md` with numbers: p95 on seeded volume, availability probe, browser
   matrix smoke.
2b. UX walkthrough: `blackadder-design-reviewer` runs the visual harness for every screen in
   the `S-` inventory on staging and walks the top 5 journeys, applying the design review
   rubric end to end (hierarchy across screens, consistent states, copy tone, keyboard-only
   completion of each journey). Findings follow the `design_review` dial; anything that
   fails an AC or WCAG AA is a blocker regardless.
3. Security checklist: RLS diff vs `03-architecture.md` (every table, every op); no secrets in
   repo (gitleaks); `npm audit` high = block; auth on every route (probe unauthenticated);
   dependency licenses in allowlist; privacy/terms pages exist if the plan's compliance
   checklist requires them.
4. Migration risk class for the release: `none | additive | destructive | config`.
   `destructive` requires the expand/contract evidence and a second human approval.
5. Findings that cannot be fixed inside an existing slice become change requests
   (`/change-request`) with an impact level; the release waits on L1/L2 fixes and on the
   human's accept/defer decision for L3/L4.
6. Write `docs/blackadder/releases/vX.Y.Z.md`: changelog by slice, migration summary and
   risk class, rollback command, known/deferred CRs. Ledger row `release vX.Y.Z pass|fail`.

## `/release --promote` (hard gate G6)

Never run a deploy command. Open the gate:

```
## G6 — Promote vX.Y.Z to production
What changes: <slices>. Migrations: <files> (risk: additive). Rollback: workflow rollback.yml → <previous deployment ids>.
Default if you reply `go`: dispatch promote.yml (GitHub Environment `production`, required reviewers apply).
Reply `go` or `hold`.
```

On `go`: dispatch `promote.yml` (tag `vX.Y.Z`), wait for the smoke test in the workflow,
post the result, and record `promoted` in `units.tsv`. On failure: dispatch `rollback.yml`,
open a CR at the right level, escalate.

## After production

Production errors (Sentry or equivalent) arrive as issues labelled `source:production`; route
them through `/change-request` like any other finding.
