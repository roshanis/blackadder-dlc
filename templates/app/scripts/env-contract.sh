#!/usr/bin/env bash
# Every process.env.X read in app code must be declared in .env.example.
set -euo pipefail
declared=$(grep -oE '^[A-Z0-9_]+' .env.example | sort -u)
used=$(grep -rhoE 'process\.env\.[A-Z0-9_]+' apps packages 2>/dev/null | sed 's/process\.env\.//' | sort -u)
missing=$(comm -13 <(echo "$declared") <(echo "$used") || true)
if [ -n "$missing" ]; then
  echo "::error::env vars read in code but not declared in .env.example:"; echo "$missing"; exit 1
fi
