/* eslint-disable @next/next/no-img-element */
'use client';

import React, { useState, useEffect } from 'react';
import { supabase, DEFAULT_DEMO_PROFILES } from '@/config/supabaseClient';
import Card from '@/components/ui/Card';
import { useUser } from '@/context/UserContext';
import { Search, ShieldCheck, ShieldAlert, MessageSquare, Clock, MapPin, ChevronRight, User } from 'lucide-react';
import AuthGuard from '@/components/AuthGuard';
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

  useEffect(() => {
    const loadChats = async () => {
      setLoading(true);
      const { data } = await supabase.from('chats').select('*');
      
      if (data) {
        const decorated = data.map((chat, idx) => {
          let partner = DEFAULT_DEMO_PROFILES[idx % DEFAULT_DEMO_PROFILES.length];
          
          let partnerName = partner?.full_name || `User ${idx + 1}`;
          let partnerAvatar = partner?.nid_photo_url || "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&h=250&q=80";
          let partnerNID = partner?.nid_status || "verified";
          let routeInfo = partner?.corridor || "Dhaka Highway Corridor";

          const lastMsg = chat.messages && chat.messages.length > 0
            ? chat.messages[chat.messages.length - 1]
            : { message_text: "No messages yet", created_at: chat.created_at };

          return {
            ...chat,
            partnerName,
            partnerAvatar,
            partnerNID,
            routeInfo,
            lastMessage: lastMsg.message_text,
            lastMsgTime: lastMsg.created_at
          };
        });
        
        setChats(decorated);
      }
      setLoading(false);
    };

    loadChats();
  }, []);

  const filteredChats = chats.filter(chat => 
    chat.partnerName.toLowerCase().includes(searchQuery.toLowerCase()) ||
    chat.routeInfo.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="max-w-md mx-auto px-4 py-6 md:max-w-3xl md:pl-56 min-h-screen">
      
      {/* Header title */}
      <div className="mb-6 space-y-1">
        <span className="text-[10px] bg-orange-500/10 text-orange-600 dark:text-orange-400 border border-orange-500/20 px-3 py-1 rounded-full font-black uppercase tracking-wider">
          Peer-to-Peer Inbox
        </span>
        <h1 className="text-2xl md:text-3xl font-black text-on-surface tracking-tight font-display">
          Active Conversations & Deals
        </h1>
        <p className="text-xs text-on-surface-variant font-medium">
          Negotiate delivery surcharges, attach open-box cargo photos, and lock matches in escrow.
        </p>
      </div>

      {/* Search Input Box */}
      <div className="relative flex items-center bg-surface border border-orange-500/25 rounded-2xl px-4 py-3 mb-6 focus-within:ring-2 focus-within:ring-orange-500 transition-all shadow-sm">
        <Search className="w-4 h-4 text-orange-500 mr-2.5 flex-shrink-0" />
        <input 
          type="text" 
          placeholder="Search partner name or corridor route..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="bg-transparent border-none p-0 text-xs font-bold w-full focus:ring-0 text-on-surface placeholder:text-on-surface-variant/60 outline-none"
        />
      </div>

      {loading ? (
        <div className="flex flex-col items-center justify-center py-20 gap-3">
          <svg className="animate-spin h-8 w-8 text-orange-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
            <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
            <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          <span className="text-xs font-bold text-on-surface-variant">Loading inbox...</span>
        </div>
      ) : filteredChats.length === 0 ? (
        <div className="text-center py-16 bg-surface border border-orange-500/25 rounded-[28px] p-6 space-y-3 shadow-md">
          <MessageSquare className="w-10 h-10 text-orange-500/50 mx-auto" />
          <h3 className="font-black text-on-surface text-base">No active chats found</h3>
          <p className="text-xs text-on-surface-variant font-medium max-w-xs mx-auto">
            Send delivery requests to active travelers in the Matching tab to initiate conversations.
          </p>
        </div>
      ) : (
        <div className="space-y-3.5">
          {filteredChats.map((chat) => (
            <Link href={`/chat/${chat.id}`} key={chat.id} className="block">
              <Card className="flex items-center gap-4 p-4.5 bg-surface border border-orange-500/20 hover:border-orange-500/50 hover:shadow-xl transition-all duration-300 rounded-[28px] cursor-pointer">
                {/* Partner Avatar with NID badge */}
                <div className="relative flex-shrink-0">
                  <img 
                    src={chat.partnerAvatar} 
                    alt={chat.partnerName} 
                    className="w-13 h-13 rounded-full border border-orange-500/30 object-cover shadow-sm"
                  />
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
                    <h4 className="font-black text-on-surface text-sm truncate font-display">
                      {chat.partnerName}
                    </h4>
                    <span className="text-[10px] text-on-surface-variant whitespace-nowrap flex items-center gap-1 font-bold">
                      <Clock className="w-3 h-3 text-orange-500" />
                      {new Date(chat.lastMsgTime).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                    </span>
                  </div>
                  
                  <p className="text-[11px] font-black text-orange-600 dark:text-orange-400 mt-0.5 flex items-center gap-1">
                    <MapPin className="w-3.5 h-3.5 flex-shrink-0" />
                    {chat.routeInfo}
                  </p>

                  <p className="text-xs text-on-surface-variant mt-1 truncate font-medium">
                    {chat.lastMessage}
                  </p>
                </div>

                {/* Arrow navigation helper */}
                <div className="flex-shrink-0 text-orange-500">
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
