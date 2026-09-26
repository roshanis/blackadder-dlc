---
name: verify
description: Blackadder verifier procedure. Run in a FRESH context against a slice PR - executes acceptance + regression suites on the preview URL, does bounded adversarial checks, screenshot/axe pass for UI, checks architecture and design deltas, and records a SHA-keyed verdict in .blackadder/ledger.tsv. Never modifies application code.
---

# /verify — a verdict, not feedback

You did not write this code. You must not read the builder's transcript. Inputs: the slice
row and its ACs, the pinned docs, the PR diff, the preview URL and seeded credentials.

## Procedure

1. **Baseline**: CI must be green on the PR head SHA. If not, verdict `blocked: ci-red` and stop.
2. **Test-diff review first**: did the PR touch `tests/acceptance/**`? Any test deleted,
   skipped, `.only`, snapshot mass-updated, assertion weakened? Any of these → `fail` with
   type `test_quality`, severity `blocker`, regardless of anything else.
3. **Run** on the preview URL: `tests/acceptance/<INC-id>/`, then the whole
   `tests/acceptance/` regression suite. A regression is always a blocker.
4. **Adversarial by category** (only for surfaces this slice touches; no style findings ever):
   unauthenticated access, cross-tenant access with seeded user B, duplicate submit /
   idempotency, stale update (version conflict), malformed input, empty and error states.
5. **Architecture conformance**: migration present and forward-only; RLS policies on every
   new table; no service-role key reachable from client code; env vars declared in
   `.env.example`; module boundaries from `03-architecture.md` respected; indexes for new
   list queries (`EXPLAIN` if in doubt).
6. **Design fidelity** (UI slices): screenshots at three breakpoints in both themes, axe run,
   compare against the `/design-system` reference route and screenshot baselines. Deviations
   not declared in the PR's "Design delta" are `minor` findings.
7. **Verdict**: `pass` (no blocker/major), `pass-with-issues` (minor only), or `fail`.
   Flaky E2E: retry once; a test that flips is filed as `flaky`/`minor`, not functional.

## Output — exactly this, as a PR review (approve / request changes) and in the ledger

```json
{
  "slice": "INC-03", "round": 2, "sha": "abc1234",
  "verdict": "fail",
  "env": {"web": "https://…vercel.app", "db_branch": "pr-42"},
  "ac_coverage": {"AC-3.1": "verified", "AC-3.2": "failed", "AC-3.3": "not_testable: reason"},
  "regression": {"total": 41, "passed": 40, "failed": 1, "flaky": 0},
  "findings": [{
    "id": "INC-03-F2", "ac_ref": "AC-3.2",
    "severity": "blocker|major|minor", "type": "functional|regression|security|data|ux|perf|test_quality|flaky",
    "title": "Duplicate POST /projects creates two rows",
    "steps": ["login as alice@t1", "POST /projects twice with same Idempotency-Key", "GET /projects"],
    "expected": "one row", "actual": "two rows",
    "evidence": "tests/acceptance/INC-03/create.spec.ts::idempotent-create",
    "suspected_location": "apps/web/app/api/projects/route.ts:41",
    "repeat_of": "INC-03-F2@round1"
  }],
  "test_diff_review": {"tests_deleted": 0, "tests_skipped": 0, "snapshots_updated": 0},
  "notes_for_human": "optional, one paragraph"
}
```

Append to `.blackadder/ledger.tsv`: `sha  slice  round  verdict  blockers  majors  minors  date`.
A new head SHA voids this verdict; re-run.

Severity: `blocker` = an AC fails, a regression, a security or test-quality problem;
`major` = AC passes but adversarial check found a data/authz gap; `minor` = works but
violates the design system or an edge case. There is no `nit`; do not file style.
