#!/usr/bin/env bash
# Zero-token design check: Impeccable's deterministic anti-pattern detector (61 rules: overused
# fonts, purple→blue gradients, pure black/gray, gray text on colored backgrounds, cards nested in
# cards, bounce/elastic easing, dark glows, cramped padding, small touch targets, skipped heading
# levels, long lines). No skills installed, no LLM call — just `npx impeccable detect`.
#
# Exit code follows the design_review dial in docs/blackadder/01-idea.md:
#   annotate (default) → findings are printed as warnings, exit 0
#   block              → exit 2 on findings
set -uo pipefail
targets=("$@"); [ ${#targets[@]} -gt 0 ] || targets=(apps packages/ui)
existing=(); for t in "${targets[@]}"; do [ -e "$t" ] && existing+=("$t"); done
[ ${#existing[@]} -gt 0 ] || { echo "design-detect: nothing to scan"; exit 0; }

mode=$(grep -m1 -E '^design_review:' docs/blackadder/01-idea.md 2>/dev/null | awk '{print $2}')
out=$(mktemp); err=$(mktemp); trap 'rm -f "$out" "$err"' EXIT

npx --yes impeccable detect --json "${existing[@]}" >"$out" 2>"$err"; rc=$?
cat "$err"
case $rc in
  0) echo "design-detect: clean" ;;
  2) if [ "$mode" = "block" ]; then
       echo "::error::design-detect: anti-pattern findings (design_review: block)"; exit 2
     else
       echo "::warning::design-detect: anti-pattern findings (design_review: annotate — surfaced, not blocking)"
     fi ;;
  *) echo "::warning::design-detect: scanner could not run (exit $rc); not blocking" ;;
esac
[ -s "$out" ] && cp "$out" design-detect.json && echo "design-detect: report in design-detect.json"
exit 0
