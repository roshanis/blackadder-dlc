# Blackadder DLC — OpenAI Codex

This folder is the Codex plugin root: `plugin.json` (Agent Plugins 1.0), `skills/` (synced
copy of the repo's canonical `skills/`), plus the project-level pieces Codex plugins do not
carry — `agents/*.toml` (three custom agents), `hooks.json` + `hooks/blackadder-guard.sh`,
`config.toml.example`, and `workflow.yml` (GitHub Action).

## 1. Install the plugin

```
codex plugin marketplace add roshanis/blackadder-dlc
codex plugin add blackadder@blackadder-dlc        # or /plugins inside a session, then restart the session
```

Codex reads the repo-root `.agents/plugins/marketplace.json` (→ `codex/`). Plugins carry
**skills**; custom agents and hooks are project-level, so also run the installer below.

## 2. Prepare the app repo

```
git clone https://github.com/roshanis/blackadder-dlc /tmp/blackadder-dlc
/tmp/blackadder-dlc/scripts/install.sh codex . --app-template --workflows codex
```

Writes `AGENTS.md` (Codex's native instruction file), `.agents/skills/` (Codex's shared
discovery path — the skills-only route if you skip the plugin), `.codex/agents/*.toml`
(`blackadder-acceptance-author`, `blackadder-builder`, `blackadder-verifier`),
`.codex/hooks.json` + `.codex/hooks/blackadder-guard.sh` (`PreToolUse` on `Bash`), and
`.codex/config.toml` with `[agents] enabled = true`.

Codex does not auto-spawn custom agents: the `/slice` skill tells the main agent to delegate
to them by name. The verifier runs `sandbox_mode = "read-only"`, so the orchestrating agent
appends its ledger row.

## 3. Run

```
codex
/blackadder
```

Invoke skills with `$slice INC-03` or by name in the prompt.

## 4. Headless / CI

```
codex exec --sandbox workspace-write --json -o /tmp/out.txt "Run the /slice skill for INC-03"
codex -a never exec --sandbox read-only "Run the /verify skill against PR #42"
```

`workflow.yml` (installed as `.github/workflows/blackadder-codex.yml`) runs `/verify` on
every PR with `openai/codex-action@v1` (`safety-strategy: read-only`, secret
`OPENAI_API_KEY`) and posts the JSON verdict as a comment. Or use gh-aw with `engine: codex`.

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
