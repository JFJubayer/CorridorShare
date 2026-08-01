import { supabase } from '@/config/supabaseClient';

const SAFE_SELF_PROFILE_FIELDS = new Set(['full_name', 'nid_photo_url']);

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
  async updateOwnDetails(id, fields) {
    const unsafeField = Object.keys(fields).find((field) => !SAFE_SELF_PROFILE_FIELDS.has(field));
    if (unsafeField) throw new Error(`${unsafeField} is managed by a server-side workflow.`);
    const { error } = await supabase.from('profiles').update(fields).eq('id', id);
    if (error) throw error;
    return true;
  },
  async listForAdmin() {
    const [{ data: profiles, error: profileError }, { data: accounts, error: accountError }] = await Promise.all([
      supabase.from('profiles').select('*'),
      supabase.from('wallet_accounts').select('*'),
    ]);
    if (profileError) throw profileError;
    if (accountError) throw accountError;
    const accountsByProfileId = new Map((accounts ?? []).map((account) => [account.profile_id, account]));
    return (profiles ?? []).map((profile) => {
      const account = accountsByProfileId.get(profile.id);
      return {
        ...profile,
        wallet_balance_minor: account?.available_balance_minor ?? 0,
        wallet_balance: (account?.available_balance_minor ?? 0) / 100,
      };
    });
  },
  async setNidStatus(id, status) {
    const { data, error } = await supabase.rpc('admin_set_nid_status', { p_profile_id: id, p_status: status });
    if (error) throw error;
    return data;
  },
  async createDemoProfile(profile) {
    const { error } = await supabase.from('profiles').insert(profile);
    if (error) throw error;
    return profile;
  },
};
