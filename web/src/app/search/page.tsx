"use client";

import { useState, useEffect, useMemo } from "react";
import Link from "next/link";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Search as SearchIcon, Package, Box, Users, ArrowUpRight, Sparkles, GitBranch } from "lucide-react";

interface SearchResult {
  type: "module" | "template" | "contributor";
  namespace: string;
  name: string;
  displayName: string;
  description: string;
  tags?: string[];
}

async function fetchSearchData(): Promise<SearchResult[]> {
  return [
    {
      type: "module",
      namespace: "lattice",
      name: "agent-identity",
      displayName: "Agent Identity",
      description: "Configure identity and authentication for AI agents",
      tags: ["identity", "authentication", "oauth", "oidc"],
    },
    {
      type: "module",
      namespace: "lattice",
      name: "policy-engine",
      displayName: "Policy Engine",
      description: "Runtime policy enforcement and authorization rules",
      tags: ["policy", "authorization", "enforcement"],
    },
    {
      type: "module",
      namespace: "lattice",
      name: "livekit-integration",
      displayName: "LiveKit Integration",
      description: "Real-time audio/video communication for AI agents",
      tags: ["integration", "livekit", "realtime", "voice", "video"],
    },
    {
      type: "contributor",
      namespace: "lattice",
      name: "lattice",
      displayName: "Lattice",
      description: "Official Lattice Runtime modules",
    },
  ];
}

