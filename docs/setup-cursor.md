# Setup — Cursor

## 1. Install the plugin

Cursor installs plugins from a Git repository with a `.cursor-plugin/plugin.json` manifest
(this repo has one, plus an Agent Plugins 1.0 `plugin.json`). In Cursor: **Customize →
Plugins → add from GitHub** → `roshanis/blackadder-dlc`. You get the skills, the three
subagents (`harness/cursor/agents/`) and the always-on rule.

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
(`BLACKADDER_ROLE=acceptance-author`), and **denies** deploy/force-push/linked-DB shell
commands via `beforeShellExecution`. If you already have a `.cursor/hooks.json`, the
installer writes `.cursor/hooks.blackadder.json` for you to merge.

## 3. Run

Open the repo, type `/blackadder`. Subagents are spawned by the skills; pick different
models for builder and verifier in the subagent picker or in the agent files (`model:`).

## 4. Headless / CI / Cloud Agents

```
agent -p "/slice INC-03" --output-format json          # proposes changes only
agent -p "/verify" --force --output-format text        # --force applies/executes (CI only)
```

`templates/workflows/cursor.yml` runs `/blackadder…`, `/slice…`, `/verify` comments through
the Cursor CLI on Actions (secret `CURSOR_API_KEY`). Cursor Cloud Agents can run the same
prompts against the repo via the Cloud Agents API.
