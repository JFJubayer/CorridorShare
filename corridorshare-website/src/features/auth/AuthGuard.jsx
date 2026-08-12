'use client';

import React, { useState } from 'react';
import { useUser } from '@/context/UserContext';
import AuthModal from './AuthModal';
import { Lock, ShieldAlert, UserCheck, ShieldX } from 'lucide-react';
import Card from '@/components/ui/Card';

export default function AuthGuard({ children, title = "Authentication Required", requireAdmin = false }) {
  const { isAuthenticated, profile, loading, authError } = useUser();
  const [showModal, setShowModal] = useState(false);

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] gap-3">
        <svg className="animate-spin h-8 w-8 text-primary" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
          <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
        </svg>
        <span className="text-xs font-bold text-on-surface-variant">Checking authorization...</span>
      </div>
    );
  }

  if (!isAuthenticated) {
    return (
      <div className="min-h-[75vh] flex items-center justify-center p-6 bg-background">
        <Card className="max-w-md w-full border border-primary/25 bg-surface p-8 text-center rounded-xl shadow-sm space-y-6">
          
          <div className="w-14 h-14 rounded-xl bg-primary text-white flex items-center justify-center mx-auto shadow-sm">
            <Lock className="w-7 h-7" />
          </div>

          <div className="space-y-2">
            <span className="eyebrow">
              <ShieldAlert className="w-3.5 h-3.5" />
              Restricted access
            </span>
            <h2 className="text-2xl md:text-3xl font-semibold text-on-surface tracking-tight font-display">
              {title}
            </h2>
            <p className="text-xs md:text-sm text-on-surface-variant leading-relaxed font-medium">
              {authError || 'Please sign up or log in with your phone number to access highway corridor matching, deal negotiations, and identity verification.'}
            </p>
            {authError && (
              <p className="text-[11px] text-on-surface-variant font-medium">
                Matching and chat stay gated until the website can reach a configured backend.
              </p>
            )}
          </div>

          {!authError && <div className="pt-2">
            <button
              onClick={() => setShowModal(true)}
              className="w-full bg-primary hover:bg-primary-700 text-white py-3.5 rounded-full font-semibold text-xs tracking-wide transition-all shadow-sm flex items-center justify-center gap-2 cursor-pointer tactile-btn"
            >
              <UserCheck className="w-4 h-4" />
              Log In / Register Now
            </button>
          </div>}

          <AuthModal 
            isOpen={showModal} 
            onClose={() => setShowModal(false)}
            title="Log in to unlock live corridor matching and deal chat."
          />
        </Card>
      </div>
    );
  }

  // Admin Role Check
  if (requireAdmin && profile?.role !== 'admin') {
    return (
      <div className="min-h-[75vh] flex items-center justify-center p-6 bg-background">
        <Card className="max-w-md w-full border border-red-500/30 bg-surface p-8 text-center rounded-xl shadow-sm space-y-6">
          <div className="w-16 h-16 rounded-full bg-red-500/10 text-red-600 flex items-center justify-center mx-auto border border-red-500/20">
            <ShieldX className="w-8 h-8" />
          </div>
          <div className="space-y-2">
            <span className="text-[10px] font-black text-red-600 bg-red-500/10 px-3.5 py-1 rounded-full border border-red-500/20 uppercase tracking-widest inline-flex items-center gap-1.5 shadow-xs">
              403 FORBIDDEN
            </span>
            <h2 className="text-2xl font-black text-on-surface font-display">Admin Access Required</h2>
            <p className="text-xs text-on-surface-variant leading-relaxed font-medium">
              You do not have sufficient administrative permissions to access the verification portal.
            </p>
          </div>
        </Card>
      </div>
    );
  }

  return children;
}
