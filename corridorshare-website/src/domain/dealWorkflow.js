/** RPC names for escrow / delivery workflow — swap here if migrations rename them. */
export const DEAL_RPCS = Object.freeze({
  lock: 'lock_deal_with_inspection',
  issueOtp: 'issue_delivery_otp',
  release: 'wallet_release',
  refund: 'wallet_refund',
});

export function createLockDealParams({ dealId, amountMinor, inspectionPhotoUrl, idempotencyKey }) {
  return {
    p_deal_id: dealId,
    p_amount_minor: amountMinor,
    p_inspection_photo_url: inspectionPhotoUrl,
    p_idempotency_key: idempotencyKey,
  };
}

export function createIssueOtpParams(dealId) {
  return { p_deal_id: dealId };
}

export function createReleaseParams({ dealId, deliveryOtp, idempotencyKey }) {
  return {
    p_deal_id: dealId,
    p_delivery_otp: deliveryOtp,
    p_idempotency_key: idempotencyKey,
  };
}

export function createRefundParams({ dealId, idempotencyKey }) {
  return {
    p_deal_id: dealId,
    p_idempotency_key: idempotencyKey,
  };
}
