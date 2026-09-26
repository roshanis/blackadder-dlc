---
name: skeleton
description: Blackadder phase 3, slice INC-00. Builds the walking skeleton: monorepo scaffold, CI, Supabase migration tooling, seed files, /api/health, design tokens installed, preview deploy per PR, staging on main. Nothing else is built until this is live on a URL.
disable-model-invocation: true
---

# /skeleton — slice INC-00, the walking skeleton

Deployment is the substrate, not the last phase. Every later slice ships to a preview URL,
so the preview path must exist before any feature code.

Input: G2 approved (architecture + design system). The human has run the one-time bootstrap
(`docs/bootstrap.md` in the app; created the Vercel project, Supabase projects for staging and
prod, optional Railway project, GitHub Environments `preview`/`staging`/`production` with
secrets). If they haven't, open a gate listing exactly what is missing and stop.

## What INC-00 delivers (all are acceptance criteria)

- Monorepo (`pnpm` + turborepo): `apps/web` (Next.js App Router, `@supabase/ssr`),
  `packages/ui` (from `/design-system`), `packages/db` (Drizzle or Prisma + generated types),
  `supabase/` (config, `migrations/0001_init.sql`, `seed.sql`, `seed.dev.sql`, `tests/` pgTAP),
  `apps/worker` only if `/architect` justified Railway.
- `.github/workflows/ci.yml` from the plugin's `templates/app/.github/workflows/ci.yml` (`scripts/install.sh … --app-template`): lint, typecheck,
  unit, `supabase db reset` from empty AND from `main`, pgTAP, RLS lint, migration lint,
  gitleaks, env-contract check, Playwright against the preview URL once Vercel reports ready.
- `.env.example` as the env contract; CI fails if code reads an undeclared var.
- `/api/health` checks DB connectivity and returns the git SHA.
- One page renders the design tokens and calls `/api/health`.
- Vercel preview per PR (Git integration; no agent holds a Vercel token), Supabase preview
  branch per PR, staging deploy on merge to `main` (`staging.yml` runs migrations with the
  staging token), `promote.yml` gated by the `production` environment, `rollback.yml`.
- `tests/acceptance/INC-00/` (written first by the acceptance author): preview URL shows the
  API version string; CI applies migrations from empty; RLS lint passes.
- Branch protection on `main`; agents only open PRs.

## Procedure

Same loop as `/slice` (acceptance author → builder → CI → verifier → human), applied to
INC-00. When done, record `INC-00 done` in `slices.md` and `.blackadder/units.tsv`, and
post the preview URL as the G3 evidence. G3 is soft: it passes when the URL works and CI is
green.
