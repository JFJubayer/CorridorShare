/**
 * Normalize Bangladesh mobile numbers for OTP auth.
 * UI fields show a +880 prefix and usually collect the national digits
 * (e.g. 1712345678). Callers may also pass full E.164 or a leading 0.
 */
export function toBdE164(raw) {
  const trimmed = String(raw || '').trim();
  if (!trimmed) throw new Error('Enter a Bangladesh mobile number.');

  if (trimmed.startsWith('+')) {
    const digits = trimmed.slice(1).replace(/\D/g, '');
    if (digits.startsWith('880') && digits.length >= 13) return `+${digits}`;
    throw new Error('Use a valid Bangladesh number starting with +880.');
  }

  const digits = trimmed.replace(/\D/g, '');
  if (digits.startsWith('880') && digits.length >= 13) return `+${digits}`;
  if (digits.startsWith('0') && digits.length >= 11) return `+880${digits.slice(1)}`;
  if (digits.length >= 10) return `+880${digits}`;

  throw new Error('Enter a valid Bangladesh mobile number (e.g. 1712345678).');
}
