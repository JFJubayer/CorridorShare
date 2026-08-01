import { supabase } from '@/config/supabaseClient';

export const packageRepository = {
  async create(packageRequest) {
    const { data, error } = await supabase.from('packages').insert(packageRequest);
    if (error) throw error;
    return data?.[0] ?? packageRequest;
  },
};
