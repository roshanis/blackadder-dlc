# Blackadder DLC

An idea-to-production development life cycle for AI coding agents — **the same pipeline on
Claude Code, Cursor, Codex and GitHub Copilot**.

```
ideate → plan (+ slice ladder) → architect ∥ design-system → skeleton (slice 0)
      → [ slice → verify ] × N → release → deploy → change-request loop
```

Small verified tracer-bullet slices; acceptance tests written *before* the build by a
different context; a fresh-context verifier with a SHA-keyed verdict; bounded loops; four
human gates; agents that never hold production secrets. The full contract is in
[`AGENTS.md`](AGENTS.md); the design rationale is in [`docs/pipeline.md`](docs/pipeline.md).

## What's in the box

| Layer | Portable | Per harness |
|---|---|---|
| Instructions | `AGENTS.md` (read by all four) | `CLAUDE.md` (`@AGENTS.md`), `.cursor/rules/blackadder.mdc`, `.github/copilot-instructions.md` |
| Skills (10) | `skills/*/SKILL.md` — Agent Skills standard | copied to `.claude/skills`, `.cursor/skills`, `.agents/skills`, `.github/skills` |
| Roles (3) | acceptance-author · builder · verifier | `agents/*.md` (Claude), `harness/cursor/agents/*.md`, `harness/codex/agents/*.toml`, `com.github.copilot/agents/*.agent.md` |
| Guard hook | `hooks/scripts/guard.sh` (one script) | `hooks/hooks.json` (Claude), `harness/cursor/hooks.json`, `harness/codex/hooks.json`, `com.github.copilot/hooks/hooks.json` |
| Plugin manifests | `plugin.json` (Agent Plugins 1.0: Codex, Cursor, Copilot, VS Code) | `.claude-plugin/` (Claude Code + Copilot legacy), `.cursor-plugin/`, `.agents/plugins/` (Codex marketplace) |
| Templates | `templates/docs/` (idea, plan, slices, architecture, design system, ADR, CR…) · `templates/app/` (CI, promote/rollback, RLS + migration linters, seeds, migration 0001) · `templates/workflows/` (gh-aw + per-vendor Actions) | |

## Install

### Claude Code
```
/plugin marketplace add roshanis/blackadder-dlc
/plugin install blackadder@blackadder-dlc
```
Project-local alternative: `scripts/install.sh claude <app-repo>`. Details: [docs/setup-claude.md](docs/setup-claude.md).

### Cursor
Add the plugin from this repository (Customize → Plugins → add from GitHub → `roshanis/blackadder-dlc`),
or project-local: `scripts/install.sh cursor <app-repo>`. Details: [docs/setup-cursor.md](docs/setup-cursor.md).

### Codex
```
codex plugin marketplace add roshanis/blackadder-dlc
codex plugin add blackadder@blackadder-dlc      # or /plugins inside a session
```
Project-local: `scripts/install.sh codex <app-repo>` (skills → `.agents/skills`, agents → `.codex/agents`). Details: [docs/setup-codex.md](docs/setup-codex.md).

### GitHub Copilot (CLI, VS Code, cloud agent)
```
copilot plugin marketplace add roshanis/blackadder-dlc
copilot plugin install blackadder@blackadder-dlc
```
Project-local (also what the cloud agent reads): `scripts/install.sh copilot <app-repo>`. Details: [docs/setup-copilot.md](docs/setup-copilot.md).

### All four at once, plus the app template and GitHub workflows
```
git clone https://github.com/roshanis/blackadder-dlc
blackadder-dlc/scripts/install.sh all <app-repo> --app-template --workflows gh-aw
```

## Use

In the app repo, in any of the four harnesses:

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

If [pstack](https://github.com/cursor/plugins/tree/main/pstack) (or its
[Claude Code/Codex port](https://github.com/michael-denyer/pstack-claude)) is installed,
`/slice` routes the build through `/poteto-mode`'s `feature` playbook and its verification
lanes. Blackadder keeps ownership of the phases, gates, documents and `.blackadder/` state.

## Repo layout

```
AGENTS.md  CLAUDE.md  plugin.json  .claude-plugin/  .cursor-plugin/  .agents/plugins/
skills/            blackadder ideate plan architect design-system skeleton slice verify release change-request
agents/            Claude Code subagents
harness/           cursor/{agents,rules,hooks.json}  codex/{agents,hooks.json,config.toml.example}  copilot/copilot-instructions.md
com.github.copilot/ agents/*.agent.md  hooks/hooks.json     (Agent Plugins 1.0 extension namespace)
hooks/             hooks.json (Claude)  scripts/guard.sh (shared)
templates/         docs/  app/  workflows/
scripts/           install.sh  validate.sh
docs/              pipeline.md  setup-claude.md  setup-cursor.md  setup-codex.md  setup-copilot.md
```

Run `scripts/validate.sh` before committing changes to the plugin.

## License

MIT.
