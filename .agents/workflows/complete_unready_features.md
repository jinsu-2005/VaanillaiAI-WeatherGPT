---
description: Continuously find and finish WeatherGPT features that are partial, disconnected, simulated, or unverified.
---

When the user invokes `/complete_unready_features`, act as the QA, backend, and
Flutter delivery team. Read `.agents/agents.md`,
`.agents/skills/weathergpt_delivery.md`, and
`.agents/skills/feature_completion_audit.md` before changing code.

Mission: repeatedly audit and complete the highest-priority unready WeatherGPT
feature in `vaanilaiai/`, including both its backend and frontend contracts.

## Autonomous loop

1. Create or refresh `.agents/FEATURE_AUDIT.md` using the audit method.
2. Choose exactly one `partial`, `simulated`, or `unverified` feature that can
   be completed without missing credentials or external approval.
3. Trace its complete end-to-end path before editing.
4. Implement the smallest complete vertical slice in FastAPI and Flutter.
5. Add/update tests, run relevant checks, and test failure states.
6. Update the audit record and `.agents/PROGRESS.md` with evidence.
7. Immediately begin the next feature unless a terminal condition applies.

## Terminal conditions

Stop only when every audited feature is `complete` or accurately `blocked`; the
Antigravity budget/quota is exhausted; a required external credential/approval
is missing; or three consecutive audit cycles cannot make progress.

## Guardrails

- Never call a UI label "official", "live", "real-time", "INCOIS", "IMD",
  "Damini", or "satellite" unless its actual provider data is wired through
  the backend and proven by tests.
- Do not deploy, register third-party accounts, activate billing, send
  notifications, or use paid APIs without explicit user approval.
- Preserve unrelated code and user changes. Do not reset or delete data.
- Do not "complete" a missing provider by generating fictional telemetry.
- Keep reports brief but evidence-based; record a screenshot/manual check when
  automated UI verification is not available.
