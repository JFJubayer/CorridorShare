/* eslint-disable @next/next/no-img-element */
'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useUser } from '@/context/UserContext';
import { Bell, ShieldCheck, Home, Compass, MessageSquare, User, ShieldAlert, Sun, Moon, LogOut } from 'lucide-react';
import AuthModal from './AuthModal';

export default function NavWrapper({ children }) {
  const pathname = usePathname();
  const { profile, role, toggleRole, theme, toggleTheme, logout, isAuthenticated } = useUser();
  const [showAuthModal, setShowAuthModal] = useState(false);


  const [mounted, setMounted] = useState(false);
  // eslint-disable-next-line react-hooks/set-state-in-effect
  React.useEffect(() => { setMounted(true); }, []);

  const [showNotifications, setShowNotifications] = useState(false);
  const notificationRef = React.useRef(null);

  // Load notifications from LocalStorage or default to empty for clean user experience
  const [notifications, setNotifications] = useState([]);

  React.useEffect(() => {
    if (typeof window !== 'undefined') {
      const stored = localStorage.getItem('cs_notifications');
      if (stored) {
        try {
          setNotifications(JSON.parse(stored));
        } catch {
          setNotifications([]);
        }
      }
    }
  }, []);

  // Update LocalStorage whenever notifications change
  const updateNotifications = (newNotifs) => {
    setNotifications(newNotifs);
    if (typeof window !== 'undefined') {
      localStorage.setItem('cs_notifications', JSON.stringify(newNotifs));
    }
  };

  // Close notifications dropdown reliably whenever clicking anywhere outside
  React.useEffect(() => {
    function handleClickOutside(event) {
      if (notificationRef.current && !notificationRef.current.contains(event.target)) {
        setShowNotifications(false);
      }
    }
    document.addEventListener('mousedown', handleClickOutside);
    document.addEventListener('touchstart', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
      document.removeEventListener('touchstart', handleClickOutside);
    };
  }, []);

  // Hide default navigation if we are on the admin portal
  const isAdmin = pathname.startsWith('/admin') || pathname.startsWith('/admin-portal');
  const hasUnread = notifications.some(n => !n.read);

  return (
    <div className="flex flex-col min-h-screen transition-colors duration-300 bg-background text-on-surface">
      {/* Top Navigation Bar */}
      <nav className="fixed top-0 left-0 w-full h-16 z-40 flex justify-between items-center px-6 bg-surface/85 backdrop-blur-md border-b border-outline-variant/80 shadow-xs transition-colors duration-300">
        <div className="flex items-center gap-2.5">
          <span className="text-xl font-black bg-gradient-to-r from-orange-600 to-amber-500 bg-clip-text text-transparent tracking-tight font-display">CorridorShare</span>
          <span className="text-[9px] bg-orange-500/10 text-orange-600 dark:text-orange-400 border border-orange-500/20 px-2.5 py-0.5 rounded-full font-black uppercase tracking-widest">
            HIGHWAY P2P
          </span>
        </div>

        <div className="flex items-center gap-2">
          {/* Theme Toggler */}
          <button 
            onClick={toggleTheme}
            className="p-2 text-on-surface-variant hover:bg-slate-50 dark:hover:bg-slate-900 rounded-full transition-colors cursor-pointer"
            title="Toggle Theme"
            aria-label="Toggle light and dark theme"
          >
            {!mounted ? (
              <span className="w-5 h-5 block" />
            ) : theme === 'dark' ? (
              <Sun className="w-5 h-5 text-amber-400 fill-amber-400/20" />
            ) : (
              <Moon className="w-5 h-5 text-slate-700 fill-slate-700/10" />
            )}
          </button>

          {/* Bell Notification Dropdown System */}
          <div className="relative" ref={notificationRef}>
            <button 
              onClick={() => setShowNotifications(!showNotifications)}
              className="p-2 text-on-surface-variant hover:bg-slate-50 dark:hover:bg-slate-900 rounded-full transition-colors relative cursor-pointer"
              title="Notifications"
            >
              <Bell className="w-5 h-5" />
              {hasUnread && (
                <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-orange-500 rounded-full animate-ping"></span>
              )}
            </button>

            {showNotifications && (
              <div className="absolute right-0 mt-2 w-80 bg-surface border border-orange-500/25 rounded-2xl shadow-2xl py-2 z-50 animate-in fade-in zoom-in-95 duration-150">
                <div className="px-4 py-2.5 border-b border-outline-variant/60 flex justify-between items-center">
                  <span className="font-black text-xs text-on-surface uppercase tracking-wider font-display">Notifications</span>
                  {notifications.length > 0 && (
                    <button 
                      onClick={() => updateNotifications([])}
                      className="text-[10px] font-bold text-orange-600 dark:text-orange-400 hover:underline outline-none cursor-pointer"
                    >
                      Clear All
                    </button>
                  )}
                </div>
                
                <div className="max-h-64 overflow-y-auto divide-y divide-outline-variant/30 custom-scrollbar">
                  {notifications.length === 0 ? (
                    <div className="text-center py-8 px-4 space-y-1">
                      <Bell className="w-6 h-6 text-on-surface-variant/40 mx-auto" />
                      <p className="text-xs font-bold text-on-surface-variant">No new notifications</p>
                      <p className="text-[10px] text-on-surface-variant/70">Matching requests & system alerts will appear here.</p>
                    </div>
                  ) : (
                    notifications.map(n => (
                      <Link 
                        key={n.id} 
                        href={n.link || '#'}
                        onClick={() => {
                          updateNotifications(notifications.map(item => item.id === n.id ? { ...item, read: true } : item));
                          setShowNotifications(false);
                        }}
                        className={`block px-4 py-3 hover:bg-orange-500/10 transition-colors text-left ${
                          !n.read ? 'bg-orange-500/5' : ''
                        }`}
                      >
                        <p className="text-xs text-on-surface leading-normal font-bold">{n.text}</p>
                        <span className="text-[10px] text-on-surface-variant/80 mt-1 block font-medium">{n.time}</span>
                      </Link>
                    ))
                  )}
                </div>
              </div>
            )}
          </div>
          
          {isAuthenticated && profile ? (
            <div className="relative flex items-center gap-2 pl-2 border-l border-slate-100 dark:border-slate-800">
              <div className="text-right hidden sm:block">
                <p className="text-[11px] font-bold text-slate-800 dark:text-slate-200 leading-tight">
                  {profile?.phone_number ? `${profile.phone_number.slice(0, 7)}...` : 'User'}
                </p>
                <p className="text-[9px] text-slate-500 dark:text-slate-400 font-bold">
                  {profile?.nid_status ? profile.nid_status.toUpperCase() : 'UNVERIFIED'}
                </p>
              </div>
              
              <div 
                className="relative group cursor-pointer" 
                onClick={logout} 
                title="Click to Log Out"
              >
                <img 
                  className="w-9 h-9 rounded-full border border-outline-variant dark:border-slate-800 object-cover group-hover:opacity-75 transition-all" 
                  src={profile?.nid_photo_url || "https://lh3.googleusercontent.com/aida-public/AB6AXuDTqLVAhud7-rJLQtn3WA1UK5FsN0dyhl_f3RaXXfLWLUWvoHs7FGjQkbFuNPBiB7UDPfT_DgGfOdKbcTz4gZO1MiL9ETrT3ffZV3N2S0rEEGHNKUMvif8QdIcoPaDQoiFrJodIg4UiCjzVizHBvgfoPZbdvZtJq9bOq2s-WNTgJsndCRLGq-AgioZSaQf0d4zAC9CQEnP4-CjMTsSSaaH-OOHxdSW5DRKa7bCf9GKhWMGMLXxboo56wA"}
                  alt="Profile" 
                />
                
                {profile?.nid_status === 'verified' ? (
                  <div className="absolute -bottom-1 -right-1 bg-secondary text-white border-2 border-white dark:border-slate-950 rounded-full p-0.5 flex items-center justify-center group-hover:opacity-0 transition-opacity" title="NID Verified">
                    <ShieldCheck className="w-3 h-3" />
                  </div>
                ) : (
                  <div className="absolute -bottom-1 -right-1 bg-red-500 text-white border-2 border-white dark:border-slate-950 rounded-full p-0.5 flex items-center justify-center group-hover:opacity-0 transition-opacity" title="Unverified">
                    <ShieldAlert className="w-3 h-3" />
                  </div>
                )}
                
                <div className="absolute inset-0 bg-red-600/90 rounded-full opacity-0 group-hover:opacity-100 flex items-center justify-center transition-all">
                  <LogOut className="w-4.5 h-4.5 text-white" />
                </div>
              </div>
            </div>
          ) : (
            <button
              onClick={() => setShowAuthModal(true)}
              className="bg-gradient-to-r from-orange-600 to-amber-500 text-white text-xs font-black px-4 py-2 rounded-full shadow-md hover:from-orange-500 hover:to-amber-400 transition-all cursor-pointer"
            >
              Sign In / Register
            </button>
          )}
        </div>
      </nav>

      <AuthModal 
        isOpen={showAuthModal} 
        onClose={() => setShowAuthModal(false)}
        title="Sign in with your mobile number to start matching routes and chatting."
      />

      {/* Main Content Layout */}
      <main className="flex-grow pt-16 pb-20 md:pb-8">
        {children}
      </main>

      {/* Bottom Navigation Bar (Mobile View & Base Layout) */}
      {!isAdmin && (
        <nav className="fixed bottom-0 left-0 w-full z-45 flex justify-around items-center py-2 pb-safe bg-white dark:bg-slate-950 border-t border-outline-variant dark:border-slate-800 shadow-lg md:hidden transition-colors duration-300">
          <Link 
            href="/"
            className={`flex flex-col items-center justify-center transition-all ${
              pathname === '/' 
                ? 'text-primary scale-105' 
                : 'text-on-surface-variant hover:text-primary'
            }`}
          >
            <Home className="w-5 h-5" />
            <span className="text-[10px] font-bold mt-0.5">Home</span>
          </Link>

          <Link 
            href="/match"
            className={`flex flex-col items-center justify-center transition-all ${
              pathname.startsWith('/match') 
                ? 'text-primary scale-105' 
                : 'text-on-surface-variant hover:text-primary'
            }`}
          >
            <Compass className="w-5 h-5" />
            <span className="text-[10px] font-bold mt-0.5">Matching</span>
          </Link>

          <Link 
            href="/chat"
            className={`flex flex-col items-center justify-center transition-all ${
              pathname === '/chat' 
                ? 'text-primary scale-105' 
                : 'text-on-surface-variant hover:text-primary'
            }`}
          >
            <MessageSquare className="w-5 h-5" />
            <span className="text-[10px] font-bold mt-0.5">Messages</span>
          </Link>
        </nav>
      )}

      {/* Desktop sidebar navigation links helper */}
      {!isAdmin && (
        <div className="hidden md:flex fixed top-16 left-0 h-[calc(100vh-64px)] w-48 border-r border-outline-variant bg-surface p-4 flex-col gap-2 transition-colors duration-300">
          <Link 
            href="/"
            className={`flex items-center gap-3 px-3.5 py-2.5 rounded-full text-xs font-black transition-all ${
              pathname === '/' 
                ? 'bg-gradient-to-r from-orange-500/15 to-amber-500/15 text-orange-600 dark:text-orange-400 border border-orange-500/30 shadow-xs' 
                : 'text-on-surface-variant hover:bg-orange-500/10'
            }`}
          >
            <Home className="w-4 h-4 text-orange-500" />
            Home
          </Link>

          <Link 
            href="/match"
            className={`flex items-center gap-3 px-3.5 py-2.5 rounded-full text-xs font-black transition-all ${
              pathname.startsWith('/match') 
                ? 'bg-gradient-to-r from-orange-500/15 to-amber-500/15 text-orange-600 dark:text-orange-400 border border-orange-500/30 shadow-xs' 
                : 'text-on-surface-variant hover:bg-orange-500/10'
            }`}
          >
            <Compass className="w-4 h-4 text-orange-500" />
            Matching
          </Link>

          <Link 
            href="/chat"
            className={`flex items-center gap-3 px-3.5 py-2.5 rounded-full text-xs font-black transition-all ${
              pathname === '/chat' 
                ? 'bg-gradient-to-r from-orange-500/15 to-amber-500/15 text-orange-600 dark:text-orange-400 border border-orange-500/30 shadow-xs' 
                : 'text-on-surface-variant hover:bg-orange-500/10'
            }`}
          >
            <MessageSquare className="w-4 h-4 text-orange-500" />
            Messages
          </Link>
        </div>
      )}
    </div>
  );
}
