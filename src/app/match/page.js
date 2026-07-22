'use client';

import React, { useState, useEffect } from 'react';
import { supabase } from '@/config/supabaseClient';
import MapCorridor from '@/components/MapCorridor';
import Card from '@/components/ui/Card';
import Button from '@/components/ui/Button';
import { useUser } from '@/context/UserContext';
import { 
  Filter, Search, MapPin, Flag, ShieldAlert, Sparkles, Navigation, Send, ArrowRight 
} from 'lucide-react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'motion/react';

export default function MatchPage() {
  const router = useRouter();
  const { profile } = useUser();
  const [activeTab, setActiveTab] = useState('list'); // 'map' or 'list' on mobile
  const [startPoint, setStartPoint] = useState('Dhaka North');
  const [startRadius, setStartRadius] = useState('5');
  const [destination, setDestination] = useState('Mymensingh City');
  const [destRadius, setDestRadius] = useState('10');
  
  const [matches, setMatches] = useState([]);
  const [selectedPkg, setSelectedPkg] = useState(null);
  const [detourBonus, setDetourBonus] = useState('150');

  const [highwayRoute, setHighwayRoute] = useState([
    [23.822349, 90.414349], // Dhaka North
    [24.747149, 90.420273]  // Mymensingh
  ]);

  useEffect(() => {
    const fetchRouteAndMatches = async () => {
      // 1. Fetch snapped actual highway road coordinates
      try {
        const response = await fetch(
          `https://router.project-osrm.org/route/v1/driving/90.414349,23.822349;90.420273,24.747149?overview=full&geometries=geojson`
        );
        const data = await response.json();
        if (data.routes && data.routes.length > 0) {
          const coords = data.routes[0].geometry.coordinates.map(coord => [coord[1], coord[0]]);
          setHighwayRoute(coords);
        }
      } catch (err) {
        console.error("Error fetching OSRM highway path:", err);
      }

      // 2. Fetch matches
      const { data } = await supabase.rpc('match_packages_within_corridor', {
        traveler_trip_id: 'trip-1',
        buffer_distance_meters: 5000.0
      });
      if (data) {
        setMatches(data);
      }
    };

    fetchRouteAndMatches();
  }, []);

  const handleSendRequest = (pkgId) => {
    alert(`Delivery request sent successfully for package ${pkgId}! Redirecting to deal chat...`);
    router.push(`/chat/deal-${pkgId}`);
  };

  const handleSendDetourOffer = (pkgId) => {
    alert(`Detour offer of ${detourBonus} BDT submitted to sender! Redirecting to deal chat...`);
    router.push(`/chat/deal-${pkgId}`);
  };

  return (
    <div className="h-[calc(100vh-64px)] flex flex-col md:flex-row md:pl-48 bg-background transition-colors duration-300">
      
      {/* Mobile Tab Swapper */}
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

      {/* Map Section */}
      <div className={`flex-grow relative h-full min-h-[300px] ${
        activeTab === 'map' ? 'block' : 'hidden md:block'
      }`}>
        <MapCorridor 
          route={highwayRoute} 
          packages={matches} 
          onSelectPackage={(pkg) => setSelectedPkg(pkg)}
        />

        {/* Floating Input Overlay */}
        <div className="absolute top-4 left-4 right-4 z-20 max-w-sm hidden lg:block">
          <div className="bg-surface p-5 rounded-[28px] shadow-xl border border-orange-500/25 transition-colors duration-300">
            <h2 className="text-xs font-black text-orange-600 dark:text-orange-400 mb-3 flex items-center gap-2">
              <Navigation className="w-4 h-4 text-orange-500" />
              MATCHING PARAMETERS
            </h2>

            <div className="space-y-3">
              <div className="flex gap-2">
                <div className="flex-grow">
                  <label className="block text-[9px] font-bold text-on-surface-variant uppercase tracking-wider mb-1">Start Point</label>
                  <div className="flex items-center bg-surface-container-low px-3 py-2 rounded-full border border-orange-500/20">
                    <MapPin className="w-4 h-4 text-orange-500 mr-1.5" />
                    <input 
                      type="text" value={startPoint} onChange={(e) => setStartPoint(e.target.value)}
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
                      type="text" value={destination} onChange={(e) => setDestination(e.target.value)}
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

      {/* Sidebar / Match Results List */}
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

        {/* Scrollable listing content */}
        <div className="flex-grow overflow-y-auto p-4 space-y-4 custom-scrollbar bg-surface-container-low transition-colors duration-300">
          
          {/* Detailed Popup Card if selected on Map */}
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
              
              <Link href={`/chat/deal-${selectedPkg.package_id || '1'}`}>
                <Button variant="primary" className="mt-3 py-2.5 text-xs w-full flex items-center justify-center gap-1.5 rounded-full font-black">
                  Go to Deal Chat
                  <ArrowRight className="w-3.5 h-3.5" />
                </Button>
              </Link>
            </Card>
          )}

          {/* Matches loop */}
          {matches.map((pkg, idx) => {
            const isNearMiss = pkg.is_near_miss;
            
            return (
              <motion.div 
                key={pkg.package_id} 
                initial={{ opacity: 0, y: 15 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.4, delay: idx * 0.08 }}
                className="space-y-1"
              >
                {isNearMiss && (
                  <div className="bg-gradient-to-r from-amber-600 to-orange-600 text-white p-1.5 rounded-t-2xl text-[9px] font-black text-center uppercase tracking-widest">
                    Near Match (500m outside route)
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
                          Sender Verified
                        </span>
                        <span className="text-amber-500 text-[10px] font-bold">4.8 ★</span>
                      </div>
                    </div>
                  </div>

                  <div className="grid grid-cols-2 gap-3 text-xs mb-4">
                    <div className="bg-surface-container-low p-3 rounded-2xl border border-orange-500/15">
                      <p className="text-[9px] text-on-surface-variant uppercase font-bold tracking-wider">Route Corridor</p>
                      <p className="font-black text-orange-600 dark:text-orange-400 mt-0.5 truncate">{pkg.route_info || 'Dhaka → Mymensingh'}</p>
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
                          onClick={() => handleSendDetourOffer(pkg.package_id)}
                          className="bg-gradient-to-r from-orange-600 to-amber-500 text-white font-black text-xs px-4 py-2 rounded-full hover:opacity-90 transition-all flex items-center gap-1 tactile-btn active:scale-95 shadow-md cursor-pointer"
                        >
                          <Send className="w-3 h-3" />
                          Send Offer
                        </button>
                      </div>
                    </div>
                  ) : (
                    <Button 
                      onClick={() => handleSendRequest(pkg.package_id)}
                      variant="primary"
                      className="py-3 text-xs uppercase tracking-wider font-black rounded-full"
                    >
                      Send Delivery Request
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



