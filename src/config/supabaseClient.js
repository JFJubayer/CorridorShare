import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || '';
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '';

// Detect if we should use a mock client for local preview/demo
const useMock = !supabaseUrl || supabaseUrl.includes('placeholder') || !supabaseAnonKey || supabaseAnonKey.includes('placeholder');

if (useMock) {
  console.warn("Supabase credentials not configured. Falling back to high-fidelity LocalStorage Mock database.");
}

// ----------------------------------------------------
// PRISTINE DEFAULT DEMO PROFILES
// ----------------------------------------------------
export const DEFAULT_DEMO_PROFILES = [
  {
    id: '11111111-1111-1111-1111-111111111111',
    phone_number: '+8801712345678',
    nid_status: 'verified',
    nid_photo_url: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&h=250&q=80',
    wallet_balance: 500.00,
    created_at: new Date().toISOString(),
  },
  {
    id: '22222222-2222-2222-2222-222222222222',
    phone_number: '+8801987654321',
    nid_status: 'verified',
    nid_photo_url: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&h=250&q=80',
    wallet_balance: 350.00,
    created_at: new Date().toISOString(),
  }
];

// Helper to get/set localStorage items
const getStorageItem = (key, defaultVal) => {
  if (typeof window === 'undefined') return defaultVal;
  const val = localStorage.getItem(key);
  if (!val && key === 'cs_profiles') {
    localStorage.setItem('cs_profiles', JSON.stringify(DEFAULT_DEMO_PROFILES));
    return DEFAULT_DEMO_PROFILES;
  }
  if (val) {
    try {
      const parsed = JSON.parse(val);
      if (key === 'cs_profiles' && Array.isArray(parsed) && parsed.length === 0) {
        localStorage.setItem('cs_profiles', JSON.stringify(DEFAULT_DEMO_PROFILES));
        return DEFAULT_DEMO_PROFILES;
      }
      return parsed;
    } catch {
      return defaultVal;
    }
  }
  return defaultVal;
};

const setStorageItem = (key, val) => {
  if (typeof window === 'undefined') return;
  localStorage.setItem(key, JSON.stringify(val));
};

// Seed initial clean mock data
const initializeMockData = () => {
  if (typeof window === 'undefined') return;
  
  setStorageItem('cs_profiles', DEFAULT_DEMO_PROFILES);

  setStorageItem('cs_trips', [
    {
      id: 'trip-1',
      traveler_id: '11111111-1111-1111-1111-111111111111',
      departure_city: 'Dhaka',
      destination_city: 'Mymensingh',
      route_path: [[23.777176, 90.399452], [24.002284, 90.425539], [24.385552, 90.412458], [24.757082, 90.407438]],
      travel_time: 'Tonight 8:30 PM',
      weight_capacity_kg: 10.0,
      status: 'scheduled',
      created_at: new Date().toISOString(),
      traveler_name: 'Aminul Islam',
      traveler_rating: '4.9 ★',
      traveler_avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&h=250&q=80'
    }
  ]);

  setStorageItem('cs_packages', [
    {
      id: 'CS-9821',
      sender_id: '22222222-2222-2222-2222-222222222222',
      pickup_lat: 24.002284,
      pickup_lng: 90.425539,
      pickup_radius_meters: 2000,
      item_description: 'Small Document Envelope',
      proposed_reward: 150.00,
      is_premium: false,
      status: 'pending',
      created_at: new Date().toISOString(),
      route_info: 'Dhaka to Mymensingh',
      item_type: 'Small Document',
      eta: 'Today'
    },
    {
      id: 'CS-5510',
      sender_id: '22222222-2222-2222-2222-222222222222',
      pickup_lat: 24.717082,
      pickup_lng: 90.497438,
      pickup_radius_meters: 1500,
      item_description: 'Box of Books (2kg)',
      proposed_reward: 250.00,
      is_premium: false,
      status: 'pending',
      created_at: new Date().toISOString(),
      route_info: 'Dhaka to Mymensingh',
      item_type: 'Box of Books',
      eta: 'Tonight'
    }
  ]);

  setStorageItem('cs_chats', [
    {
      id: 'deal-1',
      trip_id: 'trip-1',
      package_id: 'CS-5510',
      final_agreed_price: 250.00,
      deal_locked: false,
      open_box_verified: false,
      created_at: new Date().toISOString(),
      messages: [
        {
          id: 'm1',
          sender_id: '11111111-1111-1111-1111-111111111111',
          message_text: "Hi! I'm traveling to Mymensingh by car tonight on N3. I have trunk space for packages.",
          created_at: new Date(Date.now() - 3600000).toISOString()
        },
        {
          id: 'm2',
          sender_id: '22222222-2222-2222-2222-222222222222',
          message_text: "Great! It's a box of books (2kg). Surcharge of 250 BDT set in escrow.",
          created_at: new Date(Date.now() - 1800000).toISOString()
        }
      ]
    }
  ]);
};

