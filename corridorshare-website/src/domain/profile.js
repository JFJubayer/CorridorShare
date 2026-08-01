export const DEFAULT_PROFILE = Object.freeze({
  nid_status: 'unverified',
  nid_photo_url: '',
  wallet_balance: 0,
});

export function createFallbackProfile(id, phoneNumber) {
  return { ...DEFAULT_PROFILE, id, phone_number: phoneNumber };
}

export function calculateWalletBalance(currentBalance, amount, operation = 'add') {
  const delta = Number(amount);
  const balance = Number(currentBalance);
  return operation === 'subtract' ? balance - delta : balance + delta;
}
