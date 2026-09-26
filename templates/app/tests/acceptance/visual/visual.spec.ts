// Visual + accessibility lanes. Run: BASE_URL=<preview> pnpm test:acceptance tests/acceptance/visual
// Record/refresh baselines only inside a /design PR: pnpm test:acceptance tests/acceptance/visual --update-snapshots
import { test, expect, type Page } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";
import { entries, breakpoints, themes } from "./visual.manifest";

async function login(page: Page, email: string) {
  await page.goto("/login");
  await page.getByLabel(/email/i).fill(email);
  await page.getByLabel(/password/i).fill("blackadder-dev");
  await page.getByRole("button", { name: /sign in/i }).click();
  await page.waitForURL((u) => !u.pathname.startsWith("/login"));
}

for (const entry of entries) {
  test.describe(entry.id, () => {
    for (const theme of themes) {
      for (const width of breakpoints) {
        test(`${theme} @ ${width}`, async ({ page }) => {
          await page.emulateMedia({ colorScheme: theme, reducedMotion: "reduce" });
          await page.setViewportSize({ width, height: width < 800 ? 844 : 900 });
          if (entry.login) await login(page, entry.login);
          await page.goto(entry.path, { waitUntil: "networkidle" });
          await page.evaluate(() => document.fonts.ready);

          // Screenshot lane
          const opts =
            entry.lane === "reference"
              ? { maxDiffPixels: 0 }
              : { maxDiffPixelRatio: entry.ratio ?? 0.02 };
          await expect(page).toHaveScreenshot(`${entry.id}-${theme}-${width}.png`, {
            fullPage: entry.fullPage ?? true,
            animations: "disabled",
            ...opts,
          });

          // Accessibility lane (category 8 of the design review rubric)
          const axe = await new AxeBuilder({ page }).withTags(["wcag2a", "wcag2aa", "wcag22aa"]).analyze();
          const serious = axe.violations.filter((v) => v.impact === "serious" || v.impact === "critical");
          expect(serious, JSON.stringify(serious.map((v) => ({ id: v.id, nodes: v.nodes.length })), null, 2)).toEqual([]);

          // Responsive lane (category 5): no horizontal overflow
          const overflow = await page.evaluate(() => document.documentElement.scrollWidth > document.documentElement.clientWidth);
          expect(overflow, "horizontal overflow").toBe(false);
        });
      }
    }
  });
}
