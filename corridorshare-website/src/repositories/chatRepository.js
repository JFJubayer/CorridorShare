import { isMockDataSource, supabase } from '@/config/supabaseClient';
import { subscribeToDemoMessages } from '@/infrastructure/mock/client';
import {
  DEAL_RPCS,
  createIssueOtpParams,
  createLockDealParams,
  createRefundParams,
  createReleaseParams,
} from '@/domain/dealWorkflow';

const DEAL_TABLE = 'chats_and_deals';

function newIdempotencyKey(prefix) {
  if (typeof crypto !== 'undefined' && crypto.randomUUID) return `${prefix}-${crypto.randomUUID()}`;
  return `${prefix}-${Date.now()}`;
}

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
  async createDeal({ tripId, packageId, finalAgreedPriceMinor = null }) {
    if (!tripId || !packageId) throw new Error('A trip and package are required to open a deal chat.');

    const { data: existing, error: existingError } = await supabase
      .from(DEAL_TABLE)
      .select('*')
      .eq('trip_id', tripId)
      .eq('package_id', packageId);
    if (existingError) throw existingError;
    if (existing?.[0]) return existing[0];

    const payload = {
      trip_id: tripId,
      package_id: packageId,
      status: 'negotiating',
    };
    if (Number.isSafeInteger(finalAgreedPriceMinor) && finalAgreedPriceMinor > 0) {
      payload.final_agreed_price_minor = finalAgreedPriceMinor;
    }
    const { data, error } = await supabase.from(DEAL_TABLE).insert(payload).select('*');
    if (error) throw error;
    return data?.[0] ?? null;
  },
  async createMessage({ dealId, senderId, messageText, imageVerificationUrl = null }) {
    if (!senderId) throw new Error('Sign in before sending a message.');
    const { data, error } = await supabase.from('messages').insert({
      deal_id: dealId,
      sender_id: senderId,
      message_text: messageText || null,
      image_verification_url: imageVerificationUrl,
    }).select('*');
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
    if (!Number.isSafeInteger(amountMinor) || amountMinor <= 0) {
      throw new Error('Lock uses the agreed reward. Set a positive agreed amount before locking.');
    }
    const { data, error } = await supabase.rpc(DEAL_RPCS.lock, createLockDealParams({
      dealId,
      amountMinor,
      inspectionPhotoUrl,
      idempotencyKey: idempotencyKey || newIdempotencyKey('lock'),
    }));
    if (error) throw error;
    return data;
  },
  async issueDeliveryOtp(dealId) {
    const { data, error } = await supabase.rpc(DEAL_RPCS.issueOtp, createIssueOtpParams(dealId));
    if (error) throw error;
    return data;
  },
  async releaseDeal({ dealId, deliveryOtp, idempotencyKey }) {
    if (!deliveryOtp || String(deliveryOtp).trim().length < 4) {
      throw new Error('Enter the delivery OTP from the sender before releasing escrow.');
    }
    const { data, error } = await supabase.rpc(DEAL_RPCS.release, createReleaseParams({
      dealId,
      deliveryOtp: String(deliveryOtp).trim(),
      idempotencyKey: idempotencyKey || newIdempotencyKey('release'),
    }));
    if (error) throw error;
    return data;
  },
  async refundDeal({ dealId, idempotencyKey }) {
    const { data, error } = await supabase.rpc(DEAL_RPCS.refund, createRefundParams({
      dealId,
      idempotencyKey: idempotencyKey || newIdempotencyKey('refund'),
    }));
    if (error) throw error;
    return data;
  },
};
