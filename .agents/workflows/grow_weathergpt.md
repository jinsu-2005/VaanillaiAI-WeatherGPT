---
description: Autonomously discover and deliver high-value WeatherGPT improvements aligned to the IMD/MoES problem statement.
---

When the user invokes `/grow_weathergpt`, read `.agents/agents.md`,
`.agents/skills/weathergpt_delivery.md`, and
`.agents/skills/requirements_innovation.md`.

Mission: keep WeatherGPT progressing toward a complete, credible submission for
the WeatherGPT: Conversational AI for Weather Forecasting, Alerts, and Climate
Information problem statement.

## Loop

1. Read `.agents/PROGRESS.md`, `.agents/FEATURE_AUDIT.md`, and `.agents/ROADMAP.md`
   when present. Inspect the current app and tests.
2. Compare implemented capability against the project requirements: forecasts,
   natural-language intelligence, NWP context, warnings, location advice,
   Indian-language support, climate analysis, voice accessibility, and scalable
   real-time architecture.
3. Generate candidate improvements. Score them using the requirements skill and
   write the prioritized shortlist to `.agents/ROADMAP.md`.
4. Select one highest-value feature that is not already represented as partial
   work in `FEATURE_AUDIT.md`; invoke `/complete_unready_features` first if it
   is.
5. Deliver one complete vertical slice: data contract/backend, Flutter UI,
   accessibility, reliability, and tests.
6. Verify the feature's user outcome and update the roadmap and progress log.
7. Repeat until the terminal conditions apply.

## Terminal conditions

Stop when all high-value feasible requirements are complete, credits/budget are
exhausted, a necessary credential/approval is missing, or three cycles in a row
produce no safe measurable progress.

## Guardrails

- Fix broken or misleading functionality before adding a new capability.
- Do not use external paid services, deploy, register accounts, send alerts, or
  alter billing without explicit user authorization.
- For IMD, NDMA, INCOIS, MOSDAC, CWC, and Gemini integrations, only make
  claims supported by actual configured provider calls and source metadata.
- Optimize for simple mobile use, rural accessibility, clear source labels, and
  concrete disaster-preparedness benefit.
