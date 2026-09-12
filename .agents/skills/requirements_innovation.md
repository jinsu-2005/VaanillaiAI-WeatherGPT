# Skill: Requirements-driven feature discovery

## Objective

Continuously improve WeatherGPT against the official problem statement:
conversational, multilingual, mobile weather intelligence for India; real-time
information, forecasts, NWP context, early warnings, location advisories,
climate analysis, rural voice accessibility, and disaster-management value.

## Evaluate every proposed feature

Score each idea from 0-5 for:

- alignment with the problem statement and disaster-management value
- usefulness to citizens, farmers, travelers, researchers, or responders
- data reliability and source availability
- mobile usability and accessibility
- feasible end-to-end delivery within the remaining budget
- novelty/demo value without misleading claims

Build only ideas with strong alignment and a credible data path. Prefer one
complete useful capability over several impressive-looking stubs.

## Preferred roadmap

1. Accurate source attribution, robust forecast/location flow, official alerts,
   accessibility, and multilingual baseline.
2. Weather conversation grounded in selected location, source timestamps, and
   explicit uncertainty.
3. Farmer advisory, travel/outdoor risk, disaster safety center, and trusted
   push-alert readiness.
4. Climate exploration, observed rainfall, map/radar layers, and marine tools
   when the underlying source is available.
5. Optional enhancements: saved locations, comparison view, home-screen
   widgets, report feedback, low-bandwidth mode, and explainable risk cards.

## Prohibited shortcuts

- Do not invent live weather, official alerts, satellite/radar frames, lightning
  strikes, ocean conditions, or agricultural prescriptions.
- Do not turn a model heuristic into an official-data claim.
- Do not add a feature solely because it is trendy or because a screen already
  has a placeholder.
- Do not add paid, credentialed, or account-linked services without approval.

## Feature delivery standard

For every accepted feature, write the user problem, source/data contract,
failure behavior, acceptance criteria, implementation steps, and tests before
coding. Implement backend and frontend as one vertical slice. Record the
decision and evidence in `.agents/ROADMAP.md`.
