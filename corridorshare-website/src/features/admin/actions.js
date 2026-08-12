import { isMockDataSource } from '@/config/supabaseClient';
import { profileRepository } from '@/repositories/profileRepository';
import { walletRepository } from '@/repositories/walletRepository';
import { resetDemoData } from '@/infrastructure/mock/client';

export async function loadProfilesForReview() {
  return profileRepository.listForAdmin();
}

export async function setKycStatus(profileId, status) {
  return profileRepository.setNidStatus(profileId, status);
}

export function resetDemoUsers() {
  if (!isMockDataSource) throw new Error('Demo data can only be reset in demo mode.');
  resetDemoData();
}

export async function addDemoKycProfile() {
  if (!isMockDataSource) throw new Error('Test KYC profiles are only available in demo mode.');
  return profileRepository.createDemoProfile({
    phone_number: `+88017${Math.floor(10000000 + Math.random() * 90000000)}`,
    full_name: 'Demo review profile',
    role: 'member',
    nid_status: 'pending',
    nid_photo_url: 'https://images.unsplash.com/photo-1554774853-aae0a22c8aa4?auto=format&fit=crop&w=400&h=250&q=80',
  });
}

export async function creditWalletStaging({ profileId, amountBdt, note }) {
  const amountMinor = Math.round(Number(amountBdt) * 100);
  if (!Number.isSafeInteger(amountMinor) || amountMinor <= 0) {
    throw new Error('Enter a positive BDT amount to credit.');
  }
  return walletRepository.adminCreditWallet({
    profileId,
    amountMinor,
    idempotencyKey: `admin-credit-${profileId}-${Date.now()}`,
    note: note || 'Friends beta staging credit',
  });
}