export default function SearchPage() {
  const [query, setQuery] = useState("");
  const [allData, setAllData] = useState<SearchResult[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchSearchData().then((data) => {
      setAllData(data);
      setIsLoading(false);
    });
  }, []);

  const filteredResults = useMemo(() => {
    if (!query.trim()) return [];

    const searchTerms = query.toLowerCase().split(" ");
    return allData.filter((item) => {
      const searchText = `${item.displayName} ${item.description} ${item.tags?.join(" ") || ""} ${item.namespace}`.toLowerCase();
      return searchTerms.every((term) => searchText.includes(term));
    });
  }, [query, allData]);

  const getIcon = (type: string) => {
    switch (type) {
      case "module":
        return <Package className="h-5 w-5 text-orange-400" />;
      case "template":
        return <Box className="h-5 w-5 text-orange-400" />;
      case "contributor":
        return <Users className="h-5 w-5 text-orange-400" />;
      default:
        return <Package className="h-5 w-5 text-orange-400" />;
    }
  };

  const getLink = (result: SearchResult) => {
    switch (result.type) {
      case "module":
        return `/modules/${result.namespace}/${result.name}`;
      case "template":
        return `/templates/${result.namespace}/${result.name}`;
      case "contributor":
        return `/contributors/${result.namespace}`;
      default:
        return "/";
    }
  };

  const quickLinks = [
    { label: "Identity Modules", href: "/modules?category=identity", icon: Package },
    { label: "Policy Modules", href: "/modules?category=policy", icon: Package },
    { label: "Integrations", href: "/modules?category=integration", icon: Package },
    { label: "All Modules", href: "/modules", icon: Package },
    { label: "Templates", href: "/templates", icon: Box },
    { label: "Contributors", href: "/contributors", icon: Users },
  ];

  return (
    <div className="relative min-h-screen">
      {/* Background */}
      <div className="fixed inset-0 pointer-events-none">
        <div className="absolute inset-0 grid-pattern opacity-30" />
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-orange-500/5 rounded-full blur-3xl" />
        <div className="absolute bottom-1/4 right-1/3 w-[400px] h-[400px] bg-orange-500/5 rounded-full blur-3xl" />
      </div>

      <div className="relative mx-auto max-w-4xl px-4 sm:px-6 lg:px-8 py-16 md:py-24">
        {/* Header */}
        <div className="text-center mb-12">
          <div className="inline-flex p-3 rounded-2xl bg-gradient-to-br from-orange-500/20 to-orange-600/10 border border-orange-500/20 mb-6">
            <Sparkles className="h-8 w-8 text-orange-400" />
          </div>
          <h1 className="text-3xl sm:text-4xl font-bold text-slate-100 mb-4">
            Search the Registry
          </h1>
          <p className="text-lg text-slate-400">
            Find modules, templates, and contributors
          </p>
        </div>

        {/* Search Input */}
        <div className="relative mb-10">
          <SearchIcon className="absolute left-5 top-1/2 -translate-y-1/2 h-6 w-6 text-slate-500" />
          <Input
            type="text"
            placeholder="Search for modules, templates, or contributors..."
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            className="pl-14 h-14 text-lg bg-slate-900/50 border-slate-700 focus:border-orange-500/50 rounded-2xl"
            autoFocus
          />
        </div>

        {/* Quick Links */}
        {!query && (
          <div className="mb-12">
            <h2 className="text-xs font-semibold text-slate-500 mb-4 uppercase tracking-wider">
              Quick Links
            </h2>
            <div className="flex flex-wrap gap-3">
              {quickLinks.map((link, i) => (
                <Link key={i} href={link.href}>
                  <Badge
                    variant="secondary"
                    className="cursor-pointer px-4 py-2 text-sm hover:bg-slate-700 transition-colors"
                  >
                    <link.icon className="h-3.5 w-3.5 mr-2 text-orange-400" />
                    {link.label}
                  </Badge>
                </Link>
              ))}
            </div>
          </div>
        )}

        {/* Results */}
        {query && (
          <div className="space-y-4">
            {isLoading ? (
              <div className="space-y-4">
                {[...Array(3)].map((_, i) => (
                  <div key={i} className="h-24 rounded-2xl shimmer" />
                ))}
              </div>
            ) : filteredResults.length > 0 ? (
              <>
                <p className="text-sm text-slate-500 mb-6">
                  <span className="text-orange-400 font-semibold">{filteredResults.length}</span>{" "}
                  result{filteredResults.length !== 1 ? "s" : ""} for &quot;{query}&quot;
                </p>
                {filteredResults.map((result, i) => (
                  <Link key={i} href={getLink(result)} className="block group">
                    <div className="card-interactive p-5">
                      <div className="flex items-start gap-4">
                        <div className="icon-container">
                          {getIcon(result.type)}
                        </div>
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-3 mb-2">
                            <h3 className="font-semibold text-slate-100 group-hover:text-orange-400 transition-colors">
                              {result.displayName}
                            </h3>
                            <Badge variant="secondary" className="text-[10px]">
                              {result.type}
                            </Badge>
                          </div>
                          <p className="text-sm text-slate-500 mb-3">
                            {result.description}
                          </p>
                          {result.tags && (
                            <div className="flex flex-wrap gap-2">
                              {result.tags.slice(0, 4).map((tag) => (
                                <Badge key={tag} variant="outline" className="text-[10px]">
                                  {tag}
                                </Badge>
                              ))}
                            </div>
                          )}
                        </div>
                        <ArrowUpRight className="h-5 w-5 text-slate-700 opacity-0 group-hover:opacity-100 group-hover:text-orange-400 transition-all" />
                      </div>
                    </div>
                  </Link>
                ))}
              </>
            ) : (
              <div className="text-center py-16 card-base">
                <div className="icon-container-lg mx-auto mb-6">
                  <SearchIcon className="h-8 w-8 text-orange-400" />
                </div>
                <h3 className="text-xl font-semibold text-slate-100 mb-3">
                  No results found
                </h3>
                <p className="text-slate-500 max-w-md mx-auto mb-6">
                  Try different keywords or browse the categories above
                </p>
                <Link href="/modules">
                  <Button variant="outline">
                    Browse All Modules
                    <ArrowUpRight className="ml-2 h-4 w-4" />
                  </Button>
                </Link>
              </div>
            )}
          </div>
        )}

        {/* CTA */}
        {!query && (
          <div className="text-center pt-8 border-t border-slate-800">
            <p className="text-slate-500 mb-4">
              Can&apos;t find what you&apos;re looking for?
            </p>
            <a
              href="https://github.com/latticeHQ/registry/blob/main/CONTRIBUTING.md"
              target="_blank"
              rel="noopener noreferrer"
            >
              <Button variant="outline">
                <GitBranch className="mr-2 h-4 w-4" />
                Contribute to the Registry
              </Button>
            </a>
          </div>
        )}
      </div>
    </div>
  );
}
