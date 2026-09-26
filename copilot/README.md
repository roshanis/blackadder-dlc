# Blackadder DLC — GitHub Copilot (CLI, VS Code, cloud agent)

This folder is the Copilot plugin root: `plugin.json` (Agent Plugins 1.0 with the
`com.github.copilot` extension), `skills/` (synced copy of the repo's canonical `skills/`),
`com.github.copilot/agents/*.agent.md` (three custom agents),
`com.github.copilot/hooks/hooks.json` + `hooks/blackadder-guard.sh`, and
`copilot-instructions.md`.

## 1. Install the plugin

```
copilot plugin marketplace add roshanis/blackadder-dlc
copilot plugin install blackadder@blackadder-dlc
```

Copilot reads the repo-root `.github/plugin/marketplace.json` (→ `copilot/`). In VS Code the
same plugin installs through the Agent Plugins marketplace flow.

## 2. Prepare the app repo (needed for the cloud agent, which reads repo files only)

```
git clone https://github.com/roshanis/blackadder-dlc /tmp/blackadder-dlc
/tmp/blackadder-dlc/scripts/install.sh copilot . --app-template --workflows gh-aw
```

Writes `AGENTS.md` (Copilot reads it natively), `.github/copilot-instructions.md`,
`.github/skills/`, `.github/agents/*.agent.md`, `.github/hooks/blackadder.json` +
`.github/hooks/blackadder-guard.sh`, templates, state files, app CI, and the gh-aw workflow.

## 3. Run

CLI:
```
copilot
/blackadder
copilot --agent blackadder-verifier -p "Run /verify against PR #42"
```

Cloud agent: open a `Blackadder slice` issue (template installed), assign it to Copilot. It
reads `.github/copilot-instructions.md` + `AGENTS.md`, runs `/slice INC-NN`, opens a PR.
Then comment `/verify` on the PR (gh-aw) or run the verifier from the CLI.

## 4. gh-aw (GitHub Agentic Workflows) — the recommended GitHub bus

```
gh extension install github/gh-aw
gh aw compile        # compiles .github/workflows/blackadder.md → blackadder.lock.yml
```

`engine: copilot` is the default (needs `copilot-requests: write` or `COPILOT_GITHUB_TOKEN`);
switch to `claude` or `codex` with the matching API-key secret. The workflow installs this
plugin via `plugins: [roshanis/blackadder-dlc@main]`, responds to `/blackadder`, `/slice`,
`/verify`, `/release`, `/change-request` in issues and PRs, and writes only through
`safe-outputs` (comments, draft PRs, labels) — the agent job itself is read-only and sandboxed.
