import { beforeEach, describe, expect, it } from 'vitest';
import { mockClient, resetDemoData } from './client';

if (typeof globalThis.localStorage === 'undefined') {
  const store = new Map();
  globalThis.localStorage = {
    clear() { store.clear(); },
    getItem(key) { return store.has(key) ? store.get(key) : null; },
    setItem(key, value) { store.set(String(key), String(value)); },
    removeItem(key) { store.delete(String(key)); },
  };
}

// Demo mock persists through window.localStorage; provide a window shim for Node.
if (typeof globalThis.window === 'undefined') {
  globalThis.window = globalThis;
}

const DEAL_ID = '55555555-5555-4555-8555-555555555555';
const TRAVELER_PHONE = '+8801712345678';

describe('demo deal locking', () => {
  beforeEach(async () => {
    localStorage.clear();
    resetDemoData();
    await mockClient.auth.signInWithOtp({ phone: TRAVELER_PHONE });
    await mockClient.auth.verifyOtp({ phone: TRAVELER_PHONE, token: '123456', type: 'sms' });
  });

  it('moves funds to hold once and honors its idempotency key', async () => {
    const params = {
      p_deal_id: DEAL_ID,
      p_amount_minor: 25000,
      p_inspection_photo_url: 'https://example.test/proof.jpg',
      p_idempotency_key: 'lock-deal-test-1',
    };
    await expect(mockClient.rpc('lock_deal_with_inspection', params)).resolves.toMatchObject({ error: null });
    await expect(mockClient.rpc('lock_deal_with_inspection', params)).resolves.toMatchObject({ error: null });

    const { data: accounts } = await mockClient.from('wallet_accounts').select('*').eq('profile_id', '22222222-2222-4222-8222-222222222222');
    const { data: transactions } = await mockClient.from('wallet_transactions').select('*');
    expect(accounts[0]).toMatchObject({ available_balance_minor: 10000, held_balance_minor: 25000 });
    expect(transactions).toHaveLength(1);
    expect(transactions[0]).toMatchObject({ kind: 'hold', amount_minor: 25000 });
  });

  it('refuses a lock amount that does not equal the agreed reward', async () => {
    const result = await mockClient.rpc('lock_deal_with_inspection', {
      p_deal_id: DEAL_ID,
      p_amount_minor: 24000,
      p_inspection_photo_url: 'https://example.test/proof.jpg',
      p_idempotency_key: 'lock-deal-test-2',
    });
    expect(result.error.message).toMatch(/must equal agreed package reward/i);
  });

  it('refuses a lock that exceeds the available balance', async () => {
    // Drop sender available balance below the agreed 25000 reward.
    await mockClient.from('wallet_accounts').update({ available_balance_minor: 1000 }).eq('profile_id', '22222222-2222-4222-8222-222222222222');
    const result = await mockClient.rpc('lock_deal_with_inspection', {
      p_deal_id: DEAL_ID,
      p_amount_minor: 25000,
      p_inspection_photo_url: 'https://example.test/proof.jpg',
      p_idempotency_key: 'lock-deal-test-3',
    });
    expect(result.error.message).toContain('Insufficient');
  });

  it('lets an admin credit a wallet with idempotency', async () => {
    const params = {
      p_profile_id: '22222222-2222-4222-8222-222222222222',
      p_amount_minor: 5000,
      p_idempotency_key: 'admin-credit-1',
      p_note: 'Staging top-up',
    };
    await expect(mockClient.rpc('admin_credit_wallet', params)).resolves.toMatchObject({ error: null });
    await expect(mockClient.rpc('admin_credit_wallet', params)).resolves.toMatchObject({ error: null });
    const { data: accounts } = await mockClient.from('wallet_accounts').select('*').eq('profile_id', '22222222-2222-4222-8222-222222222222');
    expect(accounts[0].available_balance_minor).toBe(40000);
  });
});
