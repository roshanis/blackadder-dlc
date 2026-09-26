import { defineConfig } from "@playwright/test";

// Acceptance + visual tests run against a real deployment (preview or staging), never a mock.
export default defineConfig({
  testDir: "tests/acceptance",
  fullyParallel: true,
  retries: process.env.CI ? 1 : 0, // a test that flips once is filed as `flaky`, not as a functional failure
  reporter: [["list"], ["html", { outputFolder: "tests/acceptance/report", open: "never" }]],
  snapshotPathTemplate: "{testDir}/visual/__screenshots__/{arg}{ext}",
  use: {
    baseURL: process.env.BASE_URL ?? "http://localhost:3000",
    trace: "retain-on-failure",
    screenshot: "only-on-failure",
  },
  expect: { toHaveScreenshot: { threshold: 0.2, animations: "disabled" } },
  projects: [{ name: "chromium", use: { browserName: "chromium" } }],
});
