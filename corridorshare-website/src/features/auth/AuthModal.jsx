'use client';

import React, { useState } from 'react';
import { useUser } from '@/context/UserContext';
import { isMockDataSource } from '@/config/supabaseClient';
import { profileRepository } from '@/repositories/profileRepository';
import { uploadUserFile, STORAGE_BUCKETS } from '@/infrastructure/storage/upload';
import { toBdE164 } from '@/shared/phone/bdPhone';
import { 
  ShieldCheck, Phone, KeyRound, ArrowRight, X, Lock, User, Mail, 
  Car, Package, CheckCircle2, Sparkles, Compass, UploadCloud, ChevronLeft 
} from 'lucide-react';

export default function AuthModal({ isOpen, onClose, title = "Welcome to CorridorShare" }) {
  const { requestOtp, verifyOtp, userId, refreshProfile } = useUser();
  const [isSignUp, setIsSignUp] = useState(true);
  const [step, setStep] = useState(1); // Steps 1 to 4 for progressive onboarding
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Form Fields State
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [userRole, setUserRole] = useState('traveler'); // 'traveler' or 'sender'
  const [phoneNumber, setPhoneNumber] = useState('');
  const [otpCode, setOtpCode] = useState('');
  const [otpSent, setOtpSent] = useState(false);
  const [authError, setAuthError] = useState('');
  const [selectedCorridors, setSelectedCorridors] = useState(['N3 Dhaka ↔ Mymensingh (Gazipur Bypass)']);
  const [nidUploaded, setNidUploaded] = useState(false);
  const [nidPhotoUrl, setNidPhotoUrl] = useState('');
  const [nidUploading, setNidUploading] = useState(false);

  if (!isOpen) return null;

  // Calculate Onboarding Completion Percentage
  const getProgressPercentage = () => {
    if (!isSignUp) return 100;
    switch (step) {
      case 1: return 25;
      case 2: return 50;
      case 3: return 75;
      case 4: return 100;
      default: return 25;
    }
  };

  const handleStep1Next = (e) => {
    e.preventDefault();
    if (!fullName || !email) return;
    setStep(2);
  };

  const fullPhoneNumber = () => toBdE164(phoneNumber);

  const handleSendOTP = async (e) => {
    e.preventDefault();
    if (!phoneNumber || phoneNumber.length < 8) return;
    setIsSubmitting(true);
    setAuthError('');
    try {
      await requestOtp(fullPhoneNumber());
      setIsSubmitting(false);
      setOtpSent(true);
    } catch (error) {
      setAuthError(error.message || 'Unable to send the verification code.');
      setIsSubmitting(false);
    }
  };

  const handleVerifyOTP = async (e) => {
    e.preventDefault();
    if (!otpCode || otpCode.length < 6) {
      setAuthError('Enter the full 6-digit code (friends beta: 123456).');
      return;
    }
    setIsSubmitting(true);
    setAuthError('');
    try {
      await verifyOtp(fullPhoneNumber(), otpCode);
      setIsSubmitting(false);
      setStep(3);
    } catch (error) {
      setAuthError(error.message || 'The verification code is invalid or expired.');
      setIsSubmitting(false);
    }
  };

  const handleStep3Next = (e) => {
    e.preventDefault();
    setStep(4);
  };

  const handleNidFileChange = async (e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    if (!userId) {
      setAuthError('Verify your phone before uploading an NID photo.');
      return;
    }
    setNidUploading(true);
    setAuthError('');
    try {
      const url = await uploadUserFile({
        bucket: STORAGE_BUCKETS.nid,
        folder: userId, // storage RLS requires first path segment = auth.uid()
        file,
      });
      await profileRepository.updateOwnDetails(userId, {
        full_name: fullName.trim() || undefined,
        nid_photo_url: url,
      });
      setNidPhotoUrl(url);
      setNidUploaded(true);
      if (refreshProfile) await refreshProfile();
    } catch (error) {
      setAuthError(error.message || 'Unable to upload your NID photo.');
      setNidUploaded(false);
    } finally {
      setNidUploading(false);
      e.target.value = '';
    }
  };

  const handleCompleteRegistration = async (e) => {
    e.preventDefault();
    if (!nidUploaded || !nidPhotoUrl) {
      setAuthError('Upload a real NID photo before finishing registration.');
      return;
    }
    setIsSubmitting(true);
    setAuthError('');
    try {
      if (userId && fullName.trim()) {
        await profileRepository.updateOwnDetails(userId, { full_name: fullName.trim(), nid_photo_url: nidPhotoUrl });
        if (refreshProfile) await refreshProfile();
      }
      if (onClose) onClose();
    } catch (error) {
      setAuthError(error.message || 'Unable to finish profile setup.');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleQuickLogin = async (e) => {
    e.preventDefault();
    setIsSubmitting(true);
    setAuthError('');
    try {
      if (!otpSent) {
        await requestOtp(fullPhoneNumber());
        setOtpSent(true);
      } else {
        await verifyOtp(fullPhoneNumber(), otpCode);
        if (onClose) onClose();
      }
      setIsSubmitting(false);
    } catch (error) {
      setAuthError(error.message || 'Unable to sign in.');
      setIsSubmitting(false);
    }
  };

  const toggleCorridor = (name) => {
    if (selectedCorridors.includes(name)) {
      setSelectedCorridors(selectedCorridors.filter(c => c !== name));
    } else {
      setSelectedCorridors([...selectedCorridors, name]);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Dark overlay backdrop */}
      <div 
        className="absolute inset-0 bg-slate-950/80 backdrop-blur-md transition-opacity" 
        onClick={onClose}
      />

      <div className="bg-surface border-2 border-primary/25 rounded-2xl p-6 sm:p-8 max-w-lg w-full relative z-10 shadow-lg animate-in fade-in zoom-in-95 duration-200 overflow-hidden">
        
        {/* Top Close Button */}
        {onClose && (
          <button 
            onClick={onClose}
            className="absolute right-5 top-5 text-on-surface-variant hover:text-on-surface p-2 rounded-full hover:bg-primary/10 transition-colors z-20 cursor-pointer"
          >
            <X className="w-5 h-5" />
          </button>
        )}

        {/* Top Header & Progressive Progress Bar */}
        <div className="space-y-4 mb-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <span className="w-9 h-9 rounded-full bg-primary text-white flex items-center justify-center font-semibold text-xs shadow-sm">
                CS
              </span>
              <div>
                <h3 className="text-xl font-semibold text-on-surface tracking-tight font-display">
                  {isSignUp ? 'Progressive Registration' : 'Welcome Back'}
                </h3>
                <p className="text-[11px] text-on-surface-variant font-bold">
                  {isSignUp ? `Step ${step} of 4 • Account Setup` : 'Sign in to access your matches & messages'}
                </p>
              </div>
            </div>

            {isSignUp && (
              <span className="text-xs font-semibold text-primary bg-primary/10 px-3 py-1 rounded-full border border-outline">
                Profile {getProgressPercentage()}% Complete
              </span>
            )}
          </div>

          {/* Interactive Progress Bar */}
          {isSignUp && (
            <div className="w-full h-2.5 bg-primary/10 rounded-full overflow-hidden p-0.5 border border-outline">
              <div 
                className="h-full bg-primary rounded-full transition-all duration-500 ease-out relative"
                style={{ width: `${getProgressPercentage()}%` }}
              >
                <div className="absolute right-0 top-0 bottom-0 w-3 bg-white/60 animate-pulse rounded-full" />
              </div>
            </div>
          )}
        </div>

        {authError && (
          <p role="alert" className="mb-4 rounded-2xl border border-red-500/25 bg-red-500/10 px-4 py-3 text-xs font-bold text-red-600 dark:text-red-400">
            {authError}
          </p>
        )}

        {/* ---------------------------------------------------- */}
        {/* SIGN UP FLOW (PROGRESSIVE 4-STEP ONBOARDING) */}
        {/* ---------------------------------------------------- */}
        {isSignUp ? (
          <div>
            {/* STEP 1: Basic Information & Role Selection */}
            {step === 1 && (
              <form onSubmit={handleStep1Next} className="space-y-4 animate-in fade-in duration-200">
                <div className="space-y-1 text-center">
                  <h4 className="text-lg font-semibold text-on-surface font-display">Create Your Account</h4>
                  <p className="text-xs text-on-surface-variant font-medium">Let&apos;s get started with your name and primary role.</p>
                </div>

                <div className="space-y-3">
                  <div>
                    <label className="block text-[10px] font-semibold text-on-surface-variant tracking-wide mb-1">
                      Full Name
                    </label>
                    <div className="flex items-center bg-surface-container-low border border-outline rounded-2xl px-4 py-3 focus-within:ring-2 focus-within:ring-primary transition-all">
                      <User className="w-4 h-4 text-primary mr-2.5 flex-shrink-0" />
                      <input 
                        type="text"
                        value={fullName}
                        onChange={(e) => setFullName(e.target.value)}
                        placeholder="Aminul Islam"
                        required
                        className="bg-transparent border-none p-0 text-sm font-bold w-full focus:ring-0 text-on-surface outline-none"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-[10px] font-semibold text-on-surface-variant tracking-wide mb-1">
                      Email Address
                    </label>
                    <div className="flex items-center bg-surface-container-low border border-outline rounded-2xl px-4 py-3 focus-within:ring-2 focus-within:ring-primary transition-all">
                      <Mail className="w-4 h-4 text-primary mr-2.5 flex-shrink-0" />
                      <input 
                        type="email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        placeholder="aminul@example.com"
                        required
                        className="bg-transparent border-none p-0 text-sm font-bold w-full focus:ring-0 text-on-surface outline-none"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-[10px] font-semibold text-on-surface-variant tracking-wide mb-1.5">
                      I want to primarily:
                    </label>
                    <div className="grid grid-cols-2 gap-3">
                      <button
                        type="button"
                        onClick={() => setUserRole('traveler')}
                        className={`p-3.5 rounded-2xl border-2 transition-all flex flex-col items-center text-center gap-1.5 cursor-pointer ${ userRole === 'traveler' ? 'border-primary bg-primary/10 text-primary shadow-md' : 'border-outline-variant/60 bg-surface-container-low text-on-surface-variant' }`}
                      >
                        <Car className="w-5 h-5 text-primary" />
                        <span className="text-xs font-semibold">Highway Traveler</span>
                        <span className="text-[9px] font-medium leading-tight text-on-surface-variant">Earn surcharges while traveling</span>
                      </button>

                      <button
                        type="button"
                        onClick={() => setUserRole('sender')}
                        className={`p-3.5 rounded-2xl border-2 transition-all flex flex-col items-center text-center gap-1.5 cursor-pointer ${ userRole === 'sender' ? 'border-primary bg-primary/10 text-primary shadow-md' : 'border-outline-variant/60 bg-surface-container-low text-on-surface-variant' }`}
                      >
                        <Package className="w-5 h-5 text-primary" />
                        <span className="text-xs font-semibold">Package Sender</span>
                        <span className="text-[9px] font-medium leading-tight text-on-surface-variant">Send cargo on express routes</span>
                      </button>
                    </div>
                  </div>
                </div>

                <button
                  type="submit"
                  className="w-full bg-primary hover:bg-primary-700 text-white py-4 rounded-full font-semibold text-xs tracking-wide transition-all shadow-sm flex items-center justify-center gap-2 cursor-pointer mt-2"
                >
                  Continue to Phone Verification
                  <ArrowRight className="w-4 h-4" />
                </button>

                <div className="text-center pt-1">
                  <button
                    type="button"
                    onClick={() => setIsSignUp(false)}
                    className="text-xs text-primary font-bold hover:underline cursor-pointer"
                  >
                    Already have an account? Sign In
                  </button>
                </div>
              </form>
            )}

            {/* STEP 2: Mobile Number & OTP Code Verification */}
            {step === 2 && (
              <div className="space-y-4 animate-in fade-in duration-200">
                <div className="flex items-center justify-between">
                  <button 
                    onClick={() => setStep(1)} 
                    className="text-xs font-bold text-primary flex items-center gap-1 hover:underline cursor-pointer"
                  >
                    <ChevronLeft className="w-4 h-4" />
                    Back to Step 1
                  </button>
                  <span className="text-[10px] text-on-surface-variant font-bold">Step 2 / 4</span>
                </div>

                <div className="space-y-1 text-center">
                  <h4 className="text-lg font-semibold text-on-surface font-display">Verify Phone Number</h4>
                  <p className="text-xs text-on-surface-variant font-medium">Friends beta: use +880 1712345678 (or 1700000001–0003). OTP is always 123456 — no real SMS yet.</p>
                </div>

                {!otpSent ? (
                  <form onSubmit={handleSendOTP} className="space-y-4">
                    <div>
                      <label className="block text-[10px] font-semibold text-on-surface-variant tracking-wide mb-1.5">
                        Bangladesh Phone Number
                      </label>
                      <div className="flex items-center bg-surface-container-low border border-outline rounded-2xl px-4 py-3.5 focus-within:ring-2 focus-within:ring-primary transition-all">
                        <Phone className="w-4 h-4 text-primary mr-2 flex-shrink-0" />
                        <span className="text-xs font-semibold text-on-surface mr-1.5">+880</span>
                        <input 
                          type="tel"
                          value={phoneNumber.replace('+880', '')}
                          onChange={(e) => setPhoneNumber(e.target.value)}
                          placeholder="1712345678"
                          required
                          className="bg-transparent border-none p-0 text-sm font-bold w-full focus:ring-0 text-on-surface outline-none"
                        />
                      </div>
                    </div>

                    <button
                      type="submit"
                      disabled={isSubmitting}
                      className="w-full bg-primary hover:bg-primary-700 text-white py-4 rounded-full font-semibold text-xs tracking-wide transition-all shadow-sm flex items-center justify-center gap-2 cursor-pointer"
                    >
                      {isSubmitting ? 'Sending OTP SMS...' : 'Send 6-Digit OTP Code'}
                    </button>
                  </form>
                ) : (
                  <form onSubmit={handleVerifyOTP} className="space-y-4">
                    <div>
                      <div className="flex justify-between items-center mb-1.5">
                        <label className="block text-[10px] font-semibold text-on-surface-variant tracking-wide">
                          Enter 6-Digit Code
                        </label>
                        <button 
                          type="button" 
                          onClick={() => setOtpSent(false)}
                          className="text-[10px] font-bold text-primary hover:underline cursor-pointer"
                        >
                          Change Number
                        </button>
                      </div>
                      <div className="flex items-center bg-surface-container-low border border-outline rounded-2xl px-4 py-3.5 focus-within:ring-2 focus-within:ring-primary transition-all">
                        <KeyRound className="w-4 h-4 text-primary mr-2 flex-shrink-0" />
                        <input 
                          type="text"
                          maxLength={6}
                          value={otpCode}
                          onChange={(e) => setOtpCode(e.target.value)}
                          placeholder="123456"
                          required
                          className="bg-transparent border-none p-0 text-sm font-semibold w-full text-center tracking-widest focus:ring-0 text-on-surface outline-none"
                        />
                      </div>
                      <p className="text-[10px] text-on-surface-variant mt-1.5 text-center font-medium">
                        Friends beta code: <strong className="text-primary">123456</strong> (all 6 digits)
                      </p>
                    </div>

                    <button
                      type="submit"
                      disabled={isSubmitting}
                      className="w-full bg-primary hover:bg-primary-700 text-white py-4 rounded-full font-semibold text-xs tracking-wide transition-all shadow-sm flex items-center justify-center gap-2 cursor-pointer"
                    >
                      {isSubmitting ? 'Verifying OTP...' : 'Verify & Continue'}
                    </button>
                  </form>
                )}
              </div>
            )}

            {/* STEP 3: Highway Corridor Preferences */}
            {step === 3 && (
              <form onSubmit={handleStep3Next} className="space-y-4 animate-in fade-in duration-200">
                <div className="flex items-center justify-between">
                  <button 
                    type="button"
                    onClick={() => setStep(2)} 
                    className="text-xs font-bold text-primary flex items-center gap-1 hover:underline cursor-pointer"
                  >
                    <ChevronLeft className="w-4 h-4" />
                    Back to Step 2
                  </button>
                  <span className="text-[10px] text-on-surface-variant font-bold">Step 3 / 4</span>
                </div>

                <div className="space-y-1 text-center">
                  <h4 className="text-lg font-semibold text-on-surface font-display">Select Primary Corridors</h4>
                  <p className="text-xs text-on-surface-variant font-medium">Choose highway routes you frequently travel or ship along.</p>
                </div>

                <div className="space-y-2">
                  {[
                    "N3 Dhaka ↔ Mymensingh (Gazipur Bypass)",
                    "N1 Dhaka ↔ Chittagong (Comilla Highway)",
                    "N2 Dhaka ↔ Sylhet (Brahmanbaria)",
                    "N5 Dhaka ↔ Tangail (Sirajganj Bridge)"
                  ].map((corridor) => {
                    const isSelected = selectedCorridors.includes(corridor);
                    return (
                      <button
                        key={corridor}
                        type="button"
                        onClick={() => toggleCorridor(corridor)}
                        className={`w-full p-3.5 rounded-2xl border transition-all flex items-center justify-between text-left cursor-pointer ${ isSelected ? 'border-primary bg-primary/10 text-on-surface font-bold shadow-xs' : 'border-outline-variant/60 bg-surface-container-low text-on-surface-variant' }`}
                      >
                        <div className="flex items-center gap-2.5">
                          <Compass className={`w-4 h-4 ${isSelected ? 'text-primary' : 'text-on-surface-variant/60'}`} />
                          <span className="text-xs font-bold">{corridor}</span>
                        </div>
                        {isSelected && <CheckCircle2 className="w-4 h-4 text-primary" />}
                      </button>
                    );
                  })}
                </div>

                <button
                  type="submit"
                  className="w-full bg-primary hover:bg-primary-700 text-white py-4 rounded-full font-semibold text-xs tracking-wide transition-all shadow-sm flex items-center justify-center gap-2 cursor-pointer mt-2"
                >
                  Continue to Trust Verification
                  <ArrowRight className="w-4 h-4" />
                </button>
              </form>
            )}

            {/* STEP 4: NID Identity & Trust Verification (100% Complete) */}
            {step === 4 && (
              <form onSubmit={handleCompleteRegistration} className="space-y-4 animate-in fade-in duration-200">
                <div className="flex items-center justify-between">
                  <button 
                    type="button"
                    onClick={() => setStep(3)} 
                    className="text-xs font-bold text-primary flex items-center gap-1 hover:underline cursor-pointer"
                  >
                    <ChevronLeft className="w-4 h-4" />
                    Back to Step 3
                  </button>
                  <span className="text-[10px] text-on-surface-variant font-bold">Step 4 / 4</span>
                </div>

                <div className="space-y-1 text-center">
                  <h4 className="text-lg font-semibold text-on-surface font-display">National ID (NID) Verification</h4>
                  <p className="text-xs text-on-surface-variant font-medium">Verify your identity to unlock escrow protection & instant deals.</p>
                </div>

                <div className="bg-surface-container-low border-2 border-dashed border-primary/25 rounded-3xl p-6 text-center space-y-3">
                  <div className="w-12 h-12 rounded-full bg-primary/10 text-primary flex items-center justify-center mx-auto">
                    <UploadCloud className="w-6 h-6" />
                  </div>
                  <div>
                    <p className="text-xs font-semibold text-on-surface">Upload NID Card Photo</p>
                    <p className="text-[10px] text-on-surface-variant mt-0.5">Supports JPG, PNG or WebP (Max 5MB)</p>
                  </div>

                  <label className={`inline-flex px-4 py-2 rounded-full text-xs font-semibold transition-all cursor-pointer ${ nidUploaded ? 'bg-emerald-500/15 text-emerald-600 border border-emerald-500/30' : 'bg-primary/10 text-primary border border-primary/25' }`}>
                    <input type="file" accept="image/*,application/pdf" className="hidden" onChange={handleNidFileChange} disabled={nidUploading || !userId} />
                    {nidUploading ? 'Uploading NID...' : nidUploaded ? '✓ NID Photo Uploaded' : '+ Upload NID Photo'}
                  </label>
                  {nidPhotoUrl && (
                    <p className="text-[10px] text-on-surface-variant font-medium break-all px-2">Photo saved for admin review.</p>
                  )}
                </div>

                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="w-full bg-primary hover:bg-primary-700 text-white py-4 rounded-full font-semibold text-xs tracking-wide transition-all shadow-sm flex items-center justify-center gap-2 cursor-pointer mt-2"
                >
                  {isSubmitting ? (
                    <span>Unlocking Platform Access...</span>
                  ) : (
                    <>
                      <ShieldCheck className="w-4 h-4" />
                      Complete Profile & Start Matching
                    </>
                  )}
                </button>
              </form>
            )}
          </div>
        ) : (
          /* ---------------------------------------------------- */
          /* QUICK SIGN IN FLOW FOR RETURNING USERS */
          /* ---------------------------------------------------- */
          <form onSubmit={handleQuickLogin} className="space-y-4 animate-in fade-in duration-200">
            <div className="space-y-1 text-center mb-2">
              <h4 className="text-lg font-semibold text-on-surface font-display">Sign In to Your Account</h4>
              <p className="text-xs text-on-surface-variant font-medium">Enter your registered mobile number to receive your login code.</p>
            </div>

            <div>
              <label className="block text-[10px] font-semibold text-on-surface-variant tracking-wide mb-1">
                Registered Mobile Number
              </label>
              <div className="flex items-center bg-surface-container-low border border-outline rounded-2xl px-4 py-3.5 focus-within:ring-2 focus-within:ring-primary transition-all">
                <Phone className="w-4 h-4 text-primary mr-2 flex-shrink-0" />
                <span className="text-xs font-semibold text-on-surface mr-1.5">+880</span>
                <input 
                  type="tel"
                  value={phoneNumber.replace('+880', '')}
                  onChange={(e) => setPhoneNumber(e.target.value)}
                  placeholder="1712345678"
                  required
                  className="bg-transparent border-none p-0 text-sm font-bold w-full focus:ring-0 text-on-surface outline-none"
                />
              </div>
            </div>

            {otpSent && <div>
              <label className="block text-[10px] font-semibold text-on-surface-variant tracking-wide mb-1">
                6-Digit Login Code
              </label>
              <div className="flex items-center bg-surface-container-low border border-outline rounded-2xl px-4 py-3.5 focus-within:ring-2 focus-within:ring-primary transition-all">
                <KeyRound className="w-4 h-4 text-primary mr-2 flex-shrink-0" />
                <input 
                  type="text"
                  maxLength={6}
                  value={otpCode}
                  onChange={(e) => setOtpCode(e.target.value)}
                  placeholder="123456"
                  required
                  className="bg-transparent border-none p-0 text-sm font-semibold w-full text-center tracking-widest focus:ring-0 text-on-surface outline-none"
                />
              </div>
            </div>}

            <button
              type="submit"
              disabled={isSubmitting}
              className="w-full bg-primary hover:bg-primary-700 text-white py-4 rounded-full font-semibold text-xs tracking-wide transition-all shadow-sm flex items-center justify-center gap-2 cursor-pointer mt-2"
            >
              {isSubmitting ? 'Authenticating...' : otpSent ? 'Sign In & Access Platform' : 'Send Login Code'}
            </button>

            <div className="text-center pt-2">
              <button
                type="button"
                onClick={() => {
                  setIsSignUp(true);
                  setStep(1);
                }}
                className="text-xs text-primary font-bold hover:underline cursor-pointer"
              >
                Don&apos;t have an account? Start Progressive Registration
              </button>
            </div>
          </form>
        )}
      </div>
    </div>
  );
}
