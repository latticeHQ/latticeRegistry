"use client";

import { useEffect } from "react";
import Link from "next/link";
import { AlertCircle, RefreshCcw, Home } from "lucide-react";

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error(error);
  }, [error]);

  return (
    <div className="min-h-screen flex items-center justify-center px-4">
      <div className="max-w-2xl w-full text-center space-y-8">
        {/* Error icon */}
        <div
          className="w-20 h-20 rounded-2xl flex items-center justify-center mx-auto"
          style={{
            background: "rgba(239, 68, 68, 0.1)",
            border: "1px solid rgba(239, 68, 68, 0.2)",
          }}
        >
          <AlertCircle className="h-10 w-10" style={{ color: "#ef4444" }} />
        </div>

        {/* Error message */}
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
            Something went wrong
          </h1>
          <p
            style={{
              fontSize: "var(--font-size-base)",
              lineHeight: "var(--line-height-relaxed)",
              color: "#666666",
            }}
          >
            We encountered an unexpected error. Please try again or return to the homepage.
          </p>

          {/* Error details (only in development) */}
          {process.env.NODE_ENV === "development" && (
            <div
              className="mt-6 p-4 rounded-lg text-left overflow-auto"
              style={{
                background: "rgba(239, 68, 68, 0.05)",
                border: "1px solid rgba(239, 68, 68, 0.2)",
                maxHeight: "200px",
              }}
            >
              <p
                className="font-mono text-xs"
                style={{ color: "#ef4444" }}
              >
                {error.message}
              </p>
            </div>
          )}
        </div>

        {/* Action buttons */}
        <div className="flex flex-col sm:flex-row gap-3 justify-center">
          <button
            onClick={reset}
            className="btn-primary inline-flex items-center justify-center gap-2 px-5 py-2.5"
          >
            <RefreshCcw className="h-4 w-4" />
            Try Again
          </button>
          <Link
            href="/"
            className="btn-secondary inline-flex items-center justify-center gap-2 px-5 py-2.5"
          >
            <Home className="h-4 w-4" />
            Go Home
          </Link>
        </div>
      </div>
    </div>
  );
}
