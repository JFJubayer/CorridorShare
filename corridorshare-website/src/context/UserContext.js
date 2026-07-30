'use client';

import React, { createContext, useContext, useState, useEffect } from 'react';
import { supabase } from '@/config/supabaseClient';

const UserContext = createContext();

export function UserProvider({ children }) {
  const [role, setRole] = useState('sender'); // default role is sender/receiver
  const [profile, setProfile] = useState(null);
  const [loading, setLoading] = useState(true);
  const [userId, setUserId] = useState(null);
  const [theme, setTheme] = useState(() => {
    if (typeof window !== 'undefined') {
      return localStorage.getItem('cs_theme') || 'light';
    }
    return 'light';
  });
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  // Fetch current user & profile
  const fetchProfile = async (uid, phone = '+8801700000000') => {
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', uid);
      
      if (data && data.length > 0) {
        setProfile(data[0]);
      } else {
        // Fallback for new profiles
        setProfile({
          id: uid,
          phone_number: phone,
          nid_status: 'unverified',
          nid_photo_url: '',
          wallet_balance: 40.00 // Default balance for testing
        });
      }
    } catch (err) {
      console.error("Error loading profile:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    const initUser = async () => {
      // Check local storage persistent session
      const authSession = localStorage.getItem('cs_authenticated') === 'true';
      const authPhone = localStorage.getItem('cs_auth_phone') || '+8801700000000';
      
      if (authSession) {
        setIsAuthenticated(true);
        const { data } = await supabase.auth.getUser();
        if (data?.user) {
          setUserId(data.user.id);
          fetchProfile(data.user.id, authPhone);
        } else {
          const defaultUid = '11111111-1111-1111-1111-111111111111';
          setUserId(defaultUid);
          fetchProfile(defaultUid, authPhone);
        }
      } else {
        setIsAuthenticated(false);
        setLoading(false);
      }
    };

    // Initial theme DOM sync
    if (typeof window !== 'undefined') {
      const savedTheme = localStorage.getItem('cs_theme') || 'light';
      const root = window.document.documentElement;
      if (savedTheme === 'dark') {
        root.classList.add('dark');
      } else {
        root.classList.remove('dark');
      }
    }

    initUser();

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange((event, session) => {
      if (session?.user) {
        setUserId(session.user.id);
        fetchProfile(session.user.id, session.user.phone);
        setIsAuthenticated(true);
      }
    });

    return () => {
      subscription?.unsubscribe();
    };
  }, []);

  const toggleRole = () => {
    setRole((prev) => (prev === 'sender' ? 'traveler' : 'sender'));
  };

  const login = async (phone) => {
    localStorage.setItem('cs_authenticated', 'true');
    localStorage.setItem('cs_auth_phone', phone);
    setIsAuthenticated(true);
    const defaultUid = '11111111-1111-1111-1111-111111111111';
    setUserId(defaultUid);
    await fetchProfile(defaultUid, phone);
    return true;
  };

  const signup = async (phone) => {
    return login(phone);
  };

  const logout = () => {
    localStorage.removeItem('cs_authenticated');
    localStorage.removeItem('cs_auth_phone');
    setIsAuthenticated(false);
    setProfile(null);
  };

  const toggleTheme = () => {
    setTheme((prev) => {
      const next = prev === 'light' ? 'dark' : 'light';
      if (typeof window !== 'undefined') {
        const root = window.document.documentElement;
        if (next === 'dark') {
          root.classList.add('dark');
        } else {
          root.classList.remove('dark');
        }
        localStorage.setItem('cs_theme', next);
      }
      return next;
    });
  };

  const topUp = async (amount) => {
    if (!profile) return;
    const newBalance = parseFloat(profile.wallet_balance) + parseFloat(amount);
    
    // Update db
    const { error } = await supabase
      .from('profiles')
      .update({ wallet_balance: newBalance })
      .eq('id', profile.id);

    if (!error) {
      setProfile((prev) => ({
        ...prev,
        wallet_balance: newBalance
      }));
      return true;
    }
    return false;
  };

  const deductWallet = async (amount) => {
    if (!profile) return;
    const newBalance = parseFloat(profile.wallet_balance) - parseFloat(amount);
    
    const { error } = await supabase
      .from('profiles')
      .update({ wallet_balance: newBalance })
      .eq('id', profile.id);

    if (!error) {
      setProfile((prev) => ({
        ...prev,
        wallet_balance: newBalance
      }));
      return true;
    }
    return false;
  };

  const updateNIDStatus = async (status, photoUrl) => {
    if (!profile) return;
    const { error } = await supabase
      .from('profiles')
      .update({ nid_status: status, nid_photo_url: photoUrl })
      .eq('id', profile.id);

    if (!error) {
      setProfile((prev) => ({
        ...prev,
        nid_status: status,
        nid_photo_url: photoUrl
      }));
      return true;
    }
    return false;
  };

  return (
    <UserContext.Provider
      value={{
        role,
        setRole,
        toggleRole,
        theme,
        toggleTheme,
        isAuthenticated,
        login,
        signup,
        logout,
        profile,
        loading,
        userId,
        topUp,
        deductWallet,
        updateNIDStatus,
        refreshProfile: () => fetchProfile(userId)
      }}
    >
      {children}
    </UserContext.Provider>
  );
}

export function useUser() {
  const context = useContext(UserContext);
  if (!context) {
    throw new Error('useUser must be used within a UserProvider');
  }
  return context;
}
