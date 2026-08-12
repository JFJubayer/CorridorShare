'use client';

import React, { useState, useEffect } from 'react';
import { useUser } from '@/context/UserContext';
import Card from '@/components/ui/Card';
import Button from '@/components/ui/Button';
import FigmaMakeDashboardWidget from '@/components/FigmaMakeDashboardWidget';
import SafetyTrustMatrix from '@/features/landing/SafetyTrustMatrix';
import MobbinInspirationGrid from '@/features/landing/MobbinInspirationGrid';
import WalletGuard from '@/features/auth/WalletGuard';
import HeroBubbleShowcase from '@/features/landing/HeroBubbleShowcase';
import { postPackage, postTrip } from '@/features/dashboard/actions';
import { isMockDataSource } from '@/config/supabaseClient';
import { toBdE164 } from '@/shared/phone/bdPhone';
import { tripRepository } from '@/repositories/tripRepository';
import { packageRepository } from '@/repositories/packageRepository';
import { chatRepository } from '@/repositories/chatRepository';
import { meetupPinPreview } from '@/shared/chat/meetupPin';
import { 
  Wallet, Plus, Navigation, ChevronRight, Package, Calendar, 
  MapPin, Clock, Weight, BadgeDollarSign, ShieldAlert, Sparkles, CheckCircle2,
  Car, ShieldCheck, Users, TrendingUp, AlertCircle, LogOut, ArrowRight, Check,
  Lock, ArrowLeftRight
} from 'lucide-react';
import Link from 'next/link';
import { motion, AnimatePresence } from 'motion/react';

