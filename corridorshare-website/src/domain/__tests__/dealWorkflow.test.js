import { describe, expect, it } from 'vitest';
import {
  DEAL_RPCS,
  createIssueOtpParams,
  createLockDealParams,
  createRefundParams,
  createReleaseParams,
} from '../dealWorkflow';

describe('dealWorkflow RPC contracts', () => {
  it('keeps swap-friendly RPC names', () => {
    expect(DEAL_RPCS.lock).toBe('lock_deal_with_inspection');
    expect(DEAL_RPCS.issueOtp).toBe('issue_delivery_otp');
    expect(DEAL_RPCS.release).toBe('wallet_release');
    expect(DEAL_RPCS.refund).toBe('wallet_refund');
  });

  it('builds RPC argument objects', () => {
    expect(createLockDealParams({
      dealId: 'd1',
      amountMinor: 15000,
      inspectionPhotoUrl: 'https://example.com/p.jpg',
      idempotencyKey: 'k1',
    })).toEqual({
      p_deal_id: 'd1',
      p_amount_minor: 15000,
      p_inspection_photo_url: 'https://example.com/p.jpg',
      p_idempotency_key: 'k1',
    });
    expect(createIssueOtpParams('d1')).toEqual({ p_deal_id: 'd1' });
    expect(createReleaseParams({ dealId: 'd1', deliveryOtp: '123456', idempotencyKey: 'r1' })).toEqual({
      p_deal_id: 'd1',
      p_delivery_otp: '123456',
      p_idempotency_key: 'r1',
    });
    expect(createRefundParams({ dealId: 'd1', idempotencyKey: 'f1' })).toEqual({
      p_deal_id: 'd1',
      p_idempotency_key: 'f1',
    });
  });
});
