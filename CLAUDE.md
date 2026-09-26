@AGENTS.md

## Claude Code specifics

- Subagents for the build loop live in `agents/` when installed as a plugin, or
  `.claude/agents/` in an app repo: `blackadder-acceptance-author`, `blackadder-builder`,
  `blackadder-verifier`. Use them; do not build and verify in the same context.
- `hooks/hooks.json` blocks edits under `tests/acceptance/` and destructive git/db commands.
  Do not work around a blocked hook; escalate.
- Headless runs: `claude -p "/slice INC-03" --output-format json --permission-mode auto --max-turns 60`.
