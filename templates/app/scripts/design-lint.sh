#!/usr/bin/env bash
# Design is code: app code may only use DESIGN.md tokens (via the generated Tailwind theme)
# and packages/ui components. Flags raw colors, arbitrary Tailwind values and raw px sizes
# in apps/**. packages/ui and generated token files are exempt.
set -euo pipefail
fail=0
files=$(git ls-files 'apps/**/*.tsx' 'apps/**/*.ts' 'apps/**/*.css' 2>/dev/null | grep -v -E '(\.generated\.|tokens|/proto/__ref/)' || true)
[ -n "$files" ] || exit 0

# raw hex colors
if grep -nE '#[0-9a-fA-F]{3}([0-9a-fA-F]{3})?\b' $files | grep -vE '(//|/\*).*#[0-9a-fA-F]' ; then
  echo "::error::raw hex colors in app code — use DESIGN.md tokens"; fail=1
fi
# Tailwind arbitrary values: bg-[#..], p-[13px], text-[15px], w-[123px] …
if grep -nE '\b(bg|text|p[xytblr]?|m[xytblr]?|gap|w|h|rounded|shadow|border)-\[[^]]+\]' $files ; then
  echo "::error::arbitrary Tailwind values in app code — add a token to DESIGN.md instead"; fail=1
fi
# inline style sizes/colors
if grep -nE 'style=\{\{[^}]*(color|fontSize|padding|margin|borderRadius)' $files ; then
  echo "::error::inline style with color/size in app code"; fail=1
fi
# UI primitives must come from packages/ui
if grep -nE "from ['\"]@radix-ui/|from ['\"]@/components/ui/" $files ; then
  echo "::error::import UI primitives from packages/ui, not directly"; fail=1
fi
exit $fail
