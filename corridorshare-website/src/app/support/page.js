import Link from 'next/link';

export const metadata = {
  title: 'Support | CorridorShare',
  description: 'Support contacts for CorridorShare Bangladesh MVP.',
};

export default function SupportPage() {
  return (
    <div className="max-w-3xl mx-auto px-6 py-12 md:pl-8 space-y-6">
      <Link href="/" className="text-xs font-black text-orange-600 dark:text-orange-400 uppercase tracking-wider">← Back home</Link>
      <h1 className="text-3xl font-black text-on-surface font-display tracking-tight">Support</h1>
      <div className="text-sm text-on-surface-variant leading-relaxed font-medium space-y-4">
        <p>Need help with CorridorShare?</p>
        <ul className="list-disc pl-5 space-y-2">
          <li>For account or NID review questions, contact the admin team operating your deployment.</li>
          <li>For product bugs during the MVP, open a GitHub issue on the CorridorShare repository.</li>
          <li>Emergency cargo or safety incidents should be reported to local authorities first.</li>
        </ul>
        <p>Email placeholder: support@corridorshare.example</p>
      </div>
    </div>
  );
}
