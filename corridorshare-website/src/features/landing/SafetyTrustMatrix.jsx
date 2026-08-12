'use client';

import React, { useState } from 'react';
import Card from '@/components/ui/Card';
import {
  ShieldCheck, Lock, Camera
} from 'lucide-react';

export default function SafetyTrustMatrix() {
  const [activeTab, setActiveTab] = useState(0);

  const safetyFeatures = [
    {
      id: 'nid',
      title: 'Manual NID Review',
      badge: 'ADMIN REVIEWED',
      icon: ShieldCheck,
      tagline: 'Human review of submitted NID photos before posting privileges expand',
      description: 'Travelers and senders can upload Bangladesh National ID (NID) photos. An admin compliance panel reviews submissions and updates verification status. This is a manual process, not biometric matching.',
      metrics: [
        { label: 'Review Style', value: 'Manual Admin' },
        { label: 'Goal', value: 'Identity Check' },
      ],
      previewBadge: 'NID Status: Pending Review'
    },
    {
      id: 'escrow',
      title: 'Escrow Wallet Lock',
      badge: 'ESCROW HOLD',
      icon: Lock,
      tagline: 'Rewards stay held until a delivery OTP confirms handoff',
      description: 'Agreed delivery rewards are locked in platform escrow when a deal is inspected and locked. Funds move to the traveler only after the correct delivery OTP is entered.',
      metrics: [
        { label: 'Fund Lock', value: 'Wallet Hold' },
        { label: 'Release Trigger', value: 'Delivery OTP' },
      ],
      previewBadge: 'Escrow Status: Funds Held'
    },
    {
      id: 'openbox',
      title: 'Open-Box Inspection',
      badge: 'PHOTO PROOF',
      icon: Camera,
      tagline: 'Traveler uploads open-box photo proof before escrow lock',
      description: 'Travelers can inspect package contents and must upload an inspection photo before locking escrow. This helps reduce contraband risk; it does not claim a perfect safety record.',
      metrics: [
        { label: 'Cargo Audit', value: 'Photo Upload' },
        { label: 'Policy', value: 'No Contraband' },
      ],
      previewBadge: 'Cargo Inspection: Required'
    }
  ];

  const current = safetyFeatures[activeTab];
  const Icon = current.icon;

  return (
    <section className="mb-20">
      <div className="text-center max-w-2xl mx-auto mb-10 space-y-3">
        <span className="text-xs font-black text-orange-700 dark:text-orange-300 bg-orange-500/10 px-4 py-1.5 rounded-full border border-orange-500/30 tracking-widest uppercase inline-flex items-center gap-1.5 shadow-xs">
          <ShieldCheck className="w-4 h-4 text-orange-500" />
          SAFETY WORKFLOWS
        </span>
        <h2 className="text-3xl md:text-5xl font-black text-on-surface tracking-tight font-display">
          Practical Trust Layers
        </h2>
        <p className="text-sm md:text-base text-on-surface-variant leading-relaxed font-medium">
          CorridorShare combines manual NID review, escrow holds, and open-box photo checks for peer-to-peer highway deliveries across Bangladesh.
        </p>
      </div>

      <div className="flex flex-wrap justify-center gap-2.5 mb-8 max-w-3xl mx-auto">
        {safetyFeatures.map((feat, i) => {
          const TabIcon = feat.icon;
          const isActive = activeTab === i;
          return (
            <button
              key={feat.id}
              onClick={() => setActiveTab(i)}
              aria-label={`Select ${feat.title} feature`}
              className={`px-6 py-3 rounded-full font-black text-xs md:text-sm transition-all tactile-btn flex items-center gap-2 cursor-pointer border ${
                isActive
                  ? 'bg-gradient-to-r from-orange-600 to-amber-500 text-white border-orange-400 shadow-lg shadow-orange-500/25 scale-[1.02]'
                  : 'bg-surface-container-lowest text-on-surface-variant border-outline hover:bg-orange-500/10'
              }`}
            >
              <TabIcon className={`w-4 h-4 ${isActive ? 'text-white' : 'text-orange-500'}`} />
              {feat.title}
            </button>
          );
        })}
      </div>

      <Card className="max-w-4xl mx-auto border border-orange-500/25 bg-surface p-6 md:p-10 shadow-2xl rounded-[36px] relative overflow-hidden">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center">
          <div className="lg:col-span-7 space-y-5">
            <div className="inline-flex items-center gap-2 bg-orange-500/10 text-orange-600 dark:text-orange-400 px-3.5 py-1 rounded-full border border-orange-500/20 text-xs font-black uppercase tracking-wider">
              <span className="w-2 h-2 rounded-full bg-orange-500 animate-pulse"></span>
              {current.badge}
            </div>
            <h3 className="text-2xl md:text-3xl font-black text-on-surface tracking-tight leading-tight">
              {current.title}
            </h3>
            <p className="text-sm font-bold text-orange-600 dark:text-orange-400">
              &quot;{current.tagline}&quot;
            </p>
            <p className="text-sm text-on-surface-variant leading-relaxed font-medium">
              {current.description}
            </p>
            <div className="grid grid-cols-2 gap-4 pt-2">
              {current.metrics.map((m, idx) => (
                <div key={idx} className="bg-surface-container-low p-4 rounded-2xl border border-orange-500/15">
                  <p className="text-[10px] text-on-surface-variant font-bold uppercase tracking-wider">{m.label}</p>
                  <p className="text-base font-black text-on-surface font-mono mt-0.5">{m.value}</p>
                </div>
              ))}
            </div>
          </div>

          <div className="lg:col-span-5 relative">
            <div className="bg-gradient-to-br from-orange-500/15 to-amber-500/10 border border-orange-500/25 rounded-[28px] p-6 shadow-inner space-y-4 text-center">
              <div className="w-16 h-16 rounded-full bg-gradient-to-br from-orange-500 to-amber-400 text-white flex items-center justify-center mx-auto shadow-lg shadow-orange-500/30">
                <Icon className="w-8 h-8" />
              </div>
              <div className="space-y-1">
                <p className="text-sm font-black text-on-surface">{current.title}</p>
                <p className="text-xs text-orange-600 dark:text-orange-400 font-extrabold bg-orange-500/10 px-3 py-1 rounded-full border border-orange-500/20 w-fit mx-auto">
                  ✓ {current.previewBadge}
                </p>
              </div>
              <div className="w-full h-1.5 bg-orange-500/15 rounded-full overflow-hidden">
                <div className="w-full h-full bg-gradient-to-r from-orange-500 to-amber-400"></div>
              </div>
              <p className="text-xs text-on-surface-variant leading-normal font-medium">
                Works with user-posted corridors anywhere in Bangladesh — not limited to a single highway pair.
              </p>
            </div>
          </div>
        </div>
      </Card>
    </section>
  );
}
