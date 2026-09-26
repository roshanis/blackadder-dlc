#!/usr/bin/env bash
# Validate this plugin repo: JSON manifests, hook script syntax, skill/agent frontmatter, and
# (when the Claude CLI is present) the Claude plugin manifest.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
fail=0

echo "json:"
for f in plugin.json .claude-plugin/plugin.json .claude-plugin/marketplace.json .cursor-plugin/plugin.json \
         .cursor-plugin/marketplace.json .agents/plugins/marketplace.json hooks/hooks.json \
         harness/codex/hooks.json harness/cursor/hooks.json com.github.copilot/hooks/hooks.json; do
  jq -e . "$f" >/dev/null && echo "  ok  $f" || { echo "  BAD $f"; fail=1; }
done

echo "bash -n:"
for f in hooks/scripts/guard.sh scripts/*.sh templates/app/scripts/*.sh; do
  bash -n "$f" && echo "  ok  $f" || { echo "  BAD $f"; fail=1; }
done

echo "skills:"
for d in skills/*/; do
  n="$(basename "$d")"
  head -1 "$d/SKILL.md" | grep -q '^---$' || { echo "  BAD $d (no frontmatter)"; fail=1; }
  grep -q "^name: $n\$" "$d/SKILL.md" && echo "  ok  $n" || { echo "  BAD $d (name != dir)"; fail=1; }
  grep -q '^description: ' "$d/SKILL.md" || { echo "  BAD $d (no description)"; fail=1; }
done

echo "agents:"
for f in agents/*.md harness/cursor/agents/*.md com.github.copilot/agents/*.agent.md; do
  grep -q '^name: ' "$f" && grep -q '^description: ' "$f" && echo "  ok  $f" || { echo "  BAD $f"; fail=1; }
done
for f in harness/codex/agents/*.toml; do
  grep -q '^name = ' "$f" && grep -q '^developer_instructions = ' "$f" && echo "  ok  $f" || { echo "  BAD $f"; fail=1; }
done

if command -v claude >/dev/null 2>&1; then
  echo "claude plugin validate:"
  claude plugin validate . && echo "  ok" || { echo "  BAD"; fail=1; }
fi

echo "guard.sh smoke:"
echo '{"tool_name":"Edit","tool_input":{"file_path":"tests/acceptance/INC-01/a.spec.ts"}}' | bash hooks/scripts/guard.sh claude PreToolUse >/dev/null 2>&1 \
  && { echo "  BAD (edit to tests/acceptance was allowed)"; fail=1; } || echo "  ok  blocks builder edits to tests/acceptance"
echo '{"tool_name":"Edit","tool_input":{"file_path":"tests/acceptance/INC-01/a.spec.ts"}}' | BLACKADDER_ROLE=acceptance-author bash hooks/scripts/guard.sh claude PreToolUse >/dev/null 2>&1 \
  && echo "  ok  allows acceptance author" || { echo "  BAD (acceptance author blocked)"; fail=1; }
echo '{"tool_name":"Bash","tool_input":{"command":"git push --force origin main"}}' | bash hooks/scripts/guard.sh claude PreToolUse >/dev/null 2>&1 \
  && { echo "  BAD (force push allowed)"; fail=1; } || echo "  ok  blocks force push"
echo '{"tool_name":"Bash","tool_input":{"command":"pnpm test"}}' | bash hooks/scripts/guard.sh claude PreToolUse >/dev/null 2>&1 \
  && echo "  ok  allows pnpm test" || { echo "  BAD (pnpm test blocked)"; fail=1; }
out=$(echo '{"command":"vercel --prod"}' | bash hooks/scripts/guard.sh cursor beforeShellExecution)
echo "$out" | jq -e '.permission == "deny"' >/dev/null && echo "  ok  cursor deny JSON" || { echo "  BAD cursor: $out"; fail=1; }

exit $fail
