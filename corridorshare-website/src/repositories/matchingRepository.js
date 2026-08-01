import { supabase } from '@/config/supabaseClient';
import { MATCHING_RPC, createMatchingParams } from '@/domain/matching';

export const matchingRepository = {
  async findPackages(routePath, corridorWidthMeters) {
    const { data, error } = await supabase.rpc(MATCHING_RPC, createMatchingParams(routePath, corridorWidthMeters));
    if (error) throw error;
    return (data ?? []).map((packageMatch) => ({
      ...packageMatch,
      proposed_reward: (packageMatch.proposed_reward_minor ?? 0) / 100,
    }));
  },
};
