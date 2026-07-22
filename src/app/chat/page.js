/* eslint-disable @next/next/no-img-element */
'use client';

import React, { useState, useEffect } from 'react';
import { supabase } from '@/config/supabaseClient';
import Card from '@/components/ui/Card';
import { useUser } from '@/context/UserContext';
import { Search, ShieldCheck, ShieldAlert, MessageSquare, Clock, MapPin, ChevronRight } from 'lucide-react';
import Link from 'next/link';

export default function ChatsListPage() {
  const { userId } = useUser();
  const [chats, setChats] = useState([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadChats = async () => {
      setLoading(true);
      // Fetch chats from mock DB / LocalStorage
      const { data } = await supabase.from('chats').select('*');
      
      if (data) {
        // Decorate chats with partner meta details for visualization
        const decorated = data.map(chat => {
          let partnerName = "User Partner";
          let partnerAvatar = "https://lh3.googleusercontent.com/aida-public/AB6AXuCLxmng_obr4k3FqHdEZL7QpQ0aYzmx9gyl08cFpHNR_f-KvdHQBHPXaq6J30H9dbYwBSzsRlgH2pan2aipO2fIEtExIs8SBksxWrdZRQz2nejAzvpkMGcgVzyeXoW00ErgZvkD5mECUEGzvIybDNcnygax5pTQsdedZTeD_CNu-QNk_J2eydf4c-L5hCpOPgYvHKGy3_1JAZ8kblgIl5ESAOLxdJM6w8Diq7A9R9AjMtZm-Ar7p4cysA";
          let partnerNID = "verified";
          let routeInfo = "Dhaka to Mymensingh";
          
          if (chat.id === 'deal-1') {
            partnerName = "Tanvir Ahmed";
            partnerAvatar = "https://lh3.googleusercontent.com/aida-public/AB6AXuCLxmng_obr4k3FqHdEZL7QpQ0aYzmx9gyl08cFpHNR_f-KvdHQBHPXaq6J30H9dbYwBSzsRlgH2pan2aipO2fIEtExIs8SBksxWrdZRQz2nejAzvpkMGcgVzyeXoW00ErgZvkD5mECUEGzvIybDNcnygax5pTQsdedZTeD_CNu-QNk_J2eydf4c-L5hCpOPgYvHKGy3_1JAZ8kblgIl5ESAOLxdJM6w8Diq7A9R9AjMtZm-Ar7p4cysA";
            partnerNID = "verified";
            routeInfo = "Dhaka ↔ Mymensingh";
          } else if (chat.id === 'deal-2') {
            partnerName = "Marcus Chen";
            partnerAvatar = "https://lh3.googleusercontent.com/aida-public/AB6AXuAlPEMJ6UcShlvZYxtqqubWwP3G2F_VOkL4s3orzkJPbXNVQgTik-SMuAq9s3WichpIKsbb4nBBjJYREs9PCdC8tHgGQN6zBD0ZG3lgJT1oNMBz1VKHiw7QYOS1QfxwleEjF0aXnLwAo4kfMRFwiJ9yZhdFtHxWcp1AwgI3J1AoTBMGwi06ucNKxC5Sj70xi8Zakzf6oSOWIA38cXB19_uPqh8zxGSJUiIHxJZBn35jB_MiVS4_TBNpOA";
            partnerNID = "verified";
            routeInfo = "Dhaka ↔ Gazipur";
          }

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
    <div className="max-w-md mx-auto px-4 py-6 md:max-w-2xl md:pl-56 min-h-screen">
      
      {/* Header title */}
      <div className="mb-6">
        <h1 className="text-2xl font-extrabold text-slate-900 dark:text-slate-100 tracking-tight">
          Active Conversations
        </h1>
        <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">
          Negotiate delivery surcharges, attach open-box cargo photos, and lock matches.
        </p>
      </div>

      {/* Search Input Box */}
      <div className="relative flex items-center bg-white dark:bg-slate-950 border border-outline-variant dark:border-slate-800 rounded-xl p-3 mb-6 focus-within:ring-2 focus-within:ring-primary focus-within:border-transparent transition-all shadow-sm">
        <Search className="w-4 h-4 text-slate-400 mr-2.5" />
        <input 
          type="text" 
          placeholder="Search chat partner or route..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="bg-transparent border-none p-0 text-xs w-full focus:ring-0 text-slate-800 dark:text-slate-100 placeholder:text-slate-400"
        />
      </div>

      {loading ? (
        <div className="flex flex-col items-center justify-center py-20 gap-3">
          <svg className="animate-spin h-8 w-8 text-teal-800" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
            <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
            <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          <span className="text-sm font-semibold text-slate-500">Loading inbox...</span>
        </div>
      ) : filteredChats.length === 0 ? (
        <div className="text-center py-16 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-2xl p-6 space-y-3">
          <MessageSquare className="w-10 h-10 text-slate-300 mx-auto" />
          <h3 className="font-bold text-slate-800 dark:text-slate-200">No chats found</h3>
          <p className="text-xs text-slate-500 dark:text-slate-400">
            Send requests to active travelers in the Matching tab to initiate conversations.
          </p>
        </div>
      ) : (
        <div className="space-y-3">
          {filteredChats.map((chat) => (
            <Link href={`/chat/${chat.id}`} key={chat.id} className="block">
              <Card className="flex items-center gap-3.5 p-4 hover:bg-slate-50 dark:hover:bg-slate-900/40 cursor-pointer border border-slate-200 dark:border-slate-800 hover:border-teal-700/30 dark:hover:border-teal-500/20 transition-all duration-300">
                {/* Partner Avatar with NID badge */}
                <div className="relative flex-shrink-0">
                  <img 
                    src={chat.partnerAvatar} 
                    alt={chat.partnerName} 
                    className="w-12 h-12 rounded-full border border-slate-200 dark:border-slate-800 object-cover"
                  />
                  {chat.partnerNID === 'verified' ? (
                    <div className="absolute -bottom-0.5 -right-0.5 bg-secondary text-white border-2 border-white dark:border-slate-950 rounded-full p-0.5">
                      <ShieldCheck className="w-2.5 h-2.5" />
                    </div>
                  ) : (
                    <div className="absolute -bottom-0.5 -right-0.5 bg-red-500 text-white border-2 border-white dark:border-slate-950 rounded-full p-0.5">
                      <ShieldAlert className="w-2.5 h-2.5" />
                    </div>
                  )}
                </div>

                {/* Conversation Meta info */}
                <div className="flex-grow min-w-0">
                  <div className="flex justify-between items-start gap-2">
                    <h4 className="font-bold text-slate-900 dark:text-slate-100 text-sm truncate">
                      {chat.partnerName}
                    </h4>
                    <span className="text-[10px] text-slate-400 whitespace-nowrap flex items-center gap-1 font-medium">
                      <Clock className="w-3 h-3" />
                      {new Date(chat.lastMsgTime).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                    </span>
                  </div>
                  
                  <p className="text-[10px] font-bold text-teal-800 dark:text-teal-400 mt-0.5 flex items-center gap-1">
                    <MapPin className="w-3.5 h-3.5 flex-shrink-0" />
                    {chat.routeInfo}
                  </p>

                  <p className="text-xs text-slate-500 dark:text-slate-400 mt-1 truncate">
                    {chat.lastMessage}
                  </p>
                </div>

                {/* Arrow navigation helper */}
                <div className="flex-shrink-0 text-slate-300 dark:text-slate-700">
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
