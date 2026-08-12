import Link from 'next/link';

export const metadata = {
  title: 'Support | CorridorShare Friends Beta',
  description: 'Support for the CorridorShare friends private beta.',
};

export default function SupportPage() {
  return (
    <div className="max-w-3xl mx-auto px-6 py-12 md:pl-8 space-y-6">
      <Link href="/" className="text-xs font-black text-primary uppercase tracking-wider">← Back home</Link>
      <h1 className="text-3xl font-black text-on-surface font-display tracking-tight">Support (friends beta)</h1>
      <div className="text-sm text-on-surface-variant leading-relaxed font-medium space-y-4">
        <p>This is a private friends trial. Reach the person who invited you for account, NID, or wallet staging help.</p>
        <ul className="list-disc pl-5 space-y-2">
          <li>Wallet top-up: ask an admin to run <code className="text-primary">admin_credit_wallet</code> — there is no payment gateway.</li>
          <li>Product bugs: open a GitHub issue on the CorridorShare repository.</li>
          <li>Safety or cargo emergencies: contact local authorities first.</li>
        </ul>
      </div>
    </div>
  );
}
