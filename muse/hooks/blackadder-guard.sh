#!/usr/bin/env bash
# Blackadder guard hook — shared by Claude Code, Codex, Cursor, Copilot and Muse Code.
#
# Usage: guard.sh <claude|codex|cursor|copilot|muse> [event]
# Reads the harness's JSON payload on stdin and decides whether to block.
#
# Blocks:
#   1. any write/edit under tests/acceptance/  (unless BLACKADDER_ROLE=acceptance-author)
#   2. destructive or production-touching shell commands
#
# Exit/output conventions:
#   claude, codex, copilot, muse : JSON decision on stdout; exit 2 also blocks (Claude/Codex/Muse).
#                            Muse sends tool_input.path instead of file_path; both are read.
#   cursor                 : {"permission":"deny",...} for before* events;
#                            afterFileEdit cannot block, so the edit is reverted with git.
set -euo pipefail

HARNESS="${1:-claude}"
EVENT="${2:-}"
INPUT="$(cat)"
ROLE="${BLACKADDER_ROLE:-}"

jqget() { printf '%s' "$INPUT" | jq -r "$1 // empty" 2>/dev/null || true; }

# Extract a file path from whichever payload shape we were given.
FILE="$(jqget '.tool_input.file_path')"
[ -z "$FILE" ] && FILE="$(jqget '.tool_input.path')"
[ -z "$FILE" ] && FILE="$(jqget '.file_path')"
[ -z "$FILE" ] && FILE="$(jqget '.toolArgs.file_path')"
[ -z "$FILE" ] && FILE="$(jqget '.toolArgs.path')"

# Extract a shell command likewise.
CMD="$(jqget '.tool_input.command')"
[ -z "$CMD" ] && CMD="$(jqget '.command')"
[ -z "$CMD" ] && CMD="$(jqget '.toolArgs.command')"

deny() {
  local reason="$1"
  case "$HARNESS" in
    cursor)
      if [ "$EVENT" = "afterFileEdit" ] && [ -n "$FILE" ]; then
        git checkout -- "$FILE" 2>/dev/null || true
        printf '{"userMessage":"Blackadder: reverted %s — %s","agentMessage":"%s"}\n' "$FILE" "$reason" "$reason"
        exit 0
      fi
      printf '{"permission":"deny","userMessage":"Blackadder: %s","agentMessage":"%s"}\n' "$reason" "$reason"
      exit 0
      ;;
    *)
      printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Blackadder: %s"}}\n' "$reason"
      echo "Blackadder: $reason" >&2
      exit 2
      ;;
  esac
}

# 1. Protect acceptance tests from everyone except the acceptance author.
if [ -n "$FILE" ] && [[ "$FILE" == *"tests/acceptance/"* ]] && [ "$ROLE" != "acceptance-author" ]; then
  deny "tests/acceptance/ is written by the acceptance author before the build and must not be edited by the builder (AGENTS.md rule 2). Escalate instead."
fi

# 2. Shell command policy.
if [ -n "$CMD" ]; then
  if [[ "$CMD" =~ tests/acceptance ]] && [[ "$CMD" =~ (rm|mv|sed|truncate|>|git\ checkout|git\ rm) ]] && [ "$ROLE" != "acceptance-author" ]; then
    deny "shell command touches tests/acceptance/ (AGENTS.md rule 2)."
  fi
  if [[ "$CMD" =~ git\ push.*(--force|-f\b|--force-with-lease) ]]; then
    deny "force-push is never allowed (AGENTS.md rule 7)."
  fi
  if [[ "$CMD" =~ git\ (reset\ --hard|clean\ -fd) ]] && [[ "$CMD" =~ (main|master) ]]; then
    deny "destructive git operation on main."
  fi
  if [[ "$CMD" =~ (vercel\ .*--prod|railway\ up|railway\ deploy|supabase\ db\ push.*--linked|supabase\ db\ reset.*--linked|supabase\ link) ]]; then
    deny "agents never deploy or touch linked/production databases (AGENTS.md rule 7). Open a PR or dispatch the workflow."
  fi
  if [[ "$CMD" =~ (DROP\ (TABLE|SCHEMA|DATABASE)|TRUNCATE\ ) ]] && [[ ! "$CMD" =~ supabase/migrations ]]; then
    deny "destructive SQL outside a migration file."
  fi
fi

# Allow.
case "$HARNESS" in
  cursor) printf '{"permission":"allow"}\n' ;;
  *) exit 0 ;;
esac
