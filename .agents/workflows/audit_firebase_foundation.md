---
description: Audit and complete WeatherGPT Firebase Auth and Firestore usage, security rules, and guest-to-account experience.
---

When the user invokes `/audit_firebase_foundation`, read
`.agents/skills/firebase_product_foundation.md` and audit `vaanilaiai/` end to
end. Do not assume that configured Firebase packages mean the feature works.

1. Inventory actual Firebase Auth and Firestore calls, configured platforms,
   rules, and backend token handling.
2. Categorize each path as `working`, `partial`, `unused`, `insecure`,
   `unverified`, or `blocked` in `.agents/FIREBASE_AUDIT.md`.
3. Fix the highest-risk safe issue first: client state/auth handling, truthful
   UI, data ownership, rules, input validation, or tests.
4. Implement frontend and backend token/data contracts together where required.
5. Verify guest, signed-in, signed-out, denied-permission, offline, and
   malicious cross-user access scenarios as applicable.
6. Update the audit and `PROGRESS.md`, then continue with the next safe issue.

Never deploy Firebase configuration/rules, enable paid services, create cloud
resources, or modify production data without explicit approval. Stop only for
quota exhaustion, missing Firebase credentials/project authority, unsafe action,
or a completed verified Firebase audit.
