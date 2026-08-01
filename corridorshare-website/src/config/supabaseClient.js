import { mockClient, DEFAULT_DEMO_PROFILES } from '@/infrastructure/mock/client';
import { createSupabaseClient } from '@/infrastructure/supabase/client';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || '';
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '';

export const isMockDataSource = !supabaseUrl || supabaseUrl.includes('placeholder') || !supabaseAnonKey || supabaseAnonKey.includes('placeholder');

export const supabase = isMockDataSource
  ? mockClient
  : createSupabaseClient(supabaseUrl, supabaseAnonKey);

export { DEFAULT_DEMO_PROFILES };
