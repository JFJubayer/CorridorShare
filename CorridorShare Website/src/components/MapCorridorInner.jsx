'use client';

import React, { useEffect } from 'react';
import { MapContainer, TileLayer, Marker, Popup, Polyline, Circle, useMap } from 'react-leaflet';
import L from 'leaflet';
import { useUser } from '@/context/UserContext';
import 'leaflet/dist/leaflet.css';

// Fix Leaflet marker icon issues in React
if (typeof window !== 'undefined') {
  delete L.Icon.Default.prototype._getIconUrl;
  L.Icon.Default.mergeOptions({
    iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
    iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
    shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
  });
}

// Custom icons for start, end, and packages
const getCustomIcon = (color) => {
  return new L.DivIcon({
    html: `<span style="background-color: ${color}; width: 16px; height: 16px; display: block; border-radius: 50%; border: 3px solid white; box-shadow: 0 0 10px rgba(234,88,12,0.6);"></span>`,
    className: 'custom-div-icon',
    iconSize: [16, 16],
    iconAnchor: [8, 8]
  });
};

const pulseIcon = new L.DivIcon({
  html: `<span class="relative flex h-5 w-5">
    <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-amber-400 opacity-75"></span>
    <span class="relative inline-flex rounded-full h-5 w-5 bg-orange-500 border-2 border-white shadow-md"></span>
  </span>`,
  className: 'custom-pulse-icon',
  iconSize: [20, 20],
  iconAnchor: [10, 10]
});

// Component to dynamically fit route bounds
function MapBoundsController({ route }) {
  const map = useMap();
  useEffect(() => {
    if (route && route.length > 0) {
      map.fitBounds(route, { padding: [50, 50] });
    }
    // Fix tile rendering issues in hidden tab panels
    setTimeout(() => {
      map.invalidateSize();
    }, 150);
  }, [route, map]);
  return null;
}

export default function MapCorridorInner({ 
  route = [[23.777176, 90.399452], [24.757082, 90.407438]], 
  packages = [], 
  onSelectPackage 
}) {
  const { theme } = useUser();
  const startPoint = route[0];
  const endPoint = route[route.length - 1];

  const tileUrl = theme === 'dark'
    ? "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
    : "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png";

  const polylineColor = theme === 'dark' ? '#ff7d1a' : '#ea580c';
  const startIconColor = theme === 'dark' ? '#f97316' : '#ea580c';
  const endIconColor = theme === 'dark' ? '#fbbf24' : '#d97706';

  return (
    <div className="w-full h-full relative">
      <MapContainer 
        center={startPoint} 
        zoom={9} 
        style={{ height: '100%', width: '100%' }}
        scrollWheelZoom={true}
      >
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>'
          url={tileUrl}
        />

        {/* Dynamic Bounds Control */}
        <MapBoundsController route={route} />

        {/* Route Path (Sunset Orange Highway Line) */}
        <Polyline 
          positions={route} 
          pathOptions={{ color: polylineColor, weight: 6, opacity: 0.9, lineJoin: 'round' }} 
        />

        {/* Start Point Circle/Marker */}
        <Marker position={startPoint} icon={getCustomIcon(startIconColor)}>
          <Popup>
            <div className="font-sans text-xs">
              <p className="font-extrabold text-orange-600 dark:text-orange-400">Departure Location</p>
              <p className="text-on-surface-variant font-medium">Start coordinates of traveler</p>
            </div>
          </Popup>
        </Marker>
        <Circle center={startPoint} radius={5000} pathOptions={{ fillColor: startIconColor, color: startIconColor, weight: 1, fillOpacity: 0.15 }} />

        {/* End Point Circle/Marker */}
        <Marker position={endPoint} icon={getCustomIcon(endIconColor)}>
          <Popup>
            <div className="font-sans text-xs">
              <p className="font-extrabold text-orange-600 dark:text-orange-400">Destination Location</p>
              <p className="text-on-surface-variant font-medium">Ending coordinates of traveler</p>
            </div>
          </Popup>
        </Marker>
        <Circle center={endPoint} radius={10000} pathOptions={{ fillColor: endIconColor, color: endIconColor, weight: 1, fillOpacity: 0.1 }} />

        {/* Packages Markers */}
        {packages.map((pkg) => {
          const pkgPos = [pkg.pickup_lat, pkg.pickup_lng];
          const isNearMiss = pkg.is_near_miss;
          
          return (
            <React.Fragment key={pkg.package_id}>
              {/* Draw matching/near miss connector line if near miss */}
              {isNearMiss && (
                <Polyline 
                  positions={[pkgPos, [24.757082, 90.407438]]}
                  pathOptions={{ color: '#f59e0b', weight: 2, dashArray: '5, 8', opacity: 0.8 }}
                />
              )}

              {/* Package Marker */}
              <Marker 
                position={pkgPos} 
                icon={isNearMiss ? pulseIcon : getCustomIcon(endIconColor)}
                eventHandlers={{
                  click: () => onSelectPackage && onSelectPackage(pkg),
                }}
              >
                <Popup>
                  <div className="font-sans text-xs max-w-xs space-y-1.5 p-1">
                    <div className="flex justify-between items-center gap-2">
                      <span className="font-black text-on-surface">{pkg.item_description}</span>
                      {isNearMiss && (
                        <span className="bg-amber-500/20 text-amber-600 dark:text-amber-400 font-bold text-[9px] px-2 py-0.5 rounded-full">
                          Near Match
                        </span>
                      )}
                    </div>
                    <p className="text-on-surface-variant font-medium">Reward: <strong className="text-orange-600 dark:text-orange-400 font-black">{pkg.proposed_reward} BDT</strong></p>
                    <p className="text-on-surface-variant font-medium">Distance: {pkg.distance_from_corridor}m</p>
                    <button 
                      onClick={() => onSelectPackage && onSelectPackage(pkg)}
                      className="mt-2 w-full bg-gradient-to-r from-orange-600 to-amber-500 text-white py-1.5 rounded-full text-center text-[10px] font-black uppercase tracking-wider hover:opacity-90 cursor-pointer shadow-xs"
                    >
                      View Deal Details
                    </button>
                  </div>
                </Popup>
              </Marker>
              
              {/* Package Search Proximity Radius */}
              <Circle 
                center={pkgPos} 
                radius={pkg.pickup_radius_meters || 2000} 
                pathOptions={{ 
                  fillColor: isNearMiss ? '#f59e0b' : '#ea580c', 
                  color: isNearMiss ? '#d97706' : '#c2410c', 
                  weight: 1, 
                  fillOpacity: 0.1 
                }} 
              />
            </React.Fragment>
          );
        })}
      </MapContainer>
    </div>
  );
}

