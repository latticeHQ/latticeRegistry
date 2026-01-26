"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState, useEffect } from "react";
import { Package, Box, Users, Github, ExternalLink, Menu, X, Sparkles } from "lucide-react";

export function Header() {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [isScrolled, setIsScrolled] = useState(false);
  const pathname = usePathname();

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 10);
    };
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  const navLinks = [
    { href: "/modules", label: "Modules", icon: Package },
    { href: "/templates", label: "Templates", icon: Box },
    { href: "/presets", label: "Presets", icon: Sparkles },
    { href: "/contributors", label: "Contributors", icon: Users },
  ];

  const isActive = (href: string) => pathname.startsWith(href);

  return (
    <header
      className={`sticky top-0 z-50 w-full transition-all duration-200 ${
        isScrolled
          ? "border-b shadow-sm"
          : ""
      }`}
      style={{
        background: isScrolled ? "rgba(245, 245, 240, 0.95)" : "rgba(245, 245, 240, 0.8)",
        backdropFilter: "blur(12px)",
        borderColor: "#e0e0d8",
      }}
    >
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="flex h-14 items-center justify-between">
          {/* Logo */}
          <Link href="/" className="flex items-center gap-2.5 group">
            <img
              src="/lattice-logo.svg"
              alt="Lattice"
              className="w-7 h-7"
            />
            <div className="flex items-baseline gap-1.5">
              <span className="font-semibold text-sm" style={{ color: "#1a1a1a" }}>
                Lattice
              </span>
              <span className="text-[10px] font-medium px-1.5 py-0.5 rounded" style={{ background: "#ebe9e1", color: "#666666" }}>
                Registry
              </span>
            </div>
          </Link>

          {/* Desktop Navigation */}
          <nav className="hidden md:flex items-center gap-1">
            {navLinks.map((item) => {
              const Icon = item.icon;
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  className={`
                    flex items-center gap-1.5 px-3 py-1.5 rounded-md text-sm font-medium transition-all duration-150
                    ${isActive(item.href)
                      ? "text-[#1a1a1a] bg-[#ebe9e1]"
                      : "text-[#666666] hover:text-[#1a1a1a] hover:bg-[#ebe9e1]"
                    }
                  `}
                >
                  <Icon className="h-3.5 w-3.5" />
                  {item.label}
                </Link>
              );
            })}
            <a
              href="https://docs.latticeruntime.com"
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-md text-sm font-medium transition-all duration-150 text-[#666666] hover:text-[#1a1a1a] hover:bg-[#ebe9e1]"
            >
              Docs
              <ExternalLink className="h-3 w-3 opacity-50" />
            </a>
          </nav>

          {/* Actions */}
          <div className="flex items-center gap-2">
            <a
              href="https://github.com/latticeHQ/registry"
              target="_blank"
              rel="noopener noreferrer"
              className="hidden sm:flex items-center gap-1.5 px-3 py-1.5 rounded-md text-sm font-medium transition-all duration-150 text-[#666666] hover:text-[#1a1a1a] hover:bg-[#ebe9e1]"
            >
              <Github className="h-3.5 w-3.5" />
              <span className="hidden lg:inline">GitHub</span>
            </a>
            <div className="hidden sm:block w-px h-4" style={{ background: "#e0e0d8" }} />
            <a
              href="https://latticeruntime.com"
              target="_blank"
              rel="noopener noreferrer"
              className="hidden sm:inline-flex btn-primary text-xs py-1.5 px-3"
            >
              Get Started
            </a>

            {/* Mobile Menu Button */}
            <button
              className="md:hidden p-1.5 rounded-md transition-colors text-[#666666] hover:text-[#1a1a1a] hover:bg-[#ebe9e1]"
              onClick={() => setIsMenuOpen(!isMenuOpen)}
              aria-label="Toggle menu"
            >
              {isMenuOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
            </button>
          </div>
        </div>

        {/* Mobile Navigation */}
        {isMenuOpen && (
          <div className="md:hidden border-t py-3 animate-fade-in" style={{ borderColor: "#e0e0d8" }}>
            <nav className="flex flex-col gap-0.5">
              {navLinks.map((item) => {
                const Icon = item.icon;
                return (
                  <Link
                    key={item.href}
                    href={item.href}
                    className={`
                      flex items-center gap-2 px-3 py-2.5 rounded-md text-sm font-medium transition-colors
                      ${isActive(item.href)
                        ? "text-[#1a1a1a] bg-[#ebe9e1]"
                        : "text-[#666666]"
                      }
                    `}
                    onClick={() => setIsMenuOpen(false)}
                  >
                    <Icon className="h-4 w-4" />
                    {item.label}
                  </Link>
                );
              })}
              <a
                href="https://docs.latticeruntime.com"
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-2 px-3 py-2.5 rounded-md text-sm font-medium text-[#666666]"
              >
                Documentation
                <ExternalLink className="h-3.5 w-3.5 opacity-50" />
              </a>
              <div className="mt-2 pt-2" style={{ borderTop: "1px solid #e0e0d8" }}>
                <a
                  href="https://latticeruntime.com"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="btn-primary w-full text-center text-sm"
                >
                  Get Started
                </a>
              </div>
            </nav>
          </div>
        )}
      </div>
    </header>
  );
}
