/* eslint-disable @next/next/no-img-element */
'use client';

import React, { useState, useEffect, useRef } from 'react';
import { useUser } from '@/context/UserContext';
import { chatRepository } from '@/repositories/chatRepository';
import { tripRepository } from '@/repositories/tripRepository';
import { packageRepository } from '@/repositories/packageRepository';
import { uploadUserFile, STORAGE_BUCKETS } from '@/infrastructure/storage/upload';
import { Camera, CheckSquare, Lock, Unlock, Send, Sparkles, AlertCircle, KeyRound, RotateCcw, MapPin, ExternalLink, Navigation } from 'lucide-react';
import { formatMeetupPinMessage, parseMeetupPinMessage, meetupMapsUrl } from '@/shared/chat/meetupPin';

const CHECK_IN_CHIPS = ['Departed', 'Near pickup', 'Handed over', 'Near dropoff'];

export default function LiveChatBox({ dealId }) {
  const { userId } = useUser();
  const [deal, setDeal] = useState(null);
  const [trip, setTrip] = useState(null);
  const [pkg, setPkg] = useState(null);
  const [messages, setMessages] = useState([]);
  const [newMsg, setNewMsg] = useState('');
  const [isUploading, setIsUploading] = useState(false);
  const [sharingMeetup, setSharingMeetup] = useState(false);
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

  const handleShareMeetup = async () => {
    if (!userId || sharingMeetup) return;
    if (typeof navigator === 'undefined' || !navigator.geolocation) {
      setActionError('Geolocation is not available in this browser.');
      return;
    }
    setSharingMeetup(true);
    setActionError('');
    try {
      const position = await new Promise((resolve, reject) => {
        navigator.geolocation.getCurrentPosition(resolve, reject, {
          enableHighAccuracy: true,
          timeout: 15000,
          maximumAge: 0,
        });
      });
      const lat = Number(position.coords.latitude.toFixed(5));
      const lng = Number(position.coords.longitude.toFixed(5));
      const messageText = formatMeetupPinMessage({ lat, lng, label: 'Meetup' });
      const message = await chatRepository.createMessage({
        dealId,
        senderId: userId,
        messageText,
      });
      if (message) setMessages((previous) => previous.some((item) => item.id === message.id) ? previous : [...previous, message]);
      setActionInfo('Meetup pin shared.');
    } catch (error) {
      const denied = error?.code === 1 || /denied/i.test(error?.message || '');
      setActionError(denied
        ? 'Location permission denied. Allow location once to share a meetup pin.'
        : (error.message || 'Unable to share meetup pin.'));
    } finally {
      setSharingMeetup(false);
    }
  };

  const handleCheckIn = async (label) => {
    if (!userId || isWorking) return;
    setIsWorking(true);
    setActionError('');
    try {
      const message = await chatRepository.createMessage({
        dealId,
        senderId: userId,
        messageText: label,
      });
      if (message) setMessages((previous) => previous.some((item) => item.id === message.id) ? previous : [...previous, message]);
      setActionInfo(`Check-in sent: ${label}`);
    } catch (error) {
      setActionError(error.message || 'Unable to send check-in.');
    } finally {
      setIsWorking(false);
    }
  };

  const dealStatusLabel = () => {
    if (deal?.status === 'completed') return 'Completed — escrow released';
    if (deal?.status === 'cancelled') return 'Cancelled / refunded';
    if (deal?.deal_locked) return 'Escrow locked — in transit';
    return 'Negotiating';
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
    <div className="flex flex-col h-[calc(100vh-140px)] max-w-2xl mx-auto bg-surface rounded-xl shadow-xl border border-outline overflow-hidden transition-colors duration-300">
      {actionError && <p role="alert" className="m-4 mb-0 rounded-xl border border-red-500/25 bg-red-500/10 px-3 py-2 text-xs font-bold text-red-600 dark:text-red-400">{actionError}</p>}
      {actionInfo && <p className="m-4 mb-0 rounded-xl border border-outline bg-primary/10 px-3 py-2 text-xs font-bold text-primary">{actionInfo}</p>}

      <div className="border-b border-outline bg-surface-container-low px-4 py-3 flex flex-wrap items-center justify-between gap-2">
        <div>
          <p className="text-[10px] uppercase font-black tracking-widest text-on-surface-variant">Deal status</p>
          <p className="text-xs font-semibold text-on-surface mt-0.5">{dealStatusLabel()}</p>
        </div>
        <div className="text-right">
          <p className="text-[10px] uppercase font-black tracking-widest text-on-surface-variant">Agreed reward</p>
          <p className="text-xs font-bold text-primary mt-0.5">
            {Number.isSafeInteger(agreedAmountMinor) ? `${(agreedAmountMinor / 100).toFixed(2)} BDT` : 'Not set'}
          </p>
        </div>
      </div>

      <div className="bg-primary/10 border-b border-outline p-4 space-y-3">
        <div className="flex items-start gap-3">
          <AlertCircle className="text-primary w-5 h-5 flex-shrink-0 mt-0.5" />
          <div className="flex-grow">
            <h3 className="text-[11px] font-semibold text-primary uppercase tracking-wider">Mandatory Open-Box Inspection</h3>
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
            <label className={`flex-1 h-20 border-2 border-dashed rounded-2xl flex flex-col items-center justify-center gap-1.5 cursor-pointer transition-all ${ inspectionPhoto ? 'border-primary bg-primary/10 text-primary' : 'border-primary/25 bg-surface hover:bg-primary/10 text-on-surface-variant' }`}>
              <input type="file" onChange={handlePhotoUpload} className="hidden" accept="image/*" disabled={isUploading} />
              <Camera className="w-5 h-5 text-primary" />
              <span className="text-[10px] font-semibold uppercase tracking-wider">
                {isUploading ? 'Uploading...' : inspectionPhoto ? 'Change Photo (Uploaded)' : 'Add Inspection Proof'}
              </span>
            </label>

            <button
              onClick={() => setCheckedContraband(!checkedContraband)}
              className={`flex-1 p-3 border rounded-2xl flex items-center gap-2.5 transition-all text-left ${ checkedContraband ? 'border-primary bg-primary/10 text-primary' : 'border-primary/25 bg-surface hover:bg-primary/10 text-on-surface-variant' }`}
            >
              {checkedContraband ? (
                <CheckSquare className="w-5 h-5 text-primary flex-shrink-0" />
              ) : (
                <div className="w-5 h-5 border border-primary/30 rounded-md flex-shrink-0" />
              )}
              <span className="text-[10px] font-semibold uppercase leading-normal">
                I checked the items & confirm no contraband is inside.
              </span>
            </button>
          </div>
        )}

        {inspectionPhoto && (
          <div className="rounded-2xl overflow-hidden border border-outline max-w-xs">
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
                <div className="bg-primary/10 border border-primary/25 text-primary font-semibold text-[10px] uppercase tracking-wider px-4 py-2 rounded-full flex items-center gap-1.5 shadow-xs">
                  <Sparkles className="w-3.5 h-3.5 text-primary" />
                  {msg.message_text}
                </div>
              </div>
            );
          }

          const meetupPin = parseMeetupPinMessage(msg.message_text);
          if (meetupPin) {
            return (
              <div key={msg.id} className={`flex items-end gap-2 max-w-[90%] ${isMe ? 'ml-auto flex-row-reverse' : ''}`}>
                <div className={`w-8 h-8 rounded-full flex-shrink-0 overflow-hidden flex items-center justify-center font-semibold text-[10px] shadow-sm ${ isMe ? 'bg-primary text-white' : 'bg-amber-600 text-white' }`}>
                  {isMe ? 'ME' : 'TR'}
                </div>
                <div className="bg-surface border border-primary/30 rounded-2xl p-3.5 shadow-md min-w-[220px] space-y-2">
                  <div className="flex items-center gap-2 text-primary">
                    <MapPin className="w-4 h-4" />
                    <span className="text-xs font-semibold uppercase tracking-wider">{meetupPin.label}</span>
                  </div>
                  <p className="text-xs font-mono text-on-surface">
                    {meetupPin.lat.toFixed(5)}, {meetupPin.lng.toFixed(5)}
                  </p>
                  <a
                    href={meetupMapsUrl(meetupPin)}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="inline-flex items-center gap-1.5 text-[11px] font-bold text-primary hover:underline"
                  >
                    Open in maps
                    <ExternalLink className="w-3.5 h-3.5" />
                  </a>
                </div>
              </div>
            );
          }

          return (
            <div key={msg.id} className={`flex items-end gap-2 max-w-[85%] ${isMe ? 'ml-auto flex-row-reverse' : ''}`}>
              <div className={`w-8 h-8 rounded-full flex-shrink-0 overflow-hidden flex items-center justify-center font-semibold text-[10px] shadow-sm ${ isMe ? 'bg-primary text-white' : 'bg-amber-600 text-white' }`}>
                {isMe ? 'ME' : 'TR'}
              </div>
              <div className={`p-3.5 text-sm shadow-md leading-relaxed ${ isMe ? 'bg-primary text-white rounded-3xl rounded-br-xs font-medium' : 'bg-surface text-on-surface border border-outline rounded-3xl rounded-bl-xs font-medium' }`}>
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

      <div className="border-t border-outline-variant p-4 bg-surface space-y-4 transition-colors duration-300">
        <div className="flex gap-3">
          {dealCompleted ? (
            <div className="w-full bg-emerald-500/15 border border-emerald-500/40 text-emerald-700 dark:text-emerald-300 py-3.5 px-4 rounded-full flex items-center justify-center gap-2 font-semibold text-xs uppercase tracking-wider shadow-sm">
              <Lock className="w-4 h-4" />
              Delivery complete — escrow released
            </div>
          ) : dealCancelled ? (
            <div className="w-full bg-surface-container-low border border-outline-variant text-on-surface-variant py-3.5 px-4 rounded-full flex items-center justify-center gap-2 font-semibold text-xs uppercase tracking-wider">
              Deal cancelled / refunded
            </div>
          ) : dealLocked ? (
            <div className="w-full bg-primary/10 border border-primary/30 text-primary py-3.5 px-4 rounded-full flex items-center justify-center gap-2 font-semibold text-xs uppercase tracking-wider shadow-sm">
              <Lock className="w-4 h-4 animate-pulse text-primary" />
              DEAL LOCKED ({((agreedAmountMinor || 0) / 100).toFixed(2)} BDT)
            </div>
          ) : (
            <>
              <div className="flex-1 flex items-center bg-surface-container-low border border-outline rounded-full px-4 py-2.5">
                <span className="text-primary text-xs font-bold mr-2">BDT</span>
                <input
                  type="number"
                  value={Number.isSafeInteger(agreedAmountMinor) ? (agreedAmountMinor / 100) : ''}
                  disabled
                  placeholder="Agreed reward"
                  className="bg-transparent border-none p-0 text-sm font-semibold w-full focus:ring-0 text-on-surface"
                />
              </div>

              <button
                onClick={handleLockDeal}
                disabled={!isButtonEnabled || isLocking || !isTraveler}
                title={!isTraveler ? 'Only the traveler can lock the deal after inspection' : undefined}
                className={`flex-[1.5] py-3.5 rounded-full font-semibold text-xs tracking-wider uppercase flex items-center justify-center gap-2 shadow-md transition-all active:scale-95 ${ isButtonEnabled && isTraveler ? 'bg-primary text-white hover:bg-primary-700 cursor-pointer shadow-sm' : 'bg-surface-container-low text-on-surface-variant/40 border border-outline-variant cursor-not-allowed' }`}
              >
                {isLocking ? 'Locking...' : (<><Unlock className="w-4 h-4" /> Lock Escrow</>)}
              </button>
            </>
          )}
        </div>

        {dealLocked && !dealCompleted && !dealCancelled && (
          <div className="space-y-3 rounded-2xl border border-outline bg-surface-container-low p-3">
            {isSender && (
              <div className="space-y-2">
                <button
                  onClick={handleIssueOtp}
                  disabled={isWorking}
                  className="w-full py-3 rounded-full font-semibold text-xs uppercase tracking-wider bg-primary text-white flex items-center justify-center gap-2"
                >
                  <KeyRound className="w-4 h-4" />
                  Issue Delivery OTP
                </button>
                {issuedOtp && (
                  <p className="text-xs font-bold text-on-surface text-center">
                    OTP for handoff: <span className="font-mono text-primary">{issuedOtp}</span>
                  </p>
                )}
                <button
                  onClick={handleRefund}
                  disabled={isWorking}
                  className="w-full py-3 rounded-full font-semibold text-xs uppercase tracking-wider border border-outline-variant text-on-surface-variant flex items-center justify-center gap-2"
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
                  className="flex-grow bg-surface border border-outline rounded-full px-4 py-3 text-xs outline-none focus:ring-2 focus:ring-primary text-on-surface font-bold tracking-widest text-center"
                />
                <button
                  onClick={handleRelease}
                  disabled={isWorking || releaseOtp.trim().length < 4}
                  className="px-5 py-3 rounded-full font-semibold text-xs uppercase tracking-wider bg-primary text-white"
                >
                  Release
                </button>
              </div>
            )}
          </div>
        )}

        {!dealCompleted && !dealCancelled && (
          <div className="space-y-2">
            <div className="space-y-1.5">
              <p className="text-[10px] font-bold uppercase tracking-widest text-on-surface-variant flex items-center gap-1">
                <Navigation className="w-3 h-3 text-primary" />
                Check-in chips
              </p>
              <div className="flex flex-wrap gap-1.5">
                {CHECK_IN_CHIPS.map((label) => (
                  <button
                    key={label}
                    type="button"
                    disabled={isWorking || !userId}
                    onClick={() => handleCheckIn(label)}
                    className="px-3 py-1.5 rounded-full border border-outline bg-surface-container-low text-[10px] font-semibold uppercase tracking-wider text-on-surface hover:border-primary/40 hover:bg-primary/10 disabled:opacity-50"
                  >
                    {label}
                  </button>
                ))}
              </div>
            </div>

            <button
              type="button"
              onClick={handleShareMeetup}
              disabled={sharingMeetup || !userId}
              className="w-full py-2.5 rounded-full border border-primary/30 bg-primary/10 text-primary text-[11px] font-semibold uppercase tracking-wider flex items-center justify-center gap-2 hover:bg-primary/15 disabled:opacity-50"
            >
              <MapPin className="w-3.5 h-3.5" />
              {sharingMeetup ? 'Getting location…' : 'Share meetup pin'}
            </button>
            <form onSubmit={handleSend} className="flex gap-2">
              <input
                type="text"
                value={newMsg}
                onChange={(e) => setNewMsg(e.target.value)}
                placeholder="Type your message..."
                className="flex-grow bg-surface-container-low border border-outline rounded-full px-5 py-3 text-xs outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all text-on-surface font-medium"
              />
              <button
                type="submit"
                className="bg-primary hover:bg-primary-700 text-white rounded-full px-5 py-3 flex items-center justify-center transition-all active:scale-95 shadow-sm cursor-pointer"
              >
                <Send className="w-4 h-4" />
              </button>
            </form>
          </div>
        )}
      </div>
    </div>
  );
}
