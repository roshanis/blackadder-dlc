# Blackadder DLC — agent instructions

You are working inside a project that runs the **Blackadder Development Life Cycle (DLC)**:
an idea-to-production pipeline where AI agents build software in small, verified,
tracer-bullet slices with a human at a few well-lit gates.

This file is read by Claude Code, Cursor, Codex and GitHub Copilot. Keep it harness-neutral.

## The pipeline in one screen

```
ideate → plan (+ slice ladder) → architect ∥ design-system → skeleton (slice 0)
      → [ slice → verify ] × N → release → deploy → change-request loop
```

| Phase | Skill | Output | Gate |
|---|---|---|---|
| Ideate | `/ideate` | `docs/blackadder/01-idea.md` | **G0 hard** — human approves the Idea doc |
| Plan | `/plan` | `02-plan.md` + `slices.md` | **G1 hard** — human approves plan + slice ladder |
| Architect | `/architect` | `03-architecture.md` + `supabase/migrations/0001_*.sql` | **G2 hard** (with design) |
| Design | `/design` | direction boards → `DESIGN.md` + generated tokens + `packages/ui` + `/design-system` route → `/proto/S-NNN` prototypes | **G2 hard** — approved by *looking at it*; first screens soft |
| Skeleton | `/skeleton` | slice 0 live on a preview URL, CI green | G3 — preview URL works |
| Slice | `/slice <id>` | one PR per slice, acceptance tests pass, verifier approves | soft per slice (autonomy dial) |
| Verify | `/verify` | verdict in `.blackadder/ledger.tsv` keyed by PR + SHA | — |
| Release | `/release` | release verify on staging, security checklist, promote PR | **G6 hard** — production deploy |
| Change request | `/change-request` | `docs/blackadder/cr/CR-NNNN.md`, routed L1–L4 | L3/L4 hard |

Run `/blackadder` to find out which phase the project is in and what to do next.

## Non-negotiable rules

1. **Done is never a sentence from a model.** A slice is done only when: CI is green, the
   acceptance tests in `tests/acceptance/<slice-id>/` pass, a fresh-context verifier recorded
   a verdict of `pass` in `.blackadder/ledger.tsv` for the exact head SHA, and a human merged.
2. **Acceptance tests are written before the builder starts, by a different context**, from the
   slice's Given/When/Then criteria. The builder may not create, edit, delete, skip or weaken
   anything under `tests/acceptance/`. Hooks and CI enforce this.
3. **Tracer bullets, not layers.** Every slice is one user-visible behavior that touches every
   layer it needs (UI → API → DB → back), ships on its own preview URL, and fits one PR
   (aim for < 500 non-generated lines).
4. **Slice 0 is the walking skeleton.** No feature code before an empty app is deployed to a
   preview URL with CI, one migration, `/api/health`, and the design tokens installed.
5. **Loop bounds.** Max 3 build/verify rounds per slice. If the failing count does not drop for
   two consecutive rounds, or the same finding fails twice, stop and escalate to a human with
   the diff, the failing checks, and "split this slice" as the default remedy.
6. **The data model is a migration file.** Schema changes ship as forward-only files in
   `supabase/migrations/` in the same PR as the code. Every table has RLS enabled and policies.
   Renames use expand/contract. CI resets from empty and from `main`.
7. **Agents never hold production secrets and never deploy.** Deploys happen from Git
   integration and GitHub Environments with required reviewers. Your power is: open PR, add
   label, dispatch workflow. Never force-push, never run prod migrations, never delete tests.
8. **Ask-and-exit.** When you need a human decision: post ONE question with a proposed default
   so that `go` is a valid answer, record it in `.blackadder/gates.md`, then stop. Never block
   waiting. Proceed on reversible work with a logged default in `docs/blackadder/ASSUMPTIONS.md`.
9. **Every doc has front matter and stable IDs** (`R-001`, `AC-014`, `E-003`, `S-002`, `INC-05`,
   `ADR-0002`, `CR-0001`). Findings and change requests cite IDs, never "the plan".
10. **Record what you built against.** Every slice PR body and every ledger row carries the
    commit SHAs of the docs it was built from. A doc change marks downstream slices `stale`.
11. **Design is code plus a visual oracle.** `DESIGN.md` (open design.md format) is the
    system; tokens are generated from it, never hand-written; app code uses only those tokens
    and `packages/ui`. The screen's `/proto/S-NNN` prototype is the spec a UI slice is
    diffed against; every deviation is declared under "Design delta". The design reviewer's
    findings block only when `design_review: block`.

