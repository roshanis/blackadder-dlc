// Blackadder guard for OpenClaw. Same policy as hooks/blackadder-guard.sh, expressed as a
// native before_tool_call hook because OpenClaw detects Claude hooks/hooks.json in bundles
// but does not run it. Blocks return { block: true, blockReason }.
import { definePluginEntry } from "openclaw/plugin-sdk/plugin-entry";

type ToolEvent = {
  toolName: string;
  params?: Record<string, unknown>;
  derivedPaths?: string[];
};
type ToolCtx = { agentId?: string };
type Verdict = { block: true; blockReason: string } | undefined;

const ACCEPTANCE = /(^|\/)tests\/acceptance\//;
const FILE_TOOLS = ["write", "edit", "apply_patch"];
const SHELL_TOOLS = ["exec", "process", "terminal", "code_execution"];

function str(v: unknown): string {
  return typeof v === "string" ? v : "";
}

function pathsOf(event: ToolEvent): string[] {
  const p = event.params ?? {};
  const out = [
    ...(event.derivedPaths ?? []),
    str(p.path),
    str(p.file_path),
    str(p.filePath),
  ].filter(Boolean);
  const patch = str(p.patch) || str(p.input);
  for (const m of patch.matchAll(/^\*\*\* (?:Add|Update|Delete) File: (.+)$/gm)) out.push(m[1]);
  return out;
}

function commandOf(event: ToolEvent): string {
  const p = event.params ?? {};
  return str(p.command) || str(p.cmd) || str(p.script);
}

function deny(reason: string): Verdict {
  return { block: true, blockReason: `Blackadder: ${reason}` };
}

export function guard(event: ToolEvent, ctx: ToolCtx, authors: string[]): Verdict {
  const isAuthor = !!ctx.agentId && authors.includes(ctx.agentId);

  if (FILE_TOOLS.includes(event.toolName) && !isAuthor) {
    if (pathsOf(event).some((f) => ACCEPTANCE.test(f))) {
      return deny(
        "tests/acceptance/ is written by the acceptance author before the build and must not be edited by the builder (AGENTS.md rule 2). Escalate instead.",
      );
    }
  }

  if (SHELL_TOOLS.includes(event.toolName)) {
    const cmd = commandOf(event);
    if (!cmd) return undefined;
    if (/tests\/acceptance/.test(cmd) && /(\brm\b|\bmv\b|\bsed\b|\btruncate\b|>|git checkout|git rm)/.test(cmd) && !isAuthor) {
      return deny("shell command touches tests/acceptance/ (AGENTS.md rule 2).");
    }
    if (/git push.*(--force|-f\b|--force-with-lease)/.test(cmd)) {
      return deny("force-push is never allowed (AGENTS.md rule 7).");
    }
    if (/git (reset --hard|clean -fd)/.test(cmd) && /(main|master)/.test(cmd)) {
      return deny("destructive git operation on main.");
    }
    if (/(vercel .*--prod|railway up|railway deploy|supabase db push.*--linked|supabase db reset.*--linked|supabase link)/.test(cmd)) {
      return deny("agents never deploy or touch linked/production databases (AGENTS.md rule 7). Open a PR or dispatch the workflow.");
    }
    if (/(DROP (TABLE|SCHEMA|DATABASE)|TRUNCATE )/.test(cmd) && !/supabase\/migrations/.test(cmd)) {
      return deny("destructive SQL outside a migration file.");
    }
  }
  return undefined;
}

export default definePluginEntry({
  id: "blackadder",
  name: "Blackadder DLC",
  description: "Blackadder guard: protects tests/acceptance/, blocks force-push, deploys and linked-DB commands.",
  register(api: any) {
    const cfg = (api.pluginConfig ?? api.config ?? {}) as { acceptanceAuthorAgentIds?: string[] };
    const authors = cfg.acceptanceAuthorAgentIds ?? ["blackadder-acceptance-author"];
    api.on(
      "before_tool_call",
      (event: ToolEvent, ctx: ToolCtx) => guard(event, ctx, authors),
      { matcher: [...FILE_TOOLS, ...SHELL_TOOLS], priority: 50 },
    );
  },
});
