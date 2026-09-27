# Design-source MCP servers

`DESIGN.md` at the repo root is what lands in git and what CI lints; the tools below are
where designers work and where `/design --sync` pulls from.

## Figma (Dev Mode MCP)

Remote server, no desktop app needed; authenticates through your Figma account on first use.

| Harness | Config |
|---|---|
| Claude Code | `.mcp.json` (installed by `--app-template`): `{"mcpServers":{"figma":{"type":"http","url":"https://mcp.figma.com/mcp"}}}` |
| Cursor | `.cursor/mcp.json`: same `mcpServers` block |
| Codex | `.codex/config.toml`: `[mcp_servers.figma]` `url = "https://mcp.figma.com/mcp"` |
| Copilot (VS Code) | `.vscode/mcp.json`: `{"servers":{"figma":{"type":"http","url":"https://mcp.figma.com/mcp"}}}` |
| Muse Code | `~/.config/muse/settings.json`: `"mcp_servers": {"figma": {"transport": "streamable_http", "url": "https://mcp.figma.com/mcp", "enabled": true}}` |
| OpenClaw | `~/.openclaw/openclaw.json`: the gateway's MCP tools section, same URL |

If you prefer the desktop server, use `http://127.0.0.1:3845/mcp` with Figma running.
Set up **Code Connect** so each Figma component maps to its `packages/ui` export; `/design
--screen` then implements frames with real imports instead of guessing.

## Google Stitch

Stitch exports and imports `DESIGN.md` natively. For agent-driven screen generation, add the
Stitch MCP server (URL and token from your Stitch project settings → MCP) under the same
`mcpServers` key as `stitch`. `/design --directions` and `/design --screen` use it when
`design_source` includes `stitch`.

## Claude Design

No MCP needed. In Claude Code, `/design-sync` reads the Claude Design system's tokens and
components into the repo, and a finished design hands off as a bundle Claude Code implements.
Run `/design --system` afterwards so `DESIGN.md` is refreshed for the other harnesses.
