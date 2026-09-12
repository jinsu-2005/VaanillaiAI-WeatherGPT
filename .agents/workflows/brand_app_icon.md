---
description: Create and configure an original VaanilaiAI mobile app icon and production-ready launcher branding.
---

When the user invokes `/brand_app_icon`, inspect the current Flutter application
identity and icon assets. Create an original VaanilaiAI icon concept suited to a
weather and disaster-intelligence product: clear at 24dp, recognizable at 48dp,
and polished at 1024px. Do not imitate logos or use copyrighted app assets.

1. Audit existing Android, iOS, web, and manifest icon configuration.
2. Create or select a suitable original 1024x1024 source asset, with adaptive
   Android foreground/background safe zones.
3. If needed, add a maintained launcher-icon generator as a dev dependency;
   document and run its reproducible configuration.
4. Update all relevant launcher outputs and verify that the project still
   builds/analyzes.
5. Record source asset, generator configuration, generated targets, and visual
   verification in `.agents/UI_AUDIT.md`.

Do not change package/bundle identifiers, publishing credentials, store listing,
or signing configuration. Stop only for quota exhaustion, unavailable source
asset/required licensing decision, or a verified completed configuration.
