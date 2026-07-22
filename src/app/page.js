'use client';

import React, { useState, useEffect } from 'react';
import { useUser } from '@/context/UserContext';
import Card from '@/components/ui/Card';
import Button from '@/components/ui/Button';
import FigmaMakeDashboardWidget from '@/components/FigmaMakeDashboardWidget';
import SafetyTrustMatrix from '@/components/SafetyTrustMatrix';
import MobbinInspirationGrid from '@/components/MobbinInspirationGrid';
import WalletGuard from '@/components/WalletGuard';
import HeroBubbleShowcase from '@/components/HeroBubbleShowcase';
import { 
  Wallet, Plus, Navigation, ChevronRight, Package, Calendar, 
  MapPin, Clock, Weight, BadgeDollarSign, ShieldAlert, Sparkles, CheckCircle2,
  Car, ShieldCheck, Users, TrendingUp, AlertCircle, LogOut, ArrowRight, Check,
  Lock, ArrowLeftRight
} from 'lucide-react';
import Link from 'next/link';
import { motion, AnimatePresence } from 'motion/react';

export default function RootPage() {
  const { 
    role, setRole, profile, topUp, isAuthenticated, login, signup, logout 
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
  const [packageForm, setPackageForm] = useState({ desc: '', weight: '2', reward: '150', location: 'Dhaka' });

  // Handle Mock Phone Verification Send Code
  const handleSendCode = (e) => {
    e.preventDefault();
    if (!phoneInput || phoneInput.length < 10) {
      setAuthError('Please enter a valid phone number.');
      return;
    }
    setAuthError('');
    setOtpSent(true);
  };

  // Handle Mock Verification Verification OTP
  const handleVerifyOTP = async (e) => {
    e.preventDefault();
    if (otpInput.length !== 6) {
      setAuthError('OTP code must be 6 digits.');
      return;
    }
    setAuthError('');
    
    // Call mock auth context helper
    const success = await login(phoneInput);
    if (success) {
      setShowAuthModal(false);
      setOtpSent(false);
      setPhoneInput('');
      setOtpInput('');
    } else {
      setAuthError('Invalid OTP code verification failed.');
    }
  };

  // Trip posting inside authenticated dashboard
  const handlePostTrip = (e) => {
    e.preventDefault();
    const currentTrips = JSON.parse(localStorage.getItem('cs_trips') || '[]');
    const newTrip = {
      id: `trip-${Date.now()}`,
      traveler_id: profile?.id || '11111111-1111-1111-1111-111111111111',
      departure_city: tripForm.departure,
      destination_city: tripForm.destination,
      route_path: [[23.777176, 90.399452], [24.757082, 90.407438]],
      travel_time: new Date(tripForm.date).toISOString(),
      weight_capacity_kg: parseFloat(tripForm.capacity),
      status: 'scheduled',
      created_at: new Date().toISOString(),
      traveler_name: 'Aminul Islam',
      traveler_rating: '4.9 ★',
      traveler_avatar: profile?.nid_photo_url
    };

    localStorage.setItem('cs_trips', JSON.stringify([newTrip, ...currentTrips]));
    setShowPostModal(false);
    alert('Trip posted successfully! Check "Upcoming Trips" below.');
  };

  // Package posting inside authenticated dashboard
  const handlePostPackage = (e) => {
    e.preventDefault();
    const currentPackages = JSON.parse(localStorage.getItem('cs_packages') || '[]');
    const newPkg = {
      id: `CS-${Math.floor(1000 + Math.random() * 9000)}`,
      sender_id: profile?.id || '11111111-1111-1111-1111-111111111111',
      pickup_lat: 23.777176,
      pickup_lng: 90.399452,
      pickup_radius_meters: 2000,
      item_description: packageForm.desc,
      proposed_reward: parseFloat(packageForm.reward),
      is_premium: false,
      status: 'pending',
      created_at: new Date().toISOString(),
      route_info: `${packageForm.location} to Destination`,
      item_type: `${packageForm.desc} (${packageForm.weight}kg)`,
      eta: 'Pending Match'
    };

    localStorage.setItem('cs_packages', JSON.stringify([newPkg, ...currentPackages]));
    setShowPostModal(false);
    alert('Package delivery request posted! Navigating to Matching tab will find travelers.');
  };

  const activeDeliveries = [
    {
      id: 'CS-9821',
      route: 'Dhaka to Chittagong',
      status: 'In Transit',
      item: 'Small Document',
      eta: 'Today',
      progress: 66
    },
    {
      id: 'CS-7742',
      route: 'Sylhet to Dhaka',
      status: 'Matched',
      item: 'Electronics (2kg)',
      eta: 'Match Date: May 12',
      progress: 33
    }
  ];

  const upcomingTrips = [
    {
      id: 'trip-1',
      route: 'Dhaka to Mymensingh',
      time: 'Tonight 8 PM',
      capacity: '10kg capacity',
      status: 'Scheduled'
    },
    {
      id: 'trip-2',
      route: 'Dhaka to Sherpur',
      time: 'Today 2 PM',
      capacity: '15kg capacity',
      status: 'Active'
    }
  ];

  const platformFeed = [
    { text: "CS-1092 matched on N3 Corridor (Gazipur Bypass)", time: "2 mins ago" },
    { text: "Safety Lock enforced for Package CS-5510", time: "15 mins ago" },
    { text: "Traveler Aminul verification status updated to Verified", time: "1 hr ago" }
  ];

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
            <span className="text-xs uppercase font-extrabold text-orange-700 dark:text-orange-300 bg-orange-500/10 px-4 py-1.5 rounded-full border border-orange-500/30 tracking-widest inline-flex items-center gap-2 shadow-xs">
              <span className="w-2 h-2 rounded-full bg-orange-500 animate-ping"></span>
              PEER-TO-PEER HIGHWAY LOGISTICS
            </span>
            <h1 className="text-4xl md:text-6xl font-black text-on-surface tracking-tight leading-[1.08]">
              Share Highway Journeys.<br/>
              <span className="bg-gradient-to-r from-orange-600 to-amber-500 bg-clip-text text-transparent">Earn Surcharges.</span><br/>
              Ship Securely.
            </h1>
            <p className="text-base text-on-surface-variant max-w-lg leading-relaxed font-medium">
              Bangladesh&apos;s peer-to-peer logistics network matching highway travelers with package senders in real-time.
            </p>
            <div className="flex flex-wrap sm:flex-nowrap gap-3 pt-2">
              <Button 
                variant="primary" 
                onClick={() => {
                  setAuthMode('signup');
                  setShowAuthModal(true);
                }}
                className="py-4 px-8 text-sm font-black uppercase tracking-wider shadow-lg shadow-orange-500/25 flex items-center justify-center gap-2 max-w-xs"
              >
                Get Started Free
                <ArrowRight className="w-4 h-4" />
              </Button>
              <Button 
                variant="secondary" 
                onClick={() => {
                  setAuthMode('login');
                  setShowAuthModal(true);
                }}
                className="py-4 px-8 text-sm font-bold border border-outline hover:bg-orange-500/10 max-w-xs rounded-full"
              >
                Sign In to Account
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

        {/* Pricing Calculator Widget */}
        <section className="mb-16">
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5 }}
            className="text-center max-w-xl mx-auto mb-8"
          >
            <span className="text-[10px] uppercase font-extrabold text-orange-600 dark:text-orange-400 bg-orange-500/10 px-3.5 py-1 rounded-full border border-orange-500/20 tracking-widest inline-block mb-2">
              REAL-TIME FARE CALCULATOR
            </span>
            <h2 className="text-3xl font-black text-on-surface tracking-tight">Micro-Surcharge Estimator</h2>
            <p className="text-sm text-on-surface-variant mt-1.5 font-medium">
              Input cargo details and detour parameters to calculate a recommended peer-to-peer delivery fee instantly.
            </p>
          </motion.div>

          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6, delay: 0.1 }}
            className="max-w-3xl mx-auto bg-surface border border-orange-500/30 rounded-[32px] p-6 md:p-8 shadow-xl grid grid-cols-1 md:grid-cols-2 gap-8 items-center transition-colors duration-300 relative overflow-hidden"
          >
            <div className="absolute top-0 right-0 w-48 h-48 bg-gradient-to-br from-orange-500/10 to-amber-500/5 rounded-full blur-2xl pointer-events-none" />

            {/* Controls */}
            <div className="space-y-6 relative z-10">
              <div className="space-y-2">
                <div className="flex justify-between text-xs sm:text-sm font-bold text-on-surface">
                  <span>Luggage Weight Limit</span>
                  <span className="text-orange-600 dark:text-orange-400 font-mono font-black text-base">{calcWeight.toFixed(1)} KG</span>
                </div>
                <input 
                  type="range" min="0.5" max="15.0" step="0.5"
                  value={calcWeight} onChange={(e) => setCalcWeight(parseFloat(e.target.value))}
                  className="w-full h-3 bg-orange-500/15 rounded-full appearance-none cursor-pointer accent-orange-500 transition-all"
                />
                <div className="flex justify-between text-[10px] text-on-surface-variant uppercase font-extrabold tracking-wider">
                  <span>0.5 kg</span>
                  <span>15.0 kg</span>
                </div>
              </div>

              <div className="space-y-2">
                <div className="flex justify-between text-xs sm:text-sm font-bold text-on-surface">
                  <span>Detour Travel Distance</span>
                  <span className="text-orange-600 dark:text-orange-400 font-mono font-black text-base">{calcDetour.toFixed(0)} KM</span>
                </div>
                <input 
                  type="range" min="0" max="25" step="1"
                  value={calcDetour} onChange={(e) => setCalcDetour(parseInt(e.target.value))}
                  className="w-full h-3 bg-orange-500/15 rounded-full appearance-none cursor-pointer accent-orange-500 transition-all"
                />
                <div className="flex justify-between text-[10px] text-on-surface-variant uppercase font-extrabold tracking-wider">
                  <span>0 km (Direct)</span>
                  <span>25 km</span>
                </div>
              </div>
            </div>

            {/* Display widget with dynamic price pop animation */}
            <div className="bg-gradient-to-br from-orange-500/15 to-amber-500/10 border border-orange-500/30 rounded-[28px] p-6 text-center space-y-3 shadow-inner relative z-10">
              <span className="text-[10px] uppercase font-black tracking-widest text-orange-600 dark:text-orange-400 block">Recommended Surcharge</span>
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
                <span className="text-base font-black text-orange-600 dark:text-orange-400">BDT</span>
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
                className="py-3.5 w-full text-xs font-black uppercase tracking-wider mt-2 shadow-lg shadow-orange-500/25"
              >
                Ship For This Surcharge
              </Button>
            </div>
          </motion.div>
        </section>

        {/* Figma Make UI Tracking & Analytics Dashboard Component */}
        <FigmaMakeDashboardWidget />

        {/* How It Works Section */}
        <section className="mb-16">
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5 }}
            className="text-center max-w-xl mx-auto mb-10"
          >
            <span className="text-[10px] uppercase font-extrabold text-orange-600 dark:text-orange-400 bg-orange-500/10 px-3.5 py-1 rounded-full border border-orange-500/20 tracking-widest inline-block mb-2">
              SIMPLE 3-STEP PROCESS
            </span>
            <h2 className="text-3xl font-black text-on-surface tracking-tight">How CorridorShare Works</h2>
            <p className="text-xs text-on-surface-variant mt-1.5 font-medium">
              A 3-step geofenced delivery model connecting verified travelers with highway-corridor packages.
            </p>
          </motion.div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
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
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: i * 0.15 }}
              >
                <Card className="border border-orange-500/20 hover:border-orange-500/50 flex flex-col items-center text-center p-6 space-y-4 h-full rounded-[28px] transition-all">
                  <div className="w-14 h-14 bg-gradient-to-br from-orange-500 to-amber-500 text-white rounded-full flex items-center justify-center font-black text-lg shadow-lg shadow-orange-500/30">
                    {item.step}
                  </div>
                  <h4 className="font-black text-on-surface text-base">{item.title}</h4>
                  <p className="text-xs text-on-surface-variant leading-relaxed font-medium">
                    {item.desc}
                  </p>
                </Card>
              </motion.div>
            ))}
          </div>
        </section>

        {/* Mobbin-Inspired Live Corridor Inspiration Directory */}
        <MobbinInspirationGrid />

        {/* Interactive Safety & Escrow Trust Architecture Component */}
        <SafetyTrustMatrix />

        {/* Footnotes */}
        <footer className="text-center py-6 border-t border-outline-variant/35 text-[10px] text-on-surface-variant font-bold">
          &copy; {new Date().getFullYear()} CorridorShare P2P Logistics. Bangladesh.
        </footer>

        {/* STATEFUL AUTHENTICATION MODAL (LOG IN / SIGN UP) */}
        {showAuthModal && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
            {/* Backdrop */}
            <div className="absolute inset-0 bg-slate-950/60 backdrop-blur-sm" onClick={() => setShowAuthModal(false)}></div>
            
            {/* Form Box */}
            <div className="bg-surface-container-lowest rounded-2xl border border-outline-variant shadow-2xl p-6 w-full max-w-sm relative z-10 animate-in fade-in zoom-in-95 duration-200">
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
                    <p className="font-bold uppercase tracking-wider text-[9px] mb-1">Sandbox OTP Mode Active</p>
                    <p className="text-[10px]">Enter any 6-digit code (e.g. <strong>123456</strong>) to verify and unlock access instantly!</p>
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
          <h1 className="text-3xl font-extrabold text-on-surface tracking-tight">
            Hello, Friend! 👋
          </h1>
          <p className="text-xs text-on-surface-variant mt-1 max-w-xl">
            Welcome to the CorridorShare logistics portal. Share corridor travel paths, match with local senders, and secure micro-surcharges.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <span className="text-[10px] uppercase font-bold text-orange-700 dark:text-orange-300 bg-orange-500/10 px-3.5 py-1.5 rounded-full border border-orange-500/30 flex items-center gap-1.5">
            <span className="w-2 h-2 rounded-full bg-orange-500 animate-pulse"></span>
            Simulated Sandbox Active
          </span>
        </div>
      </div>

      {/* Select Active Role Cards */}
      <section className="mb-8">
        <h2 className="text-xs uppercase font-extrabold tracking-widest text-on-surface-variant mb-4 flex items-center gap-1">
          <ArrowLeftRight className="w-4 h-4 text-orange-500" />
          Select Your Active Role
        </h2>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
          {/* Traveler Card */}
          <div 
            onClick={() => setRole('traveler')}
            className={`cursor-pointer rounded-[28px] p-6 border transition-all duration-300 relative overflow-hidden flex flex-col gap-4 group hover:-translate-y-1 hover:shadow-lg ${
              role === 'traveler' 
                ? 'bg-orange-500/10 dark:bg-orange-500/20 border-orange-500 ring-2 ring-orange-500/40 shadow-md' 
                : 'bg-surface-container-lowest border-outline-variant hover:border-orange-500/30 shadow-sm'
            }`}
          >
            <div aria-hidden="true" className="absolute right-4 bottom-2 text-6xl font-black opacity-0 select-none pointer-events-none tracking-wider">
              TRAVELER
            </div>

            <div className="flex items-start gap-4">
              <div className={`p-4 rounded-2xl transition-all duration-300 ${
                role === 'traveler' 
                  ? 'bg-gradient-to-br from-orange-500 to-amber-500 text-white scale-110 shadow-md shadow-orange-500/30' 
                  : 'bg-surface-container-low text-on-surface-variant group-hover:bg-orange-500/10'
              }`}>
                <Car className="w-7 h-7" />
              </div>
              
              <div className="flex-grow space-y-0.5">
                <div className="flex items-center justify-between">
                  <h3 className="font-black text-lg text-on-surface">Traveler Mode</h3>
                  {role === 'traveler' ? (
                    <span className="text-[9px] bg-gradient-to-r from-orange-500 to-amber-500 text-white px-3 py-1 rounded-full font-bold uppercase tracking-wider shadow-xs">Active Mode</span>
                  ) : (
                    <span className="text-[9px] bg-surface-container-low text-on-surface-variant px-2.5 py-0.5 rounded-full font-bold uppercase tracking-wider group-hover:text-orange-500">Select</span>
                  )}
                </div>
                <p className="text-xs text-on-surface-variant leading-relaxed">
                  Post routes to earn extra money carrying parcels along your path.
                </p>
              </div>
            </div>

            <div className="pt-3 border-t border-outline-variant/40 grid grid-cols-1 sm:grid-cols-3 gap-2">
              <span className="text-[10px] text-on-surface-variant font-bold flex items-center gap-1.5">
                <Check className="w-3.5 h-3.5 text-orange-500" /> Earn micro-fees
              </span>
              <span className="text-[10px] text-on-surface-variant font-bold flex items-center gap-1.5">
                <Check className="w-3.5 h-3.5 text-orange-500" /> Flexible schedules
              </span>
              <span className="text-[10px] text-on-surface-variant font-bold flex items-center gap-1.5">
                <Check className="w-3.5 h-3.5 text-orange-500" /> Custom detour fees
              </span>
            </div>
          </div>

          {/* Sender/Receiver Card */}
          <div 
            onClick={() => setRole('sender')}
            className={`cursor-pointer rounded-[28px] p-6 border transition-all duration-300 relative overflow-hidden flex flex-col gap-4 group hover:-translate-y-1 hover:shadow-lg ${
              role === 'sender' 
                ? 'bg-orange-500/10 dark:bg-orange-500/20 border-orange-500 ring-2 ring-orange-500/40 shadow-md' 
                : 'bg-surface-container-lowest border-outline-variant hover:border-orange-500/30 shadow-sm'
            }`}
          >
            <div aria-hidden="true" className="absolute right-4 bottom-2 text-6xl font-black opacity-0 select-none pointer-events-none tracking-wider">
              SENDER
            </div>

            <div className="flex items-start gap-4">
              <div className={`p-4 rounded-2xl transition-all duration-300 ${
                role === 'sender' 
                  ? 'bg-gradient-to-br from-orange-500 to-amber-500 text-white scale-110 shadow-md shadow-orange-500/30' 
                  : 'bg-surface-container-low text-on-surface-variant group-hover:bg-orange-500/10'
              }`}>
                <Package className="w-7 h-7" />
              </div>
              
              <div className="flex-grow space-y-0.5">
                <div className="flex items-center justify-between">
                  <h3 className="font-black text-lg text-on-surface">Sender & Receiver Mode</h3>
                  {role === 'sender' ? (
                    <span className="text-[9px] bg-gradient-to-r from-orange-500 to-amber-500 text-white px-3 py-1 rounded-full font-bold uppercase tracking-wider shadow-xs">Active Mode</span>
                  ) : (
                    <span className="text-[9px] bg-surface-container-low text-on-surface-variant px-2.5 py-0.5 rounded-full font-bold uppercase tracking-wider group-hover:text-orange-500">Select</span>
                  )}
                </div>
                <p className="text-xs text-on-surface-variant leading-relaxed">
                  Post package shipment coordinates and match with travelers nearby.
                </p>
              </div>
            </div>

            <div className="pt-3 border-t border-outline-variant/40 grid grid-cols-1 sm:grid-cols-3 gap-2">
              <span className="text-[10px] text-on-surface-variant font-bold flex items-center gap-1.5">
                <Check className="w-3.5 h-3.5 text-orange-500" /> Escrow secured
              </span>
              <span className="text-[10px] text-on-surface-variant font-bold flex items-center gap-1.5">
                <Check className="w-3.5 h-3.5 text-orange-500" /> Snapped matching
              </span>
              <span className="text-[10px] text-on-surface-variant font-bold flex items-center gap-1.5">
                <Check className="w-3.5 h-3.5 text-orange-500" /> Verified travel paths
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
              <Link href="/match" className="text-xs font-bold text-orange-600 dark:text-orange-400 flex items-center gap-0.5 hover:underline">
                Matching Portal <ChevronRight className="w-3.5 h-3.5" />
              </Link>
            </div>

            <div className="space-y-4">
              {role === 'traveler' ? (
                upcomingTrips.map((trip) => (
                  <Card key={trip.id} className="relative group overflow-hidden border border-outline-variant rounded-[24px]">
                    <div className="flex justify-between items-start mb-3">
                      <div>
                        <span className="text-[10px] font-bold text-on-surface-variant block uppercase">Trip ID: {trip.id}</span>
                        <span className="font-bold text-on-surface text-base mt-1 block">{trip.route}</span>
                      </div>
                      <span className={`text-[10px] font-bold uppercase tracking-wider px-2.5 py-0.5 rounded-full ${
                        trip.status === 'Active' 
                          ? 'bg-orange-500/15 text-orange-600 dark:text-orange-400 border border-orange-500/30' 
                          : 'bg-surface-container-low text-on-surface-variant border border-outline-variant'
                      }`}>
                        {trip.status}
                      </span>
                    </div>

                    <div className="pt-2.5 border-t border-outline-variant flex justify-between items-center text-xs text-on-surface-variant font-medium">
                      <div className="flex items-center gap-1.5">
                        <Clock className="w-4 h-4 text-orange-500" />
                        <span>{trip.time}</span>
                      </div>
                      <div className="flex items-center gap-1.5">
                        <Weight className="w-4 h-4 text-orange-500" />
                        <span>{trip.capacity}</span>
                      </div>
                    </div>
                  </Card>
                ))
              ) : (
                activeDeliveries.map((pkg) => (
                  <Card key={pkg.id} className="overflow-hidden border border-outline-variant rounded-[24px]">
                    <div className="flex justify-between items-start mb-3">
                      <div>
                        <span className="text-[10px] font-bold text-on-surface-variant block uppercase">Package ID: {pkg.id}</span>
                        <span className="font-bold text-on-surface text-base mt-1 block">{pkg.route}</span>
                      </div>
                      <span className="bg-orange-500/15 text-orange-600 dark:text-orange-400 border border-orange-500/30 text-[10px] font-bold uppercase tracking-wider px-2.5 py-0.5 rounded-full">
                        {pkg.status}
                      </span>
                    </div>

                    {/* Progress Visual Tracker */}
                    <div className="space-y-2 py-2">
                      <div className="flex justify-between text-[9px] font-bold text-on-surface-variant uppercase tracking-wide">
                        <span className={pkg.progress >= 33 ? 'text-orange-600 dark:text-orange-400 font-bold' : ''}>Matched</span>
                        <span className={pkg.progress >= 66 ? 'text-orange-600 dark:text-orange-400 font-bold' : ''}>In Transit</span>
                        <span className={pkg.progress >= 100 ? 'text-orange-600 dark:text-orange-400 font-bold' : ''}>Delivered</span>
                      </div>
                      <div className="w-full h-2 bg-orange-500/15 rounded-full overflow-hidden flex border border-orange-500/20">
                        <div 
                          className="h-full bg-gradient-to-r from-orange-500 to-amber-400 transition-all duration-500 relative"
                          style={{ width: `${pkg.progress}%` }}
                        >
                          <div className="absolute right-0 top-0 bottom-0 w-8 bg-gradient-to-r from-transparent to-white/40 animate-pulse"></div>
                        </div>
                      </div>
                    </div>

                    <div className="pt-2.5 border-t border-outline-variant flex justify-between items-center text-xs text-on-surface-variant font-medium">
                      <div className="flex items-center gap-1.5">
                        <Package className="w-4 h-4 text-orange-500" />
                        <span>{pkg.item}</span>
                      </div>
                      <span className="text-orange-600 dark:text-orange-400 font-extrabold text-xs">{pkg.eta}</span>
                    </div>
                  </Card>
                ))
              )}
            </div>
          </section>

          {/* Quick Info Guides */}
          <section className="bg-gradient-to-br from-orange-500/10 to-amber-500/5 border border-orange-500/20 rounded-[24px] p-5 flex items-start gap-4">
            <ShieldCheck className="w-6 h-6 text-orange-500 flex-shrink-0 mt-0.5" />
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
            <Card className="bg-gradient-to-br from-orange-600 via-orange-500 to-amber-600 text-white relative overflow-hidden border-none shadow-xl rounded-[28px]">
              <div className="absolute -right-8 -bottom-8 w-36 h-36 bg-white/10 rounded-full blur-2xl pointer-events-none"></div>
              <div className="absolute right-4 top-4 bg-white/20 backdrop-blur-md p-2.5 rounded-full">
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
                    onClick={() => {
                      const amt = prompt("Enter simulated amount to top up via bKash/Nagad (BDT):", "50");
                      if (amt && !isNaN(amt)) {
                        topUp(parseFloat(amt));
                      }
                    }}
                    className="bg-white/20 hover:bg-white/30 border border-white/30 text-white py-3 w-full flex items-center justify-center gap-1.5 rounded-full"
                  >
                    <Plus className="w-4 h-4" />
                    Quick Top Up
                  </Button>

                  <Button
                    variant="primary"
                    onClick={() => setShowPostModal(true)}
                    className="bg-white hover:bg-amber-50 text-orange-700 py-3 shadow-md w-full flex items-center justify-center gap-1.5 rounded-full font-black"
                  >
                    <Navigation className="w-4 h-4 text-orange-600" />
                    {role === 'traveler' ? 'Post New Trip' : 'Request Delivery'}
                  </Button>
                </div>
              </div>
            </Card>
          </section>

          {/* Real-time Activity Feed */}
          <section>
            <div className="bg-surface border border-orange-500/20 rounded-[28px] p-5 shadow-sm">
              <h3 className="font-extrabold text-xs text-on-surface uppercase tracking-wider mb-4 flex items-center gap-1.5">
                <TrendingUp className="w-4 h-4 text-orange-500" />
                Live Matching Corridor Activity
              </h3>
              <div className="space-y-4">
                {platformFeed.map((f, i) => (
                  <div key={i} className="flex gap-2.5 text-xs border-b border-outline-variant/30 pb-3 last:border-b-0 last:pb-0">
                    <div className="w-2 h-2 rounded-full bg-orange-500 mt-1.5 flex-shrink-0 animate-ping"></div>
                    <div className="flex-grow space-y-0.5">
                      <p className="text-on-surface leading-normal font-medium">{f.text}</p>
                      <span className="text-[11px] text-on-surface-variant block font-medium">{f.time}</span>
                    </div>
                  </div>
                ))}
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
          <div className="bg-surface-container-lowest rounded-2xl border border-outline-variant shadow-2xl p-6 w-full max-w-md relative z-10 animate-in fade-in zoom-in-95 duration-200">
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
                    <div className="grid grid-cols-3 gap-3">
                      <div className="col-span-2">
                        <label className="block text-[10px] font-bold text-on-surface-variant uppercase mb-1">Pickup Area</label>
                        <input 
                          type="text" required placeholder="e.g. Uttara, Dhaka"
                          value={packageForm.location} onChange={(e) => setPackageForm({...packageForm, location: e.target.value})}
                          className="w-full bg-surface-container-low border border-outline-variant rounded-lg p-2.5 text-xs outline-none focus:ring-2 focus:ring-primary text-on-surface"
                        />
                      </div>
                      <div>
                        <label className="block text-[10px] font-bold text-on-surface-variant uppercase mb-1">Weight (KG)</label>
                        <input 
                          type="number" required placeholder="e.g. 2"
                          value={packageForm.weight} onChange={(e) => setPackageForm({...packageForm, weight: e.target.value})}
                          className="w-full bg-surface-container-low border border-outline-variant rounded-lg p-2.5 text-xs outline-none focus:ring-2 focus:ring-primary text-on-surface"
                        />
                      </div>
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
