---
id: DS
version: 1
status: draft
supersedes: null
built_from: { idea: <sha>, plan: <sha> }
owner: design-system
approved_by: []
approved_at: null
reference_route: /design-system
changes_from_previous: null
---

# <Product> — Design system

The deliverable is code: `packages/ui/tokens.json`, the Tailwind config, `packages/ui/`
components, and the `/design-system` reference route. This document indexes them.

## 1. Principles (3–5, each with a "we do not")

## 2. Tokens
Color (light + dark) with contrast table vs each background (all pairs ≥ AA); type scale;
spacing; radius; elevation; motion. Source: `packages/ui/tokens.json`.

## 3. Component inventory
| id | component | variants | states | a11y notes |
|---|---|---|---|---|
| C-001 | Button | primary/secondary/ghost/destructive | hover/focus/disabled/loading | role, keyboard |

## 4. Layout and responsive rules
Breakpoints, grid, page templates.

## 5. Content and tone
Microcopy, error messages, empty states.

## 6. Accessibility standard
WCAG 2.2 AA; per-component checklist; axe in CI.

## 7. Screen inventory
| id | screen | persona | data (E-) | components (C-) | ACs |
|---|---|---|---|---|---|
| S-001 | Sign in | P-001 | — | C-001, C-004 | AC-001 |
Specs in `docs/blackadder/screens/S-NNN-*.md`.

## 8. Architecture impacts (consumed by `/plan --reconcile`)

## 9. Changelog
- v1 — initial
