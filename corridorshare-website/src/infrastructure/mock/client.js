const DEMO_ADMIN_ID = '11111111-1111-4111-8111-111111111111';
const DEMO_SENDER_ID = '22222222-2222-4222-8222-222222222222';
const DEMO_TRIP_ID = '33333333-3333-4333-8333-333333333333';
const DEMO_PACKAGE_ID = '44444444-4444-4444-8444-444444444444';
const DEMO_DEAL_ID = '55555555-5555-4555-8555-555555555555';

export const DEFAULT_DEMO_PROFILES = Object.freeze([
  {
    id: DEMO_ADMIN_ID,
    phone_number: '+8801712345678',
    full_name: 'Aminul Islam',
    role: 'admin',
    nid_status: 'verified',
    nid_photo_url: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&h=250&q=80',
    created_at: '2026-01-01T00:00:00.000Z',
  },
  {
    id: DEMO_SENDER_ID,
    phone_number: '+8801987654321',
    full_name: 'Nusrat Jahan',
    role: 'member',
    nid_status: 'verified',
    nid_photo_url: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&h=250&q=80',
    created_at: '2026-01-01T00:00:00.000Z',
  },
]);

const DEMO_SEED = Object.freeze({
  cs_profiles: DEFAULT_DEMO_PROFILES,
  cs_wallet_accounts: [
    { profile_id: DEMO_ADMIN_ID, available_balance_minor: 50000, held_balance_minor: 0 },
    { profile_id: DEMO_SENDER_ID, available_balance_minor: 35000, held_balance_minor: 0 },
  ],
  cs_trips: [{
    id: DEMO_TRIP_ID,
    traveler_id: DEMO_ADMIN_ID,
    departure_city: 'Dhaka',
    destination_city: 'Mymensingh',
    route_path: 'LINESTRING(90.399452 23.777176, 90.407438 24.757082)',
    travel_time: '2026-01-10T20:30:00.000Z',
    weight_capacity_kg: 10,
    status: 'scheduled',
    created_at: '2026-01-01T00:00:00.000Z',
  }],
  cs_packages: [{
    id: DEMO_PACKAGE_ID,
    sender_id: DEMO_SENDER_ID,
    pickup_location: 'POINT(90.425539 24.002284)',
    dropoff_location: 'POINT(90.407438 24.757082)',
    pickup_lat: 24.002284,
    pickup_lng: 90.425539,
    pickup_radius_meters: 2000,
    item_description: 'Box of Books (2kg)',
    weight_kg: 2,
    proposed_reward_minor: 25000,
    is_premium: false,
    status: 'pending',
    created_at: '2026-01-01T00:00:00.000Z',
    route_info: 'Dhaka to Mymensingh',
    item_type: 'Box of Books',
    eta: 'Tonight',
  }],
  cs_chats_and_deals: [{
    id: DEMO_DEAL_ID,
    trip_id: DEMO_TRIP_ID,
    package_id: DEMO_PACKAGE_ID,
    final_agreed_price_minor: 25000,
    deal_locked: false,
    open_box_verified: false,
    created_at: '2026-01-01T00:00:00.000Z',
  }],
  cs_messages: [{
    id: '66666666-6666-4666-8666-666666666666',
    deal_id: DEMO_DEAL_ID,
    sender_id: DEMO_ADMIN_ID,
    message_text: "Hi! I'm traveling to Mymensingh by car tonight on N3.",
    created_at: '2026-01-01T19:30:00.000Z',
  }],
  cs_wallet_transactions: [],
});

const TABLE_KEYS = Object.freeze({ chats_and_deals: 'cs_chats_and_deals' });
const messageSubscribers = new Set();
const authSubscribers = new Set();

const clone = (value) => JSON.parse(JSON.stringify(value));
const storageKeyFor = (table) => TABLE_KEYS[table] || `cs_${table}`;

function createId() {
  if (typeof crypto !== 'undefined' && crypto.randomUUID) return crypto.randomUUID();
  return '00000000-0000-4000-8000-000000000000'.replace(/0/g, () => Math.floor(Math.random() * 16).toString(16));
}

function getStorageItem(key, fallback = []) {
  if (typeof window === 'undefined') return clone(fallback);
  const raw = window.localStorage.getItem(key);
  if (raw === null && Object.hasOwn(DEMO_SEED, key)) {
    const seeded = clone(DEMO_SEED[key]);
    window.localStorage.setItem(key, JSON.stringify(seeded));
    return seeded;
  }
  if (raw === null) return clone(fallback);
  try {
    return JSON.parse(raw);
  } catch {
    return clone(fallback);
  }
}

function setStorageItem(key, value) {
  if (typeof window !== 'undefined') window.localStorage.setItem(key, JSON.stringify(value));
}

function getRows(table) {
  return getStorageItem(storageKeyFor(table), []);
}

