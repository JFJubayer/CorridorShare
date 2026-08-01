# CorridorShare Website

Next.js website for CorridorShare's highway peer-to-peer delivery experience.

## Development

```bash
npm ci
npm run dev
```

The website uses Supabase when `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` are set. Without them it uses the browser LocalStorage demo adapter.

## Architecture

- `src/app`: route entry points and layouts
- `src/features`: feature UI for auth, chat, landing, and matching flows
- `src/domain`: pure business rules and data contracts
- `src/repositories`: feature-facing data access interfaces
- `src/infrastructure`: Supabase and LocalStorage mock adapters
- `src/components`: shared presentation components
- `src/shared`: cross-feature utilities and errors

Route components should use repositories instead of importing an infrastructure adapter directly.

## Verification

```bash
npm run lint
npm test
npm run build
```

GitHub Actions runs the same checks for website changes.
