---
name: change-request
description: Blackadder feedback router. Turns a finding from any tester, reviewer or production into a change request with an impact level L1-L4 and routes it to the lowest document that must change - without re-running the pipeline. Usage /change-request <finding or CR id>.
disable-model-invocation: true
---

# /change-request — feedback needs an address and a ladder

Feedback cannot "flow back to the ideator"; that context is gone. Classify, address by ID,
and change the lowest doc that must change.

## Procedure

1. Create `docs/blackadder/cr/CR-NNNN.md` from `docs/blackadder/templates/change-request.md`: raised by,
   observed at (phase / slice / evidence), symptom, root-cause hypothesis, affected doc IDs.
2. Classify the impact level:

| Level | Meaning | Route | Human |
|---|---|---|---|
| **L1** | code is wrong, docs are right | `bug` sub-issue on the slice → `/slice` fix round | no |
| **L2** | an AC was under-specified or a slice missed something | `/plan` patch version (changelog by AC id), one slice added or amended | soft gate |
| **L3** | architecture or design must change | `/architect` or `/design --sync`/`--system` writes an ADR + `DESIGN.md` minor version (with `design.md diff`) and an `Affects:` list; `/plan --reconcile` on affected slices only; merged slices get a follow-up slice, not a rewrite | **hard gate** |
| **L4** | the idea changes (scope, persona, a WON'T becomes a MUST) | `/ideate` conversation scoped to the CR; idea vN+1 with changelog; downstream re-evaluated by ID | **hard gate** |

3. Mark downstream items whose upstream IDs changed as `stale` in `slices.md` /
   `units.tsv`; do not rebuild anything whose IDs did not change.
4. Cap: max 2 upstream (L3/L4) revisions per release cycle before a human must intervene.
5. Record the decision (accept / defer to backlog milestone / reject with reason) in the CR
   file and `.blackadder/decisions.tsv`. Deferred CRs are listed in the release notes so the
   release is honest about what it does not do.

Until you have seen real change requests on a project, put a human on all of them
(`supervised` behaviour), regardless of the autonomy dial.
