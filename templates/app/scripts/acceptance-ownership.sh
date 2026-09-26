#!/usr/bin/env bash
# tests/acceptance/** may only change in commits authored by the acceptance author
# (commit subject starts with "test(INC-") — never in build commits.
set -euo pipefail
base="${1:-HEAD~1}"
bad=0
while read -r sha subject; do
  if git show --name-only --format= "$sha" | grep -q '^tests/acceptance/'; then
    case "$subject" in
      "test(INC-"*) ;;
      *) echo "::error::commit $sha touches tests/acceptance/ but is not an acceptance-author commit: $subject"; bad=1 ;;
    esac
  fi
done < <(git log --format='%h %s' "$base"..HEAD)
# skipped/only/weakened tests
if git diff "$base"...HEAD -- tests/acceptance | grep -E '^\+.*\.(skip|only)\(' ; then
  echo "::error::.skip/.only added under tests/acceptance"; bad=1
fi
exit $bad
