# The Blackadder DLC — design notes

`AGENTS.md` is the contract; the skills are the procedures. This page records *why*.

## Roles: three, not ten

A role earns a boundary only if it has a fresh context **and** a different rubric. So:

- **Spec** roles (ideator, planner, architect, designer) are one interactive session with
  five skills. They write documents; nothing else.
- **Acceptance author** — fresh context, never sees the implementation, writes
  `tests/acceptance/<slice>/` before the build. This is the structural guarantee that the
  builder is not grading its own homework.
- **Builder** — one slice, one branch, one PR; resumed across rounds within a slice, never
  across slices.
- **Verifier** — fresh context, read-only on app code, ideally a different model family;
  records a verdict keyed by PR + SHA.

Security review, code review, release engineering and product ownership are checklists,
CI jobs and one-off fresh-context passes, not standing agents. The product owner is the human.

## Gates

Hard (pipeline blocks): **G0** idea, **G1** plan + slice ladder, **G2** architecture +
design system (approved by looking at `/design-system`), **G6** production. Everything else
is soft and follows the autonomy dial (`supervised | balanced | autopilot`). Stop conditions
(auth, payments, PII schema, deletion, public API, spend, production) always escalate.

Every question an agent asks carries a proposed default so `go` is a valid answer, and is
recorded in `.blackadder/gates.md` — the human's single inbox.

## The build loop

```
slice row (ready) ──► acceptance author writes red tests ──► builder makes them green
      ▲                                                            │
      │                                                            ▼
   next slice ◄── human merges ◄── verifier: pass ◄── CI green ◄── draft PR
                                       │ fail (round+1, ≤3; failing count must drop; same finding twice = stop)
                                       ▼
                                  needs-human: diff + failing ACs + "split this slice"
```

"Done is never a sentence from a model": CI green + acceptance pass + verifier `pass` for
the exact head SHA + human merge.

## State

Machine state is **single-writer files** in the repo, not issue labels (labels have no
compare-and-swap and webhooks are at-least-once):

| file | content |
|---|---|
| `docs/blackadder/*.md` | the documents, with front matter (`id`, `version`, `status`, `built_from` SHAs) and stable IDs |
| `docs/blackadder/slices.md` | the ladder; row state `ready/building/verifying/review/done/stale/blocked` |
| `.blackadder/units.tsv` | per-slice: branch, PR, head SHA, merge SHA, round, doc SHAs |
| `.blackadder/ledger.tsv` | verdicts keyed by SHA; a new SHA voids the row |
| `.blackadder/decisions.tsv` | judgment calls with reasons |
| `.blackadder/gates.md` | open/closed human gates and questions |
| `docs/blackadder/ASSUMPTIONS.md` | every default an agent chose instead of asking |
| `docs/blackadder/lessons.md` | what cost a round; read by the builder each slice |

GitHub Issues/PRs are the **human-facing mirror and command surface** (`/slice`, `/verify`
comments via gh-aw), never the source of truth.

