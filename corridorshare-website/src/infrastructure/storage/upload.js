import { isMockDataSource, supabase } from '@/config/supabaseClient';

function randomId() {
  if (typeof crypto !== 'undefined' && crypto.randomUUID) return crypto.randomUUID();
  return `${Date.now()}-${Math.random().toString(16).slice(2)}`;
}

async function fileToDataUrl(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(String(reader.result || ''));
    reader.onerror = () => reject(new Error('Unable to read that file.'));
    reader.readAsDataURL(file);
  });
}

/**
 * Uploads a user file to private Supabase Storage (or a durable data URL in demo mode).
 * Path convention required by RLS: first folder segment must be auth.uid().
 * Returns a time-limited signed URL suitable for storing on profiles/deals.
 */
export async function uploadUserFile({ bucket, folder = 'uploads', file, cacheControl = '3600' }) {
  if (!file) throw new Error('Choose a file to upload.');
  if (!file.type?.startsWith('image/')) {
    throw new Error('Upload a JPG, PNG, or WebP image.');
  }
  if (file.size > 5 * 1024 * 1024) {
    throw new Error('File must be 5MB or smaller.');
  }

  if (isMockDataSource) {
    return fileToDataUrl(file);
  }

  const {
    data: { user },
    error: userError,
  } = await supabase.auth.getUser();
  if (userError) throw new Error(userError.message || 'Unable to confirm your session.');
  if (!user?.id) throw new Error('Sign in before uploading files.');

  const root = String(folder || '').split('/').filter(Boolean)[0];
  if (root !== user.id) {
    throw new Error('Upload folder must start with your account id.');
  }

  const extension = (file.name?.split('.').pop() || 'jpg').toLowerCase().replace(/[^a-z0-9]/g, '') || 'jpg';
  const path = `${folder}/${randomId()}.${extension}`;
  const { error } = await supabase.storage.from(bucket).upload(path, file, {
    cacheControl,
    upsert: false,
    contentType: file.type || 'application/octet-stream',
  });
  if (error) {
    throw new Error(error.message || `Unable to upload to ${bucket}.`);
  }

  // Buckets are private — public URLs will 403. Persist a signed URL instead.
  const { data: signed, error: signedError } = await supabase.storage
    .from(bucket)
    .createSignedUrl(path, 60 * 60 * 24 * 7);
  if (signedError || !signed?.signedUrl) {
    throw new Error(signedError?.message || 'Upload succeeded but no signed URL was returned.');
  }
  return signed.signedUrl;
}

export const STORAGE_BUCKETS = Object.freeze({
  inspection: process.env.NEXT_PUBLIC_STORAGE_BUCKET_INSPECTION || 'parcel-inspections',
  nid: process.env.NEXT_PUBLIC_STORAGE_BUCKET_NID || 'nid-photos',
});
