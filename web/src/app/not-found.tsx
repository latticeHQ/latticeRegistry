import Link from "next/link";
import { Home, Search, Package, FileQuestion } from "lucide-react";

export default function NotFound() {
  return (
    <div className="min-h-screen flex items-center justify-center px-4">
      <div className="max-w-2xl w-full text-center space-y-10">
        {/* 404 visual */}
        <div className="relative">
          <div
            className="text-[200px] font-bold leading-none select-none opacity-5"
            style={{ color: "#1a1a1a" }}
          >
            404
          </div>
          <div className="absolute inset-0 flex items-center justify-center">
            <div
              className="w-24 h-24 rounded-3xl flex items-center justify-center"
              style={{
                background: "rgba(217, 119, 6, 0.1)",
                border: "1px solid rgba(217, 119, 6, 0.2)",
              }}
            >
              <FileQuestion className="h-12 w-12" style={{ color: "#d97706" }} />
            </div>
          </div>
        </div>

        {/* Message */}
        <div className="space-y-4">
          <h1
            style={{
              fontSize: "var(--font-size-3xl)",
              lineHeight: "var(--line-height-tight)",
              letterSpacing: "var(--letter-spacing-tight)",
              fontWeight: "400",
              color: "#1a1a1a",
            }}
          >
            Page Not Found
          </h1>
          <p
            style={{
              fontSize: "var(--font-size-base)",
              lineHeight: "var(--line-height-relaxed)",
              color: "#666666",
            }}
          >
            The page you're looking for doesn't exist or has been moved.
          </p>
        </div>

        {/* Action buttons */}
        <div className="flex flex-col sm:flex-row gap-3 justify-center">
          <Link href="/" className="btn-primary inline-flex items-center justify-center gap-2 px-5 py-2.5">
            <Home className="h-4 w-4" />
            Go Home
          </Link>
          <Link href="/modules" className="btn-secondary inline-flex items-center justify-center gap-2 px-5 py-2.5">
            <Package className="h-4 w-4" />
            Browse Modules
          </Link>
        </div>

        {/* Quick links */}
        <div className="pt-8" style={{ borderTop: "1px solid #e0e0d8" }}>
          <p className="mb-5" style={{ fontSize: "var(--font-size-sm)", color: "#666666" }}>
            Looking for something specific?
          </p>
          <div className="flex flex-wrap gap-6 justify-center">
            <Link
              href="/modules"
              className="transition-colors"
              style={{ fontSize: "var(--font-size-sm)", fontWeight: "500", color: "#666666" }}
            >
              Modules
            </Link>
            <Link
              href="/templates"
              className="transition-colors"
              style={{ fontSize: "var(--font-size-sm)", fontWeight: "500", color: "#666666" }}
            >
              Templates
            </Link>
            <Link
              href="/contributors"
              className="transition-colors"
              style={{ fontSize: "var(--font-size-sm)", fontWeight: "500", color: "#666666" }}
            >
              Contributors
            </Link>
            <a
              href="https://docs.latticeruntime.com"
              target="_blank"
              rel="noopener noreferrer"
              className="transition-colors"
              style={{ fontSize: "var(--font-size-sm)", fontWeight: "500", color: "#666666" }}
            >
              Documentation
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}