initializeMockData();

// Build custom LocalStorage mock client mimicking Supabase syntax
const mockClient = {
  auth: {
    getUser: async () => {
      if (typeof window === 'undefined') return { data: { user: null }, error: null };
      const currentUserId = localStorage.getItem('cs_current_user_id') || '11111111-1111-1111-1111-111111111111';
      const profiles = getStorageItem('cs_profiles', []);
      const userProfile = profiles.find(p => p.id === currentUserId);
      if (!userProfile) return { data: { user: null }, error: null };
      return {
        data: {
          user: {
            id: userProfile.id,
            phone: userProfile.phone_number,
            role: 'authenticated'
          }
        },
        error: null
      };
    },
    signUp: async ({ phone }) => {
      const id = `user-${Math.random().toString(36).substr(2, 9)}`;
      const profiles = getStorageItem('cs_profiles', []);
      const newProfile = {
        id,
        phone_number: phone,
        nid_status: 'verified',
        nid_photo_url: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&h=250&q=80',
        wallet_balance: 500.00,
        created_at: new Date().toISOString()
      };
      profiles.push(newProfile);
      setStorageItem('cs_profiles', profiles);
      localStorage.setItem('cs_current_user_id', id);
      return { data: { user: { id, phone } }, error: null };
    },
    signInWithOtp: async ({ phone }) => {
      const profiles = getStorageItem('cs_profiles', []);
      let userProfile = profiles.find(p => p.phone_number === phone);
      if (!userProfile) {
        userProfile = {
          id: `user-${Math.random().toString(36).substr(2, 9)}`,
          phone_number: phone,
          nid_status: 'verified',
          nid_photo_url: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&h=250&q=80',
          wallet_balance: 500.00,
          created_at: new Date().toISOString()
        };
        profiles.push(userProfile);
        setStorageItem('cs_profiles', profiles);
      }
      localStorage.setItem('cs_current_user_id', userProfile.id);
      return { data: { message: "OTP sent successfully" }, error: null };
    },
    signOut: async () => {
      localStorage.removeItem('cs_current_user_id');
      return { error: null };
    },
    onAuthStateChange: (callback) => {
      if (typeof window !== 'undefined') {
        const id = localStorage.getItem('cs_current_user_id') || '11111111-1111-1111-1111-111111111111';
        callback('SIGNED_IN', { id, role: 'authenticated' });
      }
      return { data: { subscription: { unsubscribe: () => {} } } };
    }
  },

  from: (table) => {
    const key = `cs_${table}`;
    let data = getStorageItem(key, []);

    const builder = {
      select: (cols) => builder,
      insert: async (records) => {
        const currentData = getStorageItem(key, []);
        const toAdd = Array.isArray(records) ? records : [records];
        const updated = [...toAdd, ...currentData];
        setStorageItem(key, updated);
        return { data: updated, error: null };
      },
      update: (fields) => {
        builder._updateFields = fields;
        return builder;
      },
      eq: (col, val) => {
        builder._filterCol = col;
        builder._filterVal = val;
        if (builder._updateFields) {
          const currentData = getStorageItem(key, []);
          const updated = currentData.map(item => {
            if (item[col] === val) {
              return { ...item, ...builder._updateFields };
            }
            return item;
          });
          setStorageItem(key, updated);
          return Promise.resolve({ data: updated, error: null });
        }
        return builder;
      },
      then: (resolve) => {
        let result = getStorageItem(key, []);
        if (builder._filterCol && builder._filterVal) {
          result = result.filter(item => item[builder._filterCol] === builder._filterVal);
        }
        resolve({ data: result, error: null });
      }
    };

    return builder;
  },

  rpc: async (functionName, params) => {
    if (functionName === 'match_packages_within_corridor') {
      const packages = getStorageItem('cs_packages', []);
      const matched = packages.map((pkg, idx) => ({
        package_id: pkg.id,
        item_description: pkg.item_description,
        item_type: pkg.item_type || pkg.item_description,
        proposed_reward: pkg.proposed_reward,
        distance_from_corridor: idx === 1 ? 480.0 : 120.0,
        is_near_miss: idx === 1,
        is_premium: pkg.is_premium,
        pickup_lat: pkg.pickup_lat,
        pickup_lng: pkg.pickup_lng,
        sender_id: pkg.sender_id,
        route_info: pkg.route_info,
        eta: pkg.eta
      }));
      return { data: matched, error: null };
    }
    return { data: [], error: null };
  }
};

export const supabase = useMock ? mockClient : createClient(supabaseUrl, supabaseAnonKey);
