/* eslint-disable @next/next/no-img-element */
'use client';

import React, { use, useState, useEffect } from 'react';
import LiveChatBox from '@/features/chat/LiveChatBox';
import { ArrowLeft, MoreVertical, ShieldCheck, Stars } from 'lucide-react';
import Link from 'next/link';
import dynamic from 'next/dynamic';
import AuthGuard from '@/features/auth/AuthGuard';
import { chatRepository } from '@/repositories/chatRepository';
import { tripRepository } from '@/repositories/tripRepository';
import { packageRepository } from '@/repositories/packageRepository';
import { profileRepository } from '@/repositories/profileRepository';
import { fetchDrivingRoute, geocodePlace } from '@/shared/geo/routeGeometry';
import { useUser } from '@/context/UserContext';

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
  const { userId } = useUser();

  const [dealMeta, setDealMeta] = useState({
    partnerName: 'Corridor Partner',
    partnerAvatar: '',
    routeStart: 'Pickup',
    routeEnd: 'Drop-off',
    details: 'Deal negotiation',
    reward: '—',
  });
  const [actualRoute, setActualRoute] = useState([]);
  const [activeChatTab, setActiveChatTab] = useState('chat');
  const [loadError, setLoadError] = useState('');

  useEffect(() => {
    let active = true;
    const load = async () => {
      try {
        const deal = await chatRepository.findById(dealId);
        if (!deal) throw new Error('This deal chat was not found.');
        const [trip, pkg] = await Promise.all([
          tripRepository.findById(deal.trip_id),
          packageRepository.findById(deal.package_id),
        ]);
        if (!active) return;

        const partnerId = userId && trip?.traveler_id === userId ? pkg?.sender_id : trip?.traveler_id;
        const partner = partnerId ? await profileRepository.findById(partnerId) : null;
        const amountMinor = deal.final_agreed_price_minor ?? pkg?.proposed_reward_minor;
        setDealMeta({
          partnerName: partner?.full_name || partner?.phone_number || 'Corridor Partner',
          partnerAvatar: partner?.nid_photo_url || '',
          routeStart: trip?.departure_city || 'Pickup',
          routeEnd: trip?.destination_city || 'Drop-off',
          details: deal.deal_locked ? 'Escrow locked' : 'Negotiating delivery',
          reward: Number.isSafeInteger(amountMinor) ? `${(amountMinor / 100).toFixed(2)} BDT` : '—',
        });

        if (typeof trip?.route_path === 'string' && trip.route_path.startsWith('LINESTRING')) {
          const coords = trip.route_path
            .replace('LINESTRING(', '')
            .replace(')', '')
            .split(',')
            .map((pair) => pair.trim().split(/\s+/))
            .filter((pair) => pair.length === 2)
            .map(([lng, lat]) => [Number(lat), Number(lng)])
            .filter(([lat, lng]) => Number.isFinite(lat) && Number.isFinite(lng));
          if (coords.length > 1) {
            setActualRoute(coords);
            return;
          }
        }

        if (trip?.departure_city && trip?.destination_city) {
          const [start, end] = await Promise.all([
            geocodePlace(trip.departure_city),
            geocodePlace(trip.destination_city),
          ]);
          const points = await fetchDrivingRoute(start, end);
          if (active) setActualRoute(points.map(({ latitude, longitude }) => [latitude, longitude]));
        }
        setLoadError('');
      } catch (error) {
        if (active) setLoadError(error.message || 'Unable to load this deal.');
      }
    };
    load();
    return () => { active = false; };
  }, [dealId, userId]);

  return (
    <div className="min-h-screen bg-background md:pl-48 transition-colors duration-300">
      <div className="bg-surface-container-lowest border-b border-outline-variant px-4 py-3 flex items-center justify-between shadow-sm sticky top-0 z-30 transition-colors duration-300">
        <div className="flex items-center gap-3">
          <Link href="/chat" className="p-1 hover:bg-surface-container-low rounded-full transition-colors">
            <ArrowLeft className="w-5 h-5 text-on-surface" />
          </Link>
          <div className="flex items-center gap-2">
            <div className="relative">
              {dealMeta.partnerAvatar ? (
                <img
                  className="w-10 h-10 rounded-full border border-outline-variant object-cover"
                  src={dealMeta.partnerAvatar}
                  alt={dealMeta.partnerName}
                />
              ) : (
                <div className="w-10 h-10 rounded-full border border-outline-variant bg-orange-500/15 text-orange-600 flex items-center justify-center text-xs font-black">
                  CS
                </div>
              )}
              <div className="absolute -bottom-0.5 -right-0.5 bg-secondary text-white rounded-full p-0.5 border border-white dark:border-slate-950">
                <ShieldCheck className="w-2.5 h-2.5" />
              </div>
            </div>
            <div>
              <h1 className="text-sm font-bold text-on-surface leading-tight flex items-center gap-1.5 font-display">
                {dealMeta.partnerName}
              </h1>
              <p className="text-[10px] text-on-surface-variant font-bold flex items-center gap-0.5">
                Deal {dealId.slice(0, 8)}…
              </p>
            </div>
          </div>
        </div>
        <button className="p-2 hover:bg-surface-container-low rounded-full transition-colors">
          <MoreVertical className="w-5 h-5 text-on-surface-variant" />
        </button>
      </div>

      {loadError && (
        <p role="alert" className="mx-4 mt-4 rounded-2xl border border-orange-500/25 bg-orange-500/10 px-4 py-3 text-xs font-bold text-orange-700 dark:text-orange-300">{loadError}</p>
      )}

      <div className="flex flex-col lg:flex-row h-[calc(100vh-130px)]">
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

        <div className={`lg:w-1/2 h-full flex flex-col ${
          activeChatTab === 'chat' ? 'block' : 'hidden lg:block'
        }`}>
          <LiveChatBox dealId={dealId} />
        </div>
      </div>

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
