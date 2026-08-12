'use client';

import React from 'react';
import { motion } from 'motion/react';
import Card from '@/components/ui/Card';
import Button from '@/components/ui/Button';
import { 
  CheckCircle2, Clock, MapPin, Truck, ArrowUpRight, TrendingUp, ShieldCheck, Star 
} from 'lucide-react';

export default function FigmaMakeDashboardWidget() {
  return (
    <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 my-10">
      
      {/* Package Tracking Timeline Card */}
      <div className="lg:col-span-7 space-y-4">
        <Card className="border border-outline bg-surface p-6 shadow-xl space-y-6 relative overflow-hidden rounded-2xl">
          <div className="flex flex-wrap justify-between items-center pb-4 border-b border-outline-variant gap-3">
            <div>
              <div className="flex items-center gap-2">
                <span className="text-xs font-black font-mono text-primary bg-primary/10 px-3 py-1 rounded-full border border-outline">
                  Example card
                </span>
                <span className="text-xs bg-primary text-white font-black px-3 py-1 rounded-full uppercase tracking-wider flex items-center gap-1.5 shadow-xs">
                  Sample UI
                </span>
              </div>
              <h3 className="font-black text-on-surface text-lg mt-2 tracking-tight">
                Dhaka → Mymensingh <span className="text-xs font-bold text-on-surface-variant">(N3 Highway)</span>
              </h3>
            </div>
            <div className="flex items-center gap-2.5 bg-surface-container-low px-4 py-2 rounded-full border border-outline">
              <div className="w-8 h-8 rounded-full bg-primary text-white flex items-center justify-center font-bold text-xs shadow-sm">
                VT
              </div>
              <div>
                <p className="text-xs font-black text-on-surface">Example Traveler</p>
                <p className="text-xs text-on-surface-variant font-bold flex items-center gap-0.5">
                  <Star className="w-3.5 h-3.5 text-amber-500" /> Sample tracking UI
                </p>
              </div>
            </div>
          </div>

          {/* Vertical Step Timeline */}
          <div className="space-y-6 relative pl-2">
            <div className="absolute left-[15px] top-3 bottom-3 w-0.5 bg-primary/40"></div>

            {/* Step 1: Picked Up */}
            <div className="flex items-start gap-4 relative z-10">
              <div className="w-7 h-7 rounded-full bg-primary text-white flex items-center justify-center font-bold text-xs shadow-md">
                ✓
              </div>
              <div className="flex-grow flex justify-between items-center">
                <div>
                  <p className="text-sm font-black text-on-surface">Picked up</p>
                  <p className="text-xs text-on-surface-variant font-medium">Gazipur Highway Station, 08:12 AM</p>
                </div>
                <span className="text-xs font-mono font-bold text-on-surface-variant">08:12 AM</span>
              </div>
            </div>

            {/* Step 2: On Route */}
            <div className="flex items-start gap-4 relative z-10">
              <div className="w-7 h-7 rounded-full bg-primary text-white flex items-center justify-center font-bold text-xs shadow-md">
                ✓
              </div>
              <div className="flex-grow flex justify-between items-center">
                <div>
                  <p className="text-sm font-black text-on-surface">On Route</p>
                  <p className="text-xs text-on-surface-variant font-medium">Trishal Corridor Junction, 11:30 AM</p>
                </div>
                <span className="text-xs font-mono font-bold text-on-surface-variant">11:30 AM</span>
              </div>
            </div>

            {/* Step 3: Current Position */}
            <div className="flex items-start gap-4 relative z-10">
              <div className="w-7 h-7 rounded-full bg-primary text-white flex items-center justify-center font-bold text-xs ring-4 ring-primary/20 shadow-lg">
                <Truck className="w-4 h-4 animate-bounce" />
              </div>
              <div className="flex-grow flex justify-between items-center bg-primary/10 p-3.5 rounded-2xl border border-outline">
                <div>
                  <p className="text-sm font-black text-primary">Current: On N3 Corridor</p>
                  <p className="text-xs text-on-surface-variant font-semibold">Near Bhaluka Highway Bypass</p>
                </div>
                <span className="text-xs font-mono font-black text-primary">13:45 PM</span>
              </div>
            </div>

            {/* Step 4: Next Arrival */}
            <div className="flex items-start gap-4 relative z-10 opacity-60">
              <div className="w-7 h-7 rounded-full bg-surface-container-low border border-outline-variant text-on-surface-variant flex items-center justify-center font-bold text-xs">
                ○
              </div>
              <div className="flex-grow flex justify-between items-center">
                <div>
                  <p className="text-sm font-bold text-on-surface">Next: Arrival</p>
                  <p className="text-xs text-on-surface-variant">Mymensingh Bypass Station</p>
                </div>
                <span className="text-xs font-mono font-bold text-on-surface-variant">15:30 PM</span>
              </div>
            </div>
          </div>

          {/* Progress Bar & ETA */}
          <div className="space-y-2 pt-2 border-t border-outline-variant">
            <div className="flex justify-between text-xs font-bold">
              <span className="text-on-surface-variant">Journey Completion</span>
              <span className="text-primary font-mono font-black">65% (ETA 45 mins)</span>
            </div>
            <div className="w-full h-2.5 bg-primary/10 rounded-full overflow-hidden border border-outline p-0.5">
              <motion.div 
                initial={{ width: 0 }}
                animate={{ width: '65%' }}
                transition={{ duration: 1.2, ease: "easeOut" }}
                className="h-full bg-primary rounded-full"
              />
            </div>
          </div>
        </Card>
      </div>

      {/* Analytics & Earnings Bento Overview */}
      <div className="lg:col-span-5 space-y-6">
        <Card className="border border-outline bg-surface p-6 shadow-xl space-y-5 rounded-2xl relative overflow-hidden">
          <div className="flex justify-between items-center">
            <div>
              <p className="text-xs uppercase font-black tracking-widest text-on-surface-variant">Earnings Overview</p>
              <h3 className="text-3xl font-black text-on-surface tracking-tight font-display mt-1">
                — <span className="text-sm font-bold text-primary">BDT</span>
              </h3>
              <p className="text-[10px] text-on-surface-variant font-medium mt-1">Illustrative layout — live totals come from your wallet.</p>
            </div>
            <div className="bg-primary/10 text-primary px-3 py-2 rounded-full border border-outline flex items-center gap-1 font-black text-xs">
              <TrendingUp className="w-4 h-4" />
              Example
            </div>
          </div>

          {/* Weekly Graph Simulation */}
          <div className="pt-2">
            <div className="flex justify-between items-end h-28 gap-2 pt-4 border-b border-outline-variant pb-2">
              {[
                { day: 'Mon', h: '45%' },
                { day: 'Tue', h: '65%' },
                { day: 'Wed', h: '35%' },
                { day: 'Thu', h: '85%' },
                { day: 'Fri', h: '95%' },
                { day: 'Sat', h: '70%' },
                { day: 'Sun', h: '60%' },
              ].map((bar, i) => (
                <div key={bar.day} className="flex-1 flex flex-col items-center gap-1.5 h-full justify-end">
                  <motion.div 
                    initial={{ height: 0 }}
                    animate={{ height: bar.h }}
                    transition={{ duration: 0.8, delay: i * 0.1 }}
                    className="w-full max-w-[20px] bg-primary rounded-t-full transition-colors shadow-xs"
                  />
                  <span className="text-xs font-bold text-on-surface-variant">{bar.day}</span>
                </div>
              ))}
            </div>
          </div>

          <div className="grid grid-cols-2 gap-3 pt-2">
            <div className="bg-surface-container-low p-4 rounded-2xl border border-outline-variant">
              <p className="text-[10px] text-on-surface-variant uppercase font-bold tracking-wider">Matched Routes</p>
              <p className="text-xl font-black text-on-surface font-mono mt-0.5">—</p>
            </div>
            <div className="bg-surface-container-low p-4 rounded-2xl border border-outline-variant">
              <p className="text-[10px] text-on-surface-variant uppercase font-bold tracking-wider">Escrow Model</p>
              <p className="text-xl font-black text-primary font-mono mt-0.5">Hold→OTP</p>
            </div>
          </div>
        </Card>
      </div>

    </div>
  );
}

