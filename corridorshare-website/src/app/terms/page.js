import Link from 'next/link';

export const metadata = {
  title: 'Terms | CorridorShare Friends Beta',
  description: 'Terms notice for the CorridorShare friends private beta.',
};

export default function TermsPage() {
  return (
    <div className="max-w-3xl mx-auto px-6 py-12 md:pl-8 space-y-6">
      <Link href="/" className="text-xs font-black text-primary uppercase tracking-wider">← Back home</Link>
      <h1 className="text-3xl font-black text-on-surface font-display tracking-tight">Terms (friends beta)</h1>
      <div className="text-sm text-on-surface-variant leading-relaxed font-medium space-y-4">
        <p>
          CorridorShare is running a small friends-only beta for peer corridor deliveries in Bangladesh.
          Features may change, break, or be wiped between staging resets.
        </p>
        <ul className="list-disc pl-5 space-y-2">
          <li>Users post trips or packages, match on corridors, and negotiate in deal chat.</li>
          <li>Escrow uses platform wallet balances. Staging funds come from admin_credit_wallet — not bKash/Nagad.</li>
          <li>Manual NID review does not guarantee identity or cargo safety. Refuse contraband and follow local law.</li>
          <li>Meetup pins are one-shot location shares in chat, not live tracking.</li>
        </ul>
        <p>These are interim beta notes, not final legal terms.</p>
      </div>
    </div>
  );
}
