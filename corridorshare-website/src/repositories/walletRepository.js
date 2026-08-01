import { isMockDataSource, supabase } from '@/config/supabaseClient';

export const walletRepository = {
  async findAccount(profileId) {
    const { data, error } = await supabase.from('wallet_accounts').select('*').eq('profile_id', profileId);
    if (error) throw error;
    return data?.[0] ?? null;
  },

  async requestDemoTopUp(profileId, amountMinor) {
    if (!isMockDataSource) {
      throw new Error('Wallet top-ups are processed by the payment service and cannot be changed from the browser.');
    }
    if (!Number.isSafeInteger(amountMinor) || amountMinor <= 0) {
      throw new Error('Top-up amount must be a positive whole number of poisha.');
    }
    const account = await this.findAccount(profileId);
    if (!account) throw new Error('Wallet account was not found.');
    const availableBalanceMinor = account.available_balance_minor + amountMinor;
    const { error } = await supabase.from('wallet_accounts').update({ available_balance_minor: availableBalanceMinor }).eq('profile_id', profileId);
    if (error) throw error;
    await supabase.from('wallet_transactions').insert({
      id: crypto.randomUUID(),
      profile_id: profileId,
      amount_minor: amountMinor,
      kind: 'credit',
      idempotency_key: `demo-top-up-${crypto.randomUUID()}`,
      description: `Demo ${amountMinor} poisha wallet credit`,
      created_at: new Date().toISOString(),
    });
    return { ...account, available_balance_minor: availableBalanceMinor };
  },
};
