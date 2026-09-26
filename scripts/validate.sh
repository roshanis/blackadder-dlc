#!/usr/bin/env bash
# Validate this repo: JSON manifests, hook script syntax, skill/agent frontmatter, per-tool
# folders in sync with the canonical sources, and (with the Claude CLI) the Claude marketplace.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
fail=0

echo "json:"
for f in .claude-plugin/marketplace.json .cursor-plugin/marketplace.json .agents/plugins/marketplace.json .github/plugin/marketplace.json \
         claude-code/.claude-plugin/plugin.json claude-code/hooks/hooks.json \
         cursor/.cursor-plugin/plugin.json cursor/plugin.json cursor/hooks.json \
         codex/plugin.json codex/hooks.json \
         copilot/plugin.json copilot/com.github.copilot/hooks/hooks.json; do
  jq -e . "$f" >/dev/null && echo "  ok  $f" || { echo "  BAD $f"; fail=1; }
done

echo "bash -n:"
for f in hooks/blackadder-guard.sh scripts/*.sh templates/app/scripts/*.sh; do
  bash -n "$f" && echo "  ok  $f" || { echo "  BAD $f"; fail=1; }
done

echo "skills (canonical):"
for d in skills/*/; do
  n="$(basename "$d")"
  head -1 "$d/SKILL.md" | grep -q '^---$' || { echo "  BAD $d (no frontmatter)"; fail=1; }
  grep -q "^name: $n\$" "$d/SKILL.md" && echo "  ok  $n" || { echo "  BAD $d (name != dir)"; fail=1; }
  grep -q '^description: ' "$d/SKILL.md" || { echo "  BAD $d (no description)"; fail=1; }
done

echo "sync:"
bash scripts/sync.sh check || fail=1

echo "agents:"
for f in claude-code/agents/*.md cursor/agents/*.md copilot/com.github.copilot/agents/*.agent.md; do
  grep -q '^name: ' "$f" && grep -q '^description: ' "$f" && echo "  ok  $f" || { echo "  BAD $f"; fail=1; }
done
for f in codex/agents/*.toml; do
  grep -q '^name = ' "$f" && grep -q '^developer_instructions = ' "$f" && echo "  ok  $f" || { echo "  BAD $f"; fail=1; }
done

if command -v claude >/dev/null 2>&1; then
  echo "claude plugin validate:"
  claude plugin validate . && claude plugin validate ./claude-code && echo "  ok" || { echo "  BAD"; fail=1; }
fi

echo "guard.sh smoke:"
G=hooks/blackadder-guard.sh
echo '{"tool_name":"Edit","tool_input":{"file_path":"tests/acceptance/INC-01/a.spec.ts"}}' | bash $G claude PreToolUse >/dev/null 2>&1 \
  && { echo "  BAD (edit to tests/acceptance was allowed)"; fail=1; } || echo "  ok  blocks builder edits to tests/acceptance"
echo '{"tool_name":"Edit","tool_input":{"file_path":"tests/acceptance/INC-01/a.spec.ts"}}' | BLACKADDER_ROLE=acceptance-author bash $G claude PreToolUse >/dev/null 2>&1 \
  && echo "  ok  allows acceptance author" || { echo "  BAD (acceptance author blocked)"; fail=1; }
echo '{"tool_name":"Bash","tool_input":{"command":"git push --force origin main"}}' | bash $G claude PreToolUse >/dev/null 2>&1 \
  && { echo "  BAD (force push allowed)"; fail=1; } || echo "  ok  blocks force push"
echo '{"tool_name":"Bash","tool_input":{"command":"pnpm test"}}' | bash $G claude PreToolUse >/dev/null 2>&1 \
  && echo "  ok  allows pnpm test" || { echo "  BAD (pnpm test blocked)"; fail=1; }
out=$(echo '{"command":"vercel --prod"}' | bash $G cursor beforeShellExecution)
echo "$out" | jq -e '.permission == "deny"' >/dev/null && echo "  ok  cursor deny JSON" || { echo "  BAD cursor: $out"; fail=1; }

exit $fail
