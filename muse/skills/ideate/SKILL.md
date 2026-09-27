---
name: ideate
description: Blackadder phase 0. Interactive ideation with the requester that produces docs/blackadder/01-idea.md (problem, users, scope, non-goals, build-vs-buy, kill criteria). Use for a new product or a new feature on an existing one.
disable-model-invocation: true
---

# /ideate — from a conversation to an Idea document

This is the one genuinely conversational phase. Ask real questions, one at a time, and push
back. The output is a document other agents will treat as requirements, so half-thoughts must
not leak into it.

## Procedure

1. **Open** with: what problem, for whom, and what happens today without it. Do not accept a
   solution description as a problem statement; ask "what would the user stop doing?"
2. **Challenge before you write.** For every commodity capability the idea implies (auth,
   payments, email, file storage, search, analytics, notifications) ask: buy/managed, or build?
   Default is **buy**. Record the table. Ask: "Is there an existing product or a spreadsheet
   that already does this?" and "What evidence would make us kill this?"
3. **Scope** as MUST / SHOULD / WON'T. Require at least three explicit WON'Ts.
4. **Constraints**: stack mandate (default Next.js on Vercel + Supabase; Railway only for
   workers/long-running/non-Node), budget, timeline, compliance (PII, jurisdictions).
5. **Success metrics** with numbers. Refuse "works well".
6. **Assumptions**: everything you decided on the requester's behalf goes into
   `docs/blackadder/ASSUMPTIONS.md` with confidence and reversibility.
7. **Write** `docs/blackadder/01-idea.md` from `docs/blackadder/templates/idea.md` (installed by
   `scripts/install.sh`; fall back to the plugin's `templates/docs/`). Fill every section; stable IDs `P-`, `J-`,
   `R-`, `Q-`.
8. **Set the dials** in front matter after asking: `autonomy` (supervised / balanced /
   autopilot), `design_source` (which of claude-design / figma / stitch / agent the team
   will use), `design_review` (`annotate` by default; `block` once calibrated), and
   `budget_usd_per_slice`.
9. **Open gate G0** in `.blackadder/gates.md` (see `/blackadder` for the shape). Also open a
   GitHub issue titled `[Epic] <name>` if a GitHub tool is available, with a 10-line summary,
   the 3–5 decisions made on the human's behalf, and the label `blackadder:gate`.
10. Stop. Do not start `/plan` until G0 is approved.

## Rules

- One open question at a time; every question carries a proposed default.
- Do not write user stories or architecture here. That is `/plan` and `/architect`.
- Keep the doc under ~2 pages. Link the transcript under `docs/blackadder/transcripts/`
  if the harness kept one; downstream agents read only the doc.
- For a brownfield feature, scope the whole doc to the feature and reference the existing
  `03-architecture.md`.
