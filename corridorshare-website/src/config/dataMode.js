const DATA_MODE_DEMO = 'demo';
const DATA_MODE_SUPABASE = 'supabase';

/**
 * Capture NEXT_PUBLIC_* via direct process.env access so Next.js/Turbopack
 * can inline them into the client bundle. Reading them only through a passed
 * `environment` object breaks production because the browser process.env is empty.
 */
const PUBLIC_ENV = {
  NEXT_PUBLIC_DATA_MODE: process.env.NEXT_PUBLIC_DATA_MODE,
  NEXT_PUBLIC_SUPABASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL,
  NEXT_PUBLIC_SUPABASE_ANON_KEY: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
  NODE_ENV: process.env.NODE_ENV,
};

/**
 * Runtime data-source selection is deliberately explicit. Demo storage is a
 * development aid and must never become an accidental production fallback.
 *
 * User-facing errors intentionally avoid leaking raw environment variable names.
 */
export function getDataMode(environment = PUBLIC_ENV) {
  const mode = environment.NEXT_PUBLIC_DATA_MODE || DATA_MODE_SUPABASE;

  if (mode !== DATA_MODE_DEMO && mode !== DATA_MODE_SUPABASE) {
    return {
      mode,
      error: 'This site is misconfigured. Ask an administrator to set a valid data mode (demo or supabase).',
    };
  }

  if (mode === DATA_MODE_DEMO && environment.NODE_ENV === 'production') {
    return { mode, error: 'Demo data mode is disabled in production builds.' };
  }

  if (mode === DATA_MODE_SUPABASE) {
    const url = environment.NEXT_PUBLIC_SUPABASE_URL;
    const anonKey = environment.NEXT_PUBLIC_SUPABASE_ANON_KEY;
    if (!url || url.includes('placeholder') || !anonKey || anonKey.includes('placeholder')) {
      return {
        mode,
        error: 'Live CorridorShare is not connected yet. Add your Supabase project URL and anonymous key to the website environment, or run locally with demo data mode.',
      };
    }
  }

  return { mode, error: null };
}

export const dataModeConfig = getDataMode();
export const isDemoDataMode = dataModeConfig.mode === DATA_MODE_DEMO;
export const dataModeError = dataModeConfig.error;
