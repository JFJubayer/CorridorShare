import Link from 'next/link';

export const metadata = {
  title: 'Privacy Notice (Draft) | CorridorShare',
  description: 'Draft privacy notice for CorridorShare in Bangladesh.',
};

export default function PrivacyPage() {
  return (
    <div className="max-w-3xl mx-auto px-6 py-12 md:pl-8 space-y-6">
      <Link href="/" className="text-xs font-black text-orange-600 dark:text-orange-400 uppercase tracking-wider">← Back home</Link>
      <h1 className="text-3xl font-black text-on-surface font-display tracking-tight">Privacy Notice (Draft)</h1>
      <div className="text-sm text-on-surface-variant leading-relaxed font-medium space-y-4">
        <p>
          CorridorShare stores account phone numbers, optional names, NID photo uploads for admin review,
          trip and package locations, chat messages, and wallet ledger entries needed to run matching and escrow.
        </p>
        <ul className="list-disc pl-5 space-y-2">
          <li>Live data is hosted on Supabase when configured.</li>
          <li>Demo mode keeps sample data in your browser only.</li>
          <li>We do not sell personal data in this MVP.</li>
        </ul>
        <p>This notice is a stub and will be replaced with a full Bangladesh-ready privacy policy.</p>
      </div>
    </div>
  );
}
