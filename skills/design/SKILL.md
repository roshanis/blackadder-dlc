---
name: design
description: Blackadder phase 2b, the design track. Produces rendered direction boards, DESIGN.md (Google's open design-system format), packages/ui + the /design-system reference route, and per-screen prototypes that become visual baselines. Syncs from Claude Design, Figma or Stitch. Usage /design --directions | --system | --screen S-NNN | --sync <source>.
disable-model-invocation: true
---

# /design — design is code plus a visual oracle

Agents cannot see, taste is not in the docs, and per-screen decisions drift. So every output
of this track is **code or an image**, decided once, enforced by lint and diff, with human
taste applied at three moments: pick a direction, approve the reference route, approve the
first screen prototypes. After that the human only reviews diffs.

Input: `02-plan.md` (`status: accepted`). Do not wait for `/architect`; UX depends on flows
and content, not on Postgres. Run in parallel; both feed `/plan --reconcile`.

Read `docs/blackadder/01-idea.md` front matter: `design_source` (any of `claude-design`,
`figma`, `stitch`, `agent`) and `design_review` (`annotate` | `block`).

## `/design --directions` — three rendered boards, human picks

1. Gather references: the idea doc's brand/constraints, any URL or product the human named,
   any uploaded brand asset. Ask for ONE reference if none exists (with a default: "a calm
   Linear/Notion-like product surface").
2. Produce **three distinct** self-contained HTML boards at
   `docs/blackadder/design/directions/{a,b,c}.html` (inline CSS, both themes, no build):
   a hero, a form, a data table, a card grid, a nav, an empty state, primary/secondary buttons.
   Each board states its one-sentence thesis and what it deliberately is *not*. Every board
   must pass `npx impeccable detect docs/blackadder/design/directions/<x>.html` (deterministic,
   zero tokens): no default typefaces (Inter/Roboto/Arial/system), no purple→blue gradients,
   no glassmorphism by default, no pure black or untinted gray, no gray text on colored
   backgrounds, no nested cards, no bounce easing. Distinct means different type, color
   temperature, density and shape language — not three shades of the same board.
   - With `stitch`: generate the three boards in Stitch (MCP `generate screen` per direction)
     and export as HTML into the same paths.
   - With `claude-design`: in Claude Code run `/design` (Claude Design) to create the three
     directions as prototypes; export standalone HTML into the same paths.
3. Screenshot each board at 1440 and 390 px; open gate **G2a** with the six images and the
   question "Which direction, and what would you change?". Stop.

## `/design --system` — DESIGN.md, tokens, components, reference route

1. **`DESIGN.md` at the repo root**, from `docs/blackadder/templates/DESIGN.md`, following
   the open spec (YAML front matter: `name`, `colors`, `typography`, `spacing`, `rounded`,
   `components` with `{token.refs}`; then exactly these h2 sections in order: Overview,
   Colors, Typography, Layout, Elevation & Depth, Shapes, Components, Do's and Don'ts).
   - `figma`: read variables, text styles and component variants through the Figma MCP
     server (`get_variable_defs`, `get_design_context` on the design-system page) and write
     them as tokens. Never hand-copy hex codes from screenshots.
   - `stitch`: import the exported `DESIGN.md` from the Stitch project and reconcile.
   - `claude-design`: in Claude Code run `/design-sync` to pull the Claude Design system's
     tokens and components into the repo, then write `DESIGN.md` from them so the other
     three harnesses see the same system.
   - `agent`: derive from the chosen direction board.
2. `npx @google/design.md lint DESIGN.md` must pass (broken refs, missing primaries, WCAG
   contrast, section order), and so must `bash scripts/design-lint.sh` (no default typeface,
   no pure black). Fix before continuing.
3. **Tokens are generated, never hand-written**: `npx @google/design.md export DESIGN.md
   --format tailwind > packages/ui/tailwind.tokens.css` (or `--format dtcg` →
   `packages/ui/tokens.json`). The Tailwind config imports only that file.
4. **Components** `packages/ui/`: start from shadcn/Radix primitives, restyle only from the
   exported tokens. Every component in `DESIGN.md`'s `components:` map exists in code with
   the same name and its states (hover/focus/disabled/loading/error/empty). Each gets a11y
   notes (role, keyboard, ARIA). With `figma`, set up Code Connect so each Figma component
   maps to its `packages/ui` export; with `claude-design`, the synced components are the base.
5. **Reference route** `/design-system` in `apps/web`: renders every component in every
   state, both themes, at three breakpoints, plus the type scale, color roles with contrast
   ratios, spacing scale, radii, elevation. This is the oracle `/verify` diffs against.
6. Record screenshot baselines: `pnpm test:acceptance --update-snapshots
   tests/acceptance/visual` for the reference route (pixel-exact lane).
7. Write `docs/blackadder/04-design-system.md` (index: principles, screen inventory,
   architecture impacts) and open gate **G2** with the reference-route screenshots. The
   human approves by *looking*. Stop.

## `/design --screen S-NNN` — the prototype is the spec

For each screen in the plan's inventory (`S-001…`), before its slice is built:

1. Write `docs/blackadder/screens/S-NNN-<name>.md`: purpose, persona, entry points, data by
   `E-` id, components by name from `DESIGN.md`, states, ACs covered, copy (real words, no
   lorem ipsum).
2. Build a static prototype route `apps/web/app/proto/S-NNN/page.tsx` with fake data, using
   **only** `packages/ui` components and tokens. With `figma`, implement from the frame via
   MCP (`get_design_context`, `get_screenshot`) and link the node URL in the spec; with
   `stitch`/`claude-design`, generate the screen there against `DESIGN.md`, export HTML, and
   port it onto `packages/ui` components (an exported HTML file is a reference, not code we ship).
3. Add the screen to `tests/acceptance/visual/visual.manifest.ts` and record baselines at
   390 / 834 / 1440 × light / dark (perceptual lane, `maxDiffPixelRatio` per manifest).
4. Attach the six screenshots to a soft gate for the first three screens (human approves or
   redirects); later screens auto-proceed under `balanced`/`autopilot` and the human sees
   diffs in PRs.

The slice that implements `S-NNN` must match the prototype within the manifest threshold;
its PR declares any deviation under "Design delta". Undeclared deviation is a finding.

## `/design --sync <claude-design|figma|stitch>`

Re-pull the source of truth after a designer changed it: refresh `DESIGN.md`, re-export
tokens, run `npx @google/design.md diff` against the previous version, list affected screens
and components, and open a change request (L3) if any token or component changed. Baselines
are re-recorded only inside that CR's PR.

## Rules

- No raw color/size values in `apps/`; only tokens and `packages/ui`. `scripts/design-lint.sh`
  and CI enforce it.
- A design change is a `DESIGN.md` PR (with `design.md diff` in the body), never an inline
  style.
- The design reviewer (`blackadder-design-reviewer`) applies
  `docs/blackadder/templates/design-review-rubric.md` on every UI slice and at release;
  `design_review: annotate` makes all its findings `minor`, `block` lets rubric categories
  marked blocking be `major`.
- Accessibility is structural: contrast in `DESIGN.md` (linted), keyboard/ARIA per component,
  axe in the visual harness.
- Deterministic first: `scripts/design-lint.sh` and `scripts/design-detect.sh` (Impeccable's
  61-rule detector via `npx impeccable detect`, no skills installed) run before any agent
  looks at a screenshot.
- Not installed, by decision: skill packs whose phases overlap this track (the Impeccable
  skill set, mattpocock/skills). Only their deterministic tools are used.
