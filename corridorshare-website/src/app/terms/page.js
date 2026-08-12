import Link from 'next/link';

export const metadata = {
  title: 'Terms of Use (Draft) | CorridorShare',
  description: 'Draft terms for CorridorShare peer-to-peer corridor logistics in Bangladesh.',
};

export default function TermsPage() {
  return (
    <div className="max-w-3xl mx-auto px-6 py-12 md:pl-8 space-y-6">
      <Link href="/" className="text-xs font-black text-primary uppercase tracking-wider">← Back home</Link>
      <h1 className="text-3xl font-black text-on-surface font-display tracking-tight">Terms of Use (Draft)</h1>
      <div className="text-sm text-on-surface-variant leading-relaxed font-medium space-y-4">
        <p>
          These draft terms describe how CorridorShare plans to operate peer-to-peer corridor deliveries across Bangladesh.
        </p>
        <ul className="list-disc pl-5 space-y-2">
          <li>Users post trips or packages and negotiate deals in-app.</li>
          <li>Escrow holds use platform wallet balances; no card or payment provider is connected in this MVP.</li>
          <li>Manual NID review does not guarantee identity or cargo safety.</li>
          <li>Users must follow Bangladesh law and refuse contraband.</li>
        </ul>
        <p>This page is a placeholder until legal counsel publishes final terms.</p>
      </div>
    </div>
  );
}
