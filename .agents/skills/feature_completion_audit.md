# Skill: Feature-completion audit

## Objective

Identify features that are present in navigation, UI, models, routes, or
marketing copy but are not fully working end-to-end. Complete them safely across
the FastAPI backend and Flutter client, or accurately label/disable them until
their required provider access exists.

## What counts as incomplete

- A visible action that does nothing, crashes, or lacks a loading/error/retry
  state.
- A Flutter API method with no matching backend endpoint or a backend route not
  reachable from the app.
- Hard-coded/demo/heuristic output shown as live, official, AI-analyzed, or
  real-time data.
- A data model field never populated, displayed, or persisted as intended.
- A feature that works only on one screen size, theme, language, or platform.
- A backend integration that has no timeout, validation, cache, fallback, or
  source attribution.
- A function with no realistic automated test for its success and failure path.

## Audit method

1. Inventory every screen, navigation destination, call-to-action, provider,
   service method, FastAPI route, model, and configured external source.
2. Trace each feature from user tap -> Flutter state -> API request -> backend
   service/provider -> persisted/result data -> UI result.
3. Mark each feature as `complete`, `partial`, `simulated`, `blocked`, or
   `unverified` in `.agents/FEATURE_AUDIT.md`.
4. Prioritize: broken safety/alert claims, crashes, data-integrity issues,
   critical navigation, primary weather flow, then secondary screens.
5. Select one small feature vertical slice. Implement both client and server
   changes as required; never declare a feature complete from UI alone.
6. Add regression tests for the API and UI/state boundary where practical.
7. Test normal, slow/offline, malformed-response, and missing-credential paths.
8. Update the audit status with concrete test evidence.

## Data honesty rule

If required access to IMD, INCOIS, MOSDAC, CWC, Gemini, device hardware, or
another service is unavailable, do not invent a substitute. Either keep the
feature as a clearly labeled forecast/estimate, or show a useful unavailable
state explaining what is needed.

## Completion standard

Mark a feature `complete` only when the user can reach it, it uses its intended
data or clearly identified fallback, it behaves well on failure, and relevant
tests pass. A feature can be `blocked` only with the exact missing credential,
approval, hardware capability, or product decision recorded.
