/* eslint-disable @next/next/no-img-element */
'use client';

import React, { use, useState, useEffect } from 'react';
import LiveChatBox from '@/components/LiveChatBox';
import { ArrowLeft, MoreVertical, ShieldCheck, Stars, Truck } from 'lucide-react';
import Link from 'next/link';
import dynamic from 'next/dynamic';

const MapCorridor = dynamic(
  () => import('@/components/MapCorridor'),
  { ssr: false }
);

export default function ChatPage({ params }) {
  // Resolve params using React.use() for Next.js App Router compatibility
  const resolvedParams = use(params);
  const dealId = resolvedParams.dealId;

  // Set coordinate anchors based on selected deal
  const isDeal2 = dealId === 'deal-2';
  const partnerName = isDeal2 ? "Marcus Chen" : "Tanvir Ahmed";
  const partnerAvatar = isDeal2 
    ? "https://lh3.googleusercontent.com/aida-public/AB6AXuAlPEMJ6UcShlvZYxtqqubWwP3G2F_VOkL4s3orzkJPbXNVQgTik-SMuAq9s3WichpIKsbb4nBBjJYREs9PCdC8tHgGQN6zBD0ZG3lgJT1oNMBz1VKHiw7QYOS1QfxwleEjF0aXnLwAo4kfMRFwiJ9yZhdFtHxWcp1AwgI3J1AoTBMGwi06ucNKxC5Sj70xi8Zakzf6oSOWIA38cXB19_uPqh8zxGSJUiIHxJZBn35jB_MiVS4_TBNpOA"
    : "https://lh3.googleusercontent.com/aida-public/AB6AXuCLxmng_obr4k3FqHdEZL7QpQ0aYzmx9gyl08cFpHNR_f-KvdHQBHPXaq6J30H9dbYwBSzsRlgH2pan2aipO2fIEtExIs8SBksxWrdZRQz2nejAzvpkMGcgVzyeXoW00ErgZvkD5mECUEGzvIybDNcnygax5pTQsdedZTeD_CNu-QNk_J2eydf4c-L5hCpOPgYvHKGy3_1JAZ8kblgIl5ESAOLxdJM6w8Diq7A9R9AjMtZm-Ar7p4cysA";
  
  const routeStart = "Dhaka";
  const routeEnd = isDeal2 ? "Gazipur" : "Mymensingh";
  const details = isDeal2 ? "Tomorrow Morning • Document Cargo" : "Tonight 8 PM • Express Corridor Delivery";
  const reward = isDeal2 ? "120 BDT" : "250 BDT";

  const [actualRoute, setActualRoute] = useState([[23.822349, 90.414349], isDeal2 ? [23.999941, 90.420021] : [24.747149, 90.420273]]);
  const [activeChatTab, setActiveChatTab] = useState('chat'); // 'chat' or 'map' on mobile/tablet

  useEffect(() => {
    const startLatLng = [23.822349, 90.414349]; // Dhaka Airport area
    const endLatLng = isDeal2 ? [23.999941, 90.420021] : [24.747149, 90.420273]; // Gazipur or Mymensingh

    const fetchSnappedRoute = async () => {
      try {
        const response = await fetch(
          `https://router.project-osrm.org/route/v1/driving/${startLatLng[1]},${startLatLng[0]};${endLatLng[1]},${endLatLng[0]}?overview=full&geometries=geojson`
        );
        const data = await response.json();
        if (data.routes && data.routes.length > 0) {
          const coords = data.routes[0].geometry.coordinates.map(coord => [coord[1], coord[0]]);
          setActualRoute(coords);
        }
      } catch (err) {
        console.error("Error fetching OSRM snapped path:", err);
      }
    };

    fetchSnappedRoute();
  }, [isDeal2]);

  return (
    <div className="min-h-screen bg-background md:pl-48 transition-colors duration-300">
      
      {/* Top Header info */}
      <div className="bg-surface-container-lowest border-b border-outline-variant px-4 py-3 flex items-center justify-between shadow-sm sticky top-0 z-30 transition-colors duration-300">
        <div className="flex items-center gap-3">
          <Link href="/chat" className="p-1 hover:bg-surface-container-low rounded-full transition-colors">
            <ArrowLeft className="w-5 h-5 text-on-surface" />
          </Link>
          <div className="flex items-center gap-2">
            <div className="relative">
              <img 
                className="w-10 h-10 rounded-full border border-outline-variant object-cover" 
                src={partnerAvatar}
                alt={partnerName} 
              />
              <div className="absolute -bottom-0.5 -right-0.5 bg-secondary text-white rounded-full p-0.5 border border-white dark:border-slate-950">
                <ShieldCheck className="w-2.5 h-2.5" />
              </div>
            </div>
            <div>
              <h1 className="text-sm font-bold text-on-surface leading-tight flex items-center gap-1.5">
                {partnerName}
                <span className="text-[9px] bg-secondary-container text-on-secondary-container px-1 py-0.2 rounded font-bold uppercase">NID VERIFIED</span>
              </h1>
              <p className="text-[10px] text-on-surface-variant font-bold flex items-center gap-0.5">
                <Stars className="w-3.5 h-3.5 text-amber-500 fill-amber-500" /> 4.9 (124 reviews)
              </p>
            </div>
          </div>
        </div>
        <button className="p-2 hover:bg-surface-container-low rounded-full transition-colors">
          <MoreVertical className="w-5 h-5 text-on-surface-variant" />
        </button>
      </div>

      {/* Mobile/Tablet Tab Swapper (Visible on screens smaller than lg) */}
      <div className="flex lg:hidden border-b border-outline-variant bg-surface-container-lowest transition-colors duration-300">
        <button 
          onClick={() => setActiveChatTab('chat')}
          className={`flex-1 py-3 text-xs font-bold text-center border-b-2 transition-all ${
            activeChatTab === 'chat' ? 'border-primary text-primary' : 'border-transparent text-on-surface-variant'
          }`}
        >
          Chat Conversation
        </button>
        <button 
          onClick={() => setActiveChatTab('map')}
          className={`flex-1 py-3 text-xs font-bold text-center border-b-2 transition-all ${
            activeChatTab === 'map' ? 'border-primary text-primary' : 'border-transparent text-on-surface-variant'
          }`}
        >
          Route Map
        </button>
      </div>

      {/* Grid Layout containing Snapped Route Map and Conversation Panel */}
      <div className="p-4 grid grid-cols-1 lg:grid-cols-2 gap-5 max-w-7xl mx-auto">
        {/* Route Details and Snap Map (Left Column) */}
        <div className={`space-y-4 flex flex-col ${activeChatTab === 'map' ? 'block' : 'hidden lg:flex'}`}>
          {/* Deal status overview panel */}
          <div className="bg-surface-container-lowest border border-outline-variant rounded-xl p-4 shadow-sm flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 transition-colors duration-300">
            <div className="space-y-1">
              <div className="flex items-center gap-1.5 text-primary text-xs font-bold uppercase">
                <Truck className="w-4 h-4 text-primary" />
                <span>Active Journey Anchor</span>
              </div>
              <div className="flex items-center gap-1.5 text-base font-bold text-on-surface">
                <span>{routeStart}</span>
                <span className="text-outline">→</span>
                <span>{routeEnd}</span>
              </div>
              <p className="text-xs text-primary font-bold">{details}</p>
            </div>
            <div className="text-left sm:text-right border-t sm:border-t-0 pt-2 sm:pt-0 border-outline-variant w-full sm:w-auto">
              <p className="text-[10px] uppercase font-bold text-on-surface-variant">Estimated Surcharge</p>
              <p className="text-lg font-bold text-on-surface">{reward}</p>
            </div>
          </div>

          {/* Actual Snapped Map Container */}
          <div className="h-[300px] lg:h-[480px] rounded-xl overflow-hidden border border-outline-variant shadow-sm relative">
            <MapCorridor route={actualRoute} packages={[]} />
          </div>
        </div>

        {/* Live Chat component (Right Column) */}
        <div className={activeChatTab === 'chat' ? 'block' : 'hidden lg:block'}>
          <LiveChatBox dealId={dealId} />
        </div>
      </div>

    </div>
  );
}
