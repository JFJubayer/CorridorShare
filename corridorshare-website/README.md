# CorridorShare Website

Next.js website for CorridorShare's highway peer-to-peer delivery experience.

## Requirements

- Node.js 22 (see the root `.nvmrc`)
- A Supabase project initialized from the root `supabase/` directory

## Development

```bash
npm ci
npm run dev
```

Copy the placeholder environment file first:

```bash
cp .env.example .env.local
npm run dev
```

Supabase is the default mode. Startup fails clearly if its public URL or anonymous key is missing. A local-only demo must be selected explicitly with `NEXT_PUBLIC_DATA_MODE=demo`; production builds reject demo mode.

## Architecture

- `src/app`: thin route entry points and layouts
- `src/features`: feature-owned UI and workflow actions
- `src/domain`: pure business rules and data contracts
- `src/repositories`: feature-facing data access interfaces
- `src/infrastructure`: Supabase and LocalStorage mock adapters
- `src/components`: shared presentation components
- `src/shared`: cross-feature utilities and errors

Route components should use repositories instead of importing an infrastructure adapter directly.
After changing the shared schema, run `npm run types:db` while the local Supabase stack is running and commit the updated database types.

## Verification

```bash
npm run lint
npm test
npm run build
```

GitHub Actions runs the same checks for website changes.
