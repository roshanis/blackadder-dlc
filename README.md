# Blackadder DLC

An idea-to-production development life cycle for AI coding agents — **the same pipeline on
Claude Code, Cursor, Codex, GitHub Copilot, Muse Code and OpenClaw**, one folder per tool.

```
ideate → plan (+ slice ladder) → architect ∥ design-system → skeleton (slice 0)
      → [ slice → verify ] × N → release → deploy → change-request loop
```

Small verified tracer-bullet slices; acceptance tests written *before* the build by a
different context; a fresh-context verifier with a SHA-keyed verdict; bounded loops; four
human gates; agents that never hold production secrets. The contract is
[`AGENTS.md`](AGENTS.md); the rationale is [`docs/pipeline.md`](docs/pipeline.md).

## Install

| Tool | Plugin (recommended) | Project-local |
|---|---|---|
| **Claude Code** | `/plugin marketplace add roshanis/blackadder-dlc` → `/plugin install blackadder@blackadder-dlc` | `scripts/install.sh claude <app-repo>` |
| **Cursor** | Customize → Plugins → add marketplace/plugin from GitHub `roshanis/blackadder-dlc` | `scripts/install.sh cursor <app-repo>` |
| **Codex** | `codex plugin marketplace add roshanis/blackadder-dlc` → `codex plugin add blackadder@blackadder-dlc` | `scripts/install.sh codex <app-repo>` |
| **Copilot** | `copilot plugin marketplace add roshanis/blackadder-dlc` → `copilot plugin install blackadder@blackadder-dlc` | `scripts/install.sh copilot <app-repo>` |
| **Muse Code** | `muse plugins marketplace add blackadder-dlc https://github.com/roshanis/blackadder-dlc.git` → `muse plugins install blackadder@blackadder-dlc` (needs `MUSE_EXPERIMENTAL_PLUGINS=1`) | `scripts/install.sh muse <app-repo>` |
| **OpenClaw** | `openclaw plugins install blackadder --marketplace git:github.com/roshanis/blackadder-dlc` (skills) or `openclaw plugins install ./openclaw` (skills + guard) | `scripts/install.sh openclaw <app-repo>` |

Type plugin commands **one per prompt** and press Enter between them (pasting both on one
line makes the harness read the second command as part of the marketplace name). Skills
are discovered at session start, so **restart the harness after installing**.

Each tool's `README.md` has the full walkthrough (project prep, subagents, hooks, headless
and GitHub automation). Everything at once, with the app template and the gh-aw workflow:

```
git clone https://github.com/roshanis/blackadder-dlc
blackadder-dlc/scripts/install.sh all <app-repo> --app-template --workflows gh-aw
```

## How to use

### 1. Set up each app repo (once per project)

```bash
mkdir my-app && cd my-app && git init
git clone https://github.com/roshanis/blackadder-dlc /tmp/blackadder-dlc
/tmp/blackadder-dlc/scripts/install.sh claude . --app-template --workflows gh-aw   # or cursor | codex | copilot | muse | openclaw | all
git add -A
git add -f .claude        # only if a global gitignore hides .claude/ (or add `!.claude/` to .gitignore)
git commit -m "Install Blackadder DLC kit"
```

The installer drops in `AGENTS.md` (the contract every harness reads), the doc templates, the
`.blackadder/` state files, `docs/bootstrap.md` (the manual infra checklist), the app CI
(RLS, migration and design lint, the visual harness), promote/rollback workflows and, with
`--workflows gh-aw`, the GitHub slash-command workflow. It never overwrites a file you already
own; re-run it after updating the kit to refresh the files it owns.

If you installed the plugin, the project-local skills and agents are harmless duplicates;
delete `.claude/skills` and `.claude/agents` (or the equivalent) if you want only the plugin.

### 2. Drive it with `/blackadder`

Open the repo in your harness and type **`/blackadder`**. It reads the state files and tells
you the phase, the spend so far and the next command. You never need to remember the order:

```
/blackadder  →  "run /ideate"  →  you run it  →  it stops at a gate  →  you answer  →  /blackadder …
```

**The gate protocol is the whole interaction model.** When an agent needs a decision it
writes one question with a proposed default into `.blackadder/gates.md` and stops. You reply
in the next message:

- `go` accepts the default
- `go --with-notes: …` accepts, with notes injected into the next phase
- `redo: …` re-runs the phase with your reasons

Anything reversible it proceeds on and logs in `docs/blackadder/ASSUMPTIONS.md`.

### 3. What you do, phase by phase

