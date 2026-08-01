'use client';

import React from 'react';
import { useUser } from '@/context/UserContext';
import { ShieldAlert } from 'lucide-react';

/** Prevents suspended identities from using protected product actions.
 * Suspension is read from the server-owned profile state; wallet balances are
 * never used as an authorization signal.
 */
export default function WalletGuard({ children, fallback = null }) {
  const { profile } = useUser();
  const isSuspended = profile?.nid_status === 'suspended';

  if (!isSuspended) return children ?? null;

  return (
    <div className="relative">
      <div className="bg-red-500/10 border border-red-500/30 rounded-2xl p-4 mb-4 flex items-start gap-3 shadow-sm">
        <ShieldAlert className="text-red-600 dark:text-red-400 w-6 h-6 flex-shrink-0 mt-0.5" />
        <div>
          <span className="text-sm font-black text-on-surface block">Account suspended</span>
          <p className="text-xs text-on-surface-variant leading-relaxed mt-1 font-medium">
            This account cannot create or match deliveries. Contact CorridorShare support for a reviewed status change.
          </p>
        </div>
      </div>
      {fallback ?? <div className="pointer-events-none opacity-40 select-none">{children}</div>}
    </div>
  );
}
