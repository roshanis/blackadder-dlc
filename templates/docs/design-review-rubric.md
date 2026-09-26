# Design review rubric

Applied by `blackadder-design-reviewer` on every UI slice (in `/verify`) and on every journey
at `/release`. Evidence for every finding is an image (screenshot with the region named) or a
diff, never an opinion. No style or naming findings outside these categories.

`design_review` in `docs/blackadder/01-idea.md` decides severity:
`annotate` → every finding is `minor` (surfaced, never blocks).
`block` → categories marked **B** may be `major` (blocks the slice); others stay `minor`.

| # | Category | Check | Blocking in `block` mode |
|---|---|---|---|
| 1 | Hierarchy | One `button-primary` per view; heading levels follow the type scale; the primary task is findable in 5 s at 390 px | — |
| 2 | Rhythm | Spacing only from `DESIGN.md` scale; elements align to the grid; consistent gutters; no orphan margins | — |
| 3 | Tokens | No colors, sizes, radii or fonts outside `DESIGN.md`; contrast of every text/background pair ≥ AA (measure, don't estimate) | **B** |
| 4 | States | Loading, empty, error and success states exist and use the system's `empty-state`/status roles; disabled controls explain why | **B** |
| 5 | Responsive | 390 / 834 / 1440: no horizontal overflow, no clipped text, touch targets ≥ 44 px, forms single-column below 834 | — |
| 6 | Copy | Real copy, sentence case, verbs on buttons, actionable errors, tone per `DESIGN.md` Overview; no lorem ipsum | — |
| 7 | Fidelity | Perceptual diff vs the screen's prototype baseline within the manifest threshold; components pixel-exact vs the `/design-system` route; deviations declared under "Design delta" in the PR | **B** |
| 8 | Accessibility | axe: zero serious/critical; keyboard order matches visual order; focus visible; every control labelled; `prefers-reduced-motion` respected | **B** |

## Output

One finding per violation, in the `/verify` JSON shape, `type: "ux"` (or `"security"` for
category 8 when it exposes data), `ac_ref` when an AC covers the screen, `evidence` = the
screenshot path and region, `suspected_location` = the component or route. Summarise as a
table of category → pass/fail per breakpoint × theme.

## Token discipline

Images cost more than text. Order of inspection: (1) the harness summary and axe/overflow
results, (2) diff images for lanes with a non-zero diff, (3) one full reference pair per
screen (1440 light, 390 dark), (4) any further full screenshot only when a finding needs it.
Do not open all six screenshots per screen by default. Report per-lane pass/fail from the
harness output, not from re-inspection.

## Calibration

Start in `annotate`. After ~5 UI slices, review the findings: if fewer than 1 in 5 were
noise, switch `design_review: block`. Record the switch in `.blackadder/decisions.tsv`.
