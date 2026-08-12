export const MEETUP_PIN_PREFIX = 'CS_MEETUP_PIN:';

export function formatMeetupPinMessage({ lat, lng, label = 'Meetup' }) {
  return `${MEETUP_PIN_PREFIX}${JSON.stringify({ lat, lng, label })}`;
}

export function parseMeetupPinMessage(text) {
  if (typeof text !== 'string' || !text.startsWith(MEETUP_PIN_PREFIX)) return null;
  try {
    const data = JSON.parse(text.slice(MEETUP_PIN_PREFIX.length));
    const lat = Number(data.lat);
    const lng = Number(data.lng);
    if (!Number.isFinite(lat) || !Number.isFinite(lng)) return null;
    return {
      lat,
      lng,
      label: typeof data.label === 'string' && data.label.trim() ? data.label.trim() : 'Meetup',
    };
  } catch {
    return null;
  }
}

export function meetupMapsUrl({ lat, lng }) {
  return `https://www.openstreetmap.org/?mlat=${lat}&mlon=${lng}#map=16/${lat}/${lng}`;
}

export function meetupPinPreview(text) {
  const pin = parseMeetupPinMessage(text);
  if (!pin) return text;
  return `Meetup pin: ${pin.label} (${pin.lat.toFixed(4)}, ${pin.lng.toFixed(4)})`;
}
