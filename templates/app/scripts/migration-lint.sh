#!/usr/bin/env bash
# Migration policy: forward-only, never edit a merged migration, destructive ops need an
# explicit justification comment, every CREATE TABLE enables RLS in the same file.
set -euo pipefail
base="${1:-origin/main}"
git fetch -q origin main 2>/dev/null || true
fail=0

# 1. merged migrations must not change
if git diff --name-status "$base"...HEAD -- supabase/migrations | grep -E '^(M|D)' ; then
  echo "::error::merged migrations were modified or deleted; add a new forward-only migration instead"
  fail=1
fi

# 2. new migrations
for f in $(git diff --name-only --diff-filter=A "$base"...HEAD -- 'supabase/migrations/*.sql'); do
  if grep -qiE '\b(drop (table|column|schema)|alter (table|column) .* type|set not null|truncate)\b' "$f" \
     && ! grep -q -- '-- allow-destructive:' "$f"; then
    echo "::error file=$f::destructive operation without '-- allow-destructive: <reason>' (use expand/contract)"
    fail=1
  fi
  tables=$(grep -ioE 'create table (if not exists )?"?[a-z_]+"?\."?[a-z_]+"?|create table (if not exists )?"?[a-z_]+"?' "$f" | awk '{print $NF}' | tr -d '"' | sed 's/.*\.//' || true)
  for t in $tables; do
    grep -qiE "alter table .*$t.* enable row level security" "$f" || {
      echo "::error file=$f::table $t created without 'enable row level security' in the same migration"; fail=1; }
  done
done
exit $fail
