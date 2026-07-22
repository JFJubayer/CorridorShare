/* eslint-disable @next/next/no-img-element */
'use client';

import React, { useState, useEffect, useRef } from 'react';
import { supabase } from '@/config/supabaseClient';
import { useUser } from '@/context/UserContext';
import { Camera, CheckSquare, Square, Lock, Unlock, Send, Sparkles, AlertCircle } from 'lucide-react';

export default function LiveChatBox({ dealId }) {
  const { userId } = useUser();
  const [deal, setDeal] = useState(null);
  const [messages, setMessages] = useState([]);
  const [newMsg, setNewMsg] = useState('');
  const [isUploading, setIsUploading] = useState(false);
  const [inspectionPhoto, setInspectionPhoto] = useState('');
  const [checkedContraband, setCheckedContraband] = useState(false);
  const [isLocking, setIsLocking] = useState(false);
  const chatEndRef = useRef(null);

  // Load deal details and messages
  useEffect(() => {
    const loadDealData = async () => {
      const { data: dealData } = await supabase
        .from('chats')
        .select('*')
        .eq('id', dealId);

      if (dealData && dealData.length > 0) {
        const activeDeal = dealData[0];
        setDeal(activeDeal);
        setMessages(activeDeal.messages || []);
        setInspectionPhoto(activeDeal.inspection_photo_url || '');
        setCheckedContraband(activeDeal.open_box_verified || false);
      }
    };

    loadDealData();

    const channel = supabase
      .channel(`chat-${dealId}`)
      .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'messages' }, payload => {
        setMessages(prev => [...prev, payload.new]);
      })
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [dealId]);

  useEffect(() => {
    chatEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const handleSend = async (e) => {
    e.preventDefault();
    if (!newMsg.trim() && !inspectionPhoto) return;

    const messageObj = {
      id: `msg-${Date.now()}`,
      deal_id: dealId,
      sender_id: userId,
      message_text: newMsg,
      image_verification_url: inspectionPhoto || null,
      created_at: new Date().toISOString()
    };

    const currentChats = JSON.parse(localStorage.getItem('cs_chats') || '[]');
    const updatedChats = currentChats.map(c => {
      if (c.id === dealId) {
        return {
          ...c,
          messages: [...(c.messages || []), messageObj]
        };
      }
      return c;
    });
    localStorage.setItem('cs_chats', JSON.stringify(updatedChats));

    setMessages(prev => [...prev, messageObj]);
    setNewMsg('');
  };

  const handlePhotoUpload = async (e) => {
    const file = e.target.files[0];
    if (!file) return;

    setIsUploading(true);
    
    setTimeout(async () => {
      const mockUrl = "https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&w=400&q=80";
      
      const currentChats = JSON.parse(localStorage.getItem('cs_chats') || '[]');
      const updatedChats = currentChats.map(c => {
        if (c.id === dealId) {
          return {
            ...c,
            inspection_photo_url: mockUrl
          };
        }
        return c;
      });
      localStorage.setItem('cs_chats', JSON.stringify(updatedChats));

      setInspectionPhoto(mockUrl);
      setIsUploading(false);

      const systemMsg = {
        id: `sys-${Date.now()}`,
        deal_id: dealId,
        sender_id: 'system',
        message_text: "Inspection photo uploaded successfully.",
        created_at: new Date().toISOString()
      };
      setMessages(prev => [...prev, systemMsg]);
    }, 1500);
  };

  const handleLockDeal = async () => {
    if (!inspectionPhoto || !checkedContraband) return;

    setIsLocking(true);
    setTimeout(() => {
      const currentChats = JSON.parse(localStorage.getItem('cs_chats') || '[]');
      const updatedChats = currentChats.map(c => {
        if (c.id === dealId) {
          return {
            ...c,
            deal_locked: true,
            open_box_verified: true
          };
        }
        return c;
      });
      localStorage.setItem('cs_chats', JSON.stringify(updatedChats));

      setDeal(prev => ({ ...prev, deal_locked: true }));
      setIsLocking(false);

      const systemMsg = {
        id: `sys-lock-${Date.now()}`,
        deal_id: dealId,
        sender_id: 'system',
        message_text: "DEAL LOCKED & SECURED: Safety Deposit and Route Handover parameters locked by platform.",
        created_at: new Date().toISOString()
      };
      setMessages(prev => [...prev, systemMsg]);
    }, 1500);
  };

  const dealLocked = deal?.deal_locked;
  const isButtonEnabled = inspectionPhoto && checkedContraband;

  return (
    <div className="flex flex-col h-[calc(100vh-140px)] max-w-2xl mx-auto bg-surface rounded-[28px] shadow-xl border border-orange-500/25 overflow-hidden transition-colors duration-300">
      
      {/* Safety Compliance Banner */}
      <div className="bg-orange-500/10 border-b border-orange-500/20 p-4 space-y-3">
        <div className="flex items-start gap-3">
          <AlertCircle className="text-orange-600 dark:text-orange-400 w-5 h-5 flex-shrink-0 mt-0.5" />
          <div className="flex-grow">
            <h3 className="text-[11px] font-black text-orange-600 dark:text-orange-400 uppercase tracking-wider">Mandatory Open-Box Inspection</h3>
            <p className="text-xs text-on-surface-variant leading-normal mt-0.5 font-medium">
              For mutual security, travelers must verify package contents. Add a photo of the open cargo to activate deal locking.
            </p>
          </div>
        </div>

        {/* Action components (Upload Photo & Checkbox) */}
        {!dealLocked && (
          <div className="flex flex-col sm:flex-row gap-3 pt-1">
            <label className={`flex-1 h-20 border-2 border-dashed rounded-2xl flex flex-col items-center justify-center gap-1.5 cursor-pointer transition-all ${
              inspectionPhoto 
                ? 'border-orange-500 bg-orange-500/15 text-orange-600 dark:text-orange-400' 
                : 'border-orange-500/30 bg-surface hover:bg-orange-500/10 text-on-surface-variant'
            }`}>
              <input type="file" onChange={handlePhotoUpload} className="hidden" accept="image/*" disabled={isUploading} />
              <Camera className="w-5 h-5 text-orange-500" />
              <span className="text-[10px] font-black uppercase tracking-wider">
                {isUploading ? 'Uploading...' : inspectionPhoto ? 'Change Photo (Uploaded)' : 'Add Inspection Proof'}
              </span>
            </label>

            <button
              onClick={() => setCheckedContraband(!checkedContraband)}
              className={`flex-1 p-3 border rounded-2xl flex items-center gap-2.5 transition-all text-left ${
                checkedContraband 
                  ? 'border-orange-500 bg-orange-500/15 text-orange-600 dark:text-orange-400' 
                  : 'border-orange-500/30 bg-surface hover:bg-orange-500/10 text-on-surface-variant'
              }`}
            >
              {checkedContraband ? (
                <CheckSquare className="w-5 h-5 text-orange-500 flex-shrink-0" />
              ) : (
                <div className="w-5 h-5 border border-orange-500/40 rounded-md flex-shrink-0" />
              )}
              <span className="text-[10px] font-black uppercase leading-normal">
                I checked the items & confirm no contraband is inside.
              </span>
            </button>
          </div>
        )}
      </div>

      {/* Messages Scroll Area */}
      <div className="flex-grow overflow-y-auto p-4 space-y-4 custom-scrollbar bg-surface-container-low transition-colors duration-300">
        {messages.map((msg) => {
          const isMe = msg.sender_id === userId;
          const isSys = msg.sender_id === 'system';

          if (isSys) {
            return (
              <div key={msg.id} className="flex justify-center animate-in fade-in slide-in-from-bottom-2">
                <div className="bg-orange-500/15 border border-orange-500/30 text-orange-600 dark:text-orange-400 font-black text-[10px] uppercase tracking-wider px-4 py-2 rounded-full flex items-center gap-1.5 shadow-xs">
                  <Sparkles className="w-3.5 h-3.5 text-orange-500" />
                  {msg.message_text}
                </div>
              </div>
            );
          }

          return (
            <div key={msg.id} className={`flex items-end gap-2 max-w-[85%] ${isMe ? 'ml-auto flex-row-reverse' : ''}`}>
              <div className={`w-8 h-8 rounded-full flex-shrink-0 overflow-hidden flex items-center justify-center font-black text-[10px] shadow-sm ${
                isMe 
                  ? 'bg-gradient-to-br from-orange-600 to-amber-500 text-white' 
                  : 'bg-amber-600 text-white'
              }`}>
                {isMe ? 'ME' : 'TR'}
              </div>
              <div className={`p-3.5 text-sm shadow-md leading-relaxed ${
                isMe 
                  ? 'bg-gradient-to-r from-orange-600 via-orange-500 to-amber-500 text-white rounded-3xl rounded-br-xs font-medium' 
                  : 'bg-surface text-on-surface border border-orange-500/20 rounded-3xl rounded-bl-xs font-medium'
              }`}>
                <p className="text-xs font-medium">{msg.message_text}</p>
                
                {msg.image_verification_url && (
                  <div className="mt-2 rounded-2xl overflow-hidden border border-white/20 max-w-xs">
                    <img src={msg.image_verification_url} alt="Cargo verification" className="w-full h-auto object-cover max-h-48" />
                  </div>
                )}
              </div>
            </div>
          );
        })}
        <div ref={chatEndRef} />
      </div>

      {/* Sticky Bottom Actions / Negotiation Footer */}
      <div className="border-t border-orange-500/15 p-4 bg-surface space-y-4 transition-colors duration-300">
        {/* Deal Lock Component */}
        <div className="flex gap-3">
          {dealLocked ? (
            <div className="w-full bg-orange-500/15 border border-orange-500/40 text-orange-600 dark:text-orange-400 py-3.5 px-4 rounded-full flex items-center justify-center gap-2 font-black text-xs uppercase tracking-wider shadow-sm">
              <Lock className="w-4 h-4 animate-pulse text-orange-500" />
              DEAL LOCKED & ENFORCED (250 BDT)
            </div>
          ) : (
            <>
              <div className="flex-1 flex items-center bg-surface-container-low border border-orange-500/20 rounded-full px-4 py-2.5">
                <span className="text-orange-600 dark:text-orange-400 text-xs font-bold mr-2">BDT</span>
                <input
                  type="number"
                  defaultValue="250"
                  disabled={true}
                  className="bg-transparent border-none p-0 text-sm font-black w-full focus:ring-0 text-on-surface"
                />
              </div>

              <button
                onClick={handleLockDeal}
                disabled={!isButtonEnabled || isLocking}
                className={`flex-[1.5] py-3.5 rounded-full font-black text-xs tracking-wider uppercase flex items-center justify-center gap-2 shadow-md transition-all active:scale-95 ${
                  isButtonEnabled
                    ? 'bg-gradient-to-r from-orange-600 to-amber-500 text-white hover:from-orange-500 hover:to-amber-400 cursor-pointer shadow-orange-500/25'
                    : 'bg-surface-container-low text-on-surface-variant/40 border border-outline-variant cursor-not-allowed'
                }`}
              >
                {isLocking ? (
                  <span className="flex items-center gap-2">
                    <svg className="animate-spin h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    Locking...
                  </span>
                ) : (
                  <>
                    <Unlock className="w-4 h-4" />
                    Propose Lock Deal
                  </>
                )}
              </button>
            </>
          )}
        </div>

        {/* Input box */}
        {!dealLocked && (
          <form onSubmit={handleSend} className="flex gap-2">
            <input
              type="text"
              value={newMsg}
              onChange={(e) => setNewMsg(e.target.value)}
              placeholder="Type your message..."
              className="flex-grow bg-surface-container-low border border-orange-500/20 rounded-full px-5 py-3 text-xs outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent transition-all text-on-surface font-medium"
            />
            <button
              type="submit"
              className="bg-gradient-to-r from-orange-600 to-amber-500 hover:from-orange-500 hover:to-amber-400 text-white rounded-full px-5 py-3 flex items-center justify-center transition-all active:scale-95 shadow-md shadow-orange-500/25 cursor-pointer"
            >
              <Send className="w-4 h-4" />
            </button>
          </form>
        )}
      </div>
    </div>
  );
}

