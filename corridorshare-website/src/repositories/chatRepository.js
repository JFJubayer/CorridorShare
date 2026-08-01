import { isMockDataSource, supabase } from '@/config/supabaseClient';
import { subscribeToDemoMessages } from '@/infrastructure/mock/client';

const DEAL_TABLE = 'chats_and_deals';

async function listMessages(dealId) {
  const { data, error } = await supabase.from('messages').select('*').eq('deal_id', dealId).order('created_at', { ascending: true });
  if (error) throw error;
  return data ?? [];
}

async function withMessages(deal) {
  if (!deal) return null;
  return { ...deal, messages: await listMessages(deal.id) };
}

export const chatRepository = {
  async list() {
    const { data, error } = await supabase.from(DEAL_TABLE).select('*').order('created_at', { ascending: false });
    if (error) throw error;
    return Promise.all((data ?? []).map(withMessages));
  },
  async findById(id) {
    const { data, error } = await supabase.from(DEAL_TABLE).select('*').eq('id', id);
    if (error) throw error;
    return withMessages(data?.[0] ?? null);
  },
  listMessages,
  async createMessage({ dealId, senderId, messageText, imageVerificationUrl = null }) {
    if (!senderId) throw new Error('Sign in before sending a message.');
    const { data, error } = await supabase.from('messages').insert({
      deal_id: dealId,
      sender_id: senderId,
      message_text: messageText || null,
      image_verification_url: imageVerificationUrl,
    });
    if (error) throw error;
    return data?.[0] ?? null;
  },
  subscribeToMessages(dealId, onMessage) {
    if (isMockDataSource) return subscribeToDemoMessages(dealId, onMessage);
    const channel = supabase
      .channel(`deal-messages-${dealId}`)
      .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'messages', filter: `deal_id=eq.${dealId}` }, (payload) => onMessage(payload.new))
      .subscribe();
    return () => supabase.removeChannel(channel);
  },
  async lockDeal({ dealId, amountMinor, inspectionPhotoUrl, idempotencyKey }) {
    if (!Number.isSafeInteger(amountMinor) || amountMinor <= 0) throw new Error('Deal amount must be a positive whole number of poisha.');
    const { data, error } = await supabase.rpc('lock_deal_with_inspection', {
      p_deal_id: dealId,
      p_amount_minor: amountMinor,
      p_inspection_photo_url: inspectionPhotoUrl,
      p_idempotency_key: idempotencyKey,
    });
    if (error) throw error;
    return data;
  },
};
