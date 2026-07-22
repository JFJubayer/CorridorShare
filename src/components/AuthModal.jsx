'use client';

import React, { useState } from 'react';
import { useUser } from '@/context/UserContext';
import { ShieldCheck, Phone, KeyRound, ArrowRight, X, Lock } from 'lucide-react';

export default function AuthModal({ isOpen, onClose, title = "Sign In to Access CorridorShare" }) {
  const { login, signup } = useUser();
  const [isSignUp, setIsSignUp] = useState(false);
  const [phoneNumber, setPhoneNumber] = useState('01712345678');
  const [otpCode, setOtpCode] = useState('123456');
  const [step, setStep] = useState(1); // 1: Phone input, 2: OTP verification
  const [isSubmitting, setIsSubmitting] = useState(false);

  if (!isOpen) return null;

  const handleSendOTP = (e) => {
    e.preventDefault();
    if (!phoneNumber || phoneNumber.length < 8) return;
    setIsSubmitting(true);
    setTimeout(() => {
      setIsSubmitting(false);
      setStep(2);
    }, 800);
  };

  const handleVerifyOTP = async (e) => {
    e.preventDefault();
    setIsSubmitting(true);
    setTimeout(async () => {
      const fullPhone = phoneNumber.startsWith('+880') ? phoneNumber : `+88${phoneNumber}`;
      if (isSignUp) {
        await signup(fullPhone);
      } else {
        await login(fullPhone);
      }
      setIsSubmitting(false);
      setStep(1);
      if (onClose) onClose();
    }, 1000);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Dark overlay backdrop */}
      <div 
        className="absolute inset-0 bg-slate-950/75 backdrop-blur-md transition-opacity" 
        onClick={onClose}
      />

      <div className="bg-surface border border-orange-500/30 rounded-[32px] p-6 sm:p-8 max-w-md w-full relative z-10 shadow-2xl animate-in fade-in zoom-in-95 duration-200">
        
        {onClose && (
          <button 
            onClick={onClose}
            className="absolute right-5 top-5 text-on-surface-variant hover:text-on-surface p-1.5 rounded-full hover:bg-orange-500/10 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        )}

        {/* Modal Header */}
        <div className="text-center space-y-2 mb-6">
          <div className="w-14 h-14 rounded-full bg-gradient-to-br from-orange-600 to-amber-500 text-white flex items-center justify-center mx-auto shadow-lg shadow-orange-500/30">
            <Lock className="w-7 h-7" />
          </div>
          
          <h3 className="text-2xl font-black text-on-surface tracking-tight font-display">
            {isSignUp ? 'Create Account' : 'Welcome Back'}
          </h3>
          <p className="text-xs text-on-surface-variant font-medium max-w-xs mx-auto">
            {title}
          </p>
        </div>

        {step === 1 ? (
          <form onSubmit={handleSendOTP} className="space-y-4">
            <div>
              <label className="block text-[10px] font-black text-on-surface-variant uppercase tracking-wider mb-1.5">
                Bangladesh Phone Number
              </label>
              <div className="flex items-center bg-surface-container-low border border-orange-500/25 rounded-full px-4 py-3 focus-within:ring-2 focus-within:ring-orange-500 transition-all">
                <Phone className="w-4 h-4 text-orange-500 mr-2 flex-shrink-0" />
                <span className="text-xs font-black text-on-surface mr-1.5">+880</span>
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
              className="w-full bg-gradient-to-r from-orange-600 to-amber-500 hover:from-orange-500 hover:to-amber-400 text-white py-3.5 rounded-full font-black text-xs uppercase tracking-wider transition-all shadow-lg shadow-orange-500/25 flex items-center justify-center gap-2 cursor-pointer"
            >
              {isSubmitting ? (
                <span>Sending OTP Code...</span>
              ) : (
                <>
                  Get Verification Code
                  <ArrowRight className="w-4 h-4" />
                </>
              )}
            </button>

            <div className="text-center pt-2">
              <button
                type="button"
                onClick={() => setIsSignUp(!isSignUp)}
                className="text-xs text-orange-600 dark:text-orange-400 font-bold hover:underline"
              >
                {isSignUp ? 'Already have an account? Sign In' : "Don't have an account? Sign Up"}
              </button>
            </div>
          </form>
        ) : (
          <form onSubmit={handleVerifyOTP} className="space-y-4">
            <div>
              <div className="flex justify-between items-center mb-1.5">
                <label className="block text-[10px] font-black text-on-surface-variant uppercase tracking-wider">
                  Enter 6-Digit OTP Code
                </label>
                <button 
                  type="button" 
                  onClick={() => setStep(1)}
                  className="text-[10px] font-bold text-orange-600 dark:text-orange-400 hover:underline"
                >
                  Change Number
                </button>
              </div>
              <div className="flex items-center bg-surface-container-low border border-orange-500/25 rounded-full px-4 py-3 focus-within:ring-2 focus-within:ring-orange-500 transition-all">
                <KeyRound className="w-4 h-4 text-orange-500 mr-2 flex-shrink-0" />
                <input 
                  type="text"
                  maxLength={6}
                  value={otpCode}
                  onChange={(e) => setOtpCode(e.target.value)}
                  placeholder="123456"
                  required
                  className="bg-transparent border-none p-0 text-sm font-black w-full text-center tracking-widest focus:ring-0 text-on-surface outline-none"
                />
              </div>
              <p className="text-[10px] text-on-surface-variant mt-1 text-center font-medium">
                Demo code preset: <strong>123456</strong>
              </p>
            </div>

            <button
              type="submit"
              disabled={isSubmitting}
              className="w-full bg-gradient-to-r from-orange-600 to-amber-500 hover:from-orange-500 hover:to-amber-400 text-white py-3.5 rounded-full font-black text-xs uppercase tracking-wider transition-all shadow-lg shadow-orange-500/25 flex items-center justify-center gap-2 cursor-pointer"
            >
              {isSubmitting ? (
                <span>Verifying Session...</span>
              ) : (
                <>
                  <ShieldCheck className="w-4 h-4" />
                  Verify & Access Platform
                </>
              )}
            </button>
          </form>
        )}
      </div>
    </div>
  );
}
