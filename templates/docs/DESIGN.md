---
version: alpha
name: <Product>
description: Design system for <Product>. Machine-readable tokens above, rationale below. Lint with `npx @google/design.md lint DESIGN.md`; export tokens with `npx @google/design.md export DESIGN.md --format tailwind`.
colors:
  # Roles, not hues. Every text/background pair used in components must pass WCAG 2.2 AA (linted).
  background: "#f9f9fb"
  on-background: "#15181f"
  surface: "#ffffff"
  surface-container: "#f1f3f7"
  surface-container-high: "#e6e9ef"
  on-surface: "#15181f"
  on-surface-variant: "#4c5563"
  outline: "#8a94a6"
  outline-variant: "#d3d9e3"
  primary: "#1f4fd8"
  on-primary: "#ffffff"
  primary-container: "#dbe4ff"
  on-primary-container: "#0b1f6b"
  secondary: "#5b6b82"
  on-secondary: "#ffffff"
  secondary-container: "#dfe6f2"
  on-secondary-container: "#182131"
  error: "#b3261e"
  on-error: "#ffffff"
  error-container: "#f9dedc"
  on-error-container: "#410e0b"
  success: "#1e7f4f"
  on-success: "#ffffff"
  warning: "#8a5a00"
  on-warning: "#ffffff"
typography:
  display:
    fontFamily: Inter
    fontSize: 40px
    fontWeight: "700"
    lineHeight: 48px
    letterSpacing: -0.02em
  headline:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: "600"
    lineHeight: 36px
    letterSpacing: -0.01em
  title:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: "600"
    lineHeight: 28px
  body:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: "400"
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: "400"
    lineHeight: 20px
  label:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: "500"
    lineHeight: 20px
    letterSpacing: 0.01em
  mono:
    fontFamily: JetBrains Mono
    fontSize: 13px
    fontWeight: "400"
    lineHeight: 20px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 40px
  2xl: 64px
  gutter: 16px
  margin: 24px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  full: 9999px
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.label}"
    rounded: "{rounded.DEFAULT}"
    padding: "{spacing.md}"
  button-primary-hover:
    backgroundColor: "{colors.on-primary-container}"
    textColor: "{colors.on-primary}"
  button-secondary:
    backgroundColor: "{colors.secondary-container}"
    textColor: "{colors.on-secondary-container}"
    typography: "{typography.label}"
    rounded: "{rounded.DEFAULT}"
    padding: "{spacing.md}"
  button-destructive:
    backgroundColor: "{colors.error}"
    textColor: "{colors.on-error}"
    typography: "{typography.label}"
    rounded: "{rounded.DEFAULT}"
    padding: "{spacing.md}"
  input:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.on-surface}"
    typography: "{typography.body}"
    rounded: "{rounded.DEFAULT}"
    padding: "{spacing.sm}"
  card:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.md}"
    padding: "{spacing.lg}"
  badge:
    backgroundColor: "{colors.secondary-container}"
    textColor: "{colors.on-secondary-container}"
    typography: "{typography.label}"
    rounded: "{rounded.full}"
    padding: "{spacing.xs}"
  table-row-hover:
    backgroundColor: "{colors.surface-container}"
  empty-state:
    backgroundColor: "{colors.surface-container}"
    textColor: "{colors.on-surface-variant}"
    rounded: "{rounded.md}"
    padding: "{spacing.xl}"
---

## Overview

One paragraph: who this product is for, what the interface should feel like, and the one
thing it must never feel like. Three principles, each with a "we do not":

1. **<Principle>** — we do not …
2. **<Principle>** — we do not …
3. **<Principle>** — we do not …

Direction chosen at gate G2a: `docs/blackadder/design/directions/<a|b|c>.html`.

## Colors

Roles, not hues. `primary` is reserved for the single most important action on a view;
`secondary-container` for supporting actions; `error`/`success`/`warning` only for status.
Dark theme maps the same roles (`background` ↔ `on-background` invert; containers step up in
lightness). All pairs used in `components:` are linted for WCAG 2.2 AA; large text may use
AA-large.

## Typography

`Inter` for UI, `JetBrains Mono` for code and identifiers. The scale has seven steps; do not
introduce intermediate sizes. Headings use `headline`/`title`; body copy `body`; controls and
table headers `label`. Line length 60–75 characters for reading surfaces.

## Layout

4 px base unit; spacing only from the scale. Page gutter `gutter`, page margin `margin`.
Breakpoints: 390 (phone), 834 (tablet), 1440 (desktop). Content max-width 1200 px. Forms
single column below 834. Touch targets ≥ 44 px. Dense data tables may use `body-sm`.

## Elevation & Depth

Flat by default; hierarchy comes from `surface-container*` tonal steps, not shadows. One
ambient shadow level for floating elements (menus, dialogs). No inner shadows, no glows.

## Shapes

`DEFAULT` (8 px) for controls, `md` (12 px) for cards and dialogs, `full` for badges and
avatars. Radii never mix within a component.

## Components

Each entry in `components:` exists in `packages/ui` under the same name with states
hover / focus-visible / disabled / loading / error / empty where applicable, keyboard
behavior, and ARIA notes in its story on the `/design-system` route. Buttons: one
`button-primary` per view. Inputs: label above, helper or error text below, never
placeholder-as-label. Tables: sticky header, `table-row-hover`, empty state uses
`empty-state`. Empty, loading and error states are required on every data surface.

## Do's and Don'ts

- Do use tokens and `packages/ui` only; never raw hex, px or arbitrary Tailwind values in `apps/`.
- Do write real copy: sentence case, verbs on buttons, actionable error messages.
- Do declare any deviation in the PR's "Design delta"; a design change is a `DESIGN.md` PR.
- Don't add a new color, size or radius per screen; propose it here.
- Don't use placeholder-as-label, lorem ipsum, or disabled buttons without a reason shown.
- Don't animate anything longer than 200 ms or without `prefers-reduced-motion` respect.
