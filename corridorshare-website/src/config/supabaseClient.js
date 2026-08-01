import { mockClient, DEFAULT_DEMO_PROFILES } from '@/infrastructure/mock/client';
import { createSupabaseClient } from '@/infrastructure/supabase/client';
import { unavailableClient } from '@/infrastructure/unavailableClient';
import { dataModeError, isDemoDataMode } from '@/config/dataMode';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || '';
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '';

export const isMockDataSource = isDemoDataMode;

export const supabase = dataModeError
  ? unavailableClient
  : isMockDataSource
  ? mockClient
  : createSupabaseClient(supabaseUrl, supabaseAnonKey);

export { DEFAULT_DEMO_PROFILES };
