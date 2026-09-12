# Skill: Flutter weather-app UI excellence

## Objective

Make WeatherGPT feel like a professional, calm, high-trust mobile weather app
without copying another product's branding, artwork, layouts, or proprietary
assets. Use web research only for current interaction patterns and accessibility
principles; design original VaanilaiAI components.

## Design direction

- Mobile-first: current location, condition, temperature, feels-like value, and
  urgent alert are visible without scrolling on a standard phone.
- Calm information hierarchy: one visual hero, compact supporting metrics,
  obvious next-hour precipitation and forecast timeline.
- Use Material 3 tokens and semantic `ColorScheme` roles. Do not scatter raw
  color literals through widgets.
- Weather condition color may enrich the experience but warning meaning must
  always include text and icon; never use color alone.
- Use scalable typography, 48dp minimum primary touch targets, `Semantics`,
  readable contrast, and robust loading/empty/error states.
- Make layouts adaptive with available window size, not device-type guesses;
  preserve state on resize/orientation changes.

## Dark theme standard

- Build dark colors from a tested semantic color scheme, not inverted light
  colors. Use subtly elevated surfaces, restrained gradients, and high-contrast
  text.
- Verify warnings, charts, dividers, disabled controls, and map overlays in
  both brightness modes.
- Offer a system/default theme choice and persist the user choice.

## Charts and maps

- Every graph must answer a user question: temperature trend, rainfall chance,
  rainfall amount, wind, or AQI. Do not add decorative charts.
- Supply labels, units, current-value markers, sensible empty states, and a
  non-visual textual summary for accessibility.
- Use the existing chart/map libraries first. Add a package only after checking
  Flutter/Dart compatibility, license, maintenance, bundle impact, and whether
  native Flutter can already solve the need.

## App identity and icon

- Create an original, simple, recognizable VaanilaiAI icon that remains clear
  at small sizes: no copied weather-app logo, fine text, or licensed artwork.
- Use a 1024x1024 source asset and Android adaptive-icon foreground/background
  treatment. Update Android, iOS, and web outputs consistently.
- If a generator package is used, configure it as a development dependency,
  generate assets reproducibly, and verify on a device/emulator or rendered
  launcher preview.

## UI cycle

1. Audit key screens at phone, tablet, and web widths in light/dark themes.
2. Identify one high-impact usability issue and state the user outcome.
3. Implement reusable semantic theme/component changes before screen-specific
   overrides.
4. Run analysis and widget tests; inspect rendered result or screenshots.
5. Record changed tokens/components, accessibility checks, and visual evidence
   in `.agents/UI_AUDIT.md`.
