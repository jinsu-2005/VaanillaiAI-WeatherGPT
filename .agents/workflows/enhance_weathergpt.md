---
description: Continuously improve WeatherGPT with evidence-led, safe autonomous delivery cycles.
---

When the user invokes `/enhance_weathergpt`, act as the WeatherGPT autonomous
delivery team defined in `.agents/agents.md` and follow
`.agents/skills/weathergpt_delivery.md`.

Mission: continue improving `vaanilaiai/` until one of these terminal
conditions is reached:

1. The project meets the Definition of Done and no valuable scoped backlog item
   remains.
2. Antigravity reports quota/credit exhaustion or the interaction budget ends.
3. A required credential, paid-service approval, external account action,
   destructive operation, or product decision requires the user's input.
4. Three successive cycles cannot make measurable progress; report the blocker
   with evidence and stop.

## Autonomous loop

Repeat delivery cycles without waiting for approval between ordinary local code
changes. At the start of every cycle, reread `.agents/PROGRESS.md` if it
exists, inspect the working tree, run targeted diagnostics, and select the
highest-impact safe task from the backlog.

Prefer this order:

1. Failing tests, crashes, incorrect source/alert claims, security issues.
2. Weather reliability, location flow, official-data readiness, notifications,
   accessibility, responsive UI, and performance.
3. High-value features explicitly supported by already available services.
4. Refactoring or cosmetic work only when it improves a user-facing outcome.

## Required behavior

- Work in small vertical slices; do not build fake integrations or placeholder
  data while calling them live/official.
- Do not add IMD, INCOIS, MOSDAC, CWC, paid map, or push-service credentials
  unless they already exist in secure environment configuration. If missing,
  build the provider interface and clear configuration documentation only.
- Never run an endless no-op loop. A cycle must either produce an evidence-backed
  change, identify a concrete blocker, or end.
- Use the app's existing tests and add regression coverage for each material
  bug fix. Run the smallest relevant test group after each change and broader
  tests periodically.
- Before modifying a file, preserve unrelated user work. Do not reset, discard,
  or overwrite unrecognized changes.
- Do not deploy, publish, send push notifications, create cloud resources, or
  spend money outside Antigravity model credits.

## Reporting

After each completed cycle, update `.agents/PROGRESS.md` with:

- cycle number and objective
- user-visible result
- files changed
- verification commands and outcomes
- data-source / safety implications
- next highest-priority candidate

Keep chat output compact: report real completed work and blockers only. On
quota exhaustion, provide a final concise handoff with the last verified state,
the next task, and any incomplete tests.
