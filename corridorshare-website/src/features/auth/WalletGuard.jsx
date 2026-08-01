'use client';

import React, { useState } from 'react';
import { useUser } from '@/context/UserContext';
import { ShieldAlert, PlusCircle, CreditCard, X } from 'lucide-react';

export default function WalletGuard({ children, fallback = null }) {
  const { profile, topUp } = useUser();
  const [showModal, setShowModal] = useState(false);
  const [depositAmount, setDepositAmount] = useState('20');
  const [isDepositing, setIsDepositing] = useState(false);

  const isSuspended = profile && parseFloat(profile.wallet_balance) < 0.00;

  const handleTopUp = async () => {
    setIsDepositing(true);
    setTimeout(async () => {
      await topUp(parseFloat(depositAmount));
      setIsDepositing(false);
      setShowModal(false);
    }, 1500);
  };

  if (isSuspended) {
    return (
      <div className="relative">
        {/* Warning Banner */}
        <div className="bg-orange-500/10 border border-orange-500/30 rounded-2xl p-4 mb-4 flex items-start gap-3 shadow-sm">
          <ShieldAlert className="text-orange-600 dark:text-orange-400 w-6 h-6 flex-shrink-0 mt-0.5" />
          <div className="flex-grow">
            <span className="text-sm font-black text-on-surface block">Account Suspended</span>
            <p className="text-xs text-on-surface-variant leading-relaxed mt-1 font-medium">
              Your wallet balance is negative ({profile.wallet_balance} BDT). Please top up at least 20 BDT via bKash or Nagad to activate matching services.
            </p>
            <button
              onClick={() => setShowModal(true)}
              className="mt-3 flex items-center gap-1.5 bg-gradient-to-r from-orange-600 to-amber-500 hover:from-orange-500 hover:to-amber-400 text-white font-bold text-xs px-4 py-2 rounded-full transition-all shadow-md"
            >
              <PlusCircle className="w-3.5 h-3.5" />
              Recharge Now
            </button>
          </div>
        </div>

        {/* Disabled Overlay on Children */}
        {fallback ? (
          fallback
        ) : (
          <div className="relative pointer-events-none opacity-40 select-none">
            {children}
          </div>
        )}

        {/* Simulated Top Up Modal */}
        {showModal && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
            <div className="absolute inset-0 bg-slate-950/70 backdrop-blur-sm" onClick={() => setShowModal(false)}></div>
            <div className="bg-surface rounded-[28px] border border-orange-500/30 shadow-2xl p-6 w-full max-w-sm relative z-10 animate-in fade-in zoom-in-95 duration-200">
              <button 
                onClick={() => setShowModal(false)}
                className="absolute right-4 top-4 text-on-surface-variant hover:text-on-surface rounded-full p-1 hover:bg-orange-500/10 transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
              
              <div className="flex items-center gap-3 mb-4">
                <div className="bg-orange-500/10 text-orange-600 dark:text-orange-400 p-3 rounded-full border border-orange-500/20">
                  <CreditCard className="w-6 h-6" />
                </div>
                <div>
                  <h3 className="font-black text-on-surface text-lg">Top Up Wallet</h3>
                  <p className="text-xs text-on-surface-variant font-medium">Fast simulated deposit via bKash/Nagad</p>
                </div>
              </div>

              <div className="space-y-4 my-4">
                <div>
                  <label className="block text-[10px] font-bold text-on-surface-variant uppercase tracking-wider mb-1.5">Select Amount</label>
                  <div className="grid grid-cols-3 gap-2">
                    {['20', '50', '100'].map((amt) => (
                      <button
                        key={amt}
                        onClick={() => setDepositAmount(amt)}
                        className={`py-2.5 rounded-full font-black text-xs border transition-all ${
                          depositAmount === amt 
                            ? 'bg-gradient-to-r from-orange-600 to-amber-500 text-white border-orange-500 shadow-md' 
                            : 'bg-surface-container-low text-on-surface border-outline hover:bg-orange-500/10'
                        }`}
                      >
                        {amt} BDT
                      </button>
                    ))}
                  </div>
                </div>

                <div>
                  <label className="block text-[10px] font-bold text-on-surface-variant uppercase tracking-wider mb-1.5">Or Enter Custom Amount</label>
                  <div className="flex items-center border border-orange-500/20 rounded-full px-3.5 py-2.5 focus-within:ring-2 focus-within:ring-orange-500 transition-all bg-surface-container-low">
                    <span className="text-orange-600 dark:text-orange-400 font-bold text-xs mr-2">BDT</span>
                    <input
                      type="number"
                      value={depositAmount}
                      onChange={(e) => setDepositAmount(e.target.value)}
                      className="border-none p-0 text-sm font-bold w-full focus:ring-0 text-on-surface bg-transparent outline-none"
                      placeholder="e.g. 200"
                    />
                  </div>
                </div>
              </div>

              <button
                onClick={handleTopUp}
                disabled={isDepositing || !depositAmount || parseFloat(depositAmount) <= 0}
                className="w-full bg-gradient-to-r from-orange-600 to-amber-500 text-white py-3.5 rounded-full font-black text-xs uppercase tracking-wider hover:from-orange-500 hover:to-amber-400 transition-all flex items-center justify-center gap-2 shadow-lg shadow-orange-500/25 disabled:opacity-50 disabled:pointer-events-none"
              >
                {isDepositing ? (
                  <span className="flex items-center gap-2">
                    <svg className="animate-spin h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    Connecting bKash...
                  </span>
                ) : (
                  <>
                    Confirm Payment ({depositAmount} BDT)
                  </>
                )}
              </button>
            </div>
          </div>
        )}
      </div>
    );
  }

  return children;
}

