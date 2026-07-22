'use client';

import React, { useState } from 'react';
import { useUser } from '@/context/UserContext';
import AuthModal from './AuthModal';
import { Lock, ShieldAlert, ArrowRight, UserCheck } from 'lucide-react';
import Card from '@/components/ui/Card';

export default function AuthGuard({ children, title = "Authentication Required" }) {
  const { isAuthenticated, loading } = useUser();
  const [showModal, setShowModal] = useState(false);

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] gap-3">
        <svg className="animate-spin h-8 w-8 text-orange-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
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
        <Card className="max-w-md w-full border border-orange-500/30 bg-surface p-8 text-center rounded-[36px] shadow-2xl space-y-6">
          
          <div className="w-16 h-16 rounded-full bg-gradient-to-br from-orange-600 to-amber-500 text-white flex items-center justify-center mx-auto shadow-lg shadow-orange-500/30">
            <Lock className="w-8 h-8" />
          </div>

          <div className="space-y-2">
            <span className="text-[10px] font-black text-orange-600 dark:text-orange-400 bg-orange-500/10 px-3.5 py-1 rounded-full border border-orange-500/20 uppercase tracking-widest inline-flex items-center gap-1.5 shadow-xs">
              <ShieldAlert className="w-3.5 h-3.5 text-orange-500" />
              RESTRICTED ACCESS
            </span>
            <h2 className="text-2xl md:text-3xl font-black text-on-surface tracking-tight font-display">
              {title}
            </h2>
            <p className="text-xs md:text-sm text-on-surface-variant leading-relaxed font-medium">
              Please sign up or log in with your phone number to access highway corridor matching, deal negotiations, and identity verification.
            </p>
          </div>

          <div className="pt-2">
            <button
              onClick={() => setShowModal(true)}
              className="w-full bg-gradient-to-r from-orange-600 to-amber-500 hover:from-orange-500 hover:to-amber-400 text-white py-4 rounded-full font-black text-xs uppercase tracking-wider transition-all shadow-lg shadow-orange-500/25 flex items-center justify-center gap-2 cursor-pointer tactile-btn"
            >
              <UserCheck className="w-4 h-4" />
              Log In / Register Now
            </button>
          </div>

          <AuthModal 
            isOpen={showModal} 
            onClose={() => setShowModal(false)}
            title="Log in to unlock live corridor matching and deal chat."
          />
        </Card>
      </div>
    );
  }

  return children;
}
