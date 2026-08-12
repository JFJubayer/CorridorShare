import { describe, expect, it } from 'vitest';
import {
  formatMeetupPinMessage,
  meetupMapsUrl,
  meetupPinPreview,
  parseMeetupPinMessage,
} from './meetupPin';

describe('meetupPin', () => {
  it('round-trips the CS_MEETUP_PIN convention', () => {
    const encoded = formatMeetupPinMessage({ lat: 23.81, lng: 90.41, label: 'Meetup' });
    expect(encoded).toBe('CS_MEETUP_PIN:{"lat":23.81,"lng":90.41,"label":"Meetup"}');
    expect(parseMeetupPinMessage(encoded)).toEqual({ lat: 23.81, lng: 90.41, label: 'Meetup' });
  });

  it('rejects garbage', () => {
    expect(parseMeetupPinMessage('hello')).toBeNull();
    expect(parseMeetupPinMessage('CS_MEETUP_PIN:{bad')).toBeNull();
    expect(parseMeetupPinMessage('CS_MEETUP_PIN:not-json')).toBeNull();
  });

  it('builds an OpenStreetMap link', () => {
    expect(meetupMapsUrl({ lat: 23.81, lng: 90.41 })).toBe(
      'https://www.openstreetmap.org/?mlat=23.81&mlon=90.41#map=16/23.81/90.41',
    );
  });

  it('previews pins for inbox rows and ignores plain text', () => {
    expect(meetupPinPreview('hello')).toBe('hello');
    expect(meetupPinPreview('CS_MEETUP_PIN:{"lat":23.81,"lng":90.41,"label":"Gate"}')).toContain('Gate');
  });
});
