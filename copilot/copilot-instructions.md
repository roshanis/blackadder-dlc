# Copilot instructions — Blackadder DLC

Read and obey `AGENTS.md` at the repository root; it is the canonical Blackadder DLC contract
(phases, gates, the ten non-negotiable rules, and where state lives).

Copilot specifics:

- Phase skills are installed under `.github/skills/` (or via the `blackadder` plugin):
  `/blackadder`, `/ideate`, `/plan`, `/architect`, `/design-system`, `/skeleton`,
  `/slice <id>`, `/verify`, `/release`, `/change-request`.
- Custom agents in `.github/agents/`: `blackadder-acceptance-author`, `blackadder-builder`,
  `blackadder-verifier`. Build and verify never share a context. From the CLI:
  `copilot --agent blackadder-verifier -p "Verify PR #42 per /verify"`.
- Hooks in `.github/hooks/blackadder.json` deny edits under `tests/acceptance/` (except by the
  acceptance author) and deploy/force-push/linked-DB commands. Do not work around a denial.
- Cloud agent: assigning a `blackadder:slice` issue to Copilot runs `/slice` for that issue's
  slice id; the PR it opens must go through `/verify` before merge.
