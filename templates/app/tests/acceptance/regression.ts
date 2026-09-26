// Regression lanes: every accepted slice registers its journey here. The verifier runs all
// lanes on every PR; a failure in any lane is a blocker regardless of the current slice.
export const lanes: { slice: string; journey: string; spec: string }[] = [
  { slice: "INC-00", journey: "health endpoint and tokens page render on preview", spec: "INC-00/health.spec.ts" },
];
