---
description: Master autonomous WeatherGPT orchestrator: audit, complete, improve, verify, and repeat without routine review gates.
---

When the user invokes `/autonomous_weathergpt`, immediately begin autonomous
delivery in `vaanilaiai/`. Do not ask the user to approve plans, designs,
individual code changes, or ordinary local test fixes. Continue working until a
terminal condition is reached.

## Master loop

Repeat the following sequence indefinitely within the available Antigravity
budget and quota:

1. Invoke `/complete_unready_features` to find and finish the most important
   partial, simulated, disconnected, or unverified feature.
2. Invoke `/grow_weathergpt` to identify and deliver the next high-value,
   requirements-aligned capability that has a reliable data path.
3. Invoke `/enhance_weathergpt` to resolve regressions, performance issues,
   accessibility gaps, source-labeling issues, and test failures introduced or
   discovered during the preceding work.
4. If the UI audit is missing, stale, or shows a material visual/accessibility/
   responsive/dark-theme gap, invoke `/elevate_flutter_ui`. If launcher branding
   is missing or unverified, invoke `/brand_app_icon`.
5. If Firebase/Auth/Firestore is configured, referenced by the UI, or has not
   been audited, invoke `/audit_firebase_foundation`.
6. Read `.agents/PROGRESS.md`, `.agents/FEATURE_AUDIT.md`,
   `.agents/ROADMAP.md`, `.agents/UI_AUDIT.md`, and `.agents/FIREBASE_AUDIT.md`;
   verify that the current cycle made measurable progress. Immediately begin the
   next cycle.

## Autonomous operating rules

- Act immediately. Do not pause for ordinary reviews or confirmations.
- Make safe, local, reversible implementation decisions using the documented
  WeatherGPT requirements and existing codebase conventions.
- Always complete backend, frontend, error behavior, and tests for a feature
  vertical slice before moving on.
- Keep iterating after tests pass; passing tests are a checkpoint, not a reason
  to stop while valuable scoped work remains.
- Preserve all evidence in `.agents/PROGRESS.md`, `.agents/FEATURE_AUDIT.md`,
  and `.agents/ROADMAP.md` so a future interaction resumes exactly where the
  last one ended.
- Do not create no-op loops: each loop must deliver a verified improvement,
  resolve a concrete defect, or record a newly evidenced blocker.

## Non-negotiable hard stops

The agent may not invent authority. Stop and report only if one of these occurs:

1. Antigravity credits/quota or interaction budget is exhausted.
2. An external credential, IP whitelist, paid API, account registration,
   deployment, billing change, or notification delivery requires user action.
3. A destructive or irreversible action is required and not explicitly
   authorized.
4. Three successive cycles cannot make measurable safe progress.
5. The project is genuinely complete against the audited feasible requirements.

At a hard stop, save the exact next action, blocker, and latest test evidence in
the progress files. Do not ask for reviews; ask only for the one missing
credential, authority, or decision needed to resume.
