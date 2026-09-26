#!/usr/bin/env bash
# Install the Blackadder DLC into an application repository for one or more harnesses.
#
#   scripts/install.sh <claude|cursor|codex|copilot|all> [target-dir] [--app-template] [--workflows <gh-aw|claude|codex|cursor|all>]
#
# What it does (idempotent; never overwrites a file you already have unless it is ours):
#   common   AGENTS.md (created, or a pointer appended), docs/blackadder/{templates,ASSUMPTIONS.md,lessons.md,gates.md},
#            .blackadder/{units,ledger,decisions}.tsv, docs/bootstrap.md
#   claude   .claude/skills, .claude/agents, .claude/hooks/blackadder-guard.sh, .claude/settings.json hooks, CLAUDE.md
#   cursor   .cursor/skills, .cursor/agents, .cursor/rules/blackadder.mdc, .cursor/hooks.json, .cursor/hooks/blackadder-guard.sh
#   codex    .agents/skills, .codex/agents/*.toml, .codex/hooks.json, .codex/hooks/blackadder-guard.sh, .codex/config.toml
#   copilot  .github/skills, .github/agents/*.agent.md, .github/hooks/blackadder.json + guard, .github/copilot-instructions.md
#   --app-template   templates/app/* (CI, promote/rollback, lint scripts, seeds, migration 0001, PR/issue templates)
#   --workflows      templates/workflows/* into .github/workflows/
#
# Prefer the plugin install where the harness supports it (see README); use this for
# project-local installs, CI runners, or harnesses without marketplace access.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HARNESS="${1:-}"; shift || true
TARGET="."
APP_TEMPLATE=0
WORKFLOWS=""
while [ $# -gt 0 ]; do
  case "$1" in
    --app-template) APP_TEMPLATE=1 ;;
    --workflows) WORKFLOWS="$2"; shift ;;
    -*) echo "unknown flag $1" >&2; exit 2 ;;
    *) TARGET="$1" ;;
  esac
  shift
done
[ -n "$HARNESS" ] || { sed -n '2,20p' "$0"; exit 2; }
TARGET="$(cd "$TARGET" && pwd)"

