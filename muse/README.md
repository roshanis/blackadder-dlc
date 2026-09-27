# Blackadder DLC — Muse Code (Meta)

This folder is the Muse Code plugin root: `.muse-plugin/plugin.json` (native manifest,
`schemaVersion: 1`), `skills/` (synced copy of the repo's canonical `skills/`), `agents/`
(four subagent briefs, registered as skills so the lead can read them), `hooks/blackadder-guard.sh`
(declared as a `PreToolUse` hook in the manifest), `hooks.json` (project-local
`.muse/hooks.json` for the installer route) and `workflow.yml` (GitHub Action).

## 1. Install the plugin

```
export MUSE_EXPERIMENTAL_PLUGINS=1
muse plugins marketplace add blackadder-dlc https://github.com/roshanis/blackadder-dlc.git
muse plugins install blackadder@blackadder-dlc
muse plugins approve blackadder          # trusts the guard hook
```

Muse reads the repo-root `.muse-plugin/marketplace.json` (→ `muse/`). From a local checkout:
`muse plugins validate ./muse && muse plugins install ./muse --scope user`.

## 2. Prepare the app repo

```
git clone https://github.com/roshanis/blackadder-dlc /tmp/blackadder-dlc
/tmp/blackadder-dlc/scripts/install.sh muse . --app-template --workflows muse
```

Writes `AGENTS.md` (Muse reads it first, then falls back to `CLAUDE.md`), the doc templates
and `.blackadder/` state files, `.agents/skills/` (skills-only route if you skip the plugin;
if your Muse build only scans `.claude/skills` and `.codex/skills`, run
`muse skills import --from claude` after `install.sh claude`), `.muse/agents/*.md` (the
briefs), `.muse/hooks.json` + `.muse/hooks/blackadder-guard.sh`.

## 3. Subagents

Muse has no custom-agent files; the lead spawns children with `subagent_spawn`. Each brief in
`agents/` says how: the builder in an isolated worktree on `blackadder/<INC-id>`, the
acceptance author in the shared checkout, the verifier and design reviewer in fresh contexts
that never see the builder's transcript. `/slice` names the roles; the lead reads the brief
(it is a plugin skill) and passes its body as the child's prompt.

The guard's acceptance-author exception is `BLACKADDER_ROLE=acceptance-author`, exported by
that role before its writes, as in the other harnesses.

## 4. Run

```
muse
/blackadder
```

## 5. Headless / CI

```
muse exec --json --yolo --max-model-steps 80 --reasoning-effort high "Run the /slice skill for INC-03"
muse exec --json --disable-approval --max-model-steps 60 --prompt-file /tmp/verify.md
```

`workflow.yml` (installed as `.github/workflows/blackadder-muse.yml`) runs `/verify` on every
PR and posts the verdict. Secret: `MODEL_API_KEY` from the Meta Model API dashboard.

## Not verified

Written against Meta's public docs and published Muse plugins (Browserbase, Superpowers), not
a running Muse. Confirm with `muse plugins validate ./muse` and `muse skills list --source plugin`.
Known unknowns: whether manifest hooks accept a `matcher` (the guard filters by payload, so
none is declared), the exact `.muse/hooks.json` wrapper key, and the env var name for
API-key auth (`MODEL_API_KEY` vs `META_API_KEY`). `muse login` works either way.

## Design sources

Set `design_source` and `design_review` in `docs/blackadder/01-idea.md` as for the other
harnesses. Add the Figma Dev Mode MCP server (`https://mcp.figma.com/mcp`) or the Stitch MCP
server under `mcp_servers` in `~/.config/muse/settings.json`; Claude Design syncs in Claude
Code and lands in the repo as `DESIGN.md`.
