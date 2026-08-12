'use client';

import React, { useState, useEffect } from 'react';
import { matchingRepository } from '@/repositories/matchingRepository';
import MapCorridor from '@/components/MapCorridor';
import Card from '@/components/ui/Card';
import Button from '@/components/ui/Button';
import { useUser } from '@/context/UserContext';
import {
  Filter, MapPin, Flag, ShieldAlert, Sparkles, Navigation, Send, ArrowRight
} from 'lucide-react';
import { useRouter } from 'next/navigation';
import { motion } from 'motion/react';
import AuthGuard from '@/features/auth/AuthGuard';
import { tripRepository } from '@/repositories/tripRepository';
import { chatRepository } from '@/repositories/chatRepository';

export default function MatchPage() {
  return (
    <AuthGuard title="Live Highway Route Matching">
      <MatchPageContent />
    </AuthGuard>
  );
}

function MatchPageContent() {
  const router = useRouter();
  const { userId } = useUser();

  const [activeTab, setActiveTab] = useState('list');
  const [startPoint, setStartPoint] = useState('');
  const [startRadius, setStartRadius] = useState('5');
  const [destination, setDestination] = useState('');
  const [destRadius, setDestRadius] = useState('10');

  const [matches, setMatches] = useState([]);
  const [matchError, setMatchError] = useState('');
  const [selectedPkg, setSelectedPkg] = useState(null);
  const [detourBonus, setDetourBonus] = useState('150');
  const [activeTrip, setActiveTrip] = useState(null);
  const [highwayRoute, setHighwayRoute] = useState([]);
  const [requestingId, setRequestingId] = useState(null);

  useEffect(() => {
    const fetchRouteAndMatches = async () => {
      try {
        const trip = await tripRepository.findLatestForTraveler(userId);
        if (!trip) throw new Error('Post a trip before searching this corridor for packages.');
        setActiveTrip(trip);
        setStartPoint(trip.departure_city || '');
        setDestination(trip.destination_city || '');

        // Prefer real trip geometry when available; otherwise snap via OSRM from city labels later.
        if (Array.isArray(trip.route_leaflet) && trip.route_leaflet.length > 1) {
          setHighwayRoute(trip.route_leaflet);
        } else if (typeof trip.route_path === 'string' && trip.route_path.startsWith('LINESTRING')) {
          const coords = trip.route_path
            .replace('LINESTRING(', '')
            .replace(')', '')
            .split(',')
            .map((pair) => pair.trim().split(/\s+/))
            .filter((pair) => pair.length === 2)
            .map(([lng, lat]) => [Number(lat), Number(lng)])
            .filter(([lat, lng]) => Number.isFinite(lat) && Number.isFinite(lng));
          if (coords.length > 1) setHighwayRoute(coords);
        }

        const data = await matchingRepository.findPackages(trip.id, 5000.0);
        if (data) setMatches(data);
        setMatchError('');
      } catch (error) {
        setMatches([]);
        setMatchError(error.message || 'Unable to load corridor matches.');
      }
    };

    fetchRouteAndMatches();
  }, [userId]);

  const openDealForPackage = async (pkg, extraRewardMinor = 0) => {
    if (!activeTrip?.id) {
      setMatchError('Post a trip before sending delivery requests.');
      return;
    }
    const packageId = pkg.package_id || pkg.id;
    if (!packageId) {
      setMatchError('That package is missing an id.');
      return;
    }

    setRequestingId(packageId);
    setMatchError('');
    try {
      const baseMinor = Number.isFinite(pkg.proposed_reward_minor)
        ? Math.round(pkg.proposed_reward_minor)
        : Math.round(Number(pkg.proposed_reward || 0) * 100);
      const amountMinor = baseMinor + Math.max(0, Math.round(Number(extraRewardMinor) || 0));
      const deal = await chatRepository.createDeal({
        tripId: activeTrip.id,
        packageId,
        finalAgreedPriceMinor: amountMinor > 0 ? amountMinor : null,
      });
      if (!deal?.id) throw new Error('Deal chat could not be created.');
      router.push(`/chat/${deal.id}`);
    } catch (error) {
      setMatchError(error.message || 'Unable to open a deal chat for this package.');
    } finally {
      setRequestingId(null);
    }
  };

  const handleSendRequest = (pkg) => openDealForPackage(pkg, 0);
  const handleSendDetourOffer = (pkg) => openDealForPackage(pkg, Math.round(Number(detourBonus || 0) * 100));

  return (
    <div className="h-[calc(100vh-64px)] flex flex-col md:flex-row md:pl-48 bg-background transition-colors duration-300">
      <div className="flex md:hidden border-b border-outline-variant bg-surface-container-lowest transition-colors duration-300">
        <button
          onClick={() => setActiveTab('list')}
          className={`flex-1 py-3 text-xs font-black text-center border-b-2 transition-all ${
            activeTab === 'list' ? 'border-orange-500 text-orange-600 dark:text-orange-400' : 'border-transparent text-on-surface-variant'
          }`}
        >
          Match Results
        </button>
        <button
          onClick={() => setActiveTab('map')}
          className={`flex-1 py-3 text-xs font-black text-center border-b-2 transition-all ${
            activeTab === 'map' ? 'border-orange-500 text-orange-600 dark:text-orange-400' : 'border-transparent text-on-surface-variant'
          }`}
        >
          Interactive Map
        </button>
      </div>

      <div className={`flex-grow relative h-full min-h-[300px] ${activeTab === 'map' ? 'block' : 'hidden md:block'}`}>
        <MapCorridor
          route={highwayRoute}
          packages={matches}
          onSelectPackage={(pkg) => setSelectedPkg(pkg)}
        />

        <div className="absolute top-4 left-4 right-4 z-20 max-w-sm hidden lg:block">
          <div className="bg-surface p-5 rounded-[28px] shadow-xl border border-orange-500/25 transition-colors duration-300">
            <h2 className="text-xs font-black text-orange-600 dark:text-orange-400 mb-3 flex items-center gap-2">
              <Navigation className="w-4 h-4 text-orange-500" />
              YOUR ACTIVE TRIP
            </h2>
            <div className="space-y-3">
              <div className="flex gap-2">
                <div className="flex-grow">
                  <label className="block text-[9px] font-bold text-on-surface-variant uppercase tracking-wider mb-1">Start Point</label>
                  <div className="flex items-center bg-surface-container-low px-3 py-2 rounded-full border border-orange-500/20">
                    <MapPin className="w-4 h-4 text-orange-500 mr-1.5" />
                    <input
                      type="text" value={startPoint} readOnly
                      className="bg-transparent border-none p-0 text-xs w-full focus:ring-0 text-on-surface outline-none font-medium"
                    />
                  </div>
                </div>
                <div className="w-18">
                  <label className="block text-[9px] font-bold text-on-surface-variant uppercase tracking-wider mb-1">Radius</label>
                  <div className="flex items-center bg-surface-container-low px-2 py-2 rounded-full border border-orange-500/20">
                    <input
                      type="number" value={startRadius} onChange={(e) => setStartRadius(e.target.value)}
                      className="bg-transparent border-none p-0 text-xs w-full text-center focus:ring-0 text-on-surface outline-none font-bold"
                    />
                    <span className="text-[8px] text-on-surface-variant font-bold ml-0.5">KM</span>
                  </div>
                </div>
              </div>

              <div className="flex gap-2">
                <div className="flex-grow">
                  <label className="block text-[9px] font-bold text-on-surface-variant uppercase tracking-wider mb-1">Destination</label>
                  <div className="flex items-center bg-surface-container-low px-3 py-2 rounded-full border border-orange-500/20">
                    <Flag className="w-4 h-4 text-amber-500 mr-1.5" />
                    <input
                      type="text" value={destination} readOnly
                      className="bg-transparent border-none p-0 text-xs w-full focus:ring-0 text-on-surface outline-none font-medium"
                    />
                  </div>
                </div>
                <div className="w-18">
                  <label className="block text-[9px] font-bold text-on-surface-variant uppercase tracking-wider mb-1">Radius</label>
                  <div className="flex items-center bg-surface-container-low px-2 py-2 rounded-full border border-orange-500/20">
                    <input
                      type="number" value={destRadius} onChange={(e) => setDestRadius(e.target.value)}
                      className="bg-transparent border-none p-0 text-xs w-full text-center focus:ring-0 text-on-surface outline-none font-bold"
                    />
                    <span className="text-[8px] text-on-surface-variant font-bold ml-0.5">KM</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <aside className={`w-full md:w-[380px] lg:w-[420px] bg-surface border-l border-outline-variant flex flex-col h-full transition-colors duration-300 ${
        activeTab === 'list' ? 'block' : 'hidden md:flex'
      }`}>
        <div className="p-5 border-b border-outline-variant flex justify-between items-center bg-surface transition-colors duration-300">
          <div>
            <h3 className="text-base font-black text-on-surface tracking-tight">Match Results</h3>
            <p className="text-xs text-on-surface-variant font-medium mt-0.5">{matches.length} Packages found along corridor</p>
          </div>
          <button className="bg-surface-container-low border border-orange-500/20 text-on-surface p-2.5 rounded-full hover:bg-orange-500/10 transition-colors">
            <Filter className="w-4 h-4 text-orange-500" />
          </button>
        </div>

        {matchError && <p role="alert" className="mx-4 mt-4 rounded-2xl border border-orange-500/25 bg-orange-500/10 px-4 py-3 text-xs font-bold text-orange-700 dark:text-orange-300">{matchError}</p>}

        <div className="flex-grow overflow-y-auto p-4 space-y-4 custom-scrollbar bg-surface-container-low transition-colors duration-300">
          {selectedPkg && (
            <Card className="border-2 border-orange-500 bg-orange-500/10 p-5 relative animate-in fade-in zoom-in-95 duration-200 rounded-[28px]">
              <button
                onClick={() => setSelectedPkg(null)}
                className="absolute right-3.5 top-3.5 text-[10px] font-black text-on-surface-variant hover:text-on-surface uppercase outline-none"
              >
                Close
              </button>
              <span className="text-[9px] font-black bg-gradient-to-r from-orange-600 to-amber-500 text-white px-2.5 py-0.5 rounded-full uppercase tracking-wider shadow-xs">
                Selected Package
              </span>
              <h4 className="font-extrabold text-on-surface mt-2 text-sm">{selectedPkg.item_description}</h4>
              <p className="text-xs text-on-surface-variant mt-1 font-medium">Reward: <strong className="text-orange-600 dark:text-orange-400">{selectedPkg.proposed_reward} BDT</strong></p>
              <p className="text-xs text-on-surface-variant font-medium">Proximity: {selectedPkg.distance_from_corridor} meters from highway</p>

              <Button
                variant="primary"
                disabled={requestingId === (selectedPkg.package_id || selectedPkg.id)}
                onClick={() => handleSendRequest(selectedPkg)}
                className="mt-3 py-2.5 text-xs w-full flex items-center justify-center gap-1.5 rounded-full font-black"
              >
                Go to Deal Chat
                <ArrowRight className="w-3.5 h-3.5" />
              </Button>
            </Card>
          )}

          {matches.map((pkg, idx) => {
            const isNearMiss = pkg.is_near_miss;
            const packageId = pkg.package_id || pkg.id;
            const corridorLabel = pkg.route_info
              || (activeTrip ? `${activeTrip.departure_city} → ${activeTrip.destination_city}` : 'Your corridor');

            return (
              <motion.div
                key={packageId}
                initial={{ opacity: 0, y: 15 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.4, delay: idx * 0.08 }}
                className="space-y-1"
              >
                {isNearMiss && (
                  <div className="bg-gradient-to-r from-amber-600 to-orange-600 text-white p-1.5 rounded-t-2xl text-[9px] font-black text-center uppercase tracking-widest">
                    Near Match (outside route buffer)
                  </div>
                )}

                <div className={`bg-surface p-5 rounded-[28px] border border-orange-500/20 shadow-sm transition-all duration-300 relative hover:shadow-lg ${
                  isNearMiss ? 'rounded-t-none border-t-0' : 'hover:border-orange-500/50'
                } ${pkg.is_premium ? 'urgent-glow' : ''}`}>
                  {pkg.is_premium && (
                    <div className="absolute top-3.5 right-3.5 bg-red-500/10 text-red-600 dark:text-red-400 border border-red-500/20 px-2.5 py-0.5 rounded-full text-[9px] font-black uppercase tracking-wider flex items-center gap-1">
                      <Sparkles className="w-3 h-3 text-red-500 animate-pulse" />
                      URGENT
                    </div>
                  )}

                  <div className="flex items-center gap-3 mb-4">
                    <div className="w-10 h-10 rounded-full bg-orange-500/10 flex-shrink-0 flex items-center justify-center font-black text-xs text-orange-600 dark:text-orange-400 border border-orange-500/20">
                      PKG
                    </div>
                    <div>
                      <h4 className="font-black text-on-surface text-sm leading-tight">{pkg.item_type || pkg.item_description}</h4>
                      <div className="flex items-center gap-1.5 mt-1">
                        <span className="bg-surface-container-low text-on-surface-variant text-[9px] px-2.5 py-0.5 rounded-full font-bold uppercase tracking-wide">
                          Package Match
                        </span>
                      </div>
                    </div>
                  </div>

                  <div className="grid grid-cols-2 gap-3 text-xs mb-4">
                    <div className="bg-surface-container-low p-3 rounded-2xl border border-orange-500/15">
                      <p className="text-[9px] text-on-surface-variant uppercase font-bold tracking-wider">Route Corridor</p>
                      <p className="font-black text-orange-600 dark:text-orange-400 mt-0.5 truncate">{corridorLabel}</p>
                    </div>
                    <div className="bg-surface-container-low p-3 rounded-2xl border border-orange-500/15">
                      <p className="text-[9px] text-on-surface-variant uppercase font-bold tracking-wider">Delivery Reward</p>
                      <p className="font-black text-orange-600 dark:text-orange-400 mt-0.5">{pkg.proposed_reward} BDT</p>
                    </div>
                  </div>

                  {isNearMiss ? (
                    <div className="bg-surface-container-low p-3.5 rounded-2xl border border-dashed border-orange-500/40 space-y-2.5">
                      <p className="text-xs font-extrabold text-on-surface flex items-center gap-1">
                        <ShieldAlert className="text-orange-500 w-4 h-4 flex-shrink-0" />
                        Propose detour bonus:
                      </p>
                      <div className="flex gap-2">
                        <div className="flex-grow flex items-center bg-surface px-3 py-1.5 rounded-full border border-orange-500/20 focus-within:ring-2 focus-within:ring-orange-500 transition-all">
                          <span className="text-orange-600 dark:text-orange-400 text-xs font-bold mr-1.5">BDT</span>
                          <input
                            type="number" value={detourBonus} onChange={(e) => setDetourBonus(e.target.value)}
                            className="bg-transparent border-none p-0 text-xs font-bold w-full focus:ring-0 text-on-surface outline-none"
                          />
                        </div>
                        <button
                          onClick={() => handleSendDetourOffer(pkg)}
                          disabled={requestingId === packageId}
                          className="bg-gradient-to-r from-orange-600 to-amber-500 text-white font-black text-xs px-4 py-2 rounded-full hover:opacity-90 transition-all flex items-center gap-1 tactile-btn active:scale-95 shadow-md cursor-pointer"
                        >
                          <Send className="w-3 h-3" />
                          Send Offer
                        </button>
                      </div>
                    </div>
                  ) : (
                    <Button
                      onClick={() => handleSendRequest(pkg)}
                      disabled={requestingId === packageId}
                      variant="primary"
                      className="py-3 text-xs uppercase tracking-wider font-black rounded-full"
                    >
                      {requestingId === packageId ? 'Opening chat...' : 'Send Delivery Request'}
                    </Button>
                  )}
                </div>
              </motion.div>
            );
          })}
        </div>
      </aside>
    </div>
  );
}
