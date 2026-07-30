'use client';

import React from 'react';

export default function Toggle({ active, onChange }) {
  return (
    <div className="bg-surface-container-low p-1 rounded-full flex relative border border-outline-variant w-full">
      <button
        onClick={() => onChange('traveler')}
        className={`flex-1 py-2 rounded-full text-xs font-bold transition-all duration-300 z-10 text-center ${
          active === 'traveler'
            ? 'text-white bg-primary shadow-sm'
            : 'text-on-surface-variant hover:text-on-surface'
        }`}
      >
        Traveler Mode
      </button>
      <button
        onClick={() => onChange('sender')}
        className={`flex-1 py-2 rounded-full text-xs font-bold transition-all duration-300 z-10 text-center ${
          active === 'sender'
            ? 'text-white bg-primary shadow-sm'
            : 'text-on-surface-variant hover:text-on-surface'
        }`}
      >
        Sender/Receiver Mode
      </button>
    </div>
  );
}
