import { supabase } from '@/config/supabaseClient';

export const tripRepository = {
  async create(trip) {
    const { data, error } = await supabase.from('trips').insert(trip).select('*');
    if (error) throw error;
    return data?.[0] ?? trip;
  },
  async findLatestForTraveler(travelerId) {
    const { data, error } = await supabase.from('trips').select('*').eq('traveler_id', travelerId).order('created_at', { ascending: false });
    if (error) throw error;
    return data?.[0] ?? null;
  },
  async findById(id) {
    const { data, error } = await supabase.from('trips').select('*').eq('id', id);
    if (error) throw error;
    return data?.[0] ?? null;
  },
};
