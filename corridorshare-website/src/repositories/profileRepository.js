import { supabase } from '@/config/supabaseClient';

export const profileRepository = {
  async findById(id) {
    const { data, error } = await supabase.from('profiles').select('*').eq('id', id);
    if (error) throw error;
    return data?.[0] ?? null;
  },
  async list() {
    const { data, error } = await supabase.from('profiles').select('*');
    if (error) throw error;
    return data ?? [];
  },
  async update(id, fields) {
    const { error } = await supabase.from('profiles').update(fields).eq('id', id);
    if (error) throw error;
    return true;
  },
  async create(profile) {
    const { error } = await supabase.from('profiles').insert(profile);
    if (error) throw error;
    return profile;
  },
};
