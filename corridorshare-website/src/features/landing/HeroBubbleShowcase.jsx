'use client';

import React from 'react';
import { motion } from 'motion/react';
import { ShieldCheck, Lock, MapPin, Package, Clock } from 'lucide-react';

export default function HeroBubbleShowcase() {
  return (
    <div className="relative w-full flex items-center justify-center p-2 select-none">
      <div className="absolute top-8 left-1/4 w-48 h-48 bg-primary/10 rounded-full blur-3xl pointer-events-none animate-pulse-glow" />
      <div className="absolute bottom-6 right-8 w-40 h-40 bg-secondary/10 rounded-full blur-3xl pointer-events-none" />

      <div className="relative w-full max-w-md bg-surface-container-lowest border border-outline rounded-xl p-5 shadow-sm space-y-4 animate-enter">
        <div className="flex items-center justify-between pb-3 border-b border-outline-variant">
          <div className="flex items-center gap-2.5">
            <span className="w-9 h-9 rounded-lg bg-primary text-white text-xs font-semibold flex items-center justify-center tracking-wide">
              CS
            </span>
            <div>
              <p className="text-base font-semibold text-on-surface font-display leading-tight">
                Corridor match preview
              </p>
              <p className="text-xs text-primary font-semibold flex items-center gap-1.5 mt-0.5">
                <span className="w-1.5 h-1.5 rounded-full bg-primary" />
                3 sample matches nearby
              </p>
            </div>
          </div>
          <span className="text-[10px] bg-primary/10 text-primary font-semibold px-2.5 py-1 rounded-full uppercase tracking-[0.12em] border border-primary/15">
            Live
          </span>
        </div>

        <motion.div
          animate={{ y: [-4, 4, -4] }}
          transition={{ duration: 5.5, repeat: Infinity, ease: 'easeInOut' }}
          className="bg-surface-container-low border border-outline rounded-xl p-4 space-y-3"
        >
          <div className="flex justify-between items-center gap-3">
            <div className="flex items-center gap-2.5 min-w-0">
              <div className="p-2.5 rounded-lg bg-primary text-white shrink-0">
                <Package className="w-4 h-4" />
              </div>
              <div className="min-w-0">
                <span className="text-[10px] uppercase font-semibold text-primary tracking-[0.12em]">Corridor match</span>
                <h4 className="text-lg font-semibold text-on-surface font-display leading-tight truncate">Dhaka ↔ Mymensingh</h4>
              </div>
            </div>
            <div className="text-right shrink-0">
              <span className="text-[10px] text-on-surface-variant block font-medium">Surcharge</span>
              <span className="text-xl font-semibold text-primary font-display">250 BDT</span>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-2 text-xs">
            <div className="bg-surface p-2.5 rounded-lg border border-outline-variant flex items-center gap-2">
              <MapPin className="w-4 h-4 text-primary flex-shrink-0" />
              <div>
                <span className="text-[10px] text-on-surface-variant block font-semibold uppercase tracking-wide">Detour</span>
                <span className="font-semibold text-sm text-on-surface">2.5 km off N3</span>
              </div>
            </div>
            <div className="bg-surface p-2.5 rounded-lg border border-outline-variant flex items-center gap-2">
              <Clock className="w-4 h-4 text-secondary flex-shrink-0" />
              <div>
                <span className="text-[10px] text-on-surface-variant block font-semibold uppercase tracking-wide">ETA</span>
                <span className="font-semibold text-sm text-on-surface">Tonight 8:30</span>
              </div>
            </div>
          </div>

          <div className="space-y-1.5">
            <div className="flex justify-between text-xs font-semibold text-on-surface">
              <span>Geofence fit</span>
              <span className="text-primary">92%</span>
            </div>
            <div className="w-full h-1.5 bg-primary/15 rounded-full overflow-hidden">
              <div className="h-full bg-primary rounded-full w-[92%]" />
            </div>
          </div>
        </motion.div>

        <div className="grid grid-cols-2 gap-3">
          <motion.div
            animate={{ y: [3, -3, 3] }}
            transition={{ duration: 6, repeat: Infinity, ease: 'easeInOut', delay: 0.2 }}
            className="bg-surface border border-outline-variant rounded-xl p-3 flex items-center gap-2.5"
          >
            <div className="relative flex-shrink-0">
              <div className="w-10 h-10 rounded-full bg-primary/10 border border-primary/20 flex items-center justify-center text-xs font-semibold text-primary">
                AI
              </div>
              <ShieldCheck className="w-4 h-4 text-primary absolute -bottom-0.5 -right-0.5 bg-surface rounded-full" />
            </div>
            <div>
              <span className="text-sm font-semibold text-on-surface block">Aminul I.</span>
              <span className="text-xs font-semibold text-primary">NID reviewed</span>
            </div>
          </motion.div>

          <motion.div
            animate={{ y: [-3, 3, -3] }}
            transition={{ duration: 6.4, repeat: Infinity, ease: 'easeInOut', delay: 0.4 }}
            className="bg-surface border border-outline-variant rounded-xl p-3 flex items-center gap-2.5"
          >
            <div className="w-10 h-10 rounded-full bg-secondary/10 border border-secondary/20 flex items-center justify-center text-secondary flex-shrink-0">
              <Lock className="w-4 h-4" />
            </div>
            <div>
              <span className="text-sm font-semibold text-on-surface block leading-tight">Escrow held</span>
              <span className="text-xs font-medium text-on-surface-variant">OTP release</span>
            </div>
          </motion.div>
        </div>
      </div>
    </div>
  );
}
