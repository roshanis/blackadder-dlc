---
name: blackadder
description: Blackadder DLC dispatcher. Use when the user asks "where are we", "what's next", "run the pipeline", or names a phase without a skill. Reads project state and routes to the right phase skill.
---

# /blackadder — where are we, what's next

You are the dispatcher for the Blackadder Development Life Cycle. You never do phase work
yourself; you determine the phase, check the gate, and hand off to exactly one phase skill.

## 1. Read state (do not guess)

Check, in order:

1. `docs/blackadder/01-idea.md` … `04-design-system.md` — exist? front matter `status:`?
2. `docs/blackadder/slices.md` — exists? which slice rows are `done | building | verifying | stale | blocked`?
3. `.blackadder/units.tsv`, `.blackadder/ledger.tsv`, `.blackadder/gates.md` — open gates? unresolved questions?
4. `git log --oneline -20` and open PRs (if a `gh`/GitHub tool is available) — anything mid-flight?

If `docs/blackadder/` does not exist, this is a fresh project: route to `/ideate`.
If the repo already has code but no `docs/blackadder/`, this is **brownfield**: run `/architect --onboard`
first (reverse-engineer `03-architecture.md` from the code, marking every statement
`observed` or `inferred`), then `/ideate` scoped to the feature.

## 2. Determine the phase

| Condition | Phase | Next skill |
|---|---|---|
| no idea doc, or `status: draft` | Ideate | `/ideate` |
| idea `accepted`, no plan or plan `draft` | Plan | `/plan` |
| plan `accepted`, no architecture or design system | Architect + Design | `/architect` and `/design-system` (parallel is fine) |
| both `accepted`, slice `INC-00` not done | Skeleton | `/skeleton` |
| `INC-00` done, any slice not done | Build loop | `/slice <next ready id>` |
| all slices done, no release verdict | Release | `/release` |
| release verdict `pass`, not promoted | Deploy | `/release --promote` (hard gate) |
| an open change request | CR routing | `/change-request <id>` |

A phase whose gate is **hard** and not yet approved by a human is *not* passed. Do not
proceed past it. Post the gate question (see below) and stop.

## 3. Report, then hand off

Print a status block of at most 15 lines:

```
Blackadder status
Phase: build   Slice: INC-03 (round 2/3)   Open gates: none
Docs pinned: idea@a1b2c3 plan@d4e5f6 arch@0a1b2c design@7f8e9d
Slices: 2 done · 1 verifying · 4 ready · 0 stale
Next: /slice INC-03
```

Then invoke the next skill, or if a human gate is open, write the gate entry to
`.blackadder/gates.md` in this exact shape and stop:

```
## G1 — Plan + slice ladder   (opened <date>, by <skill>)
Question: Approve docs/blackadder/02-plan.md and slices.md as written?
Default if you reply `go`: proceed to /architect and /design-system.
Why it matters: everything downstream is built from this ladder.
Reply: `go`, `go --with-notes: …`, or `redo: <reasons>`.
```

## Autonomy dial

`docs/blackadder/01-idea.md` front matter has `autonomy: supervised | balanced | autopilot`.

- `supervised`: every slice merge is a human gate.
- `balanced` (default): slices auto-proceed on verifier `pass` + CI green; the four hard gates remain.
- `autopilot`: same, and soft-gate questions auto-resolve to their defaults after being logged.

Stop conditions override every level: touching auth, payments, PII schema, data deletion,
public API changes, adding a paid service, or any production action always escalates.
