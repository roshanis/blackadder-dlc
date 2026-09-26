---
description: Blackadder DLC — run a phase skill from an issue or PR comment. Same workflow for every harness; switch `engine`.
on:
  slash_command:
    name: ["blackadder", "slice", "verify", "release", "change-request"]
    events: [issues, issue_comment, pull_request, pull_request_comment]
  roles: [admin, maintainer, write]
  reaction: eyes
  status-comment: true
permissions:
  contents: read
  issues: read
  pull-requests: read
engine:
  id: copilot          # copilot | claude | codex  (claude needs ANTHROPIC_API_KEY, codex needs OPENAI_API_KEY)
plugins:
  - roshanis/blackadder-dlc@main
tools:
  github:
    toolsets: [default]
  edit:
  bash: ["pnpm *", "supabase *", "git *", "npx playwright *"]
network:
  allowed: [defaults, node, "*.vercel.app", "*.supabase.co"]
safe-outputs:
  add-comment:
    target: triggering
    max: 2
  create-pull-request:
    draft: true
    title-prefix: "[blackadder] "
    labels: [blackadder]
    max: 1
  push-to-pull-request-branch:
    max: 1
  add-labels:
    allowed: [blackadder:needs-human, blackadder:verified, blackadder:stale]
    max: 3
timeout-minutes: 45
max-turns: 80
---

# Blackadder DLC runner

The command was `/${{ needs.activation.outputs.slash_command }}` with the text:

> "${{ steps.sanitized.outputs.text }}"

Read `AGENTS.md` and run the matching Blackadder skill:

- `/blackadder` → report status and the next step (comment only).
- `/slice INC-NN` → run the `/slice` skill for that id: acceptance tests first (fresh
  context), then build on branch `blackadder/INC-NN`, open a draft PR via the
  `create-pull-request` safe output. Do not verify in this run.
- `/verify` on a PR → run the `/verify` skill against the PR head; post the JSON verdict as
  a comment; add `blackadder:verified` on `pass`, `blackadder:needs-human` when the loop
  bounds are hit.
- `/release` → run release verification against staging and post the report.
- `/change-request` → classify the finding in the comment and open the CR file on a new
  branch via `create-pull-request`.

Never deploy, never force-push, never edit `tests/acceptance/` outside the acceptance-author
step. If a human gate is required, post the gate entry as a comment and stop.