| Command | You… |
|---|---|
| `/ideate` | have a conversation (one question at a time); set the dials when asked; approve `01-idea.md` (gate G0) |
| `/plan` | read `slices.md` carefully: the slice ladder is the artifact that matters most (gate G1) |
| `/architect` + `/design --directions` | glance at the architecture doc and migration 0001; **open the three HTML boards and pick one** |
| `/design --system` | open the `/design-system` route and approve by looking (gate G2) |
| `/skeleton` | first do `docs/bootstrap.md` by hand (Vercel, Supabase, GitHub Environments); then confirm the preview URL works (gate G3) |
| `/design --screen S-001` | approve the first two or three screen prototypes; after that only the diffs |
| `/slice INC-NN` | nothing until a draft PR appears with a verifier verdict; then read the PR and merge |
| `/verify` | run it yourself in a fresh session if you want a second opinion; it never edits app code |
| `/release` → `/release --promote` | read the release note; reply `go` to deploy to production (gate G6) |
| `/change-request <finding>` | any bug, review note or new idea after the plan is accepted goes here, not into a slice |

### 4. The four dials

Front matter of `docs/blackadder/01-idea.md`; set during `/ideate`, change any time:

```yaml
autonomy: balanced          # supervised = you merge every slice · balanced = auto-merge on verifier pass · autopilot
design_source: [agent]      # any of claude-design | figma | stitch | agent
design_review: annotate     # annotate = design findings never block · block = once you have calibrated a few reviews
budget_usd_per_slice: 8     # hard ceiling; a round that would exceed it opens a gate instead of running
```

Start with `supervised` and `annotate` on your first project.

### 5. From GitHub instead of the terminal

With the gh-aw workflow installed (`gh extension install github/gh-aw && gh aw compile`
once), comment on an issue or PR:

```
/slice INC-03      builds the slice and opens a draft PR
/verify            posts the verdict on a PR
/blackadder        status
```

Set `engine: copilot | claude | codex` in `.github/workflows/blackadder.md` and the matching
API-key secret. `muse/workflow.yml` does the same for Muse Code with plain Actions.

### 6. Where to look when something seems off

- `.blackadder/gates.md`: what is waiting on you
- `.blackadder/units.tsv`: per-slice state, rounds and `spent_usd`
- `.blackadder/ledger.tsv`: every verifier verdict, keyed by PR and SHA
- `docs/blackadder/ASSUMPTIONS.md`: defaults the agents took without asking
- `docs/blackadder/lessons.md`: what cost rounds; the builder reads it before every slice

## Your first project

Do it in two stages so the cheap stage validates the doc phases before you pay for the build
loop. Use a small app that still has auth, tenancy, CRUD and one async job (a team habit
tracker with a weekly digest is about six slices); do not start with your real product.

**Stage A, docs only** (an hour or two, a few dollars, no infrastructure): `/blackadder`,
`/ideate`, `go`, `/plan`, `go`, `/architect` and `/design --directions`, pick a board,
`/design --system`, `/plan --reconcile`. Pass means: every phase stopped at its gate instead
of running on, every doc has front matter and stable IDs, the agent read only what its context
contract says, and `slices.md` is something you would hand to a contractor.

**Stage B, skeleton plus two slices** (needs Vercel and Supabase): do `docs/bootstrap.md`,
then `/skeleton`, `/design --screen S-001`, `/slice INC-01`, `/slice INC-02`. Watch the loop:
red acceptance tests are committed first, the builder is refused when it touches
`tests/acceptance/` (try it), CI runs, the verifier posts a JSON verdict and a ledger row, the
design reviewer annotates. Then read `units.tsv` and `ledger.tsv`: rounds per slice, dollars
per slice, human interruptions per slice and escaped defects are the pipeline's own test
result. Write them into `docs/blackadder/lessons.md`.

## Troubleshooting

- **`Unknown command: /blackadder`**: the kit is not installed in this project or session, or
  the harness was not restarted after installing. Install the plugin or run
  `scripts/install.sh <tool> .`, then restart.
- **`nothing to commit` after the install**: you cloned the kit but did not run
  `scripts/install.sh` into the app repo, or `.claude/` is hidden by a global gitignore
  (`git add -f .claude`).
- **`its network source differs from the one declared for it in settings`** (Claude Code): a
  stale marketplace entry from an earlier attempt. `/plugin marketplace remove blackadder-dlc`,
  then add it again with one form only (`roshanis/blackadder-dlc`, not the full URL).
