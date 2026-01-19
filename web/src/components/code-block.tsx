"use client";

import { useState } from "react";
import { Check, Copy, Terminal } from "lucide-react";

interface CodeBlockProps {
  code: string;
  language?: string;
  showHeader?: boolean;
}

export function CodeBlock({ code, language = "terraform", showHeader = false }: CodeBlockProps) {
  const [copied, setCopied] = useState(false);

  const handleCopy = async () => {
    await navigator.clipboard.writeText(code);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="relative group rounded-lg overflow-hidden" style={{ border: "1px solid #e0e0d8", boxShadow: "0 2px 8px rgba(0, 0, 0, 0.04)" }}>
      {/* GitHub-style header bar */}
      {showHeader && (
        <div
          className="flex items-center justify-between px-4 py-2.5 border-b"
          style={{ background: "#fafaf8", borderColor: "#e0e0d8" }}
        >
          <div className="flex items-center gap-2">
            <Terminal className="h-3.5 w-3.5" style={{ color: "#999999" }} />
            <span className="text-xs font-medium" style={{ color: "#666666" }}>
              {language}
            </span>
          </div>
          <button
            onClick={handleCopy}
            className="flex items-center gap-1.5 px-2.5 py-1 rounded-md text-xs font-medium transition-all"
            style={{
              background: copied ? "rgba(16, 185, 129, 0.1)" : "transparent",
              border: "1px solid",
              borderColor: copied ? "#10b981" : "#e0e0d8",
              color: copied ? "#10b981" : "#666666",
            }}
            aria-label="Copy code"
          >
            {copied ? (
              <>
                <Check className="h-3 w-3" />
                Copied
              </>
            ) : (
              <>
                <Copy className="h-3 w-3" />
                Copy
              </>
            )}
          </button>
        </div>
      )}

      {/* Code content with light professional styling */}
      <div className="relative">
        <pre
          className="overflow-x-auto p-4 text-sm leading-relaxed"
          style={{
            background: "#f8f8f6",
            fontFamily: "'JetBrains Mono', 'Fira Code', 'Consolas', 'Monaco', monospace",
          }}
        >
          <code style={{ color: "#059669" }}>{code}</code>
        </pre>

        {/* Floating copy button (when no header) */}
        {!showHeader && (
          <button
            onClick={handleCopy}
            className="absolute top-3 right-3 p-2 rounded-md transition-all opacity-0 group-hover:opacity-100"
            style={{
              background: "#ffffff",
              border: "1px solid #e0e0d8",
              color: copied ? "#10b981" : "#666666",
              boxShadow: "0 2px 4px rgba(0, 0, 0, 0.1)",
            }}
            aria-label="Copy code"
          >
            {copied ? <Check className="h-3.5 w-3.5" /> : <Copy className="h-3.5 w-3.5" />}
          </button>
        )}
      </div>
    </div>
  );
}
