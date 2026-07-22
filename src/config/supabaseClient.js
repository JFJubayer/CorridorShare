import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || '';
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '';

// Detect if we should use a mock client for local preview/demo
const useMock = !supabaseUrl || supabaseUrl.includes('placeholder') || !supabaseAnonKey || supabaseAnonKey.includes('placeholder');

if (useMock) {
  console.warn("Supabase credentials not configured. Falling back to high-fidelity LocalStorage Mock database.");
}

export const DEFAULT_DEMO_PROFILES = [
  {
    id: '11111111-1111-1111-1111-111111111111',
    phone_number: '+8801712345678',
    nid_status: 'pending',
    nid_photo_url: 'https://images.unsplash.com/photo-1554774853-aae0a22c8aa4?auto=format&fit=crop&w=400&h=250&q=80',
    wallet_balance: 40.00,
    created_at: new Date().toISOString(),
  },
  {
    id: '22222222-2222-2222-2222-222222222222',
    phone_number: '+8801987654321',
    nid_status: 'pending',
    nid_photo_url: 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&w=400&h=250&q=80',
    wallet_balance: 150.00,
    created_at: new Date().toISOString(),
  },
  {
    id: '33333333-3333-3333-3333-333333333333',
    phone_number: '+8801811223344',
    nid_status: 'verified',
    nid_photo_url: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&h=250&q=80',
    wallet_balance: 500.00,
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
    } catch (e) {
      return defaultVal;
    }
  }
  return defaultVal;
};

const setStorageItem = (key, val) => {
  if (typeof window === 'undefined') return;
  localStorage.setItem(key, JSON.stringify(val));
};

