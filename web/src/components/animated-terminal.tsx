"use client";

import { useState, useEffect } from "react";
import { Terminal } from "lucide-react";

const terminalLines = [
  { type: "comment", text: "# Install Lattice Runtime" },
  { type: "command", text: "$ brew tap latticeHQ/lattice" },
  { type: "command", text: "$ brew install latticehq/lattice/lattice" },
  { type: "success", text: "Lattice installed successfully" },
  { type: "comment", text: "# Verify installation" },
  { type: "command", text: "$ lattice --help" },
  { type: "output", text: "Lattice Runtime - Runtime enforcement for AI agents" },
  { type: "output", text: "Usage: lattice [command]" },
  { type: "comment", text: "# Use a registry module" },
  { type: "command", text: "$ lattice module add lattice/okta-identity" },
  { type: "success", text: "Module added: okta-identity v1.2.0" },
  { type: "prompt", text: "$ " },
];

export function AnimatedTerminal() {
  const [visibleLines, setVisibleLines] = useState<number>(0);
  const [showCursor, setShowCursor] = useState(true);

  useEffect(() => {
    // Animate lines appearing
    if (visibleLines < terminalLines.length) {
      const timer = setTimeout(() => {
        setVisibleLines((prev) => prev + 1);
      }, 300 + Math.random() * 200);
      return () => clearTimeout(timer);
    }
  }, [visibleLines]);

  useEffect(() => {
    // Blinking cursor
    const cursorInterval = setInterval(() => {
      setShowCursor((prev) => !prev);
    }, 530);
    return () => clearInterval(cursorInterval);
  }, []);

  const getLineStyle = (type: string) => {
    switch (type) {
      case "comment":
        return "text-slate-500 text-xs";
      case "command":
        return "";
      case "success":
        return "text-emerald-400 text-xs";
      case "output":
        return "text-slate-400 text-xs";
      case "prompt":
        return "";
      default:
        return "";
    }
  };

  const renderLine = (line: typeof terminalLines[0], index: number) => {
    if (line.type === "command") {
      return (
        <div key={index}>
          <span className="text-emerald-400">$</span>{" "}
          <span className="text-orange-400">{line.text.replace("$ ", "").split(" ")[0]}</span>{" "}
          <span className="text-slate-300">{line.text.replace("$ ", "").split(" ").slice(1).join(" ")}</span>
        </div>
      );
    }
    if (line.type === "success") {
      return (
        <div key={index} className={getLineStyle(line.type)}>
          <span className="text-emerald-400">✓</span> {line.text}
        </div>
      );
    }
    if (line.type === "prompt") {
      return (
        <div key={index}>
          <span className="text-emerald-400">$</span>
          {showCursor && (
            <span className="inline-block w-2 h-4 bg-orange-400 ml-1 align-text-bottom animate-pulse" />
          )}
        </div>
      );
    }
    return (
      <div key={index} className={getLineStyle(line.type)}>
        {line.text}
      </div>
    );
  };

  return (
    <div className="relative">
      {/* Corner decorations */}
      <div className="absolute -top-2 -left-2 w-8 h-8 border-t-2 border-l-2 border-orange-500/30 pointer-events-none z-10" />
      <div className="absolute -top-2 -right-2 w-8 h-8 border-t-2 border-r-2 border-orange-500/30 pointer-events-none z-10" />
      <div className="absolute -bottom-2 -left-2 w-8 h-8 border-b-2 border-l-2 border-orange-500/30 pointer-events-none z-10" />
      <div className="absolute -bottom-2 -right-2 w-8 h-8 border-b-2 border-r-2 border-orange-500/30 pointer-events-none z-10" />

      <div className="relative terminal-dark border-2 border-orange-500/30 overflow-hidden shadow-2xl">
        {/* Terminal header */}
        <div className="terminal-dark-header py-3 px-4 border-b-2 border-orange-500/30 flex items-center text-sm">
          <Terminal size={14} className="mr-2 text-orange-400" />
          <span className="font-medium font-mono">terminal</span>
          <div className="ml-auto flex gap-2">
            <div className="w-3 h-3 rounded-full bg-red-500/80" />
            <div className="w-3 h-3 rounded-full bg-yellow-500/80" />
            <div className="w-3 h-3 rounded-full bg-green-500/80" />
          </div>
        </div>

        {/* Terminal body */}
        <div className="p-6 font-mono text-sm text-slate-300 min-h-[320px] space-y-2 terminal-dark">
          {terminalLines.slice(0, visibleLines).map((line, index) => renderLine(line, index))}
        </div>
      </div>
    </div>
  );
}
