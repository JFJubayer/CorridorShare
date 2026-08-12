/* eslint-disable @next/next/no-img-element */
'use client';

import React, { useState, useEffect, useRef } from 'react';
import { useUser } from '@/context/UserContext';
import { chatRepository } from '@/repositories/chatRepository';
import { tripRepository } from '@/repositories/tripRepository';
import { packageRepository } from '@/repositories/packageRepository';
import { uploadUserFile, STORAGE_BUCKETS } from '@/infrastructure/storage/upload';
import { Camera, CheckSquare, Lock, Unlock, Send, Sparkles, AlertCircle, KeyRound, RotateCcw } from 'lucide-react';

export default function LiveChatBox({ dealId }) {
  const { userId } = useUser();
  const [deal, setDeal] = useState(null);
  const [trip, setTrip] = useState(null);
  const [pkg, setPkg] = useState(null);
  const [messages, setMessages] = useState([]);
  const [newMsg, setNewMsg] = useState('');
  const [isUploading, setIsUploading] = useState(false);
  const [inspectionPhoto, setInspectionPhoto] = useState('');
  const [checkedContraband, setCheckedContraband] = useState(false);
  const [isLocking, setIsLocking] = useState(false);
  const [isWorking, setIsWorking] = useState(false);
  const [issuedOtp, setIssuedOtp] = useState('');
  const [releaseOtp, setReleaseOtp] = useState('');
  const [actionError, setActionError] = useState('');
  const [actionInfo, setActionInfo] = useState('');
  const chatEndRef = useRef(null);

  useEffect(() => {
    let active = true;
    const loadDealData = async () => {
      try {
        const activeDeal = await chatRepository.findById(dealId);
        if (!active || !activeDeal) return;
        setDeal(activeDeal);
        setMessages(activeDeal.messages || []);
        setInspectionPhoto(activeDeal.inspection_photo_url || '');
        setCheckedContraband(activeDeal.open_box_verified || false);
        const [tripRow, packageRow] = await Promise.all([
          tripRepository.findById(activeDeal.trip_id),
          packageRepository.findById(activeDeal.package_id),
        ]);
        if (!active) return;
        setTrip(tripRow);
        setPkg(packageRow);
      } catch (error) {
        if (active) setActionError(error.message || 'Unable to load this deal.');
      }
    };

    loadDealData();
    const unsubscribe = chatRepository.subscribeToMessages(dealId, (message) => {
      if (!active) return;
      setMessages((previous) => previous.some((item) => item.id === message.id) ? previous : [...previous, message]);
    });

    return () => {
      active = false;
      unsubscribe();
    };
  }, [dealId]);

  useEffect(() => {
    chatEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const agreedAmountMinor = Number.isSafeInteger(deal?.final_agreed_price_minor)
    ? deal.final_agreed_price_minor
    : (Number.isSafeInteger(pkg?.proposed_reward_minor) ? pkg.proposed_reward_minor : null);

  const isTraveler = Boolean(trip && userId && trip.traveler_id === userId);
  const isSender = Boolean(pkg && userId && pkg.sender_id === userId);

  const handleSend = async (e) => {
    e.preventDefault();
    if (!newMsg.trim() && !inspectionPhoto) return;

    try {
      setActionError('');
      const message = await chatRepository.createMessage({
        dealId,
        senderId: userId,
        messageText: newMsg.trim(),
        imageVerificationUrl: inspectionPhoto || null,
      });
      if (message) setMessages((previous) => previous.some((item) => item.id === message.id) ? previous : [...previous, message]);
      setNewMsg('');
    } catch (error) {
      setActionError(error.message || 'Unable to send the message.');
    }
  };

  const handlePhotoUpload = async (e) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setIsUploading(true);
    setActionError('');
    try {
      const url = await uploadUserFile({
        bucket: STORAGE_BUCKETS.inspection,
        folder: `deals/${dealId}`,
        file,
      });
      setInspectionPhoto(url);
      setActionInfo('Inspection photo uploaded.');
    } catch (error) {
      setActionError(error.message || 'Unable to upload the inspection photo.');
    } finally {
      setIsUploading(false);
      e.target.value = '';
    }
  };

  const handleLockDeal = async () => {
    if (!inspectionPhoto || !checkedContraband) return;
    if (!Number.isSafeInteger(agreedAmountMinor) || agreedAmountMinor <= 0) {
      setActionError('Lock uses the agreed reward for this deal. Open the chat from a package match that includes a reward.');
      return;
    }

    setIsLocking(true);
    try {
      const lockedDeal = await chatRepository.lockDeal({
        dealId,
        amountMinor: agreedAmountMinor,
        inspectionPhotoUrl: inspectionPhoto,
      });
      setDeal((previous) => ({ ...previous, ...(lockedDeal || {}), deal_locked: true, open_box_verified: true, final_agreed_price_minor: agreedAmountMinor }));
      setActionError('');
      setActionInfo(`Escrow locked for ${(agreedAmountMinor / 100).toFixed(2)} BDT.`);
    } catch (error) {
      setActionError(error.message || 'Unable to lock this deal.');
    } finally {
      setIsLocking(false);
    }
  };

  const handleIssueOtp = async () => {
    setIsWorking(true);
    setActionError('');
    try {
      const otp = await chatRepository.issueDeliveryOtp(dealId);
      setIssuedOtp(otp);
      setActionInfo('Delivery OTP issued. Share it only with the traveler at handoff.');
    } catch (error) {
      setActionError(error.message || 'Unable to issue a delivery OTP.');
    } finally {
      setIsWorking(false);
    }
  };

  const handleRelease = async () => {
    setIsWorking(true);
    setActionError('');
    try {
      const updated = await chatRepository.releaseDeal({ dealId, deliveryOtp: releaseOtp });
      setDeal((previous) => ({ ...previous, ...(updated || {}), status: 'completed' }));
      setActionInfo('Escrow released to the traveler.');
    } catch (error) {
      setActionError(error.message || 'Unable to release escrow.');
    } finally {
      setIsWorking(false);
    }
  };

  const handleRefund = async () => {
    if (!window.confirm('Refund escrow to the sender and cancel this deal?')) return;
    setIsWorking(true);
    setActionError('');
    try {
      const updated = await chatRepository.refundDeal({ dealId });
      setDeal((previous) => ({ ...previous, ...(updated || {}), status: 'cancelled' }));
      setActionInfo('Escrow refunded and deal cancelled.');
    } catch (error) {
      setActionError(error.message || 'Unable to refund this deal.');
    } finally {
      setIsWorking(false);
    }
  };

  const dealLocked = deal?.deal_locked;
  const dealCompleted = deal?.status === 'completed';
  const dealCancelled = deal?.status === 'cancelled';
  const isButtonEnabled = inspectionPhoto && checkedContraband && Number.isSafeInteger(agreedAmountMinor) && agreedAmountMinor > 0;

  return (
    <div className="flex flex-col h-[calc(100vh-140px)] max-w-2xl mx-auto bg-surface rounded-[28px] shadow-xl border border-orange-500/25 overflow-hidden transition-colors duration-300">
      {actionError && <p role="alert" className="m-4 mb-0 rounded-xl border border-red-500/25 bg-red-500/10 px-3 py-2 text-xs font-bold text-red-600 dark:text-red-400">{actionError}</p>}
      {actionInfo && <p className="m-4 mb-0 rounded-xl border border-orange-500/25 bg-orange-500/10 px-3 py-2 text-xs font-bold text-orange-700 dark:text-orange-300">{actionInfo}</p>}

      <div className="bg-orange-500/10 border-b border-orange-500/20 p-4 space-y-3">
        <div className="flex items-start gap-3">
          <AlertCircle className="text-orange-600 dark:text-orange-400 w-5 h-5 flex-shrink-0 mt-0.5" />
          <div className="flex-grow">
            <h3 className="text-[11px] font-black text-orange-600 dark:text-orange-400 uppercase tracking-wider">Mandatory Open-Box Inspection</h3>
            <p className="text-xs text-on-surface-variant leading-normal mt-0.5 font-medium">
              For mutual security, travelers must verify package contents. Upload a real inspection photo to activate deal locking.
            </p>
            <p className="text-[11px] text-on-surface font-bold mt-2">
              Agreed reward: {Number.isSafeInteger(agreedAmountMinor) ? `${(agreedAmountMinor / 100).toFixed(2)} BDT` : 'Not set yet'}
            </p>
          </div>
        </div>

        {!dealLocked && !dealCancelled && (
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

        {inspectionPhoto && (
          <div className="rounded-2xl overflow-hidden border border-orange-500/20 max-w-xs">
            <img src={inspectionPhoto} alt="Inspection proof" className="w-full h-auto object-cover max-h-40" />
          </div>
        )}
      </div>

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

      <div className="border-t border-orange-500/15 p-4 bg-surface space-y-4 transition-colors duration-300">
        <div className="flex gap-3">
          {dealCompleted ? (
            <div className="w-full bg-emerald-500/15 border border-emerald-500/40 text-emerald-700 dark:text-emerald-300 py-3.5 px-4 rounded-full flex items-center justify-center gap-2 font-black text-xs uppercase tracking-wider shadow-sm">
              <Lock className="w-4 h-4" />
              Delivery complete — escrow released
            </div>
          ) : dealCancelled ? (
            <div className="w-full bg-surface-container-low border border-outline-variant text-on-surface-variant py-3.5 px-4 rounded-full flex items-center justify-center gap-2 font-black text-xs uppercase tracking-wider">
              Deal cancelled / refunded
            </div>
          ) : dealLocked ? (
            <div className="w-full bg-orange-500/15 border border-orange-500/40 text-orange-600 dark:text-orange-400 py-3.5 px-4 rounded-full flex items-center justify-center gap-2 font-black text-xs uppercase tracking-wider shadow-sm">
              <Lock className="w-4 h-4 animate-pulse text-orange-500" />
              DEAL LOCKED ({((agreedAmountMinor || 0) / 100).toFixed(2)} BDT)
            </div>
          ) : (
            <>
              <div className="flex-1 flex items-center bg-surface-container-low border border-orange-500/20 rounded-full px-4 py-2.5">
                <span className="text-orange-600 dark:text-orange-400 text-xs font-bold mr-2">BDT</span>
                <input
                  type="number"
                  value={Number.isSafeInteger(agreedAmountMinor) ? (agreedAmountMinor / 100) : ''}
                  disabled
                  placeholder="Agreed reward"
                  className="bg-transparent border-none p-0 text-sm font-black w-full focus:ring-0 text-on-surface"
                />
              </div>

              <button
                onClick={handleLockDeal}
                disabled={!isButtonEnabled || isLocking || !isTraveler}
                title={!isTraveler ? 'Only the traveler can lock the deal after inspection' : undefined}
                className={`flex-[1.5] py-3.5 rounded-full font-black text-xs tracking-wider uppercase flex items-center justify-center gap-2 shadow-md transition-all active:scale-95 ${
                  isButtonEnabled && isTraveler
                    ? 'bg-gradient-to-r from-orange-600 to-amber-500 text-white hover:from-orange-500 hover:to-amber-400 cursor-pointer shadow-orange-500/25'
                    : 'bg-surface-container-low text-on-surface-variant/40 border border-outline-variant cursor-not-allowed'
                }`}
              >
                {isLocking ? 'Locking...' : (<><Unlock className="w-4 h-4" /> Lock Escrow</>)}
              </button>
            </>
          )}
        </div>

        {dealLocked && !dealCompleted && !dealCancelled && (
          <div className="space-y-3 rounded-2xl border border-orange-500/20 bg-surface-container-low p-3">
            {isSender && (
              <div className="space-y-2">
                <button
                  onClick={handleIssueOtp}
                  disabled={isWorking}
                  className="w-full py-3 rounded-full font-black text-xs uppercase tracking-wider bg-gradient-to-r from-orange-600 to-amber-500 text-white flex items-center justify-center gap-2"
                >
                  <KeyRound className="w-4 h-4" />
                  Issue Delivery OTP
                </button>
                {issuedOtp && (
                  <p className="text-xs font-bold text-on-surface text-center">
                    OTP for handoff: <span className="font-mono text-orange-600 dark:text-orange-400">{issuedOtp}</span>
                  </p>
                )}
                <button
                  onClick={handleRefund}
                  disabled={isWorking}
                  className="w-full py-3 rounded-full font-black text-xs uppercase tracking-wider border border-outline-variant text-on-surface-variant flex items-center justify-center gap-2"
                >
                  <RotateCcw className="w-4 h-4" />
                  Refund Escrow
                </button>
              </div>
            )}

            {isTraveler && (
              <div className="flex gap-2">
                <input
                  type="text"
                  inputMode="numeric"
                  maxLength={6}
                  value={releaseOtp}
                  onChange={(e) => setReleaseOtp(e.target.value)}
                  placeholder="Enter delivery OTP"
                  className="flex-grow bg-surface border border-orange-500/20 rounded-full px-4 py-3 text-xs outline-none focus:ring-2 focus:ring-orange-500 text-on-surface font-bold tracking-widest text-center"
                />
                <button
                  onClick={handleRelease}
                  disabled={isWorking || releaseOtp.trim().length < 4}
                  className="px-5 py-3 rounded-full font-black text-xs uppercase tracking-wider bg-gradient-to-r from-orange-600 to-amber-500 text-white"
                >
                  Release
                </button>
              </div>
            )}
          </div>
        )}

        {!dealLocked && !dealCancelled && (
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
