import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import { Header } from "@/components/layout/header";
import { Footer } from "@/components/layout/footer";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
  display: "swap",
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
  display: "swap",
});

export const metadata: Metadata = {
  title: "Lattice Registry - Extend Your Lattice Runtime",
  description:
    "Community-driven modules for Lattice Runtime deployments. Identity management, policy templates, AI framework integrations, and monitoring.",
  keywords: [
    "lattice",
    "lattice runtime",
    "AI agents",
    "terraform",
    "modules",
    "identity",
    "authorization",
    "runtime enforcement",
    "MCP",
    "LiveKit",
    "A2A",
  ],
  authors: [{ name: "Lattice" }],
  openGraph: {
    title: "Lattice Registry",
    description: "Extend your Lattice Runtime with community modules",
    url: "https://registry.latticeruntime.com",
    siteName: "Lattice Registry",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "Lattice Registry",
    description: "Extend your Lattice Runtime with community modules",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        <script
          dangerouslySetInnerHTML={{
            __html: `
              try {
                const theme = localStorage.getItem('theme');
                if (theme === 'light') {
                  document.documentElement.classList.add('light');
                }
              } catch (e) {}
            `,
          }}
        />
      </head>
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased min-h-screen flex flex-col bg-slate-950`}
      >
        <Header />
        <main className="flex-1">{children}</main>
        <Footer />
      </body>
    </html>
  );
}