## Where things live in an app repo

```
docs/blackadder/            01-idea.md 02-plan.md 03-architecture.md 04-design-system.md
                            slices.md ASSUMPTIONS.md lessons.md adr/ cr/
.blackadder/                units.tsv ledger.tsv decisions.tsv gates.md  (machine state, single writer)
tests/acceptance/<slice>/   written before build; builder may not touch
tests/acceptance/visual/    screenshot × breakpoint × theme + axe lanes; baselines change only in /design PRs
DESIGN.md                   the design system (linted); packages/ui/tailwind.tokens.css is generated from it
apps/web/app/proto/S-NNN/   static screen prototypes = the spec for UI slices
supabase/migrations/        forward-only; RLS in the same migration
supabase/seed.sql           prod-safe reference data
supabase/seed.dev.sql       fake users/tenants for local + preview only
.github/workflows/ci.yml    lint, typecheck, unit, db reset + pgTAP, RLS lint, migration lint, gitleaks, e2e vs preview
```

## Token discipline

Every run is paid for by the person using this pipeline. Spend tokens on judgment, not on
re-reading.

- **Read the slice, not the tree.** Each role has a context contract: the dispatcher reads
  front matter and state files only; the builder reads its slice row, ACs, the relevant
  `03-architecture.md` and screen sections, `lessons.md` and its acceptance tests; the
  verifier reads the diff, the ACs and the pinned doc sections; the design reviewer reads
  `DESIGN.md`, the screen spec and images. Nobody reads `docs/blackadder/` wholesale.
- **Delegate to keep the orchestrator small.** Build, verify and design review run in
  subagents; the orchestrating context only routes and records. Resume a builder within a
  slice; never carry a session across slices.
- **Images are expensive.** The design reviewer looks at diff images first and opens full
  screenshots only for lanes with a non-zero diff, a failed axe/overflow check, or one
  reference pair per screen (1440 light, 390 dark). Never all six per screen by default.
- **Budgets are hard.** `budget_usd_per_slice` and `budget_usd_project` in `01-idea.md`;
  spend is recorded per run in `.blackadder/units.tsv` (`spent_usd`). A round that would
  exceed the ceiling does not start; the slice goes to `blocked` with a gate.
- **Bounded loops, bounded turns.** Max 3 verify rounds; agents carry `maxTurns`/`max-turns`;
  a stalled loop escalates instead of retrying.
- **Deterministic before generative.** Lint, typecheck, `design.md lint`, `design-lint.sh`,
  `design-detect.sh` (Impeccable's 61-rule anti-slop detector), RLS lint, migration lint and
  the visual harness run in CI at zero tokens; agents are called only on their results, never
  to re-derive them.
- **No overlapping skill packs.** Do not install skill sets whose phases duplicate Blackadder's
  (mattpocock/skills, the Impeccable skill set, and the like): two "plan" or "critique" flavors
  confuse routing and every installed skill costs its description in every session. Take
  deterministic tools from them (`npx impeccable detect`), never competing phase skills.
- **Stable prefixes cache.** Keep `AGENTS.md`, `DESIGN.md` and skill bodies stable and
  timestamp-free so prompt caching keeps hitting; put volatile state in `.blackadder/`.
- **Phase skills load on demand.** They are `disable-model-invocation: true`; only
  `/blackadder` and `/verify` are auto-discoverable, so idle sessions carry little pipeline
  context.

## Working style

- Read the current phase's doc(s) and `slices.md` before acting. Do not re-derive decisions
  already recorded in `docs/blackadder/` or `adr/`.
- Prefer subtraction: the smallest change the evidence justifies.
- Name the data shape before writing code. Model the domain, then the boundary, then the UI.
- Verify against the real surface (preview URL, real DB) rather than a proxy. CI green is an
  input to a verdict, not a verdict.
- When pstack (`/poteto-mode`) is installed, route `/slice` builds through its `feature`
  playbook and verification through its verification lanes. Blackadder skills still own the
  phases, gates and state files.
- Design sources (`design_source` in the idea doc): Claude Design syncs via `/design-sync`
  in Claude Code; Figma via the Dev Mode MCP server + Code Connect; Stitch via `DESIGN.md`
  import/export and its MCP server. Whatever the source, `DESIGN.md` in the repo is the
  truth CI lints.
- Write for the reader: short PR bodies with Slice / Criteria / What changed / How to verify /
  Known gaps. No phase-narrating comments in code.
