"use client";

import Link from "next/link";
import Image from "next/image";
import { CheckCircle2, Clock, BarChart3 } from "lucide-react";
import { Preset } from "@/lib/registry";

// Client-side icon path helper
function getIconPath(iconRelativePath: string): string {
  const iconName = iconRelativePath.split('/').pop() || 'default.svg';
  return `/icons/${iconName}`;
}

interface PresetCardProps {
  preset: Preset;
}

export function PresetCard({ preset }: PresetCardProps) {
  const href = `/presets/${preset.namespace}/${preset.name}`;
  const iconPath = preset.frontmatter.icon ? getIconPath(preset.frontmatter.icon) : null;

  const difficultyColors: Record<string, string> = {
    beginner: "#10b981",
    intermediate: "#d97706",
    advanced: "#ef4444",
  };

  const difficultyColor = difficultyColors[preset.frontmatter.difficulty || "intermediate"] || "#d97706";

  return (
    <Link href={href} className="group block">
      <div className="card-interactive p-6 h-full">
        {/* Icon and Title */}
        <div className="flex items-start gap-4 mb-4">
          <div
            className="w-12 h-12 rounded-xl flex items-center justify-center flex-shrink-0 transition-all duration-200"
            style={{
              background: "rgba(217, 119, 6, 0.1)",
              border: "1px solid rgba(217, 119, 6, 0.2)",
            }}
          >
            {iconPath ? (
              <Image
                src={iconPath}
                alt={preset.frontmatter.display_name || preset.name}
                width={28}
                height={28}
                className="w-7 h-7"
                onError={(e) => {
                  (e.target as HTMLImageElement).style.display = 'none';
                }}
              />
            ) : (
              <span className="text-lg font-bold" style={{ color: "#d97706" }}>
                {(preset.frontmatter.display_name || preset.name).charAt(0).toUpperCase()}
              </span>
            )}
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 mb-1.5">
              <h3 className="font-semibold text-base group-hover:text-[#d97706] transition-colors truncate" style={{ color: "#1a1a1a" }}>
                {preset.frontmatter.display_name || preset.name}
              </h3>
            </div>
            <p className="text-xs font-mono" style={{ color: "#666666" }}>
              {preset.namespace}/{preset.name}
            </p>
          </div>
        </div>

        {/* Description */}
        <p className="text-sm line-clamp-2 mb-4 leading-relaxed" style={{ color: "#666666" }}>
          {preset.frontmatter.description}
        </p>

        {/* Meta Info */}
        <div className="flex items-center gap-4 mb-4 text-xs" style={{ color: "#999999" }}>
          {preset.frontmatter.difficulty && (
            <div className="flex items-center gap-1">
              <BarChart3 className="h-3 w-3" style={{ color: difficultyColor }} />
              <span style={{ color: difficultyColor }} className="capitalize">
                {preset.frontmatter.difficulty}
              </span>
            </div>
          )}
          {preset.frontmatter.duration && (
            <div className="flex items-center gap-1">
              <Clock className="h-3 w-3" />
              <span>{preset.frontmatter.duration}</span>
            </div>
          )}
        </div>

        {/* Category and Domain badges */}
        <div className="flex gap-1.5 flex-wrap mb-3">
          {preset.frontmatter.category && (
            <div
              className="badge-base text-[10px]"
              style={{
                background: "rgba(217, 119, 6, 0.1)",
                color: "#d97706",
              }}
            >
              {preset.frontmatter.category}
            </div>
          )}
          {preset.frontmatter.domain && (
            <div
              className="badge-base text-[10px]"
              style={{
                background: "#f5f5f0",
                color: "#666666",
              }}
            >
              {preset.frontmatter.domain}
            </div>
          )}
        </div>

        {/* Tags */}
        {preset.frontmatter.tags && preset.frontmatter.tags.length > 0 && (
          <div className="flex gap-1.5 overflow-hidden mt-auto pt-4" style={{ borderTop: "1px solid #f0f0e8" }}>
            {preset.frontmatter.tags.slice(0, 3).map((tag) => (
              <div
                key={tag}
                className="badge-base text-[10px]"
                style={{
                  background: "#f5f5f0",
                  color: "#666666",
                }}
              >
                {tag}
              </div>
            ))}
          </div>
        )}
      </div>
    </Link>
  );
}
