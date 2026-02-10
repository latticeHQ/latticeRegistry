"use client";

import Link from "next/link";
import Image from "next/image";
import { CheckCircle2 } from "lucide-react";
import { Module } from "@/lib/registry";

// Client-side icon path helper
function getIconPath(iconRelativePath: string): string {
  const iconName = iconRelativePath.split('/').pop() || 'default.svg';
  return `/icons/${iconName}`;
}

interface ModuleCardProps {
  module: Module;
  type?: "module" | "template" | "plugin";
}

export function ModuleCard({ module, type = "module" }: ModuleCardProps) {
  const hrefMap: Record<string, string> = {
    module: `/modules/${module.namespace}/${module.name}`,
    template: `/templates/${module.namespace}/${module.name}`,
    plugin: `/plugins/${module.namespace}/${module.name}`,
  };
  const href = hrefMap[type];

  const iconPath = module.frontmatter.icon ? getIconPath(module.frontmatter.icon) : null;

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
                alt={module.frontmatter.display_name || module.name}
                width={28}
                height={28}
                className="w-7 h-7"
                onError={(e) => {
                  // If image fails to load, hide it and show fallback
                  (e.target as HTMLImageElement).style.display = 'none';
                }}
              />
            ) : (
              <span className="text-lg font-bold" style={{ color: "#d97706" }}>
                {(module.frontmatter.display_name || module.name).charAt(0).toUpperCase()}
              </span>
            )}
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 mb-1.5">
              <h3 className="font-semibold text-base group-hover:text-[#d97706] transition-colors truncate" style={{ color: "#1a1a1a" }}>
                {module.frontmatter.display_name || module.name}
              </h3>
              {module.frontmatter.verified && (
                <CheckCircle2 className="h-4 w-4 flex-shrink-0" style={{ color: "#10b981" }} />
              )}
            </div>
            <p className="text-xs font-mono" style={{ color: "#666666" }}>
              {module.namespace}/{module.name}
            </p>
          </div>
        </div>

        {/* Description */}
        <p className="text-sm line-clamp-2 mb-5 leading-relaxed" style={{ color: "#666666" }}>
          {module.frontmatter.description}
        </p>

        {/* Tags */}
        {module.frontmatter.tags && module.frontmatter.tags.length > 0 && (
          <div className="flex gap-1.5 overflow-hidden mt-auto pt-4" style={{ borderTop: "1px solid #f0f0e8" }}>
            {module.frontmatter.tags.slice(0, 3).map((tag) => (
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
