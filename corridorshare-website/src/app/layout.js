import './globals.css';
import { UserProvider } from '@/context/UserContext';
import NavWrapper from '@/components/NavWrapper';

export const metadata = {
  title: "CorridorShare | Peer-to-Peer Corridor Logistics",
  description: "Peer-to-peer highway delivery across Bangladesh with escrow holds, open-box inspection, and manual NID review.",
};

export default function RootLayout({ children }) {
  return (
    <html lang="en" className="h-full">
      <body className="min-h-full flex flex-col bg-background text-on-surface">
        <UserProvider>
          <NavWrapper>
            {children}
          </NavWrapper>
        </UserProvider>
      </body>
    </html>
  );
}