function setRows(table, rows) {
  setStorageItem(storageKeyFor(table), rows);
}

function currentUser() {
  if (typeof window === 'undefined') return null;
  const id = window.localStorage.getItem('cs_demo_current_user_id');
  if (!id) return null;
  return getRows('profiles').find((profile) => profile.id === id) || null;
}

function notifyAuth() {
  const profile = currentUser();
  const session = profile ? { user: { id: profile.id, phone: profile.phone_number, role: 'authenticated' } } : null;
  authSubscribers.forEach((callback) => callback(profile ? 'SIGNED_IN' : 'SIGNED_OUT', session));
}

function emitMessage(message) {
  messageSubscribers.forEach((subscriber) => {
    if (subscriber.dealId === message.deal_id) subscriber.callback({ ...message });
  });
}

function makeBuilder(table) {
  const state = { filters: [], updateFields: null, ascending: true };
  const filteredRows = () => {
    const rows = getRows(table).filter((row) => state.filters.every(({ column, value }) => row[column] === value));
    return state.orderColumn
      ? rows.toSorted((a, b) => (a[state.orderColumn] > b[state.orderColumn] ? (state.ascending ? 1 : -1) : (state.ascending ? -1 : 1)))
      : rows;
  };
  const executeUpdate = () => {
    const rows = getRows(table);
    const updated = rows.map((row) => state.filters.every(({ column, value }) => row[column] === value)
      ? { ...row, ...state.updateFields }
      : row);
    setRows(table, updated);
    return { data: updated.filter((row) => state.filters.every(({ column, value }) => row[column] === value)), error: null };
  };
  const builder = {
    select() { return builder; },
    order(column, { ascending = true } = {}) { state.orderColumn = column; state.ascending = ascending; return builder; },
    eq(column, value) {
      state.filters.push({ column, value });
      return builder;
    },
    update(fields) { state.updateFields = fields; return builder; },
    insert: async (records) => {
      const additions = (Array.isArray(records) ? records : [records]).map((record) => ({ ...record, id: record.id || createId() }));
      setRows(table, [...getRows(table), ...additions]);
      additions.filter((record) => table === 'messages').forEach(emitMessage);
      return { data: additions, error: null };
    },
    then(resolve, reject) {
      try {
        resolve(state.updateFields ? executeUpdate() : { data: filteredRows(), error: null });
      } catch (error) {
        if (reject) reject(error);
      }
    },
  };
  return builder;
}

export function subscribeToDemoMessages(dealId, callback) {
  const subscriber = { dealId, callback };
  messageSubscribers.add(subscriber);
  return () => messageSubscribers.delete(subscriber);
}

export function resetDemoData() {
  if (typeof window === 'undefined') return;
  Object.entries(DEMO_SEED).forEach(([key, value]) => setStorageItem(key, clone(value)));
  window.localStorage.removeItem('cs_demo_current_user_id');
  notifyAuth();
}

