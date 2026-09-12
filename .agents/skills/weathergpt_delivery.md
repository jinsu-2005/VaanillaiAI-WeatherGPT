# Skill: WeatherGPT continuous delivery

## Project context

The application is in `vaanilaiai/`: Flutter client in `lib/` and FastAPI
backend in `backend/`. Work in the existing architecture; do not replace the
stack without a concrete, documented reason.

## Non-negotiable rules

1. Never fabricate, relabel, or imply live official weather, lightning,
   marine, crop, air-quality, or disaster-alert data.
2. Only label a value "Official IMD", "INCOIS", "NDMA", or similar when the
   matching provider is actually called and its returned provenance is stored.
3. Keep secrets in environment variables. Never commit API keys, credentials,
   tokens, or a `.env` file.
4. Do not make external deployments, publish notifications, change cloud
   billing, register accounts, or call paid APIs without explicit user approval.
5. Avoid unrelated rewrites. Make each cycle small, coherent, reversible, and
   testable.
6. Preserve user data and migrations. Ask before destructive database actions.
7. Every user-facing network feature needs loading, success, empty, error,
   retry, and unavailable/offline states.

## Backlog priority

P0: crashes, failing tests, security/secrets, wrong data attribution, stale
location responses, broken navigation, inaccessible severe-weather alerts.

P1: official IMD provider integration after credentials/access are supplied;
NDMA alert normalization; Firebase Messaging after user approval; device
location permission; caching; source/timestamp labels; forecast and alert UI.

P2: INCOIS/MOSDAC/NASA/CWC integrations after documented access exists;
climate research tools; advanced maps; optional visual polish.

## Delivery cycle

For one cycle only:

1. Read the current code, tests, prior cycle notes, and the product brief.
2. Select exactly one P0/P1/P2 deliverable whose scope fits the remaining
   budget. Do not choose a task that requires unavailable credentials.
3. Write a short implementation plan in `.agents/PROGRESS.md`.
4. Implement the smallest complete version.
5. Add or update targeted automated tests.
6. Run formatting, static analysis, and the relevant Flutter/Python tests.
7. Inspect the user-facing happy path and failure path.
8. Record changed files, test evidence, known limitations, and the next
   candidate in `.agents/PROGRESS.md`.

## Definition of done

A deliverable is done only when its intended behavior works, its failure path
is understandable, relevant tests pass, and data source labels are truthful.
If a check cannot be run, record the exact reason; do not claim success.