export default function HomeExperience() {
  const { 
    role, setRole, profile, topUp, isAuthenticated, requestOtp, verifyOtp, userId, logout
  } = useUser();

  // Authentication Dialog States
  const [showAuthModal, setShowAuthModal] = useState(false);
  const [authMode, setAuthMode] = useState('login'); // 'login' or 'signup'
  const [phoneInput, setPhoneInput] = useState('');
  const [otpInput, setOtpInput] = useState('');
  const [otpSent, setOtpSent] = useState(false);
  const [authError, setAuthError] = useState('');

  // Surcharge Calculator States
  const [calcWeight, setCalcWeight] = useState(2.0); // kg
  const [calcDetour, setCalcDetour] = useState(5.0); // km
  // Derived estimated surcharge: Base (100) + weight*25 + detour*20
  const estimatedSurcharge = Math.round(100 + calcWeight * 25 + calcDetour * 20);

  // Dashboard Create States
  const [showPostModal, setShowPostModal] = useState(false);
  const [tripForm, setTripForm] = useState({ departure: '', destination: '', date: '', capacity: '5' });
  const [packageForm, setPackageForm] = useState({ desc: '', weight: '2', reward: '150', pickup: '', dropoff: '', recipientPhone: '', recipientName: '' });

  // Handle Mock Phone Verification Send Code
  const handleSendCode = async (e) => {
    e.preventDefault();
    if (!phoneInput || phoneInput.length < 10) {
      setAuthError('Please enter a valid phone number.');
      return;
    }
    try {
      await requestOtp(toBdE164(phoneInput));
      setAuthError('');
      setOtpSent(true);
    } catch (error) {
      setAuthError(error.message || 'Unable to send the verification code.');
    }
  };

  // Handle Mock Verification Verification OTP
  const handleVerifyOTP = async (e) => {
    e.preventDefault();
    if (otpInput.length !== 6) {
      setAuthError('OTP code must be 6 digits.');
      return;
    }
    setAuthError('');
    
    try {
      await verifyOtp(toBdE164(phoneInput), otpInput);
      setShowAuthModal(false);
      setOtpSent(false);
      setPhoneInput('');
      setOtpInput('');
    } catch (error) {
      setAuthError(error.message || 'Invalid or expired OTP code.');
    }
  };

  // Trip posting inside authenticated dashboard
  const handlePostTrip = async (e) => {
    e.preventDefault();
    try {
      await postTrip({ userId, form: tripForm });
      setShowPostModal(false);
      await refreshDashboard();
      alert('Trip posted successfully! Check "Upcoming Trips" below.');
    } catch (error) {
      alert(error.message || 'Unable to post this trip.');
    }
  };

  // Package posting inside authenticated dashboard
  const handlePostPackage = async (e) => {
    e.preventDefault();
    try {
      await postPackage({ userId, form: packageForm });
      setShowPostModal(false);
      await refreshDashboard();
      alert('Package delivery request posted! Matching can find travelers once a trip is live.');
    } catch (error) {
      alert(error.message || 'Unable to post this package request.');
    }
  };

  const [upcomingTrips, setUpcomingTrips] = useState([]);
  const [activeDeliveries, setActiveDeliveries] = useState([]);
  const [activityFeed, setActivityFeed] = useState([]);
  const [dashboardLoading, setDashboardLoading] = useState(false);
  const [dashboardError, setDashboardError] = useState('');

  const packageProgress = (status) => {
    const key = String(status || '').toLowerCase();
    if (key === 'delivered' || key === 'completed') return 100;
    if (key === 'in_transit' || key === 'in-transit') return 66;
    if (key === 'matched' || key === 'accepted' || key === 'locked') return 33;
    return 10;
  };

  const refreshDashboard = async () => {
    if (!userId) {
      setUpcomingTrips([]);
      setActiveDeliveries([]);
      setActivityFeed([]);
      return;
    }
    setDashboardLoading(true);
    setDashboardError('');
    try {
      const [trips, packages, deals] = await Promise.all([
        tripRepository.listForTraveler(userId),
        packageRepository.listForSender(userId),
        chatRepository.list().catch(() => []),
      ]);

      setUpcomingTrips((trips || []).map((trip) => ({
        id: trip.id,
        route: `${trip.departure_city || 'Pickup'} to ${trip.destination_city || 'Drop-off'}`,
        time: trip.travel_time
          ? new Date(trip.travel_time).toLocaleString([], { dateStyle: 'medium', timeStyle: 'short' })
          : 'Schedule TBD',
        capacity: trip.weight_capacity_kg != null ? `${trip.weight_capacity_kg}kg capacity` : 'Capacity TBD',
        status: trip.status || 'scheduled',
      })));

      setActiveDeliveries((packages || []).map((pkg) => ({
        id: pkg.id,
        route: pkg.item_description || 'Package request',
        status: pkg.status || 'pending',
        item: pkg.weight_kg != null ? `${pkg.weight_kg}kg · ${(pkg.proposed_reward_minor || 0) / 100} BDT` : 'Package',
        eta: pkg.created_at ? `Posted ${new Date(pkg.created_at).toLocaleDateString()}` : '',
        progress: packageProgress(pkg.status),
      })));

      const feed = (deals || []).slice(0, 8).map((deal) => {
        const last = deal.messages && deal.messages.length > 0
          ? deal.messages[deal.messages.length - 1]
          : null;
        const preview = last?.message_text
          ? meetupPinPreview(last.message_text)
          : (deal.deal_locked ? 'Escrow locked' : 'Deal opened');
        return {
          id: deal.id,
          text: preview,
          time: last?.created_at || deal.created_at
            ? new Date(last?.created_at || deal.created_at).toLocaleString([], { dateStyle: 'short', timeStyle: 'short' })
            : '',
          href: `/chat/${deal.id}`,
        };
      });
      setActivityFeed(feed);
    } catch (error) {
      setDashboardError(error.message || 'Unable to load your trips and packages.');
    } finally {
      setDashboardLoading(false);
    }
  };

  useEffect(() => {
    if (!isAuthenticated || !userId) return undefined;
    let active = true;
    (async () => {
      if (!active) return;
      await refreshDashboard();
    })();
    return () => { active = false; };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isAuthenticated, userId]);

  // ----------------------------------------------------
  // LANDING PAGE MARKUP (UNAUTHENTICATED)
  // ----------------------------------------------------
  if (!isAuthenticated) {
    return (
      <div className="max-w-7xl mx-auto px-4 pt-2 pb-8 md:pl-56 transition-colors duration-300">
        
        {/* Hero Section */}
        <header className="mb-12 grid grid-cols-1 lg:grid-cols-5 gap-8 items-center pt-4">
          <motion.div 
            initial={{ opacity: 0, y: 25 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.7, ease: [0.16, 1, 0.3, 1] }}
            className="lg:col-span-3 space-y-6"
          >
            <span className="eyebrow">
              <span className="w-1.5 h-1.5 rounded-full bg-primary" />
              Peer-to-peer highway logistics
            </span>
            <h1 className="text-4xl md:text-5xl lg:text-6xl font-semibold text-on-surface tracking-tight leading-[1.12] font-display">
              Share highway journeys.<br/>
              <span className="text-primary">Earn surcharges.</span><br/>
              Ship securely.
            </h1>
            <p className="text-base md:text-lg text-on-surface-variant max-w-lg leading-relaxed">
              Bangladesh&apos;s corridor network matching highway travelers with package senders — escrow-held, NID-reviewed, practical.
            </p>
            <div className="flex flex-wrap sm:flex-nowrap gap-3 pt-2">
              <Button 
                variant="primary" 
                onClick={() => {
                  setAuthMode('signup');
                  setShowAuthModal(true);
                }}
                className="py-3.5 px-7 text-sm font-semibold tracking-wide shadow-sm flex items-center justify-center gap-2 max-w-xs"
              >
                Get started
                <ArrowRight className="w-4 h-4" />
              </Button>
              <Button 
                variant="secondary" 
                onClick={() => {
                  setAuthMode('login');
                  setShowAuthModal(true);
                }}
                className="py-3.5 px-7 text-sm font-semibold border border-outline max-w-xs rounded-full"
              >
                Sign in
              </Button>
            </div>
          </motion.div>

          {/* Hero Interactive Bubble Showcase Component */}
          <motion.div 
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.8, delay: 0.2, ease: [0.16, 1, 0.3, 1] }}
            className="lg:col-span-2 relative lg:mt-1"
          >
            <HeroBubbleShowcase />
          </motion.div>
        </header>

        {/* How It Works Section (Prominent, High-Readability 3 Steps directly after Hero) */}
        <section className="mb-20">
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5 }}
            className="text-center max-w-3xl mx-auto mb-12 space-y-3"
          >
            <span className="eyebrow">Simple 3-step process</span>
            <h2 className="text-3xl md:text-4xl font-semibold text-on-surface tracking-tight font-display">
              How CorridorShare works
            </h2>
            <p className="text-base md:text-lg text-on-surface-variant leading-relaxed max-w-2xl mx-auto">
              A clear geofenced delivery model connecting travelers with highway-corridor packages.
            </p>
          </motion.div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 max-w-6xl mx-auto">
            {[
              {
                step: "01",
                title: "Post Route or Package",
                desc: "Travelers list their scheduled highway corridors (e.g. Dhaka N3 road). Senders upload package cargo pickup coordinates."
              },
              {
                step: "02",
                title: "Geofence Match Calculation",
                desc: "Our spatial engine analyzes routes and matches packages within 5km of the travel path, prompting detour offers."
              },
              {
                step: "03",
                title: "Escrow Wallet Lock",
                desc: "Senders lock surcharge rewards in escrow. Upon OTP package verification at pickup, delivery funds are released instantly."
              }
            ].map((item, i) => (
              <motion.div
                key={item.step}
                initial={{ opacity: 0, y: 35 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: i * 0.15 }}
              >
                <Card className="border border-outline hover:border-primary/30 bg-surface flex flex-col items-center text-center p-8 md:p-10 space-y-5 h-full rounded-xl transition-all group relative overflow-hidden">
                  <div className="w-14 h-14 bg-primary text-white rounded-xl flex items-center justify-center font-semibold text-lg font-display tracking-tight">
                    {item.step}
                  </div>

                  <h3 className="font-semibold text-on-surface text-xl md:text-2xl tracking-tight font-display leading-tight">
                    {item.title}
                  </h3>

                  <p className="text-sm md:text-base text-on-surface-variant leading-relaxed font-medium">
                    {item.desc}
                  </p>
                </Card>
              </motion.div>
            ))}
          </div>
        </section>

        {/* Pricing Calculator Widget */}
        <section className="mb-16">
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5 }}
            className="text-center max-w-xl mx-auto mb-8"
          >
            <span className="eyebrow mb-2">Fare calculator</span>
            <h2 className="text-3xl font-semibold text-on-surface tracking-tight font-display">Micro-surcharge estimator</h2>
            <p className="text-sm text-on-surface-variant mt-1.5 font-medium">
              Input cargo details and detour parameters to calculate a recommended peer-to-peer delivery fee instantly.
            </p>
          </motion.div>

          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6, delay: 0.1 }}
            className="max-w-3xl mx-auto bg-surface border border-primary/25 rounded-2xl p-6 md:p-8 shadow-xl grid grid-cols-1 md:grid-cols-2 gap-8 items-center transition-colors duration-300 relative overflow-hidden"
          >
            <div className="absolute top-0 right-0 w-48 h-48 bg-primary/8 rounded-full blur-2xl pointer-events-none" />

            {/* Controls */}
            <div className="space-y-6 relative z-10">
              <div className="space-y-2">
                <div className="flex justify-between text-xs sm:text-sm font-bold text-on-surface">
                  <span>Luggage Weight Limit</span>
                  <span className="text-primary font-mono font-black text-base">{calcWeight.toFixed(1)} KG</span>
                </div>
                <input 
                  type="range" min="0.5" max="15.0" step="0.5"
                  value={calcWeight} onChange={(e) => setCalcWeight(parseFloat(e.target.value))}
                  className="w-full h-3 bg-primary/10 rounded-full appearance-none cursor-pointer accent-primary transition-all"
                />
                <div className="flex justify-between text-[10px] text-on-surface-variant uppercase font-extrabold tracking-wider">
                  <span>0.5 kg</span>
                  <span>15.0 kg</span>
                </div>
              </div>

              <div className="space-y-2">
                <div className="flex justify-between text-xs sm:text-sm font-bold text-on-surface">
                  <span>Detour Travel Distance</span>
                  <span className="text-primary font-mono font-black text-base">{calcDetour.toFixed(0)} KM</span>
                </div>
                <input 
                  type="range" min="0" max="25" step="1"
                  value={calcDetour} onChange={(e) => setCalcDetour(parseInt(e.target.value))}
                  className="w-full h-3 bg-primary/10 rounded-full appearance-none cursor-pointer accent-primary transition-all"
                />
                <div className="flex justify-between text-[10px] text-on-surface-variant uppercase font-extrabold tracking-wider">
                  <span>0 km (Direct)</span>
                  <span>25 km</span>
                </div>
              </div>
            </div>

            {/* Display widget with dynamic price pop animation */}
            <div className="bg-primary/8 border border-primary/25 rounded-xl p-6 text-center space-y-3 shadow-inner relative z-10">
              <span className="text-[10px] uppercase font-black tracking-widest text-primary block">Recommended Surcharge</span>
              <div className="flex items-baseline justify-center gap-1.5 overflow-hidden py-1">
                <AnimatePresence mode="popLayout">
                  <motion.span 
                    key={estimatedSurcharge}
                    initial={{ y: 20, opacity: 0, scale: 0.8 }}
                    animate={{ y: 0, opacity: 1, scale: 1 }}
                    exit={{ y: -20, opacity: 0, scale: 0.8 }}
                    transition={{ type: "spring", stiffness: 300, damping: 25 }}
                    className="text-5xl font-black text-on-surface tracking-tight font-display inline-block"
                  >
                    {estimatedSurcharge}
                  </motion.span>
                </AnimatePresence>
                <span className="text-base font-black text-primary">BDT</span>
              </div>
              <p className="text-xs text-on-surface-variant leading-relaxed max-w-xs mx-auto font-medium">
                Includes platform escrow protection, fuel/detour compensation, and traveler cargo carry fees.
              </p>
              <Button 
                variant="primary" 
                onClick={() => {
                  setAuthMode('signup');
                  setShowAuthModal(true);
                }}
                className="py-3.5 w-full text-xs font-black uppercase tracking-wider mt-2 shadow-sm"
              >
                Ship For This Surcharge
              </Button>
            </div>
          </motion.div>
        </section>

        {/* Figma Make UI Tracking & Analytics Dashboard Component */}
        <FigmaMakeDashboardWidget />

        {/* Example Bangladesh corridor cards */}
        <MobbinInspirationGrid />

        {/* Interactive Safety & Escrow Trust Architecture Component */}
        <SafetyTrustMatrix />

        {/* Footnotes */}
        <footer className="text-center py-6 border-t border-outline-variant/35 text-[10px] text-on-surface-variant font-bold space-y-2">
          <div className="flex justify-center gap-4">
            <Link href="/terms" className="hover:text-primary dark:hover:text-primary">Terms</Link>
            <Link href="/privacy" className="hover:text-primary dark:hover:text-primary">Privacy</Link>
            <Link href="/support" className="hover:text-primary dark:hover:text-primary">Support</Link>
          </div>
          <p>&copy; {new Date().getFullYear()} CorridorShare P2P Logistics. Bangladesh.</p>
        </footer>

        {/* STATEFUL AUTHENTICATION MODAL (LOG IN / SIGN UP) */}
        {showAuthModal && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
            {/* Backdrop */}
            <div className="absolute inset-0 bg-slate-950/60 backdrop-blur-sm" onClick={() => setShowAuthModal(false)}></div>
            
            {/* Form Box */}
            <div className="bg-surface-container-lowest rounded-2xl border border-outline-variant shadow-lg p-6 w-full max-w-sm relative z-10 animate-in fade-in zoom-in-95 duration-200">
              <div className="mb-5 text-center">
                <h3 className="font-extrabold text-on-surface text-lg">
                  {authMode === 'login' ? 'Welcome Back!' : 'Create CorridorShare Account'}
                </h3>
                <p className="text-[10px] text-on-surface-variant mt-0.5">
                  {authMode === 'login' ? 'Verify your registered phone number' : 'Sign up using NID and phone details'}
                </p>
              </div>

              {authError && (
                <div className="bg-red-500/10 border border-red-500/20 text-red-600 dark:text-red-400 p-2.5 rounded-lg text-xs mb-4 flex items-center gap-1.5">
                  <AlertCircle className="w-4 h-4 flex-shrink-0" />
                  <span className="font-semibold">{authError}</span>
                </div>
              )}

              {!otpSent ? (
                <form onSubmit={handleSendCode} className="space-y-4">
                  <div>
                    <label className="block text-[9px] font-bold text-on-surface-variant uppercase tracking-widest mb-1.5">Phone Number</label>
                    <div className="flex items-center bg-surface-container-low px-3 py-2 border border-outline-variant rounded-lg focus-within:ring-2 focus-within:ring-primary focus-within:border-transparent transition-all">
                      <span className="text-on-surface-variant text-xs font-bold mr-2">+880</span>
                      <input 
                        type="tel" required placeholder="1700000000"
                        value={phoneInput} onChange={(e) => setPhoneInput(e.target.value)}
                        className="bg-transparent border-none p-0 text-xs w-full focus:ring-0 text-on-surface outline-none"
                      />
                    </div>
                  </div>

                  <Button variant="primary" type="submit" className="py-2.5 w-full text-xs uppercase tracking-wider font-extrabold">
                    Send Verification Code
                  </Button>

                  <div className="text-center pt-2">
                    <button 
                      type="button"
                      onClick={() => setAuthMode(authMode === 'login' ? 'signup' : 'login')}
                      className="text-[10px] text-primary hover:underline font-bold"
                    >
                      {authMode === 'login' ? "Don't have an account? Sign Up" : "Already have an account? Log In"}
                    </button>
                  </div>
                </form>
              ) : (
                <form onSubmit={handleVerifyOTP} className="space-y-4">
                  <div className="bg-teal-500/10 border border-teal-500/20 text-teal-800 dark:text-teal-400 p-3 rounded-lg text-xs mb-2">
                    <p className="font-bold uppercase tracking-wider text-[9px] mb-1">
                      {isMockDataSource ? 'Demo OTP Mode' : 'Verification Code Sent'}
                    </p>
                    <p className="text-[10px]">
                      {isMockDataSource
                        ? <>Use the explicit demo code <strong>123456</strong>.</>
                        : 'Enter the six-digit code sent by the configured phone provider.'}
                    </p>
                  </div>

                  <div>
                    <label className="block text-[9px] font-bold text-on-surface-variant uppercase tracking-widest mb-1.5">Enter 6-Digit OTP Code</label>
                    <input 
                      type="text" required placeholder="000000" maxLength={6}
                      value={otpInput} onChange={(e) => setOtpInput(e.target.value)}
                      className="w-full bg-surface-container-low border border-outline-variant rounded-lg p-2.5 text-center text-sm font-bold tracking-widest outline-none focus:ring-2 focus:ring-primary text-on-surface"
                    />
                  </div>

                  <div className="flex gap-2">
                    <Button variant="secondary" type="button" onClick={() => setOtpSent(false)} className="py-2.5 text-xs">
                      Back
                    </Button>
                    <Button variant="primary" type="submit" className="py-2.5 flex-grow text-xs uppercase tracking-wider font-extrabold">
                      Verify & Log In
                    </Button>
                  </div>
                </form>
              )}
            </div>
          </div>
        )}
      </div>
    );
  }

  // ----------------------------------------------------
  // DASHBOARD WORKSPACE (AUTHENTICATED)
  // ----------------------------------------------------
  return (
    <div className="max-w-7xl mx-auto px-4 pt-2 pb-6 md:pl-56 transition-colors duration-300">
      
      {/* Wallet Guard Suspended Indicator */}
      <WalletGuard />

      {/* Top Banner Greeting */}
      <div className="mb-8 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-semibold text-on-surface tracking-tight font-display">
            Hello, friend
          </h1>
          <p className="text-xs text-on-surface-variant mt-1 max-w-xl">
            Welcome to the CorridorShare logistics portal. Share corridor travel paths, match with local senders, and secure micro-surcharges.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <span className="text-[10px] uppercase font-bold text-primary bg-primary/10 px-3.5 py-1.5 rounded-full border border-primary/25 flex items-center gap-1.5">
            <span className="w-2 h-2 rounded-full bg-primary"></span>
            Account Connected
          </span>
        </div>
      </div>

      {/* Select Active Role Cards */}
      <section className="mb-8">
        <h2 className="text-xs uppercase font-extrabold tracking-widest text-on-surface-variant mb-4 flex items-center gap-1">
          <ArrowLeftRight className="w-4 h-4 text-primary" />
          Select Your Active Role
        </h2>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
          {/* Traveler Card */}
          <div 
            onClick={() => setRole('traveler')}
            className={`cursor-pointer rounded-xl p-6 border transition-all duration-300 relative overflow-hidden flex flex-col gap-4 group hover:-translate-y-1 hover:shadow-lg ${ role === 'traveler' ? 'bg-primary/10 dark:bg-primary/15 border-primary ring-2 ring-primary/30 shadow-md' : 'bg-surface-container-lowest border-outline-variant hover:border-primary/25 shadow-sm' }`}
          >
            <div aria-hidden="true" className="absolute right-4 bottom-2 text-6xl font-black opacity-0 select-none pointer-events-none tracking-wider">
              TRAVELER
            </div>

            <div className="flex items-start gap-4">
              <div className={`p-4 rounded-2xl transition-all duration-300 ${ role === 'traveler' ? 'bg-primary text-white scale-110 shadow-sm' : 'bg-surface-container-low text-on-surface-variant group-hover:bg-primary/10' }`}>
                <Car className="w-7 h-7" />
              </div>
              
              <div className="flex-grow space-y-0.5">
                <div className="flex items-center justify-between">
                  <h3 className="font-black text-lg text-on-surface">Traveler Mode</h3>
                  {role === 'traveler' ? (
                    <span className="text-[9px] bg-primary text-white px-3 py-1 rounded-full font-bold uppercase tracking-wider shadow-xs">Active Mode</span>
                  ) : (
                    <span className="text-[9px] bg-surface-container-low text-on-surface-variant px-2.5 py-0.5 rounded-full font-bold uppercase tracking-wider group-hover:text-primary">Select</span>
                  )}
                </div>
                <p className="text-xs text-on-surface-variant leading-relaxed">
                  Post routes to earn extra money carrying parcels along your path.
                </p>
              </div>
            </div>

            <div className="pt-3 border-t border-outline-variant/40 grid grid-cols-1 sm:grid-cols-3 gap-2">
              <span className="text-[10px] text-on-surface-variant font-bold flex items-center gap-1.5">
                <Check className="w-3.5 h-3.5 text-primary" /> Earn micro-fees
              </span>
              <span className="text-[10px] text-on-surface-variant font-bold flex items-center gap-1.5">
                <Check className="w-3.5 h-3.5 text-primary" /> Flexible schedules
              </span>
              <span className="text-[10px] text-on-surface-variant font-bold flex items-center gap-1.5">
                <Check className="w-3.5 h-3.5 text-primary" /> Custom detour fees
              </span>
            </div>
          </div>

          {/* Sender/Receiver Card */}
          <div 
            onClick={() => setRole('sender')}
            className={`cursor-pointer rounded-xl p-6 border transition-all duration-300 relative overflow-hidden flex flex-col gap-4 group hover:-translate-y-1 hover:shadow-lg ${ role === 'sender' ? 'bg-primary/10 dark:bg-primary/15 border-primary ring-2 ring-primary/30 shadow-md' : 'bg-surface-container-lowest border-outline-variant hover:border-primary/25 shadow-sm' }`}
          >
            <div aria-hidden="true" className="absolute right-4 bottom-2 text-6xl font-black opacity-0 select-none pointer-events-none tracking-wider">
              SENDER
            </div>

            <div className="flex items-start gap-4">
              <div className={`p-4 rounded-2xl transition-all duration-300 ${ role === 'sender' ? 'bg-primary text-white scale-110 shadow-sm' : 'bg-surface-container-low text-on-surface-variant group-hover:bg-primary/10' }`}>
                <Package className="w-7 h-7" />
              </div>
              
              <div className="flex-grow space-y-0.5">
                <div className="flex items-center justify-between">
                  <h3 className="font-black text-lg text-on-surface">Sender & Receiver Mode</h3>
                  {role === 'sender' ? (
                    <span className="text-[9px] bg-primary text-white px-3 py-1 rounded-full font-bold uppercase tracking-wider shadow-xs">Active Mode</span>
                  ) : (
                    <span className="text-[9px] bg-surface-container-low text-on-surface-variant px-2.5 py-0.5 rounded-full font-bold uppercase tracking-wider group-hover:text-primary">Select</span>
                  )}
                </div>
                <p className="text-xs text-on-surface-variant leading-relaxed">
                  Post package shipment coordinates and match with travelers nearby.
                </p>
              </div>
            </div>

            <div className="pt-3 border-t border-outline-variant/40 grid grid-cols-1 sm:grid-cols-3 gap-2">
              <span className="text-[10px] text-on-surface-variant font-bold flex items-center gap-1.5">
                <Check className="w-3.5 h-3.5 text-primary" /> Escrow secured
              </span>
              <span className="text-[10px] text-on-surface-variant font-bold flex items-center gap-1.5">
                <Check className="w-3.5 h-3.5 text-primary" /> Snapped matching
              </span>
              <span className="text-[10px] text-on-surface-variant font-bold flex items-center gap-1.5">
                <Check className="w-3.5 h-3.5 text-primary" /> Verified travel paths
              </span>
            </div>
          </div>
        </div>
      </section>

      {/* Main Grid - Contents (Left) & Wallet / Feeds (Right) */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        
        {/* Left Side: Active Listings/Shipments */}
        <div className="lg:col-span-2 space-y-6">
          <section>
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-lg font-bold text-on-surface tracking-tight">
                {role === 'traveler' ? 'Your Upcoming & Active Journeys' : 'Your Ongoing Shipments'}
              </h2>
              <Link href="/match" className="text-xs font-bold text-primary flex items-center gap-0.5 hover:underline">
                Matching Portal <ChevronRight className="w-3.5 h-3.5" />
              </Link>
            </div>

            {dashboardError && (
              <p role="alert" className="mb-3 rounded-xl border border-outline bg-primary/10 px-3 py-2 text-xs font-bold text-primary">{dashboardError}</p>
            )}
            {!dashboardLoading && upcomingTrips.length === 0 && activeDeliveries.length === 0 && activityFeed.length === 0 && (
              <Card className="mb-4 border border-primary/25 bg-primary/5 rounded-xl p-5 space-y-3">
                <h3 className="font-semibold text-sm text-on-surface">Friends beta checklist</h3>
                <ol className="list-decimal pl-5 space-y-1.5 text-xs text-on-surface-variant font-medium">
                  <li>Confirm NID status in Account (admin reviews submissions).</li>
                  <li>Ask an admin to credit staging wallet if you need escrow funds.</li>
                  <li>Traveler: post a trip. Sender: request a delivery.</li>
                  <li>Open Matching → send a delivery request → use deal chat check-ins / meetup pin.</li>
                </ol>
                <div className="flex flex-wrap gap-2 pt-1">
                  <Button variant="primary" onClick={() => setShowPostModal(true)} className="py-2 text-xs">
                    {role === 'traveler' ? 'Post New Trip' : 'Request Delivery'}
                  </Button>
                  <Link href="/match" className="inline-flex items-center justify-center px-4 py-2 rounded-full border border-outline text-xs font-semibold text-primary hover:bg-primary/10">
                    Open Matching
                  </Link>
                  <Link href="/chat" className="inline-flex items-center justify-center px-4 py-2 rounded-full border border-outline text-xs font-semibold text-on-surface hover:bg-surface-container-low">
                    Messages
                  </Link>
                </div>
              </Card>
            )}
            <div className="space-y-4">
              {dashboardLoading ? (
                <Card className="border border-outline-variant rounded-xl p-6 text-center text-xs text-on-surface-variant font-medium">
                  Loading your {role === 'traveler' ? 'trips' : 'packages'}…
                </Card>
              ) : role === 'traveler' ? (
                upcomingTrips.length === 0 ? (
                  <Card className="border border-dashed border-outline-variant rounded-xl p-6 text-center space-y-2">
                    <Car className="w-8 h-8 text-primary/50 mx-auto" />
                    <h3 className="font-semibold text-on-surface text-sm">No trips yet</h3>
                    <p className="text-xs text-on-surface-variant font-medium">
                      Post a trip to start matching packages along your Bangladesh route.
                    </p>
                    <Button variant="primary" onClick={() => setShowPostModal(true)} className="mt-2 py-2 text-xs">
                      Post New Trip
                    </Button>
                  </Card>
                ) : (
                  upcomingTrips.map((trip) => (
                    <Card key={trip.id} className="relative group overflow-hidden border border-outline-variant rounded-xl">
                      <div className="flex justify-between items-start mb-3">
                        <div>
                          <span className="text-[10px] font-bold text-on-surface-variant block uppercase">Trip ID: {String(trip.id).slice(0, 8)}…</span>
                          <span className="font-bold text-on-surface text-base mt-1 block">{trip.route}</span>
                        </div>
                        <span className={`text-[10px] font-bold uppercase tracking-wider px-2.5 py-0.5 rounded-full ${ String(trip.status).toLowerCase() === 'active' ? 'bg-primary/10 text-primary border border-primary/25' : 'bg-surface-container-low text-on-surface-variant border border-outline-variant' }`}>
                          {trip.status}
                        </span>
                      </div>

                      <div className="pt-2.5 border-t border-outline-variant flex justify-between items-center text-xs text-on-surface-variant font-medium">
                        <div className="flex items-center gap-1.5">
                          <Clock className="w-4 h-4 text-primary" />
                          <span>{trip.time}</span>
                        </div>
                        <div className="flex items-center gap-1.5">
                          <Weight className="w-4 h-4 text-primary" />
                          <span>{trip.capacity}</span>
                        </div>
                      </div>
                    </Card>
                  ))
                )
              ) : (
                activeDeliveries.length === 0 ? (
                  <Card className="border border-dashed border-outline-variant rounded-xl p-6 text-center space-y-2">
                    <Package className="w-8 h-8 text-primary/50 mx-auto" />
                    <h3 className="font-semibold text-on-surface text-sm">No packages yet</h3>
                    <p className="text-xs text-on-surface-variant font-medium">
                      Request a delivery, then ask a friend traveler to match from the Matching tab.
                    </p>
                    <Button variant="primary" onClick={() => setShowPostModal(true)} className="mt-2 py-2 text-xs">
                      Request Delivery
                    </Button>
                  </Card>
                ) : (
                  activeDeliveries.map((pkg) => (
                    <Card key={pkg.id} className="overflow-hidden border border-outline-variant rounded-xl">
                      <div className="flex justify-between items-start mb-3">
                        <div>
                          <span className="text-[10px] font-bold text-on-surface-variant block uppercase">Package ID: {String(pkg.id).slice(0, 8)}…</span>
                          <span className="font-bold text-on-surface text-base mt-1 block">{pkg.route}</span>
                        </div>
                        <span className="bg-primary/10 text-primary border border-primary/25 text-[10px] font-bold uppercase tracking-wider px-2.5 py-0.5 rounded-full">
                          {pkg.status}
                        </span>
                      </div>

                      <div className="space-y-2 py-2">
                        <div className="flex justify-between text-[9px] font-bold text-on-surface-variant uppercase tracking-wide">
                          <span className={pkg.progress >= 33 ? 'text-primary font-bold' : ''}>Matched</span>
                          <span className={pkg.progress >= 66 ? 'text-primary font-bold' : ''}>In Transit</span>
                          <span className={pkg.progress >= 100 ? 'text-primary font-bold' : ''}>Delivered</span>
                        </div>
                        <div className="w-full h-2 bg-primary/10 rounded-full overflow-hidden flex border border-outline">
                          <div
                            className="h-full bg-primary transition-all duration-500 relative"
                            style={{ width: `${pkg.progress}%` }}
                          />
                        </div>
                      </div>

                      <div className="pt-2.5 border-t border-outline-variant flex justify-between items-center text-xs text-on-surface-variant font-medium">
                        <div className="flex items-center gap-1.5">
                          <Package className="w-4 h-4 text-primary" />
                          <span>{pkg.item}</span>
                        </div>
                        <span className="text-primary font-extrabold text-xs">{pkg.eta}</span>
                      </div>
                    </Card>
                  ))
                )
              )}
            </div>
          </section>

          {/* Quick Info Guides */}
          <section className="bg-primary/8 border border-outline rounded-xl p-5 flex items-start gap-4">
            <ShieldCheck className="w-6 h-6 text-primary flex-shrink-0 mt-0.5" />
            <div className="space-y-1">
              <h3 className="font-extrabold text-sm text-on-surface">Escrow Safe Guarantee</h3>
              <p className="text-xs text-on-surface-variant leading-relaxed">
                CorridorShare guarantees delivery safety by holding traveler deposits until the recipient confirms the open-box inspect code validation. No contraband cargo is allowed.
              </p>
            </div>
          </section>
        </div>

        {/* Right Side: Wallet & Feeds */}
        <div className="space-y-6">
          {/* Balance Widget Card */}
          <section>
            <Card className="bg-primary text-white relative overflow-hidden border-none shadow-sm rounded-xl">
              <div className="absolute right-4 top-4 bg-white/15 p-2.5 rounded-lg">
                <Wallet className="w-5 h-5 text-white" />
              </div>

              <div className="space-y-4">
                <div>
                  <span className="text-[10px] uppercase font-black tracking-widest text-amber-100">Available Wallet Balance</span>
                  <div className="flex items-baseline gap-1.5 mt-1.5">
                    <span className="text-4xl font-black tracking-tight font-display">
                      {profile ? parseFloat(profile.wallet_balance).toFixed(2) : '0.00'}
                    </span>
                    <span className="text-sm font-bold text-amber-100">BDT</span>
                  </div>
                </div>

                {/* Quick Actions */}
                <div className="flex flex-col gap-2 pt-2">
                  <Button 
                    variant="secondary" 
                    disabled={!isMockDataSource}
                    title={isMockDataSource ? 'Add local demo funds' : 'Live top-up is coming later — payment providers are not connected yet'}
                    onClick={() => {
                      if (!isMockDataSource) return;
                      const amt = prompt("Enter simulated amount to top up (demo only, BDT):", "50");
                      if (amt && !isNaN(amt)) {
                        topUp(parseFloat(amt));
                      }
                    }}
                    className="bg-white/20 hover:bg-white/30 border border-white/30 text-white py-3 w-full flex items-center justify-center gap-1.5 rounded-full"
                  >
                    <Plus className="w-4 h-4" />
                    {isMockDataSource ? 'Demo Top Up' : 'Top Up Coming Later'}
                  </Button>
                  {!isMockDataSource && (
                    <p className="text-[10px] text-amber-100/90 font-medium leading-relaxed">
                      Live provider top-up is deferred. For friends beta, ask an admin to credit your wallet. Escrow lock, OTP, release, and refund already use wallet balance.
                    </p>
                  )}

                  <Button
                    variant="primary"
                    onClick={() => setShowPostModal(true)}
                    className="bg-white hover:bg-primary-container text-primary py-3 shadow-sm w-full flex items-center justify-center gap-1.5 rounded-full font-semibold"
                  >
                    <Navigation className="w-4 h-4 text-primary" />
                    {role === 'traveler' ? 'Post New Trip' : 'Request Delivery'}
                  </Button>
                </div>
              </div>
            </Card>
          </section>

          {/* Account panel */}
          <section>
            <div className="bg-surface border border-outline rounded-xl p-5 shadow-sm space-y-4">
              <h3 className="font-extrabold text-xs text-on-surface uppercase tracking-wider flex items-center gap-1.5">
                <Users className="w-4 h-4 text-primary" />
                Account
              </h3>
              <dl className="space-y-2 text-xs">
                <div className="flex justify-between gap-3">
                  <dt className="text-on-surface-variant font-bold">Phone</dt>
                  <dd className="font-semibold text-on-surface text-right">{profile?.phone_number || '—'}</dd>
                </div>
                <div className="flex justify-between gap-3">
                  <dt className="text-on-surface-variant font-bold">NID status</dt>
                  <dd className="font-semibold text-on-surface uppercase text-right">{profile?.nid_status || 'unverified'}</dd>
                </div>
                <div className="flex justify-between gap-3">
                  <dt className="text-on-surface-variant font-bold">Security role</dt>
                  <dd className="font-semibold text-on-surface uppercase text-right">{profile?.role || 'member'}</dd>
                </div>
                <div className="flex justify-between gap-3">
                  <dt className="text-on-surface-variant font-bold">Active mode</dt>
                  <dd className="font-semibold text-on-surface uppercase text-right">{role}</dd>
                </div>
                <div className="flex justify-between gap-3">
                  <dt className="text-on-surface-variant font-bold">Wallet</dt>
                  <dd className="font-semibold text-primary text-right">
                    {profile ? parseFloat(profile.wallet_balance).toFixed(2) : '0.00'} BDT
                  </dd>
                </div>
              </dl>
              <p className="text-[10px] text-on-surface-variant leading-relaxed font-medium bg-primary/8 border border-outline rounded-lg p-2.5">
                Friends beta: live payment top-up is not connected. Ask an admin to credit your wallet via <span className="font-bold">admin_credit_wallet</span> for staging demos.
              </p>
              <Button
                variant="secondary"
                onClick={async () => {
                  try {
                    await logout();
                  } catch (error) {
                    alert(error.message || 'Unable to log out.');
                  }
                }}
                className="w-full py-2.5 text-xs flex items-center justify-center gap-1.5"
              >
                <LogOut className="w-3.5 h-3.5" />
                Log out
              </Button>
            </div>
          </section>

          {/* Deal activity from real chats */}
          <section>
            <div className="bg-surface border border-outline rounded-xl p-5 shadow-sm">
              <h3 className="font-extrabold text-xs text-on-surface uppercase tracking-wider mb-4 flex items-center gap-1.5">
                <TrendingUp className="w-4 h-4 text-primary" />
                Your deal activity
              </h3>
              <div className="space-y-4">
                {activityFeed.length === 0 ? (
                  <p className="text-xs text-on-surface-variant font-medium">
                    No deals yet. Match a package to open a chat.
                  </p>
                ) : (
                  activityFeed.map((f) => (
                    <Link key={f.id} href={f.href} className="flex gap-2.5 text-xs border-b border-outline-variant/30 pb-3 last:border-b-0 last:pb-0 hover:opacity-80">
                      <div className="w-2 h-2 rounded-full bg-primary mt-1.5 flex-shrink-0"></div>
                      <div className="flex-grow space-y-0.5 min-w-0">
                        <p className="text-on-surface leading-normal font-medium truncate">{f.text}</p>
                        <span className="text-[11px] text-on-surface-variant block font-medium">{f.time}</span>
                      </div>
                    </Link>
                  ))
                )}
              </div>
            </div>
          </section>
        </div>

      </div>

      {/* Interactive Safety & Escrow Trust Architecture Component */}
      <div className="mt-12">
        <SafetyTrustMatrix />
      </div>

      {/* Creation Modal protected by Wallet Check */}
      {showPostModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div className="absolute inset-0 bg-slate-900/60 backdrop-blur-sm" onClick={() => setShowPostModal(false)}></div>
          <div className="bg-surface-container-lowest rounded-2xl border border-outline-variant shadow-lg p-6 w-full max-w-md relative z-10 animate-in fade-in zoom-in-95 duration-200">
            <h3 className="font-bold text-on-surface text-lg mb-4">
              {role === 'traveler' ? 'Post Upcoming Trip Details' : 'Request Package Shipment'}
            </h3>

            {/* Wallet guard nested block to confirm balance */}
            <WalletGuard fallback={
              <div className="text-center p-4 space-y-2">
                <ShieldAlert className="text-red-500 w-8 h-8 mx-auto" />
                <p className="text-xs text-on-surface-variant font-medium">
                  Your wallet balance is negative. Please recharge your wallet balance above before you can create items.
                </p>
                <Button variant="secondary" onClick={() => setShowPostModal(false)}>
                  Close Window
                </Button>
              </div>
            }>
              {role === 'traveler' ? (
                <form onSubmit={handlePostTrip} className="space-y-4">
                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="block text-[10px] font-bold text-on-surface-variant uppercase mb-1">Departure City</label>
                      <input 
                        type="text" required placeholder="e.g. Dhaka"
                        value={tripForm.departure} onChange={(e) => setTripForm({...tripForm, departure: e.target.value})}
                        className="w-full bg-surface-container-low border border-outline-variant rounded-lg p-2.5 text-xs outline-none focus:ring-2 focus:ring-primary text-on-surface"
                      />
                    </div>
                    <div>
                      <label className="block text-[10px] font-bold text-on-surface-variant uppercase mb-1">Destination City</label>
                      <input 
                        type="text" required placeholder="e.g. Mymensingh"
                        value={tripForm.destination} onChange={(e) => setTripForm({...tripForm, destination: e.target.value})}
                        className="w-full bg-surface-container-low border border-outline-variant rounded-lg p-2.5 text-xs outline-none focus:ring-2 focus:ring-primary text-on-surface"
                      />
                    </div>
                  </div>
                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="block text-[10px] font-bold text-on-surface-variant uppercase mb-1">Travel Time</label>
                      <input 
                        type="datetime-local" required
                        value={tripForm.date} onChange={(e) => setTripForm({...tripForm, date: e.target.value})}
                        className="w-full bg-surface-container-low border border-outline-variant rounded-lg p-2.5 text-xs outline-none focus:ring-2 focus:ring-primary text-on-surface"
                      />
                    </div>
                    <div>
                      <label className="block text-[10px] font-bold text-on-surface-variant uppercase mb-1">Luggage Limit (KG)</label>
                      <input 
                        type="number" required placeholder="e.g. 10"
                        value={tripForm.capacity} onChange={(e) => setTripForm({...tripForm, capacity: e.target.value})}
                        className="w-full bg-surface-container-low border border-outline-variant rounded-lg p-2.5 text-xs outline-none focus:ring-2 focus:ring-primary text-on-surface"
                      />
                    </div>
                  </div>
                  <div className="flex gap-2 pt-2">
                    <Button variant="secondary" type="button" onClick={() => setShowPostModal(false)}>Cancel</Button>
                    <Button variant="primary" type="submit">Submit Trip</Button>
                  </div>
                </form>
              ) : (
                <form onSubmit={handlePostPackage} className="space-y-4">
                  <div className="space-y-3">
                    <div>
                      <label className="block text-[10px] font-bold text-on-surface-variant uppercase mb-1">Package Description</label>
                      <input 
                        type="text" required placeholder="e.g. Document envelope, clothing, books"
                        value={packageForm.desc} onChange={(e) => setPackageForm({...packageForm, desc: e.target.value})}
                        className="w-full bg-surface-container-low border border-outline-variant rounded-lg p-2.5 text-xs outline-none focus:ring-2 focus:ring-primary text-on-surface"
                      />
                    </div>
                    <div className="grid grid-cols-2 gap-3">
                      <div>
                        <label className="block text-[10px] font-bold text-on-surface-variant uppercase mb-1">Pickup Place</label>
                        <input 
                          type="text" required placeholder="e.g. Uttara, Dhaka"
                          value={packageForm.pickup} onChange={(e) => setPackageForm({...packageForm, pickup: e.target.value})}
                          className="w-full bg-surface-container-low border border-outline-variant rounded-lg p-2.5 text-xs outline-none focus:ring-2 focus:ring-primary text-on-surface"
                        />
                      </div>
                      <div>
                        <label className="block text-[10px] font-bold text-on-surface-variant uppercase mb-1">Drop-off Place</label>
                        <input 
                          type="text" required placeholder="e.g. Sylhet Sadar"
                          value={packageForm.dropoff} onChange={(e) => setPackageForm({...packageForm, dropoff: e.target.value})}
                          className="w-full bg-surface-container-low border border-outline-variant rounded-lg p-2.5 text-xs outline-none focus:ring-2 focus:ring-primary text-on-surface"
                        />
                      </div>
                    </div>
                    <div className="grid grid-cols-2 gap-3">
                      <div>
                        <label className="block text-[10px] font-bold text-on-surface-variant uppercase mb-1">Weight (KG)</label>
                        <input 
                          type="number" required placeholder="e.g. 2"
                          value={packageForm.weight} onChange={(e) => setPackageForm({...packageForm, weight: e.target.value})}
                          className="w-full bg-surface-container-low border border-outline-variant rounded-lg p-2.5 text-xs outline-none focus:ring-2 focus:ring-primary text-on-surface"
                        />
                      </div>
                      <div>
                        <label className="block text-[10px] font-bold text-on-surface-variant uppercase mb-1">Proposed Reward (BDT)</label>
                        <input 
                          type="number" required placeholder="e.g. 200"
                          value={packageForm.reward} onChange={(e) => setPackageForm({...packageForm, reward: e.target.value})}
                          className="w-full bg-surface-container-low border border-outline-variant rounded-lg p-2.5 text-xs outline-none focus:ring-2 focus:ring-primary text-on-surface"
                        />
                      </div>
                    </div>
                    <div className="grid grid-cols-2 gap-3">
                      <div>
                        <label className="block text-[10px] font-bold text-on-surface-variant uppercase mb-1">Recipient Phone</label>
                        <input 
                          type="tel" required placeholder="e.g. +88017XXXXXXXX"
                          value={packageForm.recipientPhone} onChange={(e) => setPackageForm({...packageForm, recipientPhone: e.target.value})}
                          className="w-full bg-surface-container-low border border-outline-variant rounded-lg p-2.5 text-xs outline-none focus:ring-2 focus:ring-primary text-on-surface"
                        />
                      </div>
                      <div>
                        <label className="block text-[10px] font-bold text-on-surface-variant uppercase mb-1">Recipient Name (optional)</label>
                        <input 
                          type="text" placeholder="e.g. Rahim Uddin"
                          value={packageForm.recipientName} onChange={(e) => setPackageForm({...packageForm, recipientName: e.target.value})}
                          className="w-full bg-surface-container-low border border-outline-variant rounded-lg p-2.5 text-xs outline-none focus:ring-2 focus:ring-primary text-on-surface"
                        />
                      </div>
                    </div>
                    <p className="text-[10px] text-on-surface-variant -mt-1">Recipient phone is required for handoff. Required by the backend after PR #2.</p>
                  </div>
                  <div className="flex gap-2 pt-2">
                    <Button variant="secondary" type="button" onClick={() => setShowPostModal(false)}>Cancel</Button>
                    <Button variant="primary" type="submit">Submit Request</Button>
                  </div>
                </form>
              )}
            </WalletGuard>
          </div>
        </div>
      )}
    </div>
  );
}
