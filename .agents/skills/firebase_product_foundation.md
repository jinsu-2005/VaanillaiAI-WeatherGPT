# Skill: Firebase, Firestore, and authentication foundation

## Objective

Determine whether Firebase Authentication and Cloud Firestore are genuinely
used, correctly configured, and appropriate for WeatherGPT. Make the smallest
safe improvements to complete the intended user-account experience.

## Audit

Trace Firebase initialization, platform config, authentication state, sign-in
and sign-out flows, Firestore reads/writes, offline behavior, `firestore.rules`,
and user-facing failure handling. Write findings to `.agents/FIREBASE_AUDIT.md`.

## Architecture rules

- Firebase Auth is the identity source of truth. FastAPI must validate identity
  tokens before treating a request as authenticated; never trust a UID supplied
  by the client.
- Firestore should hold user-scoped profile/preferences data only when it adds
  real value: saved locations, notification preferences, language/theme choice,
  and optionally user reports. Do not duplicate FastAPI's weather cache or make
  Firestore a dumping ground.
- Enforce per-user ownership in Firestore Security Rules using `request.auth.uid`.
  Deny unauthenticated and cross-user reads/writes by default.
- Validate document fields, sizes, and allowed collection paths in rules and
  server/client code. Use server-side timestamps for auditable writes.
- Support guest usage, explicit sign-in, sign-out, account recovery, and a
  helpful offline/auth-error state.
- Do not create a Firebase project, change billing, deploy rules, enable a
  provider, or alter production users/data without explicit user authority.

## Completion standard

Mark Firebase `complete` only if the app uses it intentionally, the selected
flows work with real configuration, rules are least-privilege, tests/emulator
checks exist where possible, and all unconfigured cases degrade safely. If it
is not needed, remove misleading UI claims and document why it remains unused.
