// Screens and prototypes under visual verification. `/design --screen` appends here.
// lane "reference": pixel-exact (the /design-system route) — any diff fails.
// lane "prototype": perceptual — the built screen must match its /proto baseline within `ratio`.
export type VisualEntry = {
  id: string;            // S-001, or "design-system"
  path: string;          // route on BASE_URL
  lane: "reference" | "prototype";
  ratio?: number;        // maxDiffPixelRatio for lane "prototype" (default 0.02)
  login?: "alice@t1.test" | "bob@t1.test" | "carol@t2.test";
  fullPage?: boolean;
};

export const breakpoints = [390, 834, 1440] as const;
export const themes = ["light", "dark"] as const;

export const entries: VisualEntry[] = [
  { id: "design-system", path: "/design-system", lane: "reference", fullPage: true },
  // { id: "S-001", path: "/proto/S-001", lane: "prototype", ratio: 0.02 },
  // { id: "S-001-built", path: "/login", lane: "prototype", ratio: 0.03 },
];
