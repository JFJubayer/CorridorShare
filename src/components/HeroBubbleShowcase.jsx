'use client';

import React, { useState } from 'react';
import { motion } from 'motion/react';
import { ShieldCheck, Lock, MapPin, Sparkles, Star, Package, ArrowRight, Zap, CheckCircle2 } from 'lucide-react';

export default function HeroBubbleShowcase() {
  const [activeBubble, setActiveBubble] = useState(null);

  return (
    <div className="relative w-full h-full min-h-[440px] flex items-center justify-center p-2 select-none">
      {/* Background Ambient Orange Liquid Glow Blobs */}
      <div className="absolute top-10 left-1/4 w-64 h-64 bg-gradient-to-br from-orange-500/25 to-amber-500/15 rounded-full blur-3xl pointer-events-none animate-pulse-glow" />
      <div className="absolute bottom-6 right-10 w-52 h-52 bg-gradient-to-tr from-amber-600/20 to-orange-400/20 rounded-full blur-3xl pointer-events-none animate-bubble-float" />

      {/* Main Glassmorphic Bubble Container */}
      <div className="relative w-full max-w-lg bg-surface-container-lowest/80 backdrop-blur-2xl border border-orange-500/30 rounded-[36px] p-6 shadow-2xl overflow-hidden space-y-5">
        
        {/* Subtle Top Header Pill */}
        <div className="flex items-center justify-between pb-3 border-b border-orange-500/15">
          <div className="flex items-center gap-2">
            <span className="w-8 h-8 rounded-full bg-gradient-to-br from-orange-500 to-amber-500 flex items-center justify-center text-white text-xs font-black shadow-md shadow-orange-500/30">
              CS
            </span>
            <div>
              <p className="text-xs font-extrabold text-on-surface flex items-center gap-1">
                Highway Geofence Radar
                <Sparkles className="w-3.5 h-3.5 text-orange-500 animate-spin" style={{ animationDuration: '8s' }} />
              </p>
              <p className="text-[10px] text-orange-600 dark:text-orange-400 font-bold flex items-center gap-1">
                <span className="w-1.5 h-1.5 rounded-full bg-orange-500 animate-ping"></span>
                3 Live Matched Corridor Paths Nearby
              </p>
            </div>
          </div>
          <span className="text-[10px] bg-gradient-to-r from-orange-500 to-amber-500 text-white font-black px-3 py-1 rounded-full uppercase tracking-wider shadow-sm">
            Live Stream
          </span>
        </div>

        {/* Central Floating Match Card */}
        <motion.div 
          animate={{ y: [0, -6, 0] }}
          transition={{ duration: 4.5, repeat: Infinity, ease: "easeInOut" }}
          className="bg-gradient-to-br from-orange-500/10 via-amber-500/5 to-transparent border border-orange-500/25 rounded-3xl p-5 shadow-lg relative space-y-4 backdrop-blur-md"
        >
          <div className="flex justify-between items-center">
            <div className="flex items-center gap-2">
              <div className="p-2 rounded-2xl bg-orange-500 text-white shadow-md shadow-orange-500/30">
                <Package className="w-5 h-5" />
              </div>
              <div>
                <span className="text-[10px] uppercase font-bold text-orange-600 dark:text-orange-400 tracking-wider">Matched Journey</span>
                <h4 className="text-sm font-black text-on-surface">Dhaka ↔ Mymensingh</h4>
              </div>
            </div>
            <div className="text-right">
              <span className="text-xs text-on-surface-variant block font-medium">Earn Surcharge</span>
              <span className="text-lg font-black text-orange-600 dark:text-orange-400 font-display">250 BDT</span>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-2 text-xs">
            <div className="bg-surface/80 dark:bg-surface-container-low/80 p-2.5 rounded-2xl border border-orange-500/10 flex items-center gap-2">
              <MapPin className="w-4 h-4 text-orange-500" />
              <div>
                <span className="text-[9px] text-on-surface-variant block font-bold">Detour</span>
                <span className="font-extrabold text-on-surface">2.5 KM off N3</span>
              </div>
            </div>
            <div className="bg-surface/80 dark:bg-surface-container-low/80 p-2.5 rounded-2xl border border-orange-500/10 flex items-center gap-2">
              <Zap className="w-4 h-4 text-amber-500" />
              <div>
                <span className="text-[9px] text-on-surface-variant block font-bold">ETA Match</span>
                <span className="font-extrabold text-on-surface">Tonight 8:30 PM</span>
              </div>
            </div>
          </div>

          {/* Interactive Liquid Progress Bar */}
          <div className="space-y-1">
            <div className="flex justify-between text-[10px] font-bold text-on-surface-variant">
              <span>Geofence Match Lock</span>
              <span className="text-orange-600 dark:text-orange-400 font-extrabold">92% Verified</span>
            </div>
            <div className="w-full h-2 bg-orange-500/15 rounded-full overflow-hidden p-0.5 border border-orange-500/20">
              <div className="h-full bg-gradient-to-r from-orange-500 to-amber-400 rounded-full w-[92%] relative">
                <div className="absolute right-0 top-0 bottom-0 w-4 bg-white/40 animate-pulse rounded-full"></div>
              </div>
            </div>
          </div>
        </motion.div>

        {/* Floating Bubble Badges Stack */}
        <div className="grid grid-cols-2 gap-3">
          {/* Bubble 1: Verified Traveler */}
          <motion.div
            whileHover={{ scale: 1.04, y: -4 }}
            animate={{ y: [0, -4, 0] }}
            transition={{ duration: 5, repeat: Infinity, ease: "easeInOut", delay: 0.5 }}
            className="bg-surface-container-low/90 border border-orange-500/20 rounded-2xl p-3.5 flex items-center gap-3 shadow-md cursor-pointer hover:border-orange-500/50"
            onMouseEnter={() => setActiveBubble(1)}
            onMouseLeave={() => setActiveBubble(null)}
          >
            <div className="relative">
              <div className="w-10 h-10 rounded-full bg-gradient-to-tr from-orange-500 to-amber-400 p-0.5 shadow-md">
                <div className="w-full h-full rounded-full bg-surface flex items-center justify-center text-xs font-bold text-orange-600">
                  AI
                </div>
              </div>
              <ShieldCheck className="w-4 h-4 text-orange-500 absolute -bottom-1 -right-1 bg-surface rounded-full fill-orange-500/20" />
            </div>
            <div>
              <div className="flex items-center gap-1">
                <span className="text-xs font-black text-on-surface">Aminul I.</span>
                <span className="text-[10px] text-amber-500 font-bold flex items-center"><Star className="w-3 h-3 fill-amber-400 text-amber-400" /> 4.9</span>
              </div>
              <span className="text-[10px] text-orange-600 dark:text-orange-400 font-bold">NID Verified Traveler</span>
            </div>
          </motion.div>

          {/* Bubble 2: Escrow Lock */}
          <motion.div
            whileHover={{ scale: 1.04, y: -4 }}
            animate={{ y: [0, -4, 0] }}
            transition={{ duration: 5.5, repeat: Infinity, ease: "easeInOut", delay: 1 }}
            className="bg-surface-container-low/90 border border-orange-500/20 rounded-2xl p-3.5 flex items-center gap-3 shadow-md cursor-pointer hover:border-orange-500/50"
            onMouseEnter={() => setActiveBubble(2)}
            onMouseLeave={() => setActiveBubble(null)}
          >
            <div className="w-10 h-10 rounded-full bg-gradient-to-br from-amber-500/20 to-orange-500/20 border border-orange-500/30 flex items-center justify-center text-orange-600 dark:text-orange-400 shadow-inner">
              <Lock className="w-5 h-5" />
            </div>
            <div>
              <span className="text-xs font-black text-on-surface block">Escrow Protected</span>
              <span className="text-[10px] text-on-surface-variant font-medium">OTP Deposit Release</span>
            </div>
          </motion.div>
        </div>

        {/* Floating Pill Status Bar */}
        <div className="flex items-center justify-between text-xs text-on-surface-variant pt-1 border-t border-orange-500/10">
          <span className="flex items-center gap-1.5 font-bold">
            <CheckCircle2 className="w-4 h-4 text-orange-500" />
            Open-Box Security Scan
          </span>
          <span className="text-[10px] font-black uppercase text-orange-600 dark:text-orange-400 bg-orange-500/10 px-2.5 py-0.5 rounded-full border border-orange-500/20">
            Zero Contraband Policy
          </span>
        </div>
      </div>
    </div>
  );
}
