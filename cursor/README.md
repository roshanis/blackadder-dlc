# Blackadder DLC — Cursor

This folder is the Cursor plugin root: `.cursor-plugin/plugin.json` (plus an Agent Plugins
1.0 `plugin.json`), `skills/` (synced copy of the repo's canonical `skills/`), `agents/`
(three subagents), `rules/blackadder.mdc` (always-on), `hooks.json` +
`hooks/blackadder-guard.sh`, `workflow.yml` (GitHub Action).

## 1. Install the plugin

Cursor installs plugins from a Git repository with a `.cursor-plugin/plugin.json` manifest
and lists plugins from a repo-root `.cursor-plugin/marketplace.json` (this repo has both; the
marketplace points at `cursor/`). In Cursor: **Customize → Plugins → add from GitHub** →
`roshanis/blackadder-dlc`. If your Cursor build only accepts a plugin at the repo root, use
the project-local install below.

pstack is native here: `/add-plugin pstack`. With both installed, `/slice` routes builds
through `/poteto-mode`'s `feature` playbook.

## 2. Prepare the app repo (hooks are project-level in Cursor)

```
git clone https://github.com/roshanis/blackadder-dlc /tmp/blackadder-dlc
/tmp/blackadder-dlc/scripts/install.sh cursor . --app-template --workflows cursor
```

Writes `AGENTS.md` (Cursor reads it natively), `.cursor/rules/blackadder.mdc`,
`.cursor/skills/`, `.cursor/agents/`, `.cursor/hooks.json` +
`.cursor/hooks/blackadder-guard.sh`, templates, state files, app CI.

Cursor hooks cannot block a file edit before it happens (`afterFileEdit` only), so the guard
**reverts** any edit under `tests/acceptance/` not made by the acceptance author
(`BLACKADDER_ROLE=acceptance-author`) and **denies** deploy/force-push/linked-DB shell
commands via `beforeShellExecution`. If you already have a `.cursor/hooks.json`, the
installer writes `.cursor/hooks.blackadder.json` for you to merge.

## 3. Run

Open the repo, type `/blackadder`. Subagents are spawned by the skills; pick different
models for builder and verifier in the subagent picker.

## 4. Headless / CI / Cloud Agents

```
agent -p "/slice INC-03" --output-format json          # proposes changes only
agent -p "/verify" --force --output-format text        # --force applies/executes (CI only)
```

`workflow.yml` (installed as `.github/workflows/blackadder-cursor.yml`) runs
`/blackadder…`, `/slice…`, `/verify` comments through the Cursor CLI on Actions (secret
`CURSOR_API_KEY`). Cursor Cloud Agents can run the same prompts via the Cloud Agents API.

## Design sources

Set `design_source` in `docs/blackadder/01-idea.md` (any of `claude-design`, `figma`,
`stitch`, `agent`) and `design_review` (`annotate` | `block`). `/design --sync <source>`
refreshes `DESIGN.md` from the source of truth; CI lints `DESIGN.md` and fails if
`packages/ui/tailwind.tokens.css` was hand-edited.

- **Figma** — add the Dev Mode MCP server (`https://mcp.figma.com/mcp`); see
  `templates/app/mcp/README.md` for this harness's config file. Set up Code Connect so Figma
  components map to `packages/ui`.
- **Stitch** — export `DESIGN.md` from the Stitch project into the repo root; add the Stitch
  MCP server for `/design --directions` and `--screen`.
- **Claude Design** — sync happens in Claude Code (`/design-sync`); this harness consumes the
  resulting `DESIGN.md`, `packages/ui` and `/proto/*` routes from the repo.
