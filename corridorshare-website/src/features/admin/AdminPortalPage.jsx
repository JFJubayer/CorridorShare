/* eslint-disable @next/next/no-img-element */
'use client';

import React, { useState, useEffect, useCallback } from 'react';
import { DEFAULT_DEMO_PROFILES, isMockDataSource } from '@/config/supabaseClient';
import { addDemoKycProfile, loadProfilesForReview, resetDemoUsers, setKycStatus } from '@/features/admin/actions';
import Card from '@/components/ui/Card';
import Button from '@/components/ui/Button';
import { ShieldCheck, ShieldAlert, Phone, DollarSign, Calendar, RefreshCw, ZoomIn, Ban, RotateCcw, Plus, CheckCircle2 } from 'lucide-react';
import AuthGuard from '@/features/auth/AuthGuard';

export default function AdminPortalPage() {
  return (
    <AuthGuard title="Admin Compliance & Identity Verification Portal" requireAdmin={true}>
      <AdminPortalPageContent />
    </AuthGuard>
  );
}

function AdminPortalPageContent() {
  const [profiles, setProfiles] = useState(DEFAULT_DEMO_PROFILES);
  const [selectedPhoto, setSelectedPhoto] = useState(null);
  const [loading, setLoading] = useState(false);
  const [activeFilter, setActiveFilter] = useState('all');
  const [actionError, setActionError] = useState('');

  const loadProfiles = useCallback(async (showSpinner = false) => {
    if (showSpinner) setLoading(true);
    try {
      setProfiles(await loadProfilesForReview());
      setActionError('');
    } catch (error) {
      setActionError(error.message || 'Unable to load profiles.');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    const timer = window.setTimeout(() => loadProfiles(), 0);
    return () => window.clearTimeout(timer);
  }, [loadProfiles]);

  const handleApprove = async (id) => {
    try {
      await setKycStatus(id, 'verified');
      await loadProfiles();
    } catch (error) {
      setActionError(error.message || 'Unable to approve this verification.');
    }
  };

  const handleSuspend = async (id) => {
    try {
      await setKycStatus(id, 'suspended');
      await loadProfiles();
    } catch (error) {
      setActionError(error.message || 'Unable to suspend this account.');
    }
  };

  const handleResetDemoData = async () => {
    try {
      resetDemoUsers();
      await loadProfiles();
    } catch (error) {
      setActionError(error.message || 'Unable to reset demo data.');
    }
  };

  const handleAddSampleKYC = async () => {
    try {
      await addDemoKycProfile();
      await loadProfiles();
    } catch (error) {
      setActionError(error.message || 'Unable to create a demo profile.');
    }
  };

  const filteredProfiles = profiles.filter((p) => {
    if (activeFilter === 'all') return true;
    if (activeFilter === 'pending') return p.nid_status === 'pending' || p.nid_status === 'unverified';
    return p.nid_status === activeFilter;
  });

  return (
    <div className="min-h-screen bg-background p-6 md:pl-56 transition-colors duration-300">
      
      {/* Header */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-6">
        <div>
          <span className="text-[10px] bg-primary text-white px-3 py-1 rounded-full font-black uppercase tracking-wider shadow-xs">
            KYC Compliance
          </span>
          <h1 className="text-2xl font-black text-on-surface tracking-tight mt-1.5 font-display">
            Admin Identity Verification Portal
          </h1>
          <p className="text-xs text-on-surface-variant mt-0.5 font-medium">
            Review user-submitted National Identity Card (NID) photos and manage verification statuses.
          </p>
        </div>

        <div className="flex flex-wrap items-center gap-2">
          {isMockDataSource && <>
          <button 
            onClick={handleAddSampleKYC}
            className="flex items-center gap-1.5 bg-primary text-white px-4 py-2.5 rounded-full text-xs font-black transition-all shadow-md hover:bg-primary-700 active:scale-95 outline-none cursor-pointer"
          >
            <Plus className="w-3.5 h-3.5" />
            Add Test KYC
          </button>
          
          <button 
            onClick={handleResetDemoData}
            className="flex items-center gap-1.5 bg-surface-container-low border border-outline hover:bg-primary/10 px-4 py-2.5 rounded-full text-xs font-bold text-on-surface transition-all shadow-xs outline-none cursor-pointer"
          >
            <RotateCcw className="w-3.5 h-3.5 text-primary" />
            Reset Demo Users
          </button>
          </>}

          <button 
            onClick={() => loadProfiles(true)}
            className="flex items-center gap-1.5 bg-surface border border-outline hover:bg-primary/10 px-4 py-2.5 rounded-full text-xs font-bold text-on-surface transition-all shadow-xs outline-none cursor-pointer"
          >
            <RefreshCw className="w-3.5 h-3.5 text-primary" />
            Reload
          </button>
        </div>
      </div>

      {actionError && <p role="alert" className="mb-4 rounded-2xl border border-red-500/25 bg-red-500/10 px-4 py-3 text-xs font-bold text-red-600 dark:text-red-400">{actionError}</p>}

      {/* Filter Tabs Bar */}
      <div className="flex items-center gap-2.5 border-b border-outline-variant pb-3 mb-6 overflow-x-auto">
        {[
          { id: 'all', label: 'All Profiles' },
          { id: 'pending', label: 'Pending Review' },
          { id: 'verified', label: 'Verified' },
          { id: 'suspended', label: 'Suspended' }
        ].map((tab) => {
          const count = profiles.filter((p) => {
            if (tab.id === 'all') return true;
            if (tab.id === 'pending') return p.nid_status === 'pending' || p.nid_status === 'unverified';
            return p.nid_status === tab.id;
          }).length;

          return (
            <button
              key={tab.id}
              onClick={() => setActiveFilter(tab.id)}
              className={`px-4 py-2 rounded-full text-xs font-black transition-all flex items-center gap-1.5 whitespace-nowrap cursor-pointer ${ activeFilter === tab.id ? 'bg-primary text-white shadow-md' : 'bg-surface-container-low text-on-surface-variant hover:text-on-surface hover:bg-primary/10' }`}
            >
              <span>{tab.label}</span>
              <span className={`text-[10px] px-2 py-0.2 rounded-full font-black ${ activeFilter === tab.id ? 'bg-white/25 text-white' : 'bg-surface-container-highest text-on-surface-variant' }`}>
                {count}
              </span>
            </button>
          );
        })}
      </div>

      {/* Main Content List */}
      {loading ? (
        <div className="flex flex-col items-center justify-center py-20 gap-3">
          <svg className="animate-spin h-8 w-8 text-primary" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
            <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
            <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          <span className="text-sm font-semibold text-on-surface-variant">Loading verification data...</span>
        </div>
      ) : filteredProfiles.length === 0 ? (
        <div className="bg-surface border border-primary/25 rounded-xl p-12 text-center max-w-lg mx-auto shadow-lg space-y-4 transition-colors duration-300">
          <div className="bg-primary/10 text-primary p-3 rounded-full w-fit mx-auto">
            <ShieldCheck className="w-8 h-8" />
          </div>
          <div>
            <h3 className="font-black text-on-surface text-lg">No profiles in this filter!</h3>
            <p className="text-xs text-on-surface-variant mt-1 font-medium">There are currently no user profiles matching &quot;{activeFilter}&quot;.</p>
          </div>
          <div className="flex justify-center gap-2 pt-2">
            {isMockDataSource && <>
              <Button onClick={handleAddSampleKYC} variant="primary" className="text-xs font-black rounded-full">
                Add Sample KYC Profile
              </Button>
              <Button onClick={handleResetDemoData} variant="secondary" className="text-xs font-bold rounded-full border border-outline">
                Reset Demo Users
              </Button>
            </>}
          </div>
        </div>
      ) : (
        <div className="grid grid-cols-1 xl:grid-cols-2 gap-6 animate-in fade-in duration-300">
          {filteredProfiles.map((p) => {
            const isVerified = p.nid_status === 'verified';
            const isSuspended = p.nid_status === 'suspended';

            return (
              <Card key={p.id} className="bg-surface border border-outline p-6 flex flex-col justify-between gap-5 shadow-md hover:shadow-xl transition-all duration-300 rounded-xl">
                
                {/* Profile Meta info */}
                <div className="flex flex-col sm:flex-row gap-5 items-start">
                  {/* NID Card Photo Container */}
                  <div className="relative w-full sm:w-48 h-32 rounded-2xl overflow-hidden bg-surface-container-low border border-outline group flex-shrink-0">
                    <img 
                      src={p.nid_photo_url || "https://images.unsplash.com/photo-1554774853-aae0a22c8aa4?auto=format&fit=crop&w=400&h=250&q=80"} 
                      alt="NID Submission" 
                      className="w-full h-full object-cover transition-transform group-hover:scale-105 duration-300"
                    />
                    <button 
                      onClick={() => setSelectedPhoto(p.nid_photo_url || "https://images.unsplash.com/photo-1554774853-aae0a22c8aa4?auto=format&fit=crop&w=400&h=250&q=80")}
                      className="absolute inset-0 bg-slate-950/50 opacity-0 group-hover:opacity-100 flex items-center justify-center transition-opacity rounded-2xl outline-none cursor-pointer"
                    >
                      <ZoomIn className="text-white w-6 h-6" />
                    </button>
                  </div>

                  <div className="space-y-2.5 flex-grow">
                    <div className="flex justify-between items-center gap-2">
                      <span className="text-[10px] font-black text-on-surface-variant block uppercase tracking-widest">
                        UID: {String(p.id).slice(0, 12)}...
                      </span>
                      <span className={`text-[9px] font-black uppercase px-3 py-1 rounded-full border ${ isVerified ? 'bg-emerald-500/10 text-emerald-600 border border-emerald-500/20' : isSuspended ? 'bg-red-500/10 text-red-600 border border-red-500/20' : 'bg-amber-500/10 text-amber-600 border border-amber-500/20' }`}>
                        {p.nid_status || 'pending'}
                      </span>
                    </div>

                    <div className="space-y-1.5 text-xs text-on-surface-variant font-medium">
                      <p className="flex items-center gap-1.5 font-bold text-on-surface">
                        <Phone className="w-3.5 h-3.5 text-primary" />
                        Phone: {p.phone_number}
                      </p>
                      <p className="flex items-center gap-1.5 font-bold text-on-surface">
                        <DollarSign className="w-3.5 h-3.5 text-primary" />
                        Wallet Balance: <strong className="text-primary font-mono font-black">{parseFloat(p.wallet_balance || 0).toFixed(2)} BDT</strong>
                      </p>
                      <p className="flex items-center gap-1.5 text-[11px] text-on-surface-variant/80">
                        <Calendar className="w-3.5 h-3.5 text-on-surface-variant/55" />
                        Submitted: {p.created_at ? new Date(p.created_at).toLocaleDateString() : 'Today'}
                      </p>
                    </div>
                  </div>
                </div>

                {/* Action buttons */}
                <div className="flex flex-col sm:flex-row gap-2 pt-3 border-t border-outline-variant">
                  {!isVerified ? (
                    <Button 
                      onClick={() => handleApprove(p.id)}
                      variant="success" 
                      className="flex-1 py-2.5 text-xs font-black uppercase tracking-wider rounded-full"
                    >
                      <ShieldCheck className="w-4 h-4" />
                      Approve Verification
                    </Button>
                  ) : (
                    <div className="flex-1 py-2.5 text-xs font-black text-emerald-600 bg-emerald-500/10 rounded-full flex items-center justify-center gap-1.5 border border-emerald-500/20">
                      <CheckCircle2 className="w-4 h-4" />
                      Verified Profile
                    </div>
                  )}

                  {!isSuspended && (
                    <Button 
                      onClick={() => handleSuspend(p.id)}
                      variant="danger" 
                      className="flex-1 py-2.5 text-xs bg-red-500/10 hover:bg-red-500/20 text-red-600 dark:text-red-400 border border-red-500/20 font-black uppercase tracking-wider rounded-full"
                    >
                      <Ban className="w-4 h-4" />
                      Suspend Account
                    </Button>
                  )}
                </div>

              </Card>
            );
          })}
        </div>
      )}

      {/* Image Modal Lightbox */}
      {selectedPhoto && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div className="absolute inset-0 bg-slate-950/80 backdrop-blur-sm" onClick={() => setSelectedPhoto(null)}></div>
          <div className="relative max-w-4xl max-h-[85vh] z-10 overflow-hidden rounded-xl border border-primary/25 shadow-lg">
            <img src={selectedPhoto} alt="NID Zoomed View" className="w-full h-auto max-h-[80vh] object-contain bg-slate-950" />
            <button 
              onClick={() => setSelectedPhoto(null)}
              className="absolute top-4 right-4 bg-slate-950/70 hover:bg-slate-950 text-white rounded-full px-4 py-2 transition-colors font-black text-[10px] uppercase tracking-wider outline-none cursor-pointer"
            >
              Close Zoom
            </button>
          </div>
        </div>
      )}

    </div>
  );
}
