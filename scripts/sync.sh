#!/usr/bin/env bash
# Sync the canonical, shared sources into each tool folder so every folder is a
# self-contained plugin root (plugin specs forbid paths that escape the plugin root, so
# these are committed copies, not symlinks).
#
#   skills/                  → claude-code/skills  cursor/skills  codex/skills  copilot/skills  muse/skills  openclaw/skills
#   hooks/blackadder-guard.sh → claude-code/hooks  cursor/hooks   codex/hooks   copilot/hooks   muse/hooks
#   (openclaw gets skills only: its guard is native TypeScript in openclaw/index.ts)
#
# Run after editing anything under skills/ or hooks/. `scripts/validate.sh --check-sync`
# fails if a copy has drifted.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
MODE="${1:-write}"   # write | check
rc=0

sync_dir() { # src dst
  if [ "$MODE" = check ]; then
    if ! diff -rq "$1" "$2" >/dev/null 2>&1; then echo "  DRIFT $2 (run scripts/sync.sh)"; rc=1; else echo "  ok    $2"; fi
  else
    rm -rf "$2"; mkdir -p "$(dirname "$2")"; cp -r "$1" "$2"; echo "  sync  $2"
  fi
}
sync_file() { # src dst
  if [ "$MODE" = check ]; then
    if ! cmp -s "$1" "$2"; then echo "  DRIFT $2 (run scripts/sync.sh)"; rc=1; else echo "  ok    $2"; fi
  else
    mkdir -p "$(dirname "$2")"; cp "$1" "$2"; chmod +x "$2"; echo "  sync  $2"
  fi
}

for tool in claude-code cursor codex copilot muse; do
  sync_dir  skills                    "$tool/skills"
  sync_file hooks/blackadder-guard.sh "$tool/hooks/blackadder-guard.sh"
done
sync_dir skills openclaw/skills
exit $rc
