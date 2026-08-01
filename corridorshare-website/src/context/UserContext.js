'use client';

import React, { createContext, useContext, useEffect, useState } from 'react';
import { dataModeError } from '@/config/dataMode';
import { supabase } from '@/config/supabaseClient';
import { createFallbackProfile } from '@/domain/profile';
import { profileRepository } from '@/repositories/profileRepository';
import { walletRepository } from '@/repositories/walletRepository';

const UserContext = createContext();

function withWalletBalance(profile, account) {
  return {
    ...profile,
    wallet_balance: (account?.available_balance_minor ?? 0) / 100,
    wallet_balance_minor: account?.available_balance_minor ?? 0,
    wallet_held_minor: account?.held_balance_minor ?? 0,
  };
}

export function UserProvider({ children }) {
  const [role, setRole] = useState('sender');
  const [profile, setProfile] = useState(null);
  const [loading, setLoading] = useState(() => !dataModeError);
  const [userId, setUserId] = useState(null);
  const [authError, setAuthError] = useState(dataModeError);
  const [theme, setTheme] = useState(() => typeof window === 'undefined' ? 'light' : localStorage.getItem('cs_theme') || 'light');

  const clearUser = () => {
    setUserId(null);
    setProfile(null);
  };

  const fetchProfile = async (uid, phone) => {
    const [storedProfile, walletAccount] = await Promise.all([
      profileRepository.findById(uid),
      walletRepository.findAccount(uid),
    ]);
    setProfile(withWalletBalance(storedProfile ?? createFallbackProfile(uid, phone || ''), walletAccount));
  };

  useEffect(() => {
    const syncTheme = () => {
      const savedTheme = localStorage.getItem('cs_theme') || 'light';
      document.documentElement.classList.toggle('dark', savedTheme === 'dark');
    };
    syncTheme();

    if (dataModeError) {
      return undefined;
    }

    let active = true;
    const applySession = async (session) => {
      if (!session?.user) {
        if (active) clearUser();
        return;
      }
      try {
        await fetchProfile(session.user.id, session.user.phone);
        if (active) {
          setUserId(session.user.id);
          setAuthError(null);
        }
      } catch (error) {
        if (active) setAuthError(error.message || 'Unable to load your account.');
      }
    };

    const initialize = async () => {
      const { data, error } = await supabase.auth.getUser();
      if (error) {
        if (active) setAuthError(error.message);
      } else {
        await applySession(data?.user ? { user: data.user } : null);
      }
      if (active) setLoading(false);
    };

    initialize();
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      applySession(session).finally(() => active && setLoading(false));
    });
    return () => {
      active = false;
      subscription?.unsubscribe();
    };
  }, []);

  const requestOtp = async (phone) => {
    if (dataModeError) throw new Error(dataModeError);
    const { error } = await supabase.auth.signInWithOtp({ phone });
    if (error) throw error;
  };

  const verifyOtp = async (phone, token) => {
    if (dataModeError) throw new Error(dataModeError);
    const { data, error } = await supabase.auth.verifyOtp({ phone, token, type: 'sms' });
    if (error) throw error;
    if (!data?.user) throw new Error('The verification code did not create a session.');
    await fetchProfile(data.user.id, data.user.phone || phone);
    setUserId(data.user.id);
    setAuthError(null);
    return data.user;
  };

  const logout = async () => {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
    clearUser();
  };

  const toggleTheme = () => {
    setTheme((previous) => {
      const next = previous === 'light' ? 'dark' : 'light';
      document.documentElement.classList.toggle('dark', next === 'dark');
      localStorage.setItem('cs_theme', next);
      return next;
    });
  };

  const topUp = async (amount) => {
    if (!userId) throw new Error('Sign in before topping up a wallet.');
    const amountMinor = Math.round(Number(amount) * 100);
    const account = await walletRepository.requestDemoTopUp(userId, amountMinor);
    setProfile((current) => current && withWalletBalance(current, account));
    return true;
  };

  return (
    <UserContext.Provider value={{
      role,
      setRole,
      toggleRole: () => setRole((previous) => previous === 'sender' ? 'traveler' : 'sender'),
      theme,
      toggleTheme,
      isAuthenticated: Boolean(userId),
      requestOtp,
      verifyOtp,
      logout,
      profile,
      loading,
      userId,
      authError,
      topUp,
      refreshProfile: () => userId ? fetchProfile(userId, profile?.phone_number) : Promise.resolve(),
    }}>
      {children}
    </UserContext.Provider>
  );
}

export function useUser() {
  const context = useContext(UserContext);
  if (!context) throw new Error('useUser must be used within a UserProvider');
  return context;
}
