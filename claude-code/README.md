# Blackadder DLC — Claude Code

This folder is the Claude Code plugin root: `.claude-plugin/plugin.json`, `skills/` (synced
copy of the repo's canonical `skills/`), `agents/` (three subagents), `hooks/hooks.json` +
`hooks/blackadder-guard.sh`, `workflow.yml` (GitHub Action).

## 1. Install the plugin (recommended)

```
/plugin marketplace add roshanis/blackadder-dlc
/plugin install blackadder@blackadder-dlc
```

You get the ten skills (`/blackadder`, `/ideate`, `/plan`, `/architect`, `/design-system`,
`/skeleton`, `/slice`, `/verify`, `/release`, `/change-request`), the subagents
`blackadder-acceptance-author` / `blackadder-builder` / `blackadder-verifier`, and the guard
hook (blocks builder edits under `tests/acceptance/`, force-push, deploys, linked-DB commands).

Optional, for the build playbooks:

```
/plugin marketplace add michael-denyer/pstack-claude
/plugin install pstack@pstack-claude
```

## 2. Prepare the app repo

```
git clone https://github.com/roshanis/blackadder-dlc /tmp/blackadder-dlc
/tmp/blackadder-dlc/scripts/install.sh claude . --app-template --workflows claude
```

Writes `AGENTS.md`, `CLAUDE.md` (`@AGENTS.md`), `docs/blackadder/templates/`, the
`.blackadder/` state files, `docs/bootstrap.md`, the app CI/promote/rollback workflows and
lint scripts, and a project-local copy of skills/agents/hook (harmless alongside the plugin;
delete `.claude/skills` and `.claude/agents` if you only want the plugin).

Claude Code ≥ 2.1.277 reads `AGENTS.md` directly when no `CLAUDE.md` exists; the generated
`CLAUDE.md` imports it explicitly so both work.

## 3. Run

```
claude
/blackadder
```

Builder and verifier on different models: set `model:` in `agents/blackadder-verifier.md`
vs `agents/blackadder-builder.md` (e.g. `opus` / `sonnet`), or keep both on `opus` and rely
on the fresh context.

## 4. Headless / CI

```
claude -p "/slice INC-03" --output-format json --permission-mode auto --max-turns 80
claude -p "/verify" --resume "$SESSION_ID"
```

`workflow.yml` (installed as `.github/workflows/blackadder-claude.yml`) runs
`/slice <issue title>` when an issue is labelled `blackadder:slice` and answers `@claude`
mentions, via `anthropics/claude-code-action@v1` with the plugin pre-installed
(`plugin_marketplaces` + `plugins` inputs). Secret: `ANTHROPIC_API_KEY`. Or use gh-aw with
`engine: claude` (`templates/workflows/blackadder.md`).
