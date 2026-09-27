#!/usr/bin/env bash
# Design is code: app code may only use DESIGN.md tokens (via the generated Tailwind theme)
# and packages/ui components. Also a small, high-precision anti-slop subset (the full 61-rule
# deterministic pass is scripts/design-detect.sh). packages/ui and generated token files are exempt.
set -euo pipefail
fail=0

# --- DESIGN.md itself -------------------------------------------------------------------------
if [ -f DESIGN.md ]; then
  if grep -nE '^\s*fontFamily:\s*"?(Inter|Roboto|Arial|Helvetica( Neue)?|system-ui|-apple-system|Segoe UI)\b' DESIGN.md; then
    echo "::error::DESIGN.md uses an overused/default typeface — choose a distinctive one in /design --directions"; fail=1
  fi
  if grep -nE '"#000(000)?"' DESIGN.md; then
    echo "::error::DESIGN.md uses pure black — tint it toward the palette"; fail=1
  fi
fi

# --- app code ---------------------------------------------------------------------------------
files=$(git ls-files 'apps/**/*.tsx' 'apps/**/*.ts' 'apps/**/*.css' 2>/dev/null | grep -v -E '(\.generated\.|tokens|/proto/__ref/)' || true)
if [ -n "$files" ]; then
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
  # anti-slop tells
  if grep -nE 'from-(purple|violet|indigo)-[0-9]+[^"]*to-(blue|sky|cyan)-[0-9]+' $files ; then
    echo "::error::purple→blue gradient — the most recognisable AI-slop tell"; fail=1
  fi
  if grep -nE 'cubic-bezier\([^)]*(,\s*-?1\.[0-9]+|,\s*-0?\.[0-9]+)' $files ; then
    echo "::error::overshoot/bounce easing — use a plain ease-out ≤ 200 ms"; fail=1
  fi
fi
exit $fail