export const mockClient = {
  auth: {
    async getUser() {
      const profile = currentUser();
      return { data: { user: profile ? { id: profile.id, phone: profile.phone_number, role: 'authenticated' } : null }, error: null };
    },
    async signInWithOtp({ phone }) {
      if (typeof window !== 'undefined') window.localStorage.setItem('cs_demo_pending_phone', phone);
      return { data: { message: 'Demo OTP sent' }, error: null };
    },
    async verifyOtp({ phone, token }) {
      if (token !== '123456') return { data: { user: null }, error: new Error('Invalid demo OTP.') };
      const normalizedPhone = phone || (typeof window !== 'undefined' ? window.localStorage.getItem('cs_demo_pending_phone') : null);
      if (!normalizedPhone) return { data: { user: null }, error: new Error('Request an OTP before verifying it.') };
      const profiles = getRows('profiles');
      let profile = profiles.find((item) => item.phone_number === normalizedPhone);
      if (!profile) {
        profile = { id: createId(), phone_number: normalizedPhone, full_name: 'Demo member', role: 'member', nid_status: 'unverified', nid_photo_url: '', created_at: new Date().toISOString() };
        setRows('profiles', [...profiles, profile]);
        setRows('wallet_accounts', [...getRows('wallet_accounts'), { profile_id: profile.id, available_balance_minor: 0, held_balance_minor: 0 }]);
      }
      if (typeof window !== 'undefined') {
        window.localStorage.setItem('cs_demo_current_user_id', profile.id);
        window.localStorage.removeItem('cs_demo_pending_phone');
      }
      notifyAuth();
      return { data: { user: { id: profile.id, phone: profile.phone_number } }, error: null };
    },
    async signOut() {
      if (typeof window !== 'undefined') window.localStorage.removeItem('cs_demo_current_user_id');
      notifyAuth();
      return { error: null };
    },
    onAuthStateChange(callback) {
      authSubscribers.add(callback);
      return { data: { subscription: { unsubscribe: () => authSubscribers.delete(callback) } } };
    },
  },
  from: makeBuilder,
  rpc: async (functionName, params = {}) => {
    if (functionName === 'admin_set_nid_status') {
      const admin = currentUser();
      if (admin?.role !== 'admin') return { data: null, error: new Error('Admin role required.') };
      const profiles = getRows('profiles').map((profile) => profile.id === params.p_profile_id ? { ...profile, nid_status: params.p_status } : profile);
      setRows('profiles', profiles);
      return { data: profiles.find((profile) => profile.id === params.p_profile_id), error: null };
    }
    if (functionName === 'lock_deal_with_inspection') {
      if (!params.p_inspection_photo_url) return { data: null, error: new Error('Inspection photo is required.') };
      if (!Number.isSafeInteger(params.p_amount_minor) || params.p_amount_minor <= 0) return { data: null, error: new Error('A positive deal amount is required.') };
      if (!params.p_idempotency_key) return { data: null, error: new Error('An idempotency key is required.') };
      const existingTransaction = getRows('wallet_transactions').find((transaction) => transaction.idempotency_key === params.p_idempotency_key);
      if (existingTransaction) {
        const existingDeal = getRows('chats_and_deals').find((item) => item.id === params.p_deal_id);
        return { data: existingDeal, error: null };
      }
      const deals = getRows('chats_and_deals');
      const deal = deals.find((item) => item.id === params.p_deal_id);
      if (!deal) return { data: null, error: new Error('Deal not found.') };
      const trip = getRows('trips').find((item) => item.id === deal.trip_id);
      if (trip?.traveler_id !== currentUser()?.id) return { data: null, error: new Error('Only the trip traveler can verify and lock this deal.') };
      const packageRequest = getRows('packages').find((item) => item.id === deal.package_id);
      const accounts = getRows('wallet_accounts');
      const account = accounts.find((item) => item.profile_id === packageRequest.sender_id);
      if (!account || account.available_balance_minor < params.p_amount_minor) return { data: null, error: new Error('Insufficient available wallet balance.') };
      const updatedDeal = { ...deal, final_agreed_price_minor: params.p_amount_minor, inspection_photo_url: params.p_inspection_photo_url, open_box_verified: true, deal_locked: true, status: 'locked' };
      setRows('chats_and_deals', deals.map((item) => item.id === deal.id ? updatedDeal : item));
      setRows('wallet_accounts', accounts.map((item) => item.profile_id === account.profile_id
        ? { ...item, available_balance_minor: item.available_balance_minor - params.p_amount_minor, held_balance_minor: item.held_balance_minor + params.p_amount_minor }
        : item));
      setRows('wallet_transactions', [...getRows('wallet_transactions'), {
        id: createId(),
        profile_id: packageRequest.sender_id,
        deal_id: deal.id,
        kind: 'hold',
        amount_minor: params.p_amount_minor,
        idempotency_key: params.p_idempotency_key,
        created_at: new Date().toISOString(),
      }]);
      return { data: updatedDeal, error: null };
    }
    if (functionName !== 'match_packages_within_corridor') return { data: null, error: new Error(`Unsupported demo RPC: ${functionName}`) };
    const trip = getRows('trips').find((item) => item.id === params.traveler_trip_id);
    if (!trip || trip.traveler_id !== currentUser()?.id) {
      return { data: null, error: new Error('Trip not found or not owned by caller.') };
    }
    const bufferMeters = Number(params.buffer_distance_meters ?? 3000);
    if (!Number.isFinite(bufferMeters) || bufferMeters < 100 || bufferMeters > 50000) {
      return { data: null, error: new Error('Buffer distance must be between 100 and 50000 meters.') };
    }
    return {
      data: getRows('packages').filter((pkg) => pkg.status === 'pending').map((pkg) => ({
        package_id: pkg.id,
        sender_id: pkg.sender_id,
        item_description: pkg.item_description,
        item_type: pkg.item_type || pkg.item_description,
        proposed_reward_minor: pkg.proposed_reward_minor,
        is_premium: pkg.is_premium,
        distance_from_corridor: 120,
        is_near_miss: false,
        pickup_lat: pkg.pickup_lat,
        pickup_lng: pkg.pickup_lng,
        pickup_radius_meters: pkg.pickup_radius_meters,
        route_info: pkg.route_info,
        eta: pkg.eta,
      })),
      error: null,
    };
  },
  channel(name) {
    let messageHandler = null;
    return {
      on(_event, filter, callback) {
        if (filter.table === 'messages') messageHandler = subscribeToDemoMessages(filter.filter?.replace('deal_id=eq.', '') || '', (message) => callback({ new: message }));
        return this;
      },
      subscribe() { return this; },
      unsubscribe() { messageHandler?.(); },
      name,
    };
  },
  removeChannel(channel) { channel?.unsubscribe?.(); },
};
