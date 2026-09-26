# One-time bootstrap (human)

Agents never hold production credentials, so a human does this once per product before
`/skeleton`. Tick every box; `/skeleton` refuses to start otherwise.

## Accounts and projects
- [ ] GitHub repo created, branch protection on `main` (PRs only, required checks: `ci`).
- [ ] GitHub Environments: `preview`, `staging`, `production` (`production` has required reviewers).
- [ ] Vercel project linked to the repo (Git integration does all deploys; no agent gets a Vercel token).
- [ ] Supabase projects: `<app>-staging` and `<app>-prod` (prod on Pro with PITR; spend cap on staging).
- [ ] Supabase preview branching enabled for PRs.
- [ ] Railway project — only if `03-architecture.md` ADR-0001 justifies it; enable PR environments + auto-sleep.
- [ ] Error tracking (Sentry or similar) projects for web (+ worker).
- [ ] Custom SMTP for Supabase Auth on staging + prod; OAuth redirect URIs for preview wildcard, staging, prod.
- [ ] Domain + DNS pointed at Vercel (prod).

## Secrets → GitHub Environments (never in the repo)
| Secret | preview | staging | production |
|---|---|---|---|
| `SUPABASE_ACCESS_TOKEN` (CLI) | — | ✓ | ✓ |
| `SUPABASE_DB_PASSWORD` | — | ✓ | ✓ |
| `SUPABASE_PROJECT_REF` | — | ✓ | ✓ |
| `RAILWAY_TOKEN` (if used) | — | ✓ | ✓ |
| `SENTRY_AUTH_TOKEN` | — | ✓ | ✓ |
| Agent keys (`ANTHROPIC_API_KEY` / `OPENAI_API_KEY` / `CURSOR_API_KEY` / Copilot) | repo-level, agent workflows only | | |

## Cost guards
- [ ] Vercel spend limit; Railway usage limit; Supabase spend caps (off only on prod, with alert).
- [ ] Nightly cleanup workflow deletes PR environments/branches for closed PRs.
- [ ] Per-slice agent budget set in `docs/blackadder/01-idea.md` front matter (`budget_usd_per_slice`).

When done, write `bootstrap: done <date>` into `.blackadder/gates.md` and run `/skeleton`.
