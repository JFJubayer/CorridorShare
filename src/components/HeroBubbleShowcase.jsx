'use client';

import React from 'react';
import { motion } from 'motion/react';
import { ShieldCheck, Lock, MapPin, Sparkles, Star, Package, Zap } from 'lucide-react';

export default function HeroBubbleShowcase() {
  return (
    <div className="relative w-full flex items-center justify-center p-2 select-none">
      {/* Background Ambient Orange Glow Blobs */}
      <div className="absolute top-6 left-1/4 w-56 h-56 bg-gradient-to-br from-orange-500/25 to-amber-500/15 rounded-full blur-3xl pointer-events-none animate-pulse-glow" />
      <div className="absolute bottom-4 right-6 w-48 h-48 bg-gradient-to-tr from-amber-600/20 to-orange-400/20 rounded-full blur-3xl pointer-events-none animate-bubble-float" />

      {/* Main Glassmorphic Bubble Container - Fixed Compact Size */}
      <div className="relative w-full max-w-md bg-surface-container-lowest/90 backdrop-blur-2xl border-2 border-orange-500/35 rounded-[32px] p-5 shadow-2xl overflow-hidden space-y-4">
        
        {/* Top Header */}
        <div className="flex items-center justify-between pb-3 border-b border-orange-500/20">
          <div className="flex items-center gap-2.5">
            <span className="w-9 h-9 rounded-full bg-gradient-to-br from-orange-500 to-amber-500 flex items-center justify-center text-white text-xs font-black shadow-md shadow-orange-500/30">
              CS
            </span>
            <div>
              <p className="text-base font-black text-on-surface flex items-center gap-1.5 font-display leading-tight">
                Highway Geofence Radar
                <Sparkles className="w-4 h-4 text-orange-500 animate-spin" style={{ animationDuration: '8s' }} />
              </p>
              <p className="text-xs text-orange-600 dark:text-orange-400 font-black flex items-center gap-1.5 mt-0.5">
                <span className="w-2 h-2 rounded-full bg-orange-500 animate-ping"></span>
                3 Live Corridor Matches Nearby
              </p>
            </div>
          </div>
          <span className="text-xs bg-gradient-to-r from-orange-600 to-amber-500 text-white font-black px-3 py-1 rounded-full uppercase tracking-wider shadow-sm">
            LIVE
          </span>
        </div>

        {/* Central Primary Match Card (Ultra-Smooth Floating Physics) */}
        <motion.div 
          animate={{ y: [-6, 6, -6] }}
          transition={{ 
            duration: 4.2, 
            repeat: Infinity, 
            ease: [0.45, 0, 0.55, 1] 
          }}
          className="bg-gradient-to-br from-orange-500/15 via-amber-500/10 to-transparent border-2 border-orange-500/35 rounded-2xl p-4 shadow-lg space-y-3 backdrop-blur-md will-change-transform transform-gpu"
        >
          <div className="flex justify-between items-center">
            <div className="flex items-center gap-2.5">
              <div className="p-2.5 rounded-xl bg-gradient-to-br from-orange-600 to-amber-500 text-white shadow-md shadow-orange-500/30">
                <Package className="w-5 h-5" />
              </div>
              <div>
                <span className="text-xs uppercase font-black text-orange-600 dark:text-orange-400 tracking-wider">CORRIDOR MATCH</span>
                <h4 className="text-lg md:text-xl font-black text-on-surface font-display leading-tight">Dhaka ↔ Mymensingh</h4>
              </div>
            </div>
            <div className="text-right">
              <span className="text-xs text-on-surface-variant block font-bold">Surcharge</span>
              <span className="text-2xl font-black text-orange-600 dark:text-orange-400 font-display">250 BDT</span>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-2 text-xs">
            <div className="bg-surface/90 dark:bg-surface-container-low/90 p-2.5 rounded-xl border border-orange-500/20 flex items-center gap-2 shadow-xs">
              <MapPin className="w-4.5 h-4.5 text-orange-500 flex-shrink-0" />
              <div>
                <span className="text-[10px] text-on-surface-variant block font-black uppercase">Detour</span>
                <span className="font-black text-sm text-on-surface">2.5 KM off N3</span>
              </div>
            </div>
            <div className="bg-surface/90 dark:bg-surface-container-low/90 p-2.5 rounded-xl border border-orange-500/20 flex items-center gap-2 shadow-xs">
              <Zap className="w-4.5 h-4.5 text-amber-500 flex-shrink-0" />
              <div>
                <span className="text-[10px] text-on-surface-variant block font-black uppercase">ETA Match</span>
                <span className="font-black text-sm text-on-surface">Tonight 8:30 PM</span>
              </div>
            </div>
          </div>

          {/* Liquid Geofence Progress Bar */}
          <div className="space-y-1">
            <div className="flex justify-between text-xs font-black text-on-surface">
              <span>Geofence Match</span>
              <span className="text-orange-600 dark:text-orange-400">92% Verified</span>
            </div>
            <div className="w-full h-2 bg-orange-500/20 rounded-full overflow-hidden p-0.5 border border-orange-500/30">
              <div className="h-full bg-gradient-to-r from-orange-500 to-amber-400 rounded-full w-[92%] relative">
                <div className="absolute right-0 top-0 bottom-0 w-3 bg-white/60 animate-pulse rounded-full"></div>
              </div>
            </div>
          </div>
        </motion.div>

        {/* 2 Clean & Streamlined Badges (Ultra-Smooth Float Motion) */}
        <div className="grid grid-cols-2 gap-3">
          {/* Badge 1: Verified Traveler */}
          <motion.div
            animate={{ y: [4, -4, 4] }}
            transition={{ duration: 4.8, repeat: Infinity, ease: [0.45, 0, 0.55, 1], delay: 0.3 }}
            className="bg-surface-container-low/95 border-2 border-orange-500/25 rounded-2xl p-3 flex items-center gap-2.5 shadow-sm will-change-transform transform-gpu"
          >
            <div className="relative flex-shrink-0">
              <div className="w-10 h-10 rounded-full bg-gradient-to-tr from-orange-500 to-amber-400 p-0.5 shadow-xs">
                <div className="w-full h-full rounded-full bg-surface flex items-center justify-center text-xs font-black text-orange-600">
                  AI
                </div>
              </div>
              <ShieldCheck className="w-4 h-4 text-orange-500 absolute -bottom-1 -right-1 bg-surface rounded-full fill-orange-500/20" />
            </div>
            <div>
              <div className="flex items-center gap-1">
                <span className="text-sm font-black text-on-surface">Aminul I.</span>
                <span className="text-xs text-amber-500 font-black flex items-center"><Star className="w-3 h-3 fill-amber-400 text-amber-400" /> 4.9</span>
              </div>
              <span className="text-xs font-black text-orange-600 dark:text-orange-400 block">NID Verified</span>
            </div>
          </motion.div>

          {/* Badge 2: Escrow Lock */}
          <motion.div
            animate={{ y: [-4, 4, -4] }}
            transition={{ duration: 5.2, repeat: Infinity, ease: [0.45, 0, 0.55, 1], delay: 0.6 }}
            className="bg-surface-container-low/95 border-2 border-orange-500/25 rounded-2xl p-3 flex items-center gap-2.5 shadow-sm will-change-transform transform-gpu"
          >
            <div className="w-10 h-10 rounded-full bg-gradient-to-br from-amber-500/25 to-orange-500/25 border border-orange-500/35 flex items-center justify-center text-orange-600 dark:text-orange-400 shadow-inner flex-shrink-0">
              <Lock className="w-5 h-5" />
            </div>
            <div>
              <span className="text-sm font-black text-on-surface block leading-tight">Escrow Locked</span>
              <span className="text-xs font-bold text-on-surface-variant">OTP Release</span>
            </div>
          </motion.div>
        </div>

      </div>
    </div>
  );
}
