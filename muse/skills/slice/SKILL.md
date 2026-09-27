---
name: slice
description: Blackadder phase 4. Builds ONE tracer-bullet slice from slices.md end to end - acceptance tests first in a separate context, then build, CI, fresh-context verification, bounded to 3 rounds, then a PR for the human. Usage /slice INC-03.
disable-model-invocation: true
---

# /slice <INC-id> — one tracer bullet, verified

Usage: `/slice INC-03`. If no id is given, pick the first `ready` row in
`docs/blackadder/slices.md` whose dependencies are `done`.

## 0. Preconditions (stop if any fails)

- Row exists in `slices.md`, state `ready`, dependencies `done`, INC-00 `done`.
- Pin doc SHAs: `git log -1 --format=%h -- docs/blackadder/<doc>` for idea, plan,
  architecture, design-system. If any doc changed since the row was created, mark the row
  `stale`, re-read, and confirm the ACs still hold before continuing.
- Append a row to `.blackadder/units.tsv` (id, state=building, branch, pr, sha, doc SHAs).

## 1. Acceptance tests first — different context

Delegate to the **acceptance author** (subagent `blackadder-acceptance-author`; in Codex,
spawn the `blackadder-acceptance-author` custom agent; in Copilot, `--agent
blackadder-acceptance-author`). Give it ONLY: the slice row, its ACs, the relevant screen
specs and API contract sections, the preview URL pattern and seeded users. It must NOT see
any implementation. It writes `tests/acceptance/<INC-id>/*.spec.ts` (Playwright and/or HTTP)
asserting literal expected values, plus regression-lane entries, and commits them to the
slice branch `blackadder/<INC-id>` so they are red first.

## 2. Build

Branch `blackadder/<INC-id>` from `main`. Then:

1. Name the data shape first. Schema changes → new forward-only migration + RLS in this PR
   + "Architecture delta" section in the PR body.
2. `how`/`architect`-style pass: which subsystem, which boundary, what is shared mutable state.
3. Sequence into verifiable units; commit each once its check passes.
4. Unit tests are yours to write. `tests/acceptance/**` is not yours to touch — the hook and
   CI will reject it.
5. UI slices: the screen's prototype (`/proto/S-NNN`, from `/design --screen`) is the spec.
   Use only `packages/ui` components and `DESIGN.md` tokens (`scripts/design-lint.sh`
   enforces it); add the built route to `tests/acceptance/visual/visual.manifest.ts` as a
   `prototype` lane entry. Any deviation from the prototype goes under "Design delta" in the
   PR; undeclared deviations are findings.
6. Update `docs/blackadder/data-model.md` (regenerated) and `CHANGELOG.md` in the same PR.
7. Open a **draft PR** with the template: Slice / Criteria (AC list) / What changed /
   Architecture delta / Design delta / How to verify / Known gaps / Docs pinned (SHAs).

Delegate the build to the **builder** subagent when the harness supports it so the
orchestrating context stays small; resume the same builder session across rounds within
this slice, never across slices. Give the builder only the files it needs (see Token
discipline in `AGENTS.md`): the slice row, its ACs, the relevant architecture and screen
sections, `lessons.md`, and the acceptance tests — not the whole `docs/blackadder/` tree.

## Budget

`budget_usd_per_slice` in `01-idea.md` is a hard ceiling for the whole loop (acceptance
author + builder rounds + verifier + design reviewer). After each delegated run, append the
harness's reported cost to the `spent_usd` column of the slice's `units.tsv` row (Claude Code:
`total_cost_usd` from `--output-format json`; other harnesses: their usage report, or `n/a`).
If the next round would exceed the ceiling, do not start it: mark the row `blocked`, open a
gate with the spend, the remaining findings and "split this slice" as the default, and stop.

## 3. Verify (round r of 3)

Wait for CI on the PR head. If CI is red for reasons in this diff, fix and push; do not call
the verifier on a red baseline. Then delegate to the **verifier** (fresh context, read-only +
shell; a different model family from the builder when the harness allows). It follows
`/verify` and writes a ledger row; for UI slices it also delegates to the
**design reviewer**, whose findings block only when `design_review: block`. Outcomes:

- `pass` → mark row `verifying→review`, PR ready for review. Under `balanced`/`autopilot`
  with no `human-gate: yes`, request merge; under `supervised`, open a soft gate.
- `pass-with-issues` → same, plus the verifier's `minor` findings become `debt` issues.
- `fail` → round += 1. Feed the structured findings (by id) back to the builder session.
  Stop and escalate to `needs-human` when: round would exceed 3, the failing count did not
  decrease for two consecutive rounds, or the same finding id failed twice. The escalation
  names the still-failing ACs and proposes "split this slice" as the default.

## 4. Land

After merge: `slices.md` row `done`, `units.tsv` state `done` with merge SHA, append a
`docs/blackadder/lessons.md` line if the loop took > 1 round (what cost the round). Then
`/blackadder` for the next slice.

## Hard rules

- Never edit, skip, delete or weaken anything under `tests/acceptance/`.
- Never merge on CI alone. CI green is an input to a verdict.
- Never widen the slice. New scope → a new slice row or a change request.
- Stop conditions (auth, payments, PII schema, deletion, public API, spend) → `human-gate`.
