import { describe, expect, it } from 'vitest';
import { getDataMode } from './dataMode';

describe('getDataMode', () => {
  it('defaults to Supabase and rejects missing live credentials with a friendly message', () => {
    expect(getDataMode({}).mode).toBe('supabase');
    expect(getDataMode({}).error).toMatch(/not connected yet/i);
    expect(getDataMode({}).error).not.toMatch(/NEXT_PUBLIC_/);
  });

  it('accepts explicit demo mode only outside production', () => {
    expect(getDataMode({ NEXT_PUBLIC_DATA_MODE: 'demo', NODE_ENV: 'development' })).toEqual({ mode: 'demo', error: null });
    expect(getDataMode({ NEXT_PUBLIC_DATA_MODE: 'demo', NODE_ENV: 'production' }).error).toContain('production build');
  });

  it('accepts configured live mode', () => {
    expect(getDataMode({
      NEXT_PUBLIC_DATA_MODE: 'supabase',
      NEXT_PUBLIC_SUPABASE_URL: 'https://project.supabase.co',
      NEXT_PUBLIC_SUPABASE_ANON_KEY: 'anon-key',
    })).toEqual({ mode: 'supabase', error: null });
  });
});
