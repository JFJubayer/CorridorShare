import { describe, expect, it } from 'vitest';
import { toBdE164 } from './bdPhone';

describe('toBdE164', () => {
  it('prefixes national digits with +880 (not +88)', () => {
    expect(toBdE164('1712345678')).toBe('+8801712345678');
  });

  it('keeps an already-correct E.164 value', () => {
    expect(toBdE164('+8801712345678')).toBe('+8801712345678');
  });

  it('strips a leading national 0', () => {
    expect(toBdE164('01712345678')).toBe('+8801712345678');
  });
});
