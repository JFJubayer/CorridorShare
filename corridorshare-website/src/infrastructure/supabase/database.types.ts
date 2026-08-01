// Generated-shape contract for supabase/migrations/202608010001_initial_schema.sql.
// Regenerate this file with `supabase gen types typescript --local` after each migration.

export type Json = string | number | boolean | null | { [key: string]: Json | undefined } | Json[];

type Table<Row, Insert, Update = Partial<Insert>> = {
  Row: Row;
  Insert: Insert;
  Update: Update;
  Relationships: [];
};

export type Database = {
  public: {
    Tables: {
      profiles: Table<
        { id: string; phone_number: string | null; full_name: string | null; role: Database['public']['Enums']['profile_role']; nid_status: Database['public']['Enums']['profile_nid_status']; nid_photo_url: string | null; created_at: string; updated_at: string },
        { id: string; phone_number?: string | null; full_name?: string | null; role?: Database['public']['Enums']['profile_role']; nid_status?: Database['public']['Enums']['profile_nid_status']; nid_photo_url?: string | null; created_at?: string; updated_at?: string }
      >;
      wallet_accounts: Table<
        { profile_id: string; available_balance_minor: number; held_balance_minor: number; currency_code: 'BDT'; updated_at: string },
        { profile_id: string; available_balance_minor?: number; held_balance_minor?: number; currency_code?: 'BDT'; updated_at?: string }
      >;
      trips: Table<
        { id: string; traveler_id: string; departure_city: string; destination_city: string; route_path: unknown; travel_time: string; weight_capacity_kg: number; status: Database['public']['Enums']['trip_status']; created_at: string; updated_at: string },
        { id?: string; traveler_id: string; departure_city: string; destination_city: string; route_path: unknown; travel_time: string; weight_capacity_kg: number; status?: Database['public']['Enums']['trip_status']; created_at?: string; updated_at?: string }
      >;
      packages: Table<
        { id: string; sender_id: string; pickup_location: unknown; dropoff_location: unknown; pickup_radius_meters: number; item_description: string; item_type: string | null; weight_kg: number | null; proposed_reward_minor: number; is_premium: boolean; status: Database['public']['Enums']['package_status']; created_at: string; updated_at: string },
        { id?: string; sender_id: string; pickup_location: unknown; dropoff_location: unknown; pickup_radius_meters?: number; item_description: string; item_type?: string | null; weight_kg?: number | null; proposed_reward_minor: number; is_premium?: boolean; status?: Database['public']['Enums']['package_status']; created_at?: string; updated_at?: string }
      >;
      chats_and_deals: Table<
        { id: string; trip_id: string; package_id: string; final_agreed_price_minor: number | null; status: Database['public']['Enums']['deal_status']; deal_locked: boolean; open_box_verified: boolean; inspection_photo_url: string | null; delivery_otp_hash: string | null; locked_at: string | null; completed_at: string | null; created_at: string; updated_at: string },
        { id?: string; trip_id: string; package_id: string; final_agreed_price_minor?: number | null; status?: Database['public']['Enums']['deal_status']; deal_locked?: boolean; open_box_verified?: boolean; inspection_photo_url?: string | null; delivery_otp_hash?: string | null; locked_at?: string | null; completed_at?: string | null; created_at?: string; updated_at?: string }
      >;
      messages: Table<
        { id: string; deal_id: string; sender_id: string; message_text: string | null; image_verification_url: string | null; created_at: string },
        { id?: string; deal_id: string; sender_id: string; message_text?: string | null; image_verification_url?: string | null; created_at?: string }
      >;
      wallet_transactions: Table<
        { id: string; profile_id: string; deal_id: string | null; kind: Database['public']['Enums']['wallet_transaction_kind']; amount_minor: number; idempotency_key: string; description: string | null; created_at: string },
        { id?: string; profile_id: string; deal_id?: string | null; kind: Database['public']['Enums']['wallet_transaction_kind']; amount_minor: number; idempotency_key: string; description?: string | null; created_at?: string }
      >;
    };
    Views: Record<string, never>;
    Functions: {
      current_user_is_admin: { Args: Record<PropertyKey, never>; Returns: boolean };
      admin_set_nid_status: { Args: { p_profile_id: string; p_status: Database['public']['Enums']['profile_nid_status'] }; Returns: Database['public']['Tables']['profiles']['Row'] };
      match_packages_within_corridor: { Args: { traveler_trip_id: string; buffer_distance_meters?: number }; Returns: Array<{ package_id: string; sender_id: string; item_description: string; item_type: string | null; proposed_reward_minor: number; is_premium: boolean; distance_from_corridor: number; is_near_miss: boolean; pickup_lat: number; pickup_lng: number; pickup_radius_meters: number }> };
      lock_deal_with_inspection: { Args: { p_deal_id: string; p_amount_minor: number; p_inspection_photo_url: string; p_idempotency_key: string }; Returns: Database['public']['Tables']['chats_and_deals']['Row'] };
      issue_delivery_otp: { Args: { p_deal_id: string }; Returns: string };
      wallet_release: { Args: { p_deal_id: string; p_delivery_otp: string; p_idempotency_key: string }; Returns: Database['public']['Tables']['chats_and_deals']['Row'] };
      wallet_refund: { Args: { p_deal_id: string; p_idempotency_key: string }; Returns: Database['public']['Tables']['chats_and_deals']['Row'] };
    };
    Enums: {
      profile_role: 'member' | 'admin';
      profile_nid_status: 'unverified' | 'pending' | 'verified' | 'suspended';
      trip_status: 'scheduled' | 'active' | 'completed' | 'cancelled';
      package_status: 'pending' | 'matched' | 'in_transit' | 'delivered' | 'cancelled';
      deal_status: 'negotiating' | 'locked' | 'in_transit' | 'completed' | 'cancelled';
      wallet_transaction_kind: 'credit' | 'hold' | 'release' | 'refund';
    };
    CompositeTypes: Record<string, never>;
  };
};
