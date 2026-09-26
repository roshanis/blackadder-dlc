# Setup — OpenAI Codex

## 1. Install the plugin

```
codex plugin marketplace add roshanis/blackadder-dlc
codex plugin add blackadder@blackadder-dlc        # or /plugins inside a session, then restart the session
```

Codex reads the Agent Plugins 1.0 `plugin.json` and the `.agents/plugins/marketplace.json`
in this repo. Plugins carry **skills**; Codex custom agents and hooks are project-level, so
run the installer below for the app repo.

pstack for Codex: `codex plugin marketplace add michael-denyer/pstack-claude` then
`codex plugin add pstack@pstack-claude`.

## 2. Prepare the app repo

```
git clone https://github.com/roshanis/blackadder-dlc /tmp/blackadder-dlc
/tmp/blackadder-dlc/scripts/install.sh codex . --app-template --workflows codex
```

Writes `AGENTS.md` (Codex's native instruction file), `.agents/skills/` (Codex's shared
discovery path; the skills-only route if you skip the plugin), `.codex/agents/*.toml`
(`blackadder-acceptance-author`, `blackadder-builder`, `blackadder-verifier`),
`.codex/hooks.json` + `.codex/hooks/blackadder-guard.sh` (`PreToolUse` on `Bash`), and
`.codex/config.toml` with `[agents] enabled = true`.

Codex does not auto-spawn custom agents: the `/slice` skill tells the main agent to delegate
to them by name. The verifier agent runs `sandbox_mode = "read-only"`, so the orchestrating
agent appends its ledger row.

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

`templates/workflows/codex.yml` runs `/verify` on every PR with `openai/codex-action@v1`
(`safety-strategy: read-only`, secret `OPENAI_API_KEY`) and posts the JSON verdict as a
comment. Or use gh-aw with `engine: codex`.
