---
name: design-system
description: Blackadder phase 2b. Produces the design system as code (tokens, Tailwind config, packages/ui components, a rendered /design-system reference route) plus screen specs and docs/blackadder/04-design-system.md. Runs in parallel with /architect; must be approved visually before any UI slice.
disable-model-invocation: true
---

# /design-system — a design system an agent can actually follow

A markdown style guide does not stop a builder from inventing new spacing per screen. The
deliverable is **code plus a reference page the human approves by looking at it**.

Input: `02-plan.md` (`status: accepted`). Read the personas, stories and screens implied
by the ACs. Do not wait for `/architect`; UX depends on flows and content, not on Postgres.

## Procedure

1. **Principles** (3–5), each with a "we do not …".
2. **Tokens** → `packages/ui/tokens.json` and the Tailwind config: color (light + dark, with a
   contrast-ratio table against each background; every text/background pair must pass
   WCAG 2.2 AA), type scale, spacing, radius, elevation, motion.
3. **Components** `C-001…` → `packages/ui/`: start from shadcn/Radix primitives and
   customize; do not invent from scratch. Each component documents variants, states
   (hover/focus/disabled/error/loading/empty), props, keyboard and ARIA behavior, do/don't.
4. **Reference route** `/design-system` in the app: renders every component in every state,
   both themes, three breakpoints. This is the oracle `/verify` screenshots against.
5. **Layout & responsive rules**: breakpoints, grid, page templates.
6. **Content & tone**: microcopy rules, error message style, empty states.
7. **Screen inventory** `S-001…` → `docs/blackadder/screens/S-NNN-<name>.md`: purpose,
   persona, entry points, data needed by `E-` id, components by `C-` id, states, ACs covered.
8. **Architecture impacts**: data or API the screens need that the plan did not anticipate.
   `/plan --reconcile` consumes this together with the architect's list.
9. Write `04-design-system.md` from `docs/blackadder/templates/design-system.md`. Take screenshots of
   `/design-system` at three breakpoints and attach them to the gate entry. Open **gate G2**
   (jointly with `/architect`) and stop.

## Standing duty

On every slice that touches UI, `/verify` runs a design-fidelity pass: screenshots at three
breakpoints, axe, and comparison against the reference route. Keep screenshot baselines in
`tests/acceptance/__screenshots__/` so drift is a diff, not an opinion.
