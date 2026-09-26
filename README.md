# Blackadder DLC

An idea-to-production development life cycle for AI coding agents — **the same pipeline on
Claude Code, Cursor, Codex and GitHub Copilot**, one folder per tool.

```
ideate → plan (+ slice ladder) → architect ∥ design-system → skeleton (slice 0)
      → [ slice → verify ] × N → release → deploy → change-request loop
```

Small verified tracer-bullet slices; acceptance tests written *before* the build by a
different context; a fresh-context verifier with a SHA-keyed verdict; bounded loops; four
human gates; agents that never hold production secrets. The contract is
[`AGENTS.md`](AGENTS.md); the rationale is [`docs/pipeline.md`](docs/pipeline.md).

## Layout

```
AGENTS.md              canonical, harness-neutral contract (all four tools read it)
skills/                canonical skills (Agent Skills standard) — edit here, then scripts/sync.sh
hooks/blackadder-guard.sh   canonical guard hook (one script, four payload/decision formats)
templates/             docs/ (idea, plan, slices, architecture, design system, ADR, CR…)
                       app/ (CI, promote/rollback, RLS + migration linters, seeds, migration 0001)
                       workflows/blackadder.md (gh-aw slash-command workflow, engine-agnostic)
scripts/               install.sh · sync.sh · validate.sh
docs/                  pipeline.md (design notes)

claude-code/           Claude Code plugin root   → .claude-plugin/plugin.json, skills/, agents/, hooks/, workflow.yml, README.md
cursor/                Cursor plugin root        → .cursor-plugin/plugin.json + plugin.json, skills/, agents/, rules/, hooks.json, workflow.yml, README.md
codex/                 Codex plugin root         → plugin.json (Agent Plugins 1.0), skills/, agents/*.toml, hooks.json, config.toml.example, workflow.yml, README.md
copilot/               Copilot plugin root       → plugin.json + com.github.copilot/{agents,hooks}, skills/, copilot-instructions.md, README.md

.claude-plugin/marketplace.json     → ./claude-code   (Claude Code)
.cursor-plugin/marketplace.json     → cursor          (Cursor)
.agents/plugins/marketplace.json    → ./codex         (Codex)
.github/plugin/marketplace.json     → ./copilot       (Copilot CLI / VS Code)
```

`<tool>/skills/` and `<tool>/hooks/blackadder-guard.sh` are committed copies of the root
sources (plugin specs forbid paths that escape the plugin root, so no symlinks).
`scripts/validate.sh` fails if they drift.

## Install

| Tool | Plugin (recommended) | Project-local |
|---|---|---|
| **Claude Code** | `/plugin marketplace add roshanis/blackadder-dlc` → `/plugin install blackadder@blackadder-dlc` | `scripts/install.sh claude <app-repo>` |
| **Cursor** | Customize → Plugins → add marketplace/plugin from GitHub `roshanis/blackadder-dlc` | `scripts/install.sh cursor <app-repo>` |
| **Codex** | `codex plugin marketplace add roshanis/blackadder-dlc` → `codex plugin add blackadder@blackadder-dlc` | `scripts/install.sh codex <app-repo>` |
| **Copilot** | `copilot plugin marketplace add roshanis/blackadder-dlc` → `copilot plugin install blackadder@blackadder-dlc` | `scripts/install.sh copilot <app-repo>` |

Each tool's `README.md` has the full walkthrough (project prep, subagents, hooks, headless
and GitHub automation). All four at once, with the app template and the gh-aw workflow:

```
git clone https://github.com/roshanis/blackadder-dlc
blackadder-dlc/scripts/install.sh all <app-repo> --app-template --workflows gh-aw
```

## Use

In the app repo, in any of the four tools:

```
/blackadder            where are we, what's next (routes to the right phase)
/ideate                → docs/blackadder/01-idea.md           gate G0
/plan                  → 02-plan.md + slices.md               gate G1
/architect             → 03-architecture.md + migration 0001  gate G2 ┐ run in parallel
/design-system         → 04-design-system.md + packages/ui   gate G2 ┘
/skeleton              → slice INC-00 live on a preview URL   gate G3
/slice INC-03          → acceptance tests → build → CI → /verify → PR
/verify                → fresh-context verdict in .blackadder/ledger.tsv
/release               → release verify on staging; /release --promote is gate G6
/change-request        → L1–L4 routing of any finding
```

From GitHub, with the gh-aw workflow installed: comment `/slice INC-03` or `/verify` on an
issue/PR. Switch `engine:` in `.github/workflows/blackadder.md` between `copilot`, `claude`
and `codex`.

## With pstack

If [pstack](https://github.com/cursor/plugins/tree/main/pstack) (native on Cursor) or its
[Claude Code/Codex port](https://github.com/michael-denyer/pstack-claude) is installed,
`/slice` routes the build through `/poteto-mode`'s `feature` playbook and its verification
lanes. Blackadder keeps ownership of the phases, gates, documents and `.blackadder/` state.

## Contributing to the pipeline

Edit `skills/`, `hooks/blackadder-guard.sh` or a tool folder, then:

```
scripts/sync.sh && scripts/validate.sh
```

## License

MIT.
