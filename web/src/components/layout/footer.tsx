"use client";

import Link from "next/link";
import { Github, Twitter } from "lucide-react";

export function Footer() {
  return (
    <footer className="relative" style={{ borderTop: "1px solid #e0e0d8", background: "#ffffff" }}>
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-16">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-10">
          {/* Brand */}
          <div className="col-span-2 md:col-span-1">
            <Link href="/" className="inline-flex items-center gap-2 mb-5 group">
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
            <p className="text-sm leading-relaxed mb-6" style={{ color: "#666666" }}>
              Runtime enforcement and identity infrastructure for autonomous AI agents.
            </p>
            <div className="flex gap-3">
              <a
                href="https://github.com/latticeHQ"
                target="_blank"
                rel="noopener noreferrer"
                className="w-8 h-8 rounded-md flex items-center justify-center transition-all"
                style={{
                  background: "#ebe9e1",
                  border: "1px solid #e0e0d8",
                  color: "#666666",
                }}
              >
                <Github className="h-4 w-4" />
              </a>
              <a
                href="https://twitter.com/latticeruntime"
                target="_blank"
                rel="noopener noreferrer"
                className="w-8 h-8 rounded-md flex items-center justify-center transition-all"
                style={{
                  background: "#ebe9e1",
                  border: "1px solid #e0e0d8",
                  color: "#666666",
                }}
              >
                <Twitter className="h-4 w-4" />
              </a>
            </div>
          </div>

          {/* Registry */}
          <div>
            <h3 className="font-semibold text-xs uppercase tracking-wide mb-4" style={{ color: "#1a1a1a", letterSpacing: "0.05em" }}>
              Registry
            </h3>
            <ul className="space-y-3">
              <li>
                <Link
                  href="/modules"
                  className="text-sm transition-colors"
                  style={{ color: "#666666" }}
                >
                  Modules
                </Link>
              </li>
              <li>
                <Link
                  href="/templates"
                  className="text-sm transition-colors"
                  style={{ color: "#666666" }}
                >
                  Templates
                </Link>
              </li>
              <li>
                <Link
                  href="/plugins"
                  className="text-sm transition-colors"
                  style={{ color: "#666666" }}
                >
                  Plugins
                </Link>
              </li>
              <li>
                <Link
                  href="/presets"
                  className="text-sm transition-colors"
                  style={{ color: "#666666" }}
                >
                  Presets
                </Link>
              </li>
              <li>
                <Link
                  href="/contributors"
                  className="text-sm transition-colors"
                  style={{ color: "#666666" }}
                >
                  Contributors
                </Link>
              </li>
            </ul>
          </div>

          {/* Resources */}
          <div>
            <h3 className="font-semibold text-xs uppercase tracking-wide mb-4" style={{ color: "#1a1a1a", letterSpacing: "0.05em" }}>
              Resources
            </h3>
            <ul className="space-y-3">
              <li>
                <a
                  href="https://docs.latticeruntime.com"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-sm transition-colors"
                  style={{ color: "#666666" }}
                >
                  Documentation
                </a>
              </li>
              <li>
                <a
                  href="https://github.com/latticeHQ/registry"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-sm transition-colors"
                  style={{ color: "#666666" }}
                >
                  GitHub
                </a>
              </li>
              <li>
                <a
                  href="https://github.com/latticeHQ/registry/blob/main/CONTRIBUTING.md"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-sm transition-colors"
                  style={{ color: "#666666" }}
                >
                  Contributing
                </a>
              </li>
            </ul>
          </div>

          {/* Lattice */}
          <div>
            <h3 className="font-semibold text-xs uppercase tracking-wide mb-4" style={{ color: "#1a1a1a", letterSpacing: "0.05em" }}>
              Lattice
            </h3>
            <ul className="space-y-3">
              <li>
                <a
                  href="https://latticeruntime.com"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-sm transition-colors"
                  style={{ color: "#666666" }}
                >
                  Website
                </a>
              </li>
              <li>
                <a
                  href="https://github.com/latticeHQ/lattice"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-sm transition-colors"
                  style={{ color: "#666666" }}
                >
                  Runtime
                </a>
              </li>
              <li>
                <a
                  href="mailto:hello@latticeruntime.com"
                  className="text-sm transition-colors"
                  style={{ color: "#666666" }}
                >
                  Contact
                </a>
              </li>
            </ul>
          </div>
        </div>

        <div className="mt-12 pt-8" style={{ borderTop: "1px solid #e0e0d8" }}>
          <p className="text-center text-sm" style={{ color: "#666666" }}>
            &copy; {new Date().getFullYear()} Lattice Runtime. Apache 2.0 License.
          </p>
        </div>
      </div>
    </footer>
  );
}
