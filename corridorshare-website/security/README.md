# Production audit exceptions

`npm run audit:prod` runs `npm audit --omit=dev` and fails for every production
advisory except the exact package and GHSA pairs in `audit-exceptions.json`.
Transitive summary entries, such as Next.js pointing to PostCSS and Sharp, are
accepted only when every underlying advisory is accepted.

These temporary exceptions exist because Next.js 16.2.12 was the latest stable
release on 2026-08-01 and still pinned affected transitive versions. The npm
suggestion to force-install Next.js 9.3.3 is an unsafe downgrade and must not be
used. Each exception expires on 2026-09-15. Upgrade Next.js when a stable fixed
release is available, regenerate the lockfile, and remove resolved exceptions.

Do not add a broad severity threshold or a package-only exception. New advisory
IDs and expired exceptions must continue to fail CI.
