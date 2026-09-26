# Setup — Claude Code

## 1. Install the plugin (recommended)

```
/plugin marketplace add roshanis/blackadder-dlc
/plugin install blackadder@blackadder-dlc
```

You get: the ten skills (`/blackadder`, `/ideate`, …), three subagents
(`blackadder-acceptance-author`, `blackadder-builder`, `blackadder-verifier`), and the guard
hook (`hooks/hooks.json` → blocks builder edits under `tests/acceptance/`, force-push,
deploys, linked-DB commands).

Optionally also install pstack's Claude Code port for the build playbooks:

```
/plugin marketplace add michael-denyer/pstack-claude
/plugin install pstack@pstack-claude
```

## 2. Prepare the app repo

```
git clone https://github.com/roshanis/blackadder-dlc /tmp/blackadder-dlc
/tmp/blackadder-dlc/scripts/install.sh claude . --app-template --workflows claude
```

This writes `AGENTS.md`, `CLAUDE.md` (`@AGENTS.md`), `docs/blackadder/templates/`, the
`.blackadder/` state files, `docs/bootstrap.md`, the app CI/promote/rollback workflows and
lint scripts, and a project-local copy of the skills/agents/hook (harmless alongside the
plugin; delete `.claude/skills` and `.claude/agents` if you only want the plugin).

Claude Code ≥ 2.1.277 reads `AGENTS.md` directly when no `CLAUDE.md` exists; the generated
`CLAUDE.md` imports it explicitly so both work.

## 3. Run

```
claude
/blackadder
```

Verifier on a different model than the builder: edit `.claude/agents/blackadder-verifier.md`
`model:` (e.g. `opus` for the verifier, `sonnet` for the builder), or keep both on `opus`
and rely on the fresh context.

## 4. Headless / CI

```
claude -p "/slice INC-03" --output-format json --permission-mode auto --max-turns 80
claude -p "/verify" --resume "$SESSION_ID"
```

`templates/workflows/claude.yml` runs `/slice <issue title>` when an issue is labelled
`blackadder:slice`, and answers `@claude` mentions, via `anthropics/claude-code-action@v1`
with the plugin pre-installed (`plugin_marketplaces` + `plugins` inputs). Secret:
`ANTHROPIC_API_KEY`. Or use gh-aw with `engine: claude` (see `templates/workflows/blackadder.md`).
