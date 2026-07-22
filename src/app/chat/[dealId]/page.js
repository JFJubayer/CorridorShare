/* eslint-disable @next/next/no-img-element */
'use client';

import React, { use, useState, useEffect } from 'react';
import LiveChatBox from '@/components/LiveChatBox';
import { ArrowLeft, MoreVertical, ShieldCheck, Stars, Truck } from 'lucide-react';
import Link from 'next/link';
import dynamic from 'next/dynamic';
import AuthGuard from '@/components/AuthGuard';
import { supabase } from '@/config/supabaseClient';

const MapCorridor = dynamic(
  () => import('@/components/MapCorridor'),
  { ssr: false }
);

export default function ChatPage({ params }) {
  return (
    <AuthGuard title="Live Deal Negotiation & Inspection">
      <ChatPageContent params={params} />
    </AuthGuard>
  );
}

function ChatPageContent({ params }) {
  const resolvedParams = use(params);
  const dealId = resolvedParams.dealId;

  const [dealMeta, setDealMeta] = useState({
    partnerName: "Corridor Partner",
    partnerAvatar: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&h=250&q=80",
    routeStart: "Dhaka",
    routeEnd: "Mymensingh",
    details: "Tonight 8:30 PM • Express Delivery",
    reward: "250 BDT"
  });

  const [actualRoute, setActualRoute] = useState([[23.822349, 90.414349], [24.747149, 90.420273]]);
  const [activeChatTab, setActiveChatTab] = useState('chat');

  useEffect(() => {
    const fetchDeal = async () => {
      const { data } = await supabase.from('chats').select('*').eq('id', dealId);
      if (data && data.length > 0) {
        const d = data[0];
        const isDeal2 = dealId === 'deal-2';
        setDealMeta({
          partnerName: isDeal2 ? "Tanvir Ahmed" : "Aminul Islam",
          partnerAvatar: isDeal2
            ? "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&h=250&q=80"
            : "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&h=250&q=80",
          routeStart: "Dhaka",
          routeEnd: isDeal2 ? "Gazipur" : "Mymensingh",
          details: isDeal2 ? "Tomorrow Morning • Document Cargo" : "Tonight 8:30 PM • Express Corridor Delivery",
          reward: `${d.final_agreed_price || (isDeal2 ? 150 : 250)} BDT`
        });
      }
    };

    fetchDeal();

    const startLatLng = [23.822349, 90.414349];
    const endLatLng = dealId === 'deal-2' ? [23.999941, 90.420021] : [24.747149, 90.420273];

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
  }, [dealId]);

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
                src={dealMeta.partnerAvatar}
                alt={dealMeta.partnerName} 
              />
              <div className="absolute -bottom-0.5 -right-0.5 bg-secondary text-white rounded-full p-0.5 border border-white dark:border-slate-950">
                <ShieldCheck className="w-2.5 h-2.5" />
              </div>
            </div>
            <div>
              <h1 className="text-sm font-bold text-on-surface leading-tight flex items-center gap-1.5 font-display">
                {dealMeta.partnerName}
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

      {/* Main Workspace Layout */}
      <div className="flex flex-col lg:flex-row h-[calc(100vh-130px)]">
        
        {/* Deal Map Preview */}
        <div className={`lg:w-1/2 h-full relative border-r border-outline-variant ${
          activeChatTab === 'map' ? 'block' : 'hidden lg:block'
        }`}>
          <MapCorridor route={actualRoute} />
          
          <div className="absolute top-4 left-4 right-4 bg-surface/90 backdrop-blur-md p-3.5 rounded-2xl border border-orange-500/25 shadow-lg z-10">
            <div className="flex justify-between items-center">
              <div>
                <span className="text-[10px] uppercase font-black text-orange-600 dark:text-orange-400 tracking-wider">ACTIVE CORRIDOR MATCH</span>
                <h3 className="text-sm font-black text-on-surface leading-tight font-display">{dealMeta.routeStart} ↔ {dealMeta.routeEnd}</h3>
                <p className="text-[11px] text-on-surface-variant font-bold mt-0.5">{dealMeta.details}</p>
              </div>
              <div className="text-right">
                <span className="text-[10px] text-on-surface-variant block font-bold">Agreed Reward</span>
                <span className="text-base font-black text-orange-600 dark:text-orange-400 font-display">{dealMeta.reward}</span>
              </div>
            </div>
          </div>
        </div>

        {/* Live Chat & Inspection Box */}
        <div className={`lg:w-1/2 h-full flex flex-col ${
          activeChatTab === 'chat' ? 'block' : 'hidden lg:block'
        }`}>
          <LiveChatBox dealId={dealId} />
        </div>

      </div>

      {/* Mobile Tab Toggle */}
      <div className="lg:hidden fixed bottom-0 left-0 w-full z-40 bg-surface border-t border-outline-variant flex">
        <button 
          onClick={() => setActiveChatTab('chat')}
          className={`flex-1 py-3 text-xs font-black text-center border-b-2 transition-all ${
            activeChatTab === 'chat' ? 'border-orange-500 text-orange-600 dark:text-orange-400' : 'border-transparent text-on-surface-variant'
          }`}
        >
          Deal Conversation
        </button>
        <button 
          onClick={() => setActiveChatTab('map')}
          className={`flex-1 py-3 text-xs font-black text-center border-b-2 transition-all ${
            activeChatTab === 'map' ? 'border-orange-500 text-orange-600 dark:text-orange-400' : 'border-transparent text-on-surface-variant'
          }`}
        >
          Live Highway Map
        </button>
      </div>

    </div>
  );
}