log() { printf '  %s\n' "$*"; }
copy_if_missing() { # src dst
  if [ -e "$2" ]; then log "keep   $2"; else mkdir -p "$(dirname "$2")"; cp "$1" "$2"; log "create $2"; fi
}
copy_ours() { # src dst  (always refresh files we own)
  mkdir -p "$(dirname "$2")"; cp "$1" "$2"; log "write  $2"
}
copy_skills() { # dstdir
  mkdir -p "$1"
  for d in "$SRC"/skills/*/; do
    n="$(basename "$d")"; mkdir -p "$1/$n"; cp -r "$d"/. "$1/$n/"; done
  log "write  $1/{$(ls "$SRC/skills" | tr '\n' ',' | sed 's/,$//')}"
}

install_common() {
  echo "common →"
  if [ -f "$TARGET/AGENTS.md" ]; then
    grep -q 'Blackadder DLC' "$TARGET/AGENTS.md" || {
      printf '\n\n<!-- blackadder -->\n%s\n' "$(cat "$SRC/AGENTS.md")" >> "$TARGET/AGENTS.md"; log "append $TARGET/AGENTS.md"; }
  else
    copy_ours "$SRC/AGENTS.md" "$TARGET/AGENTS.md"
  fi
  mkdir -p "$TARGET/docs/blackadder/templates" "$TARGET/.blackadder"
  for f in "$SRC"/templates/docs/*.md; do copy_ours "$f" "$TARGET/docs/blackadder/templates/$(basename "$f")"; done
  copy_if_missing "$SRC/templates/docs/ASSUMPTIONS.md" "$TARGET/docs/blackadder/ASSUMPTIONS.md"
  copy_if_missing "$SRC/templates/docs/lessons.md"     "$TARGET/docs/blackadder/lessons.md"
  copy_if_missing "$SRC/templates/docs/gates.md"       "$TARGET/.blackadder/gates.md"
  copy_if_missing "$SRC/templates/docs/bootstrap.md"   "$TARGET/docs/bootstrap.md"
  for f in units ledger decisions; do copy_if_missing "$SRC/templates/app/.blackadder/$f.tsv" "$TARGET/.blackadder/$f.tsv"; done
}

install_claude() {
  echo "claude →"
  copy_skills "$TARGET/.claude/skills"
  for f in "$SRC"/agents/*.md; do copy_ours "$f" "$TARGET/.claude/agents/$(basename "$f")"; done
  copy_ours "$SRC/hooks/scripts/guard.sh" "$TARGET/.claude/hooks/blackadder-guard.sh"; chmod +x "$TARGET/.claude/hooks/blackadder-guard.sh"
  copy_if_missing "$SRC/CLAUDE.md" "$TARGET/CLAUDE.md"
  local settings="$TARGET/.claude/settings.json"
  local hook='{"type":"command","command":"bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/blackadder-guard.sh\" claude PreToolUse","timeout":10,"statusMessage":"Blackadder guard"}'
  mkdir -p "$TARGET/.claude"; [ -f "$settings" ] || echo '{}' > "$settings"
  jq --argjson h "$hook" '
    .hooks.PreToolUse = ((.hooks.PreToolUse // []) | map(select((.hooks[0].command // "") | test("blackadder-guard") | not)))
      + [{"matcher":"Edit|Write|MultiEdit|NotebookEdit","hooks":[$h]},{"matcher":"Bash","hooks":[$h]}]' \
    "$settings" > "$settings.tmp" && mv "$settings.tmp" "$settings"
  log "merge  $settings (hooks.PreToolUse)"
}

install_cursor() {
  echo "cursor →"
  copy_skills "$TARGET/.cursor/skills"
  for f in "$SRC"/harness/cursor/agents/*.md; do copy_ours "$f" "$TARGET/.cursor/agents/$(basename "$f")"; done
  copy_ours "$SRC/harness/cursor/rules/blackadder.mdc" "$TARGET/.cursor/rules/blackadder.mdc"
  copy_ours "$SRC/hooks/scripts/guard.sh" "$TARGET/.cursor/hooks/blackadder-guard.sh"; chmod +x "$TARGET/.cursor/hooks/blackadder-guard.sh"
  if [ -f "$TARGET/.cursor/hooks.json" ] && ! grep -q blackadder-guard "$TARGET/.cursor/hooks.json"; then
    copy_ours "$SRC/harness/cursor/hooks.json" "$TARGET/.cursor/hooks.blackadder.json"
    log "NOTE   .cursor/hooks.json exists — merge .cursor/hooks.blackadder.json into it by hand"
  else
    copy_ours "$SRC/harness/cursor/hooks.json" "$TARGET/.cursor/hooks.json"
  fi
}

install_codex() {
  echo "codex →"
  copy_skills "$TARGET/.agents/skills"
  for f in "$SRC"/harness/codex/agents/*.toml; do copy_ours "$f" "$TARGET/.codex/agents/$(basename "$f")"; done
  copy_ours "$SRC/hooks/scripts/guard.sh" "$TARGET/.codex/hooks/blackadder-guard.sh"; chmod +x "$TARGET/.codex/hooks/blackadder-guard.sh"
  if [ -f "$TARGET/.codex/hooks.json" ] && ! grep -q blackadder-guard "$TARGET/.codex/hooks.json"; then
    copy_ours "$SRC/harness/codex/hooks.json" "$TARGET/.codex/hooks.blackadder.json"
    log "NOTE   .codex/hooks.json exists — merge .codex/hooks.blackadder.json into it by hand"
  else
    copy_ours "$SRC/harness/codex/hooks.json" "$TARGET/.codex/hooks.json"
  fi
  copy_if_missing "$SRC/harness/codex/config.toml.example" "$TARGET/.codex/config.toml"
}

install_copilot() {
  echo "copilot →"
  copy_skills "$TARGET/.github/skills"
  for f in "$SRC"/com.github.copilot/agents/*.agent.md; do copy_ours "$f" "$TARGET/.github/agents/$(basename "$f")"; done
  copy_ours "$SRC/hooks/scripts/guard.sh" "$TARGET/.github/hooks/blackadder-guard.sh"; chmod +x "$TARGET/.github/hooks/blackadder-guard.sh"
  copy_ours "$SRC/com.github.copilot/hooks/hooks.json" "$TARGET/.github/hooks/blackadder.json"
  copy_if_missing "$SRC/harness/copilot/copilot-instructions.md" "$TARGET/.github/copilot-instructions.md"
}

install_app_template() {
  echo "app template →"
  ( cd "$SRC/templates/app" && find . -type f ! -path './.blackadder/*' | while read -r f; do
      copy_if_missing "$SRC/templates/app/$f" "$TARGET/${f#./}"; done )
  chmod +x "$TARGET"/scripts/*.sh 2>/dev/null || true
}

install_workflows() {
  echo "workflows ($1) →"
  mkdir -p "$TARGET/.github/workflows"
  case "$1" in
    gh-aw)  copy_if_missing "$SRC/templates/workflows/blackadder.md" "$TARGET/.github/workflows/blackadder.md"
            log "NOTE   run: gh extension install github/gh-aw && gh aw compile" ;;
    claude) copy_if_missing "$SRC/templates/workflows/claude.yml" "$TARGET/.github/workflows/blackadder-claude.yml" ;;
    codex)  copy_if_missing "$SRC/templates/workflows/codex.yml"  "$TARGET/.github/workflows/blackadder-codex.yml" ;;
    cursor) copy_if_missing "$SRC/templates/workflows/cursor.yml" "$TARGET/.github/workflows/blackadder-cursor.yml" ;;
    all)    for w in gh-aw claude codex cursor; do install_workflows "$w"; done ;;
    *) echo "unknown workflow set $1" >&2; exit 2 ;;
  esac
}

install_common
case "$HARNESS" in
  claude)  install_claude ;;
  cursor)  install_cursor ;;
  codex)   install_codex ;;
  copilot) install_copilot ;;
  all)     install_claude; install_cursor; install_codex; install_copilot ;;
  *) echo "unknown harness: $HARNESS (claude|cursor|codex|copilot|all)" >&2; exit 2 ;;
esac
[ "$APP_TEMPLATE" = 1 ] && install_app_template
[ -n "$WORKFLOWS" ] && install_workflows "$WORKFLOWS"
echo "done. Next: open the repo in your harness and run /blackadder"
