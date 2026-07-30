-- Enable PostGIS extension for spatial routing and geography handling
CREATE EXTENSION IF NOT EXISTS postgis;

-- Create Custom Enumerated Types
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'profile_nid_status') THEN
        CREATE TYPE profile_nid_status AS ENUM ('unverified', 'pending', 'verified', 'suspended');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'trip_status_type') THEN
        CREATE TYPE trip_status_type AS ENUM ('scheduled', 'active', 'completed', 'cancelled');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'package_status_type') THEN
        CREATE TYPE package_status_type AS ENUM ('pending', 'matched', 'in_transit', 'delivered', 'cancelled');
    END IF;
END$$;

-- 1. Profiles Table
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    phone_number TEXT UNIQUE NOT NULL,
    nid_status profile_nid_status DEFAULT 'unverified',
    nid_photo_url TEXT,
    wallet_balance NUMERIC(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT balance_floor CHECK (wallet_balance >= -50.00) -- Allows a small negative buffer for processing fees before hard-lock
);

-- 2. Trips (Traveler Itineraries) Table
CREATE TABLE IF NOT EXISTS public.trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    traveler_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    departure_city TEXT NOT NULL,
    destination_city TEXT NOT NULL,
    route_path GEOMETRY(LineString, 4326) NOT NULL, -- Spatial tracking corridor
    travel_time TIMESTAMP WITH TIME ZONE NOT NULL,
    weight_capacity_kg NUMERIC(5,2) NOT NULL,
    status trip_status_type DEFAULT 'scheduled',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Packages (Sender Requests) Table
CREATE TABLE IF NOT EXISTS public.packages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    pickup_location GEOMETRY(Point, 4326) NOT NULL,
    dropoff_location GEOMETRY(Point, 4326) NOT NULL,
    pickup_radius_meters INTEGER DEFAULT 2000,
    item_description TEXT NOT NULL,
    proposed_reward NUMERIC(10,2) NOT NULL,
    is_premium BOOLEAN DEFAULT false,
    status package_status_type DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Chats & Active Platform Deals Table
CREATE TABLE IF NOT EXISTS public.chats_and_deals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
    package_id UUID NOT NULL REFERENCES public.packages(id) ON DELETE CASCADE,
    final_agreed_price NUMERIC(10,2),
    deal_locked BOOLEAN DEFAULT false,
    open_box_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(trip_id, package_id)
);

-- 5. Real-Time Messages Table
CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    deal_id UUID NOT NULL REFERENCES public.chats_and_deals(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES public.profiles(id),
    message_text TEXT,
    image_verification_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Spatial GIST Indexing for Real-Time Corridor Geofence Calculations
CREATE INDEX IF NOT EXISTS idx_trips_route_path ON public.trips USING GIST(route_path);
CREATE INDEX IF NOT EXISTS idx_packages_pickup ON public.packages USING GIST(pickup_location);

-- ENABLE ROW LEVEL SECURITY (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chats_and_deals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- RLS Policy Definitions
DO $$
BEGIN
    DROP POLICY IF EXISTS "Profiles are readable by authenticated users." ON public.profiles;
    CREATE POLICY "Profiles are readable by authenticated users." ON public.profiles 
        FOR SELECT USING (auth.role() = 'authenticated');

    DROP POLICY IF EXISTS "Users can update their own profile." ON public.profiles;
    CREATE POLICY "Users can update their own profile." ON public.profiles 
        FOR UPDATE USING (auth.uid() = id);

    DROP POLICY IF EXISTS "Trips are visible to all authenticated members." ON public.trips;
    CREATE POLICY "Trips are visible to all authenticated members." ON public.trips 
        FOR SELECT USING (auth.role() = 'authenticated');

    DROP POLICY IF EXISTS "Travelers can insert their own trips." ON public.trips;
    CREATE POLICY "Travelers can insert their own trips." ON public.trips 
        FOR INSERT WITH CHECK (auth.uid() = traveler_id);

    DROP POLICY IF EXISTS "Packages are visible to everyone." ON public.packages;
    CREATE POLICY "Packages are visible to everyone." ON public.packages 
        FOR SELECT USING (auth.role() = 'authenticated');

    DROP POLICY IF EXISTS "Senders can create package requests." ON public.packages;
    CREATE POLICY "Senders can create package requests." ON public.packages 
        FOR INSERT WITH CHECK (auth.uid() = sender_id);

    DROP POLICY IF EXISTS "Deal visibility bounded to participants." ON public.chats_and_deals;
    CREATE POLICY "Deal visibility bounded to participants." ON public.chats_and_deals 
        FOR SELECT USING (
            auth.uid() IN (SELECT p.sender_id FROM public.packages p WHERE p.id = package_id) OR 
            auth.uid() IN (SELECT t.traveler_id FROM public.trips t WHERE t.id = trip_id)
        );

    DROP POLICY IF EXISTS "Message insert/select bounded to participants." ON public.messages;
    CREATE POLICY "Message insert/select bounded to participants." ON public.messages
        FOR ALL USING (
            auth.uid() IN (
                SELECT p.sender_id FROM public.chats_and_deals c 
                JOIN public.packages p ON c.package_id = p.id 
                WHERE c.id = deal_id
            ) OR 
            auth.uid() IN (
                SELECT t.traveler_id FROM public.chats_and_deals c 
                JOIN public.trips t ON c.trip_id = t.id 
                WHERE c.id = deal_id
            )
        );
END$$;

-- 3. ADVANCED POSTGIS CORRIDOR SEARCH ENGINE (STORED PROCEDURE)
CREATE OR REPLACE FUNCTION public.match_packages_within_corridor(
    traveler_trip_id UUID,
    buffer_distance_meters FLOAT DEFAULT 3000.0
)
RETURNS TABLE (
    package_id UUID,
    sender_id UUID,
    item_description TEXT,
    proposed_reward NUMERIC,
    is_premium BOOLEAN,
    distance_from_corridor FLOAT,
    is_near_miss BOOLEAN,
    pickup_lat FLOAT,
    pickup_lng FLOAT,
    pickup_radius_meters INTEGER
) AS $$
DECLARE
    traveler_route GEOMETRY;
BEGIN
    -- Extract the spatial trajectory LineString of the trip
    SELECT route_path INTO traveler_route FROM public.trips WHERE id = traveler_trip_id;

    RETURN QUERY
    SELECT 
        p.id,
        p.sender_id,
        p.item_description,
        p.proposed_reward,
        p.is_premium,
        ST_Distance(p.pickup_location::geography, traveler_route::geography) AS distance_from_corridor,
        CASE 
            WHEN ST_Distance(p.pickup_location::geography, traveler_route::geography) > p.pickup_radius_meters THEN TRUE
            ELSE FALSE
        END AS is_near_miss,
        ST_Y(p.pickup_location) AS pickup_lat,
        ST_X(p.pickup_location) AS pickup_lng,
        p.pickup_radius_meters
    FROM 
        public.packages p
    WHERE 
        p.status = 'pending'
        AND ST_DWithin(p.pickup_location::geography, traveler_route::geography, buffer_distance_meters)
    ORDER BY 
        p.is_premium DESC, distance_from_corridor ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