// Seed initial mock data if not exists
const initializeMockData = () => {
  if (typeof window === 'undefined') return;
  
  const existingProfiles = localStorage.getItem('cs_profiles');
  if (!existingProfiles || JSON.parse(existingProfiles || '[]').length === 0) {
    setStorageItem('cs_profiles', DEFAULT_DEMO_PROFILES);
  }

  if (!localStorage.getItem('cs_trips')) {
    setStorageItem('cs_trips', [
      {
        id: 'trip-1',
        traveler_id: '11111111-1111-1111-1111-111111111111',
        departure_city: 'Dhaka',
        destination_city: 'Mymensingh',
        route_path: [[23.777176, 90.399452], [24.002284, 90.425539], [24.385552, 90.412458], [24.757082, 90.407438]], // Coordinates representing highway
        travel_time: new Date(Date.now() + 8 * 3600 * 1000).toISOString(), // 8 hours from now
        weight_capacity_kg: 10.0,
        status: 'scheduled',
        created_at: new Date().toISOString(),
        traveler_name: 'Aminul Islam',
        traveler_rating: '4.9 ★',
        traveler_avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAhLpAKNv99no2P8iOjq6XpvY_uoUVwKZHNhv85Ksqg3MbfCqb8T03x9tFK3JRmgWTpNbBXfxZXZ3FbOiYqIbKwzu62dv5D5VyBLtMnN4upOfU-G6C7Zqq7Iv6WuoNPrXHbY2ymUOKCnWCHQHHSkJ4m9p1U5SZ2lZeE_VLEaU4C1b2_tZVMg9nNOZxH0uajaN_sWPQ8KVj4tUirjp_CWF79vWE0xMdVDMoWeZFcxheU7OkQPezFLgxgxA'
      },
      {
        id: 'trip-2',
        traveler_id: '22222222-2222-2222-2222-222222222222',
        departure_city: 'Dhaka',
        destination_city: 'Sherpur',
        route_path: [[23.777176, 90.399452], [24.757082, 90.407438], [25.018933, 90.017513]],
        travel_time: new Date(Date.now() + 2 * 3600 * 1000).toISOString(),
        weight_capacity_kg: 15.0,
        status: 'scheduled',
        created_at: new Date().toISOString(),
        traveler_name: 'Sarah Ahmed',
        traveler_rating: '4.7 ★',
        traveler_avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBqoYW7buuuGxKmU2jZFcppWrGCJqLnt8UMU5LQa0Z7DVd5jjf-VPOfCJjbonJ_ZEMWed7Kf5GXpQZcKgJmngU5RpVAqg7Nq4YEaaulhzsCOXeY32HUzuYzMNmQPvZvn1I4cGOLgdze4K6DRfPRSTdBUz-NcBNLGroP4oPihJ9dhqOn42CJmdynbAibhgc6kAOEL0yCbAQ90QzY4qgOGzOws5N_clT13ZtwUZTSH4JR_zzVjBUCgv7kQw'
      }
    ]);
  }

  if (!localStorage.getItem('cs_packages')) {
    setStorageItem('cs_packages', [
      {
        id: 'CS-9821',
        sender_id: '22222222-2222-2222-2222-222222222222',
        pickup_lat: 24.002284,
        pickup_lng: 90.425539, // Gazipur (intersects highway)
        pickup_radius_meters: 2000,
        item_description: 'Small Document Envelope',
        proposed_reward: 120.00,
        is_premium: false,
        status: 'pending',
        created_at: new Date().toISOString(),
        route_info: 'Dhaka to Chittagong',
        item_type: 'Small Document',
        eta: 'Today'
      },
      {
        id: 'CS-7742',
        sender_id: '11111111-1111-1111-1111-111111111111',
        pickup_lat: 24.385552,
        pickup_lng: 90.412458, // Bhaluka (intersects highway)
        pickup_radius_meters: 1000,
        item_description: 'Electronics & Spare Parts (2kg)',
        proposed_reward: 350.00,
        is_premium: true,
        status: 'pending',
        created_at: new Date().toISOString(),
        route_info: 'Sylhet to Dhaka',
        item_type: 'Electronics (2kg)',
        eta: 'Match Date: May 12'
      },
      {
        id: 'CS-5510',
        sender_id: '22222222-2222-2222-2222-222222222222',
        pickup_lat: 24.717082,
        pickup_lng: 90.497438, // 500m outside route path (detour test case)
        pickup_radius_meters: 1500,
        item_description: 'Box of Books',
        proposed_reward: 200.00,
        is_premium: false,
        status: 'pending',
        created_at: new Date().toISOString(),
        route_info: 'Dhaka to Mymensingh',
        item_type: 'Box of Books',
        eta: 'Tonight'
      }
    ]);
  }

  if (!localStorage.getItem('cs_chats')) {
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
            message_text: "Hi! I'm heading to Mymensingh by car. I have space for a small/medium box in the trunk.",
            created_at: new Date(Date.now() - 3600000).toISOString()
          },
          {
            id: 'm2',
            sender_id: '22222222-2222-2222-2222-222222222222',
            message_text: "Great. It's a box of books, about 2kg. Can you do 200 BDT?",
            created_at: new Date(Date.now() - 1800000).toISOString()
          },
          {
            id: 'm3',
            sender_id: '11111111-1111-1111-1111-111111111111',
            message_text: "I'm taking the highway, so 250 BDT would be fairer for the door-to-door effort. Is that okay?",
            created_at: new Date(Date.now() - 600000).toISOString()
          }
        ]
      },
      {
        id: 'deal-2',
        trip_id: 'trip-2',
        package_id: 'CS-9821',
        final_agreed_price: 120.00,
        deal_locked: true,
        open_box_verified: true,
        created_at: new Date(Date.now() - 86400000).toISOString(), // 1 day ago
        messages: [
          {
            id: 'm4',
            sender_id: '22222222-2222-2222-2222-222222222222',
            message_text: "Hey Marcus, will you be passing Gazipur bypass tomorrow morning?",
            created_at: new Date(Date.now() - 90000000).toISOString()
          },
          {
            id: 'm5',
            sender_id: '11111111-1111-1111-1111-111111111111',
            message_text: "Yes, I will reach Gazipur by 9:30 AM. I can pick up the document envelope there.",
            created_at: new Date(Date.now() - 88000000).toISOString()
          },
          {
            id: 'm6',
            sender_id: '22222222-2222-2222-2222-222222222222',
            message_text: "Sounds perfect. Photo proof uploaded and deal locked! See you tomorrow.",
            created_at: new Date(Date.now() - 86400000).toISOString()
          }
        ]
      }
    ]);
  }
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
    signUp: async ({ phone, password }) => {
      const id = Math.random().toString(36).substr(2, 9);
      const profiles = getStorageItem('cs_profiles', []);
      const newProfile = {
        id,
        phone_number: phone,
        nid_status: 'unverified',
        nid_photo_url: '',
        wallet_balance: 0.00,
        created_at: new Date().toISOString()
      };
      profiles.push(newProfile);
      setStorageItem('cs_profiles', profiles);
      localStorage.setItem('cs_current_user_id', id);
      return { data: { user: { id, phone } }, error: null };
    },
    signInWithOtp: async ({ phone }) => {
      // Return success, mock verification code
      const profiles = getStorageItem('cs_profiles', []);
      let userProfile = profiles.find(p => p.phone_number === phone);
      if (!userProfile) {
        userProfile = {
          id: Math.random().toString(36).substr(2, 9),
          phone_number: phone,
          nid_status: 'unverified',
          nid_photo_url: '',
          wallet_balance: 0.00,
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
      // Mock subscription handler, call once initially
      if (typeof window !== 'undefined') {
        const id = localStorage.getItem('cs_current_user_id') || '11111111-1111-1111-1111-111111111111';
        callback('SIGNED_IN', { id, role: 'authenticated' });
      }
      return { data: { subscription: { unsubscribe: () => {} } } };
    }
  },

  from: (table) => {
    const key = `cs_${table}`;
    const filters = [];
    let pendingUpdate = null;
    let pendingDelete = false;

    const builder = {
      select: (fields) => builder,
      eq: (column, value) => {
        filters.push((item) => item[column] === value);
        return builder;
      },
      neq: (column, value) => {
        filters.push((item) => item[column] !== value);
        return builder;
      },
      order: (column, { ascending = true } = {}) => builder,
      insert: async (records) => {
        const data = getStorageItem(key, []);
        const recordArray = Array.isArray(records) ? records : [records];
        const newRecords = recordArray.map(r => ({
          id: r.id || Math.random().toString(36).substr(2, 9),
          created_at: new Date().toISOString(),
          ...r
        }));
        setStorageItem(key, [...data, ...newRecords]);
        return { data: newRecords, error: null };
      },
      update: (changes) => {
        pendingUpdate = changes;
        return builder;
      },
      delete: () => {
        pendingDelete = true;
        return builder;
      },
      then: (resolve) => {
        let data = getStorageItem(key, []);
        filters.forEach(filterFn => {
          data = data.filter(filterFn);
        });

        if (pendingUpdate) {
          const allRecords = getStorageItem(key, []);
          const matchedIds = new Set(data.map(d => d.id));
          const updatedRecords = [];
          const newAllRecords = allRecords.map(item => {
            if (matchedIds.has(item.id)) {
              const updated = { ...item, ...pendingUpdate };
              updatedRecords.push(updated);
              return updated;
            }
            return item;
          });
          setStorageItem(key, newAllRecords);
          resolve({ data: updatedRecords, error: null });
        } else if (pendingDelete) {
          const allRecords = getStorageItem(key, []);
          const matchedIds = new Set(data.map(d => d.id));
          const newAllRecords = allRecords.filter(item => !matchedIds.has(item.id));
          setStorageItem(key, newAllRecords);
          resolve({ data: data, error: null });
        } else {
          resolve({ data, error: null });
        }
      }
    };

    return builder;
  },

  rpc: async (funcName, args) => {
    if (funcName === 'match_packages_within_corridor') {
      const packages = getStorageItem('cs_packages', []);
      const trips = getStorageItem('cs_trips', []);
      const trip = trips.find(t => t.id === args.traveler_trip_id);
      
      if (!trip) return { data: [], error: null };
      
      // Calculate distances for the mock
      // Gazipur intersects, Bhaluka intersects, Books Box is near miss (500m)
      const results = packages
        .filter(p => p.status === 'pending')
        .map(p => {
          let distance = 1000;
          let isNearMiss = false;
          
          if (p.id === 'CS-9821') {
            distance = 800; // Gazipur
          } else if (p.id === 'CS-7742') {
            distance = 450; // Bhaluka
          } else if (p.id === 'CS-5510') {
            distance = 2500; // Mymensingh outskirts
            isNearMiss = true;
          }
          
          return {
            package_id: p.id,
            sender_id: p.sender_id,
            item_description: p.item_description,
            proposed_reward: p.proposed_reward,
            is_premium: p.is_premium,
            distance_from_corridor: distance,
            is_near_miss: isNearMiss,
            item_type: p.item_type,
            eta: p.eta,
            route_info: p.route_info,
            pickup_lat: p.pickup_lat,
            pickup_lng: p.pickup_lng,
            pickup_radius_meters: p.pickup_radius_meters
          };
        });
        
      return { data: results, error: null };
    }
    return { data: [], error: null };
  },

  storage: {
    from: (bucket) => ({
      upload: async (path, file) => {
        // Return a mock URL
        const mockUrl = `https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&w=400&q=80`;
        return { data: { path, fullPath: mockUrl }, error: null };
      },
      getPublicUrl: (path) => ({
        data: { publicUrl: `https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&w=400&q=80` }
      })
    })
  },

  channel: (name) => {
    const mockChannel = {
      on: (event, filter, callback) => {
        return mockChannel;
      },
      subscribe: () => {
        return mockChannel;
      }
    };
    return mockChannel;
  },

  removeChannel: (channel) => {
    // No-op mock cleanup
    return { error: null };
  }
};

export const supabase = useMock ? mockClient : createClient(supabaseUrl, supabaseAnonKey);
