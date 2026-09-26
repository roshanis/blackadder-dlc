#!/usr/bin/env bash
# Fail on dependencies whose license is outside the allowlist.
set -euo pipefail
allow='MIT|Apache-2.0|BSD-2-Clause|BSD-3-Clause|ISC|0BSD|CC0-1.0|Unlicense|MPL-2.0'
pnpm licenses list --json 2>/dev/null \
  | jq -r 'to_entries[] | select(.key | test("^('"$allow"')$") | not) | .key as $l | .value[] | "\(.name)@\(.versions[0]) \($l)"' \
  | tee /tmp/bad-licenses.txt
test ! -s /tmp/bad-licenses.txt || { echo "::error::dependencies outside the license allowlist"; exit 1; }