- **The builder edited a file under `tests/acceptance/`**: the guard hook is not installed or
  not enabled for that harness (see the tool folder's README). Revert the edit and fix the
  hook before continuing; never merge such a PR.
- **A slice keeps failing verification**: the loop stops after three rounds and opens a gate
  with "split this slice" as the default. Take the default.

## Layout

```
AGENTS.md              canonical, harness-neutral contract (every tool reads it)
skills/                canonical skills (Agent Skills standard) — edit here, then scripts/sync.sh
hooks/blackadder-guard.sh   canonical guard hook (one script, five payload/decision formats)
templates/             docs/ (idea, plan, slices, architecture, design system, ADR, CR…)
                       app/ (CI, promote/rollback, RLS + migration linters, seeds, migration 0001)
                       workflows/blackadder.md (gh-aw slash-command workflow, engine-agnostic)
scripts/               install.sh · sync.sh · validate.sh
docs/                  pipeline.md (design notes)

claude-code/           Claude Code plugin root   → .claude-plugin/plugin.json, skills/, agents/, hooks/, workflow.yml, README.md
cursor/                Cursor plugin root        → .cursor-plugin/plugin.json + plugin.json, skills/, agents/, rules/, hooks.json, workflow.yml, README.md
codex/                 Codex plugin root         → plugin.json (Agent Plugins 1.0), skills/, agents/*.toml, hooks.json, config.toml.example, workflow.yml, README.md
copilot/               Copilot plugin root       → plugin.json + com.github.copilot/{agents,hooks}, skills/, copilot-instructions.md, README.md
muse/                  Muse Code plugin root     → .muse-plugin/plugin.json, skills/, agents/ (subagent briefs), hooks/, hooks.json, workflow.yml, README.md
openclaw/              OpenClaw plugin root      → openclaw.plugin.json + package.json + index.ts (native guard), skills/, agents/<role>/AGENTS.md, openclaw.json.example, README.md

.claude-plugin/marketplace.json     → ./claude-code   (Claude Code)
.cursor-plugin/marketplace.json     → cursor          (Cursor)
.agents/plugins/marketplace.json    → ./codex         (Codex)
.github/plugin/marketplace.json     → ./copilot       (Copilot CLI / VS Code)
.muse-plugin/marketplace.json       → ./muse          (Muse Code)
(OpenClaw installs the Claude marketplace above as a bundle, or ./openclaw as a native plugin)
```

`<tool>/skills/` and `<tool>/hooks/blackadder-guard.sh` are committed copies of the root
sources (OpenClaw's guard is native TypeScript in `openclaw/index.ts` instead) (plugin specs forbid paths that escape the plugin root, so no symlinks).
`scripts/validate.sh` fails if they drift.

## Design track

Design is code plus a visual oracle. `/design` produces three rendered direction boards
(human picks), then `DESIGN.md` in [Google's open design.md format](https://github.com/google-labs-code/design.md)
(linted for contrast and structure; tokens *generated* from it), `packages/ui` + a
`/design-system` reference route (gate G2 = the human looks at it), then a static
`/proto/S-NNN` prototype per screen that becomes the visual baseline a UI slice is diffed
against. A vision-capable `blackadder-design-reviewer` applies a fixed rubric in `/verify`
and `/release`; its findings annotate by default and block once you flip
`design_review: block`. Sources: Claude Design (`/design-sync`), Figma (Dev Mode MCP +
Code Connect), Stitch (`DESIGN.md` import/export + MCP), or agent-only.

## Token use

The pipeline is built to spend tokens on judgment, not re-reading:

- **Context contracts per role** — dispatcher reads front matter + state files; builder reads
  its slice, ACs, relevant doc sections, `lessons.md` and its acceptance tests; verifier reads
  the diff + ACs; design reviewer reads `DESIGN.md`, the screen spec and *sampled* images.
- **Hard budgets** — `budget_usd_per_slice` / `budget_usd_project` in the idea doc; spend is
  recorded per run in `.blackadder/units.tsv` and `/blackadder` shows it; a round that would
  exceed the ceiling opens a gate instead of running.
- **Deterministic first** — lint, typecheck, `design.md lint`, RLS/migration lint and the
  visual harness run in CI at zero tokens; agents act on results.
- **Bounded everything** — 3 verify rounds, `maxTurns` on every agent, `max-turns` and
  `max-ai-credits` available in the gh-aw workflow.
- **Cache-friendly** — `AGENTS.md`, `DESIGN.md` and skills are stable, timestamp-free
  prefixes; phase skills are `disable-model-invocation` so idle sessions carry little.
- **Cheap images** — the design reviewer opens diff images and one reference pair per
  screen, not all six screenshots.
- **No overlapping skill packs** — anything that duplicates a phase (mattpocock/skills, the
  Impeccable skill set) stays uninstalled; we borrow only deterministic tools such as
  `npx impeccable detect` (61 anti-slop rules, zero tokens). See `docs/pipeline.md`.

Knobs, cheapest first: `autonomy: autopilot` (fewer human round-trips), lower the per-slice
budget, keep `design_review: annotate`, and set a smaller model on the builder subagent for
mechanical rounds (`model:` in each harness's agent file) while keeping the verifier and
design reviewer on the strongest model.
## Contributing to the pipeline

Edit `skills/`, `hooks/blackadder-guard.sh` or a tool folder, then:

```
scripts/sync.sh && scripts/validate.sh
```

## License

MIT.