The ledger layout was informed by pstack's `units.tsv / ledger.tsv / frontier.json /
decisions.tsv` design; pstack itself is not a dependency (see "Deliberately not installed").

## Feedback: an address and a ladder

Findings cite IDs (`AC-014 in PLAN v2`), never "the plan". Change requests carry an impact
level: **L1** code (builder, no human) · **L2** spec gap (planner, soft gate) · **L3**
architecture/design (ADR + hard gate) · **L4** idea (human conversation). Downstream items
whose upstream IDs changed are marked `stale`; nothing else is rebuilt. Max two L3/L4
revisions per release cycle before a human must intervene.

## Deployment is the substrate

Slice 0 is a walking skeleton live on a preview URL before any feature code: CI, one
migration, `/api/health`, tokens, preview per PR, staging on `main`, human-gated promote.
Agents never hold production secrets and never deploy; they open PRs, add labels and dispatch
workflows. Next.js route handlers + Supabase by default; Railway only when the architect
justifies it (workers, long-running, non-Node, WebSockets beyond Realtime).

## Cross-harness mechanics

| | Claude Code | Cursor | Codex | Copilot |
|---|---|---|---|---|
| instructions | `CLAUDE.md` → `@AGENTS.md` | `AGENTS.md` + `.cursor/rules/*.mdc` | `AGENTS.md` | `AGENTS.md` + `.github/copilot-instructions.md` |
| skills | `.claude/skills` / plugin `skills/` | `.cursor/skills` | `.agents/skills` | `.github/skills`, `.agents/skills` |
| subagents | `agents/*.md` | `.cursor/agents/*.md` | `.codex/agents/*.toml` (explicit delegation) | `.github/agents/*.agent.md` |
| hooks | `hooks/hooks.json` `PreToolUse` (exit 2 blocks) | `.cursor/hooks.json` (`beforeShellExecution` deny; `afterFileEdit` revert) | `.codex/hooks.json` `PreToolUse` | `.github/hooks/*.json` `preToolUse` |
| plugin | `.claude-plugin/plugin.json` + `marketplace.json` | `.cursor-plugin/plugin.json` | Agent Plugins 1.0 `plugin.json` + `.agents/plugins/marketplace.json` | Agent Plugins 1.0 + `com.github.copilot/` |
| headless | `claude -p … --output-format json` | `agent -p … --force` | `codex exec --sandbox workspace-write --json` | `copilot -p … --agent …` |
| GitHub | `claude-code-action` / gh-aw `engine: claude` | Cursor CLI in Actions / Cloud Agents | `codex-action` / gh-aw `engine: codex` | cloud agent / gh-aw `engine: copilot` |

One guard script (`hooks/scripts/guard.sh`) serves all four; it normalises the payload
shapes and emits the harness's expected decision format.

## Evaluate the pipeline itself

Keep 2–3 small reference apps. After any change to a skill, template or hook, run them
through in `autopilot` with a fixed budget and compare: rounds per slice, human
interruptions per slice, cost per slice, escaped defects at release verify. A regression in
these numbers is a failing test for this repo. Every app records the pipeline version it was
built with (`.blackadder/pipeline.lock`).

## Design

Agents cannot see, taste is not in the docs, and design decisions drift per screen. So the
design track produces only code and images, decided once, enforced by lint and diff:

1. **Direction** — three rendered HTML boards; the human picks (arena for taste).
2. **System** — `DESIGN.md` (open design.md format: YAML tokens + prose, eight ordered
   sections, linted for WCAG contrast and structure). Tokens are exported from it into
   `packages/ui/tailwind.tokens.css`; CI fails if that file is hand-edited. Components from
   shadcn/Radix restyled from tokens only; the `/design-system` route is the pixel-exact oracle.
3. **Screens** — `/proto/S-NNN` static prototypes built from `packages/ui`; their screenshots
   are the baseline a UI slice must match within a per-screen threshold.
4. **Enforcement** — `scripts/design-lint.sh` (no raw values, imports only from `packages/ui`),
   the Playwright visual harness (breakpoints × themes + axe + overflow), and the design
   reviewer's rubric (hierarchy, rhythm, tokens, states, responsive, copy, fidelity, a11y).
5. **Dials** — `design_source` (claude-design | figma | stitch | agent) and `design_review`
   (`annotate` → findings never block; `block` → categories B may be `major`). Start with
   `annotate`; switch after ~5 UI slices if fewer than 1 in 5 findings were noise.

Human touchpoints for design: pick a direction, approve the reference route, approve the
first screen prototypes. Then only diffs.

## Token use

Cost is a first-class constraint: each role has a context contract (read the slice, not the
tree); build/verify/design-review run in subagents so the orchestrator stays small; budgets
are hard ceilings recorded in `units.tsv`; deterministic checks run before any agent is
called; loops and turns are bounded; the design reviewer samples images; and the stable
prefixes (`AGENTS.md`, `DESIGN.md`, skills) are kept timestamp-free so prompt caching hits.
Treat cost per completed slice as a pipeline metric alongside rounds per slice and escaped
defects.

## Deliberately not installed

Rule: if a skill pack overlaps a Blackadder phase, we do not need it. Two flavors of "plan" or
"critique" in front of the router cause drift, and every installed skill costs its description
in every session.

| Considered | Decision | Why |
|---|---|---|
| mattpocock/skills (53) | not installed | `grill-*` ≈ `/ideate`, `to-spec`/`to-tickets` ≈ `/plan`, `implement`/`tdd` ≈ builder, `code-review` ≈ verifier, `domain-modeling` ≈ `/architect`; its tickets also make the issue tracker the source of truth, which we rejected |
| Impeccable skill set (24) | not installed | `shape`/`critique`/`audit`/`polish`/`document`/`extract` ≈ the `/design` track and the design reviewer |
| pstack (Cursor) / pstack-claude port | not installed | `feature` and verification playbooks ≈ `/slice` + `/verify`; `orchestrate` ≈ `.blackadder/` ledgers |
| Impeccable **detector** | **used** | `npx impeccable detect` — 61 deterministic anti-slop rules, zero LLM calls, no skills installed; runs in CI and before the design reviewer (`scripts/design-detect.sh`) |

Credit where due: pstack's ledger design informed `.blackadder/`, and Impeccable's rules
informed the anti-slop checks. Neither is installed.
