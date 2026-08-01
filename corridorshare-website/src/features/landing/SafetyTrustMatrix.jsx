'use client';

import React, { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import Card from '@/components/ui/Card';
import { 
  ShieldCheck, Lock, Camera, CheckCircle2, ShieldAlert, ArrowRight, Eye, KeyRound 
} from 'lucide-react';

export default function SafetyTrustMatrix() {
  const [activeTab, setActiveTab] = useState(0);

  const safetyFeatures = [
    {
      id: 'nid',
      title: 'Biometric NID Verification',
      badge: 'GOVERNMENT NID AUDITED',
      icon: ShieldCheck,
      color: 'orange',
      tagline: 'Manual NID identity audit before active route matching',
      description: 'Every traveler and package sender must submit official Bangladesh National ID (NID) photos. Our admin compliance panel verifies NID details before unlocking travel posting privileges.',
      metrics: [
        { label: 'Audit Time', value: '< 15 Mins' },
        { label: 'Verification Rate', value: '100% Verified' },
      ],
      previewBadge: 'NID Status: Verified'
    },
    {
      id: 'escrow',
      title: 'Smart Escrow Wallet Lock',
      badge: '100% ESCROW PROTECTED',
      icon: Lock,
      color: 'amber',
      tagline: 'Zero upfront payouts until OTP pickup code handoff',
      description: 'Delivery rewards are locked securely in platform escrow. Funds are never transferred to the traveler until the recipient enters the secret 6-digit OTP code upon parcel delivery.',
      metrics: [
        { label: 'Fund Lock', value: 'Guaranteed' },
        { label: 'Release Trigger', value: '6-Digit OTP' },
      ],
      previewBadge: 'Escrow Status: Funds Locked'
    },
    {
      id: 'openbox',
      title: 'Open-Box Inspection Control',
      badge: 'CONTRABAND FREE CERTIFIED',
      icon: Camera,
      color: 'orange',
      tagline: 'Mandatory photo proof of package contents before travel',
      description: 'Travelers have the legal right to inspect package contents. Before accepting cargo, travelers upload timestamped open-box inspection photos to the deal room to ensure zero contraband.',
      metrics: [
        { label: 'Cargo Audit', value: 'Photo Proof' },
        { label: 'Safety Record', value: 'Zero Violations' },
      ],
      previewBadge: 'Cargo Inspection: Approved'
    }
  ];

  const current = safetyFeatures[activeTab];
  const Icon = current.icon;

  return (
    <section className="mb-20">
      {/* Section Header */}
      <div className="text-center max-w-2xl mx-auto mb-10 space-y-3">
        <span className="text-xs font-black text-orange-700 dark:text-orange-300 bg-orange-500/10 px-4 py-1.5 rounded-full border border-orange-500/30 tracking-widest uppercase inline-flex items-center gap-1.5 shadow-xs">
          <ShieldCheck className="w-4 h-4 text-orange-500" />
          TRIPLE-LOCK SECURITY ARCHITECTURE
        </span>
        <h2 className="text-3xl md:text-5xl font-black text-on-surface tracking-tight font-display">
          Three Layers of Unbreakable Trust
        </h2>
        <p className="text-sm md:text-base text-on-surface-variant leading-relaxed font-medium">
          Every parcel carried across Bangladesh highway corridors is protected by biometric verification, escrow hold locks, and open-box photo audits.
        </p>
      </div>

      {/* Interactive Tab Controls */}
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

      {/* Main Interactive Showcase Card */}
      <Card className="max-w-4xl mx-auto border border-orange-500/25 bg-surface p-6 md:p-10 shadow-2xl rounded-[36px] relative overflow-hidden">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center">
          
          {/* Left Feature Description */}
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

          {/* Right Visual Graphic Component */}
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
                Active geofence security rules enforced on all Dhaka, Mymensingh, and Chittagong corridors.
              </p>
            </div>
          </div>

        </div>
      </Card>
    </section>
  );
}

