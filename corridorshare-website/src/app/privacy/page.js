import Link from 'next/link';

export const metadata = {
  title: 'Privacy | CorridorShare Friends Beta',
  description: 'Privacy notice for the CorridorShare friends private beta.',
};

export default function PrivacyPage() {
  return (
    <div className="max-w-3xl mx-auto px-6 py-12 md:pl-8 space-y-6">
      <Link href="/" className="text-xs font-black text-primary uppercase tracking-wider">← Back home</Link>
      <h1 className="text-3xl font-black text-on-surface font-display tracking-tight">Privacy (friends beta)</h1>
      <div className="text-sm text-on-surface-variant leading-relaxed font-medium space-y-4">
        <p>
          This is a private friends trial, not a public product launch. We store phone numbers used for OTP sign-in,
          optional display names, NID photos submitted for admin review, trip/package locations needed for matching,
          deal chat messages (including optional one-shot meetup pins), and wallet ledger entries for escrow.
        </p>
        <ul className="list-disc pl-5 space-y-2">
          <li>Live data sits in the configured Supabase project. Demo mode stays in your browser only.</li>
          <li>There is no continuous GPS tracking and no payment-provider top-up in this beta.</li>
          <li>We do not sell personal data. A full Bangladesh privacy policy will replace this notice later.</li>
        </ul>
      </div>
    </div>
  );
}
