# Blackadder DLC — OpenClaw

OpenClaw is a chat-first agent gateway (WhatsApp, Telegram, Slack, Discord, web, macOS app)
rather than a repo-local coding CLI, so Blackadder fits it in a specific way: **the OpenClaw
agent is the dispatcher and gatekeeper you talk to from any channel** (`/blackadder`, `go`,
`redo:`), while the build, verify and design-review roles run as OpenClaw sub-agents with
their own workspaces, or through OpenClaw's Codex / Copilot harness plugins where this kit's
`codex/` and `copilot/` folders already apply.

This folder is a **native OpenClaw plugin root**:

```
openclaw.plugin.json      manifest (id blackadder, skills: ["skills"], configSchema)
package.json              openclaw.extensions → index.ts, compat/build versions
index.ts                  before_tool_call guard (the hook OpenClaw actually runs)
skills/                   synced copy of the canonical skills (Agent Skills format)
agents/<role>/AGENTS.md   workspace instructions for the four role agents
openclaw.json.example     agents.entries + skills allowlists + plugin config
```

## 1. Install

Skills only, no code (OpenClaw installs Claude-format bundles directly; it maps `skills/` and
`agents/` to skills, but detects and does **not** run Claude `hooks/hooks.json`):

```
openclaw plugins install blackadder --marketplace git:github.com/roshanis/blackadder-dlc
```

Skills plus the guard (the native plugin in this folder):

```
git clone https://github.com/roshanis/blackadder-dlc /tmp/blackadder-dlc
openclaw plugins install /tmp/blackadder-dlc/openclaw
openclaw plugins enable blackadder
```

Individual skills also install straight into a workspace:
`openclaw skills install /tmp/blackadder-dlc/skills/blackadder` (or `--global`).

Then merge `openclaw.json.example` into `~/.openclaw/openclaw.json` and copy each
`agents/<role>/` into the workspace path it names. Restart the gateway.

## 2. Guard

`index.ts` registers `before_tool_call` on `write`, `edit`, `apply_patch`, `exec`, `process`,
`terminal` and `code_execution`. It returns `{ block: true, blockReason }` for: any write under
`tests/acceptance/` unless `ctx.agentId` is in `acceptanceAuthorAgentIds` (default
`blackadder-acceptance-author`), force-push, destructive git on `main`, deploys and
linked-database commands, and destructive SQL outside `supabase/migrations/`. The policy is the
same as `hooks/blackadder-guard.sh`; the role check uses the agent id instead of the
`BLACKADDER_ROLE` environment variable because OpenClaw sub-agents do not carry per-agent env.

Also keep OpenClaw's own `tools.exec` and `tools.fs` policies tight for the role agents; the
guard is a second line, not the sandbox.

## 3. Run

From any connected channel, in a session whose working directory is the app repo:

```
/blackadder
```

The phase skills are `user-invocable` slash commands (`/ideate`, `/plan`, `/architect`,
`/design`, `/skeleton`, `/slice INC-03`, `/verify`, `/release`, `/change-request`) and can
also be referenced as `$slice INC-03`. Gates arrive as one question with a proposed default,
answer `go`, `go --with-notes: …` or `redo: …` from your phone. The `/slice` skill delegates
to the role agents by name; OpenClaw runs each as `sessions_spawn` with an isolated session
(no shared context), which is exactly the fresh-context property the verifier needs.

Skill front matter keys map 1:1: `disable-model-invocation: true` hides phase skills from
the model until you invoke them, and `user-invocable` (default) exposes the slash command.

## 4. Automation

OpenClaw's cron and webhook automation can run `/verify` on a schedule or on a GitHub
webhook, but CI-side verification is better done with gh-aw or the Claude/Codex/Copilot
workflows in this repo; keep OpenClaw for the human-facing loop.

## Not verified

This folder was written against the OpenClaw docs and public plugins, not against a running
gateway. Check with `openclaw plugins install ./openclaw` and `openclaw plugins list --verbose`;
the `compat.pluginApi` / `build.openclawVersion` pins in `package.json` may need bumping to your
release. ClawHub publishing (`clawhub package publish ./openclaw`) requires those two fields.

## Design sources

Set `design_source` and `design_review` in `docs/blackadder/01-idea.md` as for the other
harnesses. Figma's Dev Mode MCP server and the Stitch MCP server are added as OpenClaw MCP
tools in `openclaw.json`; Claude Design syncs in Claude Code and lands in the repo as
`DESIGN.md`, which every harness consumes.
