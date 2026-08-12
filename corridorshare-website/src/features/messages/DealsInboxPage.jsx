/* eslint-disable @next/next/no-img-element */
'use client';

import React, { useState, useEffect } from 'react';
import { chatRepository } from '@/repositories/chatRepository';
import { tripRepository } from '@/repositories/tripRepository';
import { packageRepository } from '@/repositories/packageRepository';
import { profileRepository } from '@/repositories/profileRepository';
import Card from '@/components/ui/Card';
import { useUser } from '@/context/UserContext';
import { Search, ShieldCheck, ShieldAlert, MessageSquare, Clock, MapPin, ChevronRight } from 'lucide-react';
import AuthGuard from '@/features/auth/AuthGuard';
import Link from 'next/link';

export default function ChatsListPage() {
  return (
    <AuthGuard title="Live Deal Conversations & Inbox">
      <ChatsListPageContent />
    </AuthGuard>
  );
}

function ChatsListPageContent() {
  const { userId } = useUser();

  const [chats, setChats] = useState([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState('');

  useEffect(() => {
    let active = true;
    const loadChats = async () => {
      setLoading(true);
      setLoadError('');
      try {
        const data = await chatRepository.list();
        if (!active) return;

        const decorated = await Promise.all((data || []).map(async (chat) => {
          const [trip, pkg] = await Promise.all([
            chat.trip_id ? tripRepository.findById(chat.trip_id) : null,
            chat.package_id ? packageRepository.findById(chat.package_id) : null,
          ]);
          const partnerId = userId && trip?.traveler_id === userId
            ? pkg?.sender_id
            : trip?.traveler_id;
          const partner = partnerId ? await profileRepository.findById(partnerId) : null;
          const lastMsg = chat.messages && chat.messages.length > 0
            ? chat.messages[chat.messages.length - 1]
            : { message_text: 'No messages yet', created_at: chat.created_at };

          return {
            ...chat,
            partnerName: partner?.full_name || partner?.phone_number || 'Corridor Partner',
            partnerAvatar: partner?.nid_photo_url || '',
            partnerNID: partner?.nid_status || 'unverified',
            routeInfo: trip
              ? `${trip.departure_city || 'Pickup'} → ${trip.destination_city || 'Drop-off'}`
              : (pkg?.route_info || 'Highway corridor deal'),
            lastMessage: lastMsg.message_text || 'No messages yet',
            lastMsgTime: lastMsg.created_at || chat.created_at,
          };
        }));

        if (active) setChats(decorated);
      } catch (error) {
        if (active) {
          setChats([]);
          setLoadError(error.message || 'Unable to load deal conversations.');
        }
      } finally {
        if (active) setLoading(false);
      }
    };

    loadChats();
    return () => { active = false; };
  }, [userId]);

  const filteredChats = chats.filter((chat) =>
    chat.partnerName.toLowerCase().includes(searchQuery.toLowerCase()) ||
    chat.routeInfo.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="max-w-md mx-auto px-4 py-6 md:max-w-3xl md:pl-56 min-h-screen">
      
      {/* Header title */}
      <div className="mb-6 space-y-1">
        <span className="eyebrow">Peer-to-peer inbox</span>
        <h1 className="text-2xl md:text-3xl font-semibold text-on-surface tracking-tight font-display">
          Active conversations & deals
        </h1>
        <p className="text-xs text-on-surface-variant font-medium">
          Negotiate delivery surcharges, attach open-box cargo photos, and lock matches in escrow.
        </p>
      </div>

      {/* Search Input Box */}
      <div className="relative flex items-center bg-surface border border-outline rounded-2xl px-4 py-3 mb-6 focus-within:ring-2 focus-within:ring-primary transition-all shadow-sm">
        <Search className="w-4 h-4 text-primary mr-2.5 flex-shrink-0" />
        <input 
          type="text" 
          placeholder="Search partner name or corridor route..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="bg-transparent border-none p-0 text-xs font-bold w-full focus:ring-0 text-on-surface placeholder:text-on-surface-variant/60 outline-none"
        />
      </div>

      {loadError && (
        <p role="alert" className="mb-4 rounded-2xl border border-outline bg-primary/10 px-4 py-3 text-xs font-bold text-primary">{loadError}</p>
      )}

      {loading ? (
        <div className="flex flex-col items-center justify-center py-20 gap-3">
          <svg className="animate-spin h-8 w-8 text-primary" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
            <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
            <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          <span className="text-xs font-bold text-on-surface-variant">Loading inbox...</span>
        </div>
      ) : filteredChats.length === 0 ? (
        <div className="text-center py-16 bg-surface border border-outline rounded-xl p-6 space-y-3 shadow-md">
          <MessageSquare className="w-10 h-10 text-primary/50 mx-auto" />
          <h3 className="font-semibold text-on-surface text-base">No active chats found</h3>
          <p className="text-xs text-on-surface-variant font-medium max-w-xs mx-auto">
            Send delivery requests to active travelers in the Matching tab to initiate conversations.
          </p>
        </div>
      ) : (
        <div className="space-y-3.5">
          {filteredChats.map((chat) => (
            <Link href={`/chat/${chat.id}`} key={chat.id} className="block">
              <Card className="flex items-center gap-4 p-4.5 bg-surface border border-outline hover:border-primary/35 hover:shadow-xl transition-all duration-300 rounded-xl cursor-pointer">
                {/* Partner Avatar with NID badge */}
                <div className="relative flex-shrink-0">
                  {chat.partnerAvatar ? (
                    <img 
                      src={chat.partnerAvatar} 
                      alt={chat.partnerName} 
                      className="w-13 h-13 rounded-full border border-primary/25 object-cover shadow-sm"
                    />
                  ) : (
                    <div className="w-13 h-13 rounded-full border border-primary/25 bg-primary/10 text-primary flex items-center justify-center text-xs font-semibold shadow-sm">
                      CS
                    </div>
                  )}
                  {chat.partnerNID === 'verified' ? (
                    <div className="absolute -bottom-0.5 -right-0.5 bg-secondary text-white rounded-full p-0.5 border-2 border-white dark:border-slate-950" title="NID Verified">
                      <ShieldCheck className="w-3 h-3" />
                    </div>
                  ) : (
                    <div className="absolute -bottom-0.5 -right-0.5 bg-red-500 text-white rounded-full p-0.5 border-2 border-white dark:border-slate-950" title="Unverified">
                      <ShieldAlert className="w-3 h-3" />
                    </div>
                  )}
                </div>

                {/* Conversation Meta info */}
                <div className="flex-grow min-w-0">
                  <div className="flex justify-between items-start gap-2">
                    <h4 className="font-semibold text-on-surface text-sm truncate font-display">
                      {chat.partnerName}
                    </h4>
                    <span className="text-[10px] text-on-surface-variant whitespace-nowrap flex items-center gap-1 font-bold">
                      <Clock className="w-3 h-3 text-primary" />
                      {new Date(chat.lastMsgTime).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                    </span>
                  </div>
                  
                  <p className="text-[11px] font-semibold text-primary mt-0.5 flex items-center gap-1">
                    <MapPin className="w-3.5 h-3.5 flex-shrink-0" />
                    {chat.routeInfo}
                  </p>

                  <p className="text-xs text-on-surface-variant mt-1 truncate font-medium">
                    {chat.lastMessage}
                  </p>
                </div>

                {/* Arrow navigation helper */}
                <div className="flex-shrink-0 text-primary">
                  <ChevronRight className="w-5 h-5" />
                </div>
              </Card>
            </Link>
          ))}
        </div>
      )}

    </div>
  );
}
