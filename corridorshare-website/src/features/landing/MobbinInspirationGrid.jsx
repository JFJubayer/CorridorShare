/* eslint-disable @next/next/no-img-element */
'use client';

import React, { useState } from 'react';
import { motion } from 'motion/react';
import Card from '@/components/ui/Card';
import { Search, Sparkles, Filter, Navigation, ArrowUpRight, ShieldCheck, MapPin, Star, Truck } from 'lucide-react';

export default function MobbinInspirationGrid() {
  const [activeFilter, setActiveFilter] = useState('All');
  const [searchQuery, setSearchQuery] = useState('');

  const corridorShowcases = [
    {
      id: 'dhaka-mymensingh',
      corridor: 'Dhaka ↔ Mymensingh (N3)',
      category: 'Dhaka-Mymensingh',
      traveler: 'Aminul Islam',
      rating: '4.9 ★',
      tripsCompleted: 48,
      avgFee: '250 BDT',
      escrowLocked: '100% Guaranteed',
      tag: 'Popular',
      image: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=600&q=80'
    },
    {
      id: 'dhaka-chittagong',
      corridor: 'Dhaka ↔ Chittagong (N1)',
      category: 'Dhaka-Chittagong',
      traveler: 'Tanvir Hossain',
      rating: '4.8 ★',
      tripsCompleted: 32,
      avgFee: '450 BDT',
      escrowLocked: 'Verified Escrow',
      tag: 'Express',
      image: 'https://images.unsplash.com/photo-1570125909232-eb263c188f7e?auto=format&fit=crop&w=600&q=80'
    },
    {
      id: 'sylhet-dhaka',
      corridor: 'Sylhet ↔ Dhaka (N2)',
      category: 'Sylhet-Dhaka',
      traveler: 'Farhana Ahmed',
      rating: '5.0 ★',
      tripsCompleted: 19,
      avgFee: '380 BDT',
      escrowLocked: 'Instant Release',
      tag: 'Top Rated',
      image: 'https://images.unsplash.com/photo-1519003722824-194d4455a60c?auto=format&fit=crop&w=600&q=80'
    }
  ];

  const filtered = corridorShowcases.filter(item => {
    const matchesFilter = activeFilter === 'All' || item.category === activeFilter;
    const matchesSearch = item.corridor.toLowerCase().includes(searchQuery.toLowerCase()) || 
                          item.traveler.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesFilter && matchesSearch;
  });

  return (
    <section className="mb-20">
      
      {/* Mobbin Header Title & Search Bar */}
      <div className="space-y-6 mb-10 text-center max-w-2xl mx-auto">
        <span className="text-xs font-black text-orange-700 dark:text-orange-300 bg-orange-500/10 px-4 py-1.5 rounded-full border border-orange-500/30 uppercase tracking-widest inline-flex items-center gap-1.5 shadow-xs">
          <Sparkles className="w-4 h-4 text-orange-500" />
          MOBBIN-INSPIRED UI DIRECTORY
        </span>
        <h2 className="text-3xl md:text-5xl font-black text-on-surface tracking-tight font-display">
          Explore Live Corridor Patterns
        </h2>
        <p className="text-sm md:text-base text-on-surface-variant font-medium">
          Clean, verified peer-to-peer travel routes and luggage carry presets designed with Mobbin UI elegance.
        </p>

        {/* Mobbin Signature Search Input Bar with ⌘K Badge */}
        <div className="relative max-w-xl mx-auto">
          <div className="flex items-center bg-surface-container-low border border-orange-500/25 rounded-full px-5 py-3.5 shadow-lg focus-within:ring-2 focus-within:ring-orange-500 transition-all">
            <Search className="w-5 h-5 text-orange-500 mr-3" />
            <input 
              type="text"
              placeholder="Search highway corridors, drivers, or fees..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full bg-transparent border-none outline-none text-sm font-medium text-on-surface placeholder:text-on-surface-variant/60"
            />
            <span className="text-[10px] font-mono font-bold text-on-surface-variant bg-surface-container-lowest border border-outline-variant/60 px-2 py-1 rounded-md ml-2 shadow-xs hidden sm:inline-block">
              ⌘K
            </span>
          </div>
        </div>
      </div>

      {/* Segmented Mobbin Filter Pills */}
      <div className="flex flex-wrap justify-center gap-2.5 mb-8">
        {['All', 'Dhaka-Mymensingh', 'Dhaka-Chittagong', 'Sylhet-Dhaka'].map((tab) => (
          <button
            key={tab}
            onClick={() => setActiveFilter(tab)}
            className={`px-5 py-2.5 rounded-full text-xs font-black transition-all cursor-pointer tactile-btn ${
              activeFilter === tab
                ? 'bg-gradient-to-r from-orange-600 to-amber-500 text-white shadow-md shadow-orange-500/25 border border-orange-400/30'
                : 'bg-surface-container-low text-on-surface-variant border border-outline hover:bg-orange-500/10'
            }`}
          >
            {tab}
          </button>
        ))}
      </div>

      {/* Mobbin-Style Framed Card Showcase Grid */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 max-w-6xl mx-auto">
        {filtered.map((item, index) => (
          <motion.div
            key={item.id}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: index * 0.1 }}
          >
            <Card className="border border-orange-500/25 bg-surface p-5 rounded-[28px] space-y-4 hover:-translate-y-1.5 transition-all shadow-xl relative overflow-hidden group">
              
              {/* Image Preview Window with Badge Overlay */}
              <div className="relative h-44 rounded-2xl overflow-hidden border border-orange-500/20">
                <img 
                  src={item.image} 
                  alt={item.corridor}
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" 
                />
                <div className="absolute inset-0 bg-gradient-to-t from-black/70 via-black/20 to-transparent"></div>
                
                <span className="absolute top-3 left-3 bg-gradient-to-r from-orange-600 to-amber-500 text-white text-xs font-black px-3 py-1 rounded-full shadow-md uppercase tracking-wider">
                  {item.tag}
                </span>

                <div className="absolute bottom-3 left-3 right-3 flex justify-between items-center text-white">
                  <span className="text-xs font-black flex items-center gap-1">
                    <MapPin className="w-3.5 h-3.5 text-amber-400" />
                    {item.corridor}
                  </span>
                  <span className="text-xs font-mono font-black bg-black/60 backdrop-blur-md px-2.5 py-1 rounded-full border border-white/20 text-amber-300">
                    {item.avgFee}
                  </span>
                </div>
              </div>

              {/* Driver & Security Details */}
              <div className="flex justify-between items-center pt-1">
                <div>
                  <p className="text-sm font-black text-on-surface">{item.traveler}</p>
                  <p className="text-xs text-amber-500 font-bold flex items-center gap-1 mt-0.5">
                    <Star className="w-3.5 h-3.5 fill-amber-500" />
                    {item.rating} ({item.tripsCompleted} completed trips)
                  </p>
                </div>
                <div className="text-right">
                  <span className="text-xs font-bold text-orange-600 dark:text-orange-400 bg-orange-500/10 px-3 py-1 rounded-full border border-orange-500/20 block">
                    {item.escrowLocked}
                  </span>
                </div>
              </div>

              <div className="pt-2 border-t border-orange-500/15 flex justify-between items-center text-xs font-bold text-on-surface-variant">
                <span className="flex items-center gap-1">
                  <ShieldCheck className="w-4 h-4 text-orange-500" />
                  NID Verified Traveler
                </span>
                <span className="text-orange-600 dark:text-orange-400 hover:underline flex items-center gap-0.5 font-black">
                  Match Route <ArrowUpRight className="w-3.5 h-3.5" />
                </span>
              </div>

            </Card>
          </motion.div>
        ))}
      </div>

    </section>
  );
}

