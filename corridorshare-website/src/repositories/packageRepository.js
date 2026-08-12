import { supabase } from '@/config/supabaseClient';

export const packageRepository = {
  async create(packageRequest) {
    const { data, error } = await supabase.from('packages').insert(packageRequest).select('*');
    if (error) throw error;
    return data?.[0] ?? packageRequest;
  },
  async findById(id) {
    const { data, error } = await supabase.from('packages').select('*').eq('id', id);
    if (error) throw error;
    return data?.[0] ?? null;
  },
};
