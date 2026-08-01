import { describe, expect, it } from 'vitest';
import { calculateWalletBalance, createFallbackProfile } from '../profile';

describe('profile domain', () => {
  it('creates the existing fallback profile shape', () => {
    expect(createFallbackProfile('u1', '+8801')).toMatchObject({ id: 'u1', phone_number: '+8801', wallet_balance: 0 });
  });
  it('calculates wallet changes from string values', () => {
    expect(calculateWalletBalance('40', '10')).toBe(50);
    expect(calculateWalletBalance('40', '10', 'subtract')).toBe(30);
  });
});
