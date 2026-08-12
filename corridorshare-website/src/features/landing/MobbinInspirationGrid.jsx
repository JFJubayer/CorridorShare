'use client';

import React, { useState } from 'react';
import { motion } from 'motion/react';
import Card from '@/components/ui/Card';
import { Search, Sparkles, MapPin, Star, ShieldCheck, ArrowUpRight } from 'lucide-react';

export default function MobbinInspirationGrid() {
  const [activeFilter, setActiveFilter] = useState('All');
  const [searchQuery, setSearchQuery] = useState('');

  const corridorShowcases = [
    {
      id: 'dhaka-mymensingh',
      corridor: 'Dhaka ↔ Mymensingh (N3)',
      category: 'Dhaka-Mymensingh',
      traveler: 'Example traveler profile',
      rating: 'Sample',
      tripsCompleted: '—',
      avgFee: 'Negotiated',
      escrowLocked: 'Escrow hold',
      tag: 'Example',
    },
    {
      id: 'dhaka-chittagong',
      corridor: 'Dhaka ↔ Chittagong (N1)',
      category: 'Dhaka-Chittagong',
      traveler: 'Example traveler profile',
      rating: 'Sample',
      tripsCompleted: '—',
      avgFee: 'Negotiated',
      escrowLocked: 'Escrow hold',
      tag: 'Example',
    },
    {
      id: 'sylhet-dhaka',
      corridor: 'Sylhet ↔ Dhaka (N2)',
      category: 'Sylhet-Dhaka',
      traveler: 'Example traveler profile',
      rating: 'Sample',
      tripsCompleted: '—',
      avgFee: 'Negotiated',
      escrowLocked: 'Escrow hold',
      tag: 'Example',
    }
  ];

  const filtered = corridorShowcases.filter(item => {
    const matchesFilter = activeFilter === 'All' || item.category === activeFilter;
    const matchesSearch = item.corridor.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesFilter && matchesSearch;
  });

  return (
    <section className="mb-20">
      <div className="space-y-6 mb-10 text-center max-w-2xl mx-auto">
        <span className="eyebrow">Example corridors</span>
        <h2 className="text-3xl md:text-4xl font-semibold text-on-surface tracking-tight font-display">
          Bangladesh-wide highway patterns
        </h2>
        <p className="text-sm md:text-base text-on-surface-variant font-medium">
          Illustrative corridor examples. Live matches come from trips and packages you post — anywhere in Bangladesh.
        </p>

        <div className="relative max-w-xl mx-auto">
          <div className="flex items-center bg-surface-container-low border border-outline rounded-full px-5 py-3.5 shadow-lg focus-within:ring-2 focus-within:ring-primary transition-all">
            <Search className="w-5 h-5 text-primary mr-3" />
            <input
              type="text"
              placeholder="Search example corridors..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full bg-transparent border-none outline-none text-sm font-medium text-on-surface placeholder:text-on-surface-variant/60"
            />
          </div>
        </div>
      </div>

      <div className="flex flex-wrap justify-center gap-2.5 mb-8">
        {['All', 'Dhaka-Mymensingh', 'Dhaka-Chittagong', 'Sylhet-Dhaka'].map((tab) => (
          <button
            key={tab}
            onClick={() => setActiveFilter(tab)}
            className={`px-5 py-2.5 rounded-full text-xs font-black transition-all cursor-pointer tactile-btn ${ activeFilter === tab ? 'bg-primary text-white shadow-sm border border-primary/20' : 'bg-surface-container-low text-on-surface-variant border border-outline hover:bg-primary/10' }`}
          >
            {tab}
          </button>
        ))}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 max-w-6xl mx-auto">
        {filtered.map((item, index) => (
          <motion.div
            key={item.id}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: index * 0.1 }}
          >
            <Card className="border border-outline bg-surface p-5 rounded-xl space-y-4 hover:-translate-y-1 transition-all shadow-xl relative overflow-hidden group">
              <div className="relative h-36 rounded-2xl overflow-hidden border border-outline bg-primary/10 flex items-end p-4">
                <span className="absolute top-3 left-3 bg-primary text-white text-xs font-black px-3 py-1 rounded-full shadow-md uppercase tracking-wider">
                  {item.tag}
                </span>
                <div className="flex justify-between items-center text-on-surface w-full">
                  <span className="text-xs font-black flex items-center gap-1">
                    <MapPin className="w-3.5 h-3.5 text-primary" />
                    {item.corridor}
                  </span>
                  <span className="text-xs font-mono font-black bg-surface/80 px-2.5 py-1 rounded-full border border-outline text-primary">
                    {item.avgFee}
                  </span>
                </div>
              </div>

              <div className="flex justify-between items-center pt-1">
                <div>
                  <p className="text-sm font-black text-on-surface">{item.traveler}</p>
                  <p className="text-xs text-on-surface-variant font-bold flex items-center gap-1 mt-0.5">
                    <Star className="w-3.5 h-3.5 text-amber-500" />
                    {item.rating} corridor card
                  </p>
                </div>
                <span className="text-xs font-bold text-primary bg-primary/10 px-3 py-1 rounded-full border border-outline block">
                  {item.escrowLocked}
                </span>
              </div>

              <div className="pt-2 border-t border-outline-variant flex justify-between items-center text-xs font-bold text-on-surface-variant">
                <span className="flex items-center gap-1">
                  <ShieldCheck className="w-4 h-4 text-primary" />
                  Manual NID review
                </span>
                <span className="text-primary flex items-center gap-0.5 font-black">
                  Post a trip <ArrowUpRight className="w-3.5 h-3.5" />
                </span>
              </div>
            </Card>
          </motion.div>
        ))}
      </div>
    </section>
  );
}
