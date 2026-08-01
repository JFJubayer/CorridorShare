import { supabase } from '@/config/supabaseClient';

export const chatRepository = {
  async list() { const { data, error } = await supabase.from('chats').select('*'); if (error) throw error; return data ?? []; },
  async findById(id) { const { data, error } = await supabase.from('chats').select('*').eq('id', id); if (error) throw error; return data?.[0] ?? null; },
};
