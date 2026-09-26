@AGENTS.md

## Claude Code specifics

- The Claude Code plugin lives in `claude-code/` (`.claude-plugin/plugin.json`, `skills/`,
  `agents/`, `hooks/`). `skills/` at the repo root is the canonical source; run
  `scripts/sync.sh` after editing it.
- Subagents for the build loop: `blackadder-acceptance-author`, `blackadder-builder`,
  `blackadder-verifier` (`claude-code/agents/`, or `.claude/agents/` in an app repo). Use
  them; do not build and verify in the same context.
- `claude-code/hooks/hooks.json` blocks edits under `tests/acceptance/` and destructive
  git/db/deploy commands. Do not work around a blocked hook; escalate.
- Headless runs: `claude -p "/slice INC-03" --output-format json --permission-mode auto --max-turns 80`.
