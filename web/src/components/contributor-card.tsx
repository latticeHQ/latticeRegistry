"use client";

import Link from "next/link";
import { Badge } from "@/components/ui/badge";
import { Package, Box, Github, CheckCircle2 } from "lucide-react";
import { useState } from "react";

interface ContributorCardProps {
  namespace: {
    name: string;
    frontmatter: {
      display_name?: string;
      bio?: string;
      status?: string;
      github?: string;
      avatar?: string;
    };
    modules: unknown[];
    templates: unknown[];
  };
}

export function ContributorCard({ namespace: ns }: ContributorCardProps) {
  const [imageError, setImageError] = useState(false);

  // Use the github field if available, otherwise fall back to namespace name
  const githubUsername = ns.frontmatter.github || ns.name;

  return (
    <Link href={`/contributors/${ns.name}`} className="group block">
      <div className="card-interactive h-full p-6">
        <div className="flex items-start gap-4">
          {/* Avatar - using GitHub avatar from the github field */}
          <div className="relative">
            {!imageError ? (
              <img
                src={`https://github.com/${githubUsername}.png`}
                alt={ns.frontmatter.display_name || ns.name}
                className="h-14 w-14 rounded-xl object-cover border border-slate-700 group-hover:border-orange-500/50 transition-colors"
                onError={() => setImageError(true)}
              />
            ) : (
              <div className="h-14 w-14 rounded-xl bg-gradient-to-br from-orange-500 to-orange-600 flex items-center justify-center text-white text-xl font-bold">
                {(ns.frontmatter.display_name || ns.name).charAt(0).toUpperCase()}
              </div>
            )}
            {ns.frontmatter.status === "official" && (
              <div className="absolute -bottom-1 -right-1 bg-slate-900 rounded-full p-0.5">
                <CheckCircle2 className="h-4 w-4 text-orange-400" />
              </div>
            )}
          </div>

          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 mb-1">
              <h3 className="font-semibold text-slate-100 truncate group-hover:text-orange-400 transition-colors">
                {ns.frontmatter.display_name || ns.name}
              </h3>
              {ns.frontmatter.status === "official" && (
                <Badge variant="default" className="text-[10px] px-1.5">Official</Badge>
              )}
              {ns.frontmatter.status === "partner" && (
                <Badge variant="success" className="text-[10px] px-1.5">Partner</Badge>
              )}
            </div>

            <div className="flex items-center gap-1.5 text-xs text-slate-500 mb-3">
              <Github className="h-3 w-3" />
              <span className="font-mono">@{githubUsername}</span>
            </div>

            {ns.frontmatter.bio && (
              <p className="text-sm text-slate-400 line-clamp-2 mb-4">
                {ns.frontmatter.bio}
              </p>
            )}

            <div className="flex items-center gap-4 text-xs text-slate-500">
              <span className="flex items-center gap-1.5">
                <Package className="h-3.5 w-3.5 text-orange-400" />
                <span className="text-slate-300 font-medium">{ns.modules.length}</span> modules
              </span>
              <span className="flex items-center gap-1.5">
                <Box className="h-3.5 w-3.5 text-orange-400" />
                <span className="text-slate-300 font-medium">{ns.templates.length}</span> templates
              </span>
            </div>
          </div>
        </div>
      </div>
    </Link>
  );
}
