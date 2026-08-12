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
 * Uploads a user file to Supabase Storage (or a durable data URL in demo mode).
 * Bucket names are configurable so environments can swap without code edits.
 */
export async function uploadUserFile({ bucket, folder = 'uploads', file, cacheControl = '3600' }) {
  if (!file) throw new Error('Choose a file to upload.');
  if (!file.type?.startsWith('image/') && file.type !== 'application/pdf') {
    throw new Error('Upload an image or PDF file.');
  }
  if (file.size > 5 * 1024 * 1024) {
    throw new Error('File must be 5MB or smaller.');
  }

  if (isMockDataSource) {
    return fileToDataUrl(file);
  }

  const extension = (file.name?.split('.').pop() || 'jpg').toLowerCase().replace(/[^a-z0-9]/g, '') || 'jpg';
  const path = `${folder}/${randomId()}.${extension}`;
  const { error } = await supabase.storage.from(bucket).upload(path, file, {
    cacheControl,
    upsert: false,
    contentType: file.type || 'application/octet-stream',
  });
  if (error) {
    throw new Error(error.message || `Unable to upload to ${bucket}. Create the storage bucket in Supabase if it is missing.`);
  }

  const { data } = supabase.storage.from(bucket).getPublicUrl(path);
  if (!data?.publicUrl) throw new Error('Upload succeeded but no public URL was returned.');
  return data.publicUrl;
}

export const STORAGE_BUCKETS = Object.freeze({
  inspection: process.env.NEXT_PUBLIC_STORAGE_BUCKET_INSPECTION || 'parcel-inspections',
  nid: process.env.NEXT_PUBLIC_STORAGE_BUCKET_NID || 'nid-photos',
});
