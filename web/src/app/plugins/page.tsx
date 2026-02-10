import { Suspense } from "react";
import { getAllPlugins } from "@/lib/registry";
import { ModuleCard } from "@/components/module-card";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Search, Puzzle, ArrowUpRight } from "lucide-react";

export const metadata = {
  title: "Plugins - Lattice Registry",
  description: "Browse knowledge-work plugin packs for Lattice Workbench",
};

async function PluginsList({
  searchParams,
}: {
  searchParams: Promise<{ category?: string; q?: string }>;
}) {
  const params = await searchParams;
  const plugins = await getAllPlugins();

  // Map plugins to Module-compatible shape for ModuleCard reuse
  const pluginModules = plugins.map((p) => ({
    namespace: p.namespace,
    name: p.name,
    slug: p.slug,
    frontmatter: {
      display_name: p.frontmatter.display_name,
      description: p.frontmatter.description,
      icon: p.frontmatter.icon,
      verified: p.frontmatter.verified,
      tags: p.frontmatter.tags,
    },
    content: p.content,
    htmlContent: p.htmlContent,
  }));

  let filteredPlugins = pluginModules;

  // Filter by category
  if (params.category) {
    filteredPlugins = filteredPlugins.filter((p) =>
      p.frontmatter.tags?.some((tag) =>
        tag.toLowerCase().includes(params.category!.toLowerCase())
      )
    );
  }

  // Filter by search query
  if (params.q) {
    const query = params.q.toLowerCase();
    filteredPlugins = filteredPlugins.filter(
      (p) =>
        p.name.toLowerCase().includes(query) ||
        p.frontmatter.display_name.toLowerCase().includes(query) ||
        p.frontmatter.description.toLowerCase().includes(query) ||
        p.frontmatter.tags?.some((tag) => tag.toLowerCase().includes(query))
    );
  }

  // Get all unique tags
  const allTags = Array.from(
    new Set(pluginModules.flatMap((p) => p.frontmatter.tags || []))
  ).sort();

  return (
    <div>
      {/* Search and Filters */}
      <div className="mb-8">
        <form className="relative mb-6">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4" style={{ color: "#999999" }} />
          <Input
            name="q"
            placeholder="Search plugins..."
            defaultValue={params.q}
            className="pl-11 h-11 text-sm"
            style={{ background: "#ffffff", border: "1px solid #e0e0d8", color: "#1a1a1a" }}
          />
        </form>

        {/* Tags */}
        {allTags.length > 0 && (
          <div className="flex items-center gap-2 flex-wrap">
            <a href="/plugins">
              <Badge
                variant={!params.category ? "default" : "outline"}
                className="cursor-pointer text-xs"
                style={{
                  background: !params.category ? "#d97706" : "transparent",
                  borderColor: "#e0e0d8",
                  color: !params.category ? "#ffffff" : "#666666"
                }}
              >
                All
              </Badge>
            </a>
            {allTags.map((tag) => (
              <a key={tag} href={`/plugins?category=${tag}`}>
                <Badge
                  variant={params.category === tag ? "default" : "outline"}
                  className="cursor-pointer text-xs"
                  style={{
                    background: params.category === tag ? "#d97706" : "transparent",
                    borderColor: "#e0e0d8",
                    color: params.category === tag ? "#ffffff" : "#666666"
                  }}
                >
                  {tag}
                </Badge>
              </a>
            ))}
          </div>
        )}
      </div>

      {/* Results */}
      {filteredPlugins.length > 0 ? (
        <>
          <div className="flex items-center justify-between mb-5">
            <p className="text-xs" style={{ color: "#666666" }}>
              Displaying <span style={{ color: "#1a1a1a", fontWeight: "500" }}>{filteredPlugins.length}</span>{" "}
              plugin{filteredPlugins.length !== 1 && "s"}
            </p>
          </div>
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-5">
            {filteredPlugins.map((plugin) => (
              <ModuleCard key={plugin.slug} module={plugin} type="plugin" />
            ))}
          </div>
        </>
      ) : (
        <div className="text-center py-20 card-base">
          <div className="icon-container-lg mx-auto mb-6">
            <Puzzle className="h-8 w-8 text-orange-400" />
          </div>
          <h3 className="text-xl font-semibold mb-3" style={{ color: "#1a1a1a" }}>
            No plugins found
          </h3>
          <p className="max-w-md mx-auto mb-6" style={{ color: "#666666" }}>
            {params.q
              ? `No plugins match "${params.q}". Try a different search term.`
              : "No plugins available yet. Be the first to contribute!"}
          </p>
          <a
            href="https://github.com/latticeHQ/registry/blob/main/CONTRIBUTING.md"
            target="_blank"
            rel="noopener noreferrer"
          >
            <Button>
              Contribute a Plugin
              <ArrowUpRight className="ml-2 h-4 w-4" />
            </Button>
          </a>
        </div>
      )}
    </div>
  );
}

export default async function PluginsPage({
  searchParams,
}: {
  searchParams: Promise<{ category?: string; q?: string }>;
}) {
  return (
    <div className="relative min-h-screen">
      {/* Background */}
      <div className="fixed inset-0 pointer-events-none">
        <div className="absolute inset-0 bg-grid-subtle" />
        <div className="absolute top-1/4 right-0 w-96 h-96 bg-gradient-radial blur-3xl" />
      </div>

      <div className="relative mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-16 md:py-20">
        {/* Header */}
        <div className="mb-12">
          <div className="flex items-center gap-3 mb-6">
            <div className="badge-base">Registry</div>
            <span style={{ color: "#e0e0d8" }}>→</span>
            <span className="text-sm" style={{ color: "#666666" }}>Plugins</span>
          </div>
          <h1 className="text-5xl sm:text-6xl font-bold mb-5 tracking-tight" style={{ color: "#1a1a1a" }}>
            Plugins
          </h1>
          <p className="text-lg max-w-3xl leading-relaxed" style={{ color: "#666666" }}>
            Knowledge-work plugin packs for Lattice Workbench. Domain-specific skills, commands,
            and MCP server integrations for sales, support, marketing, legal, finance, and more.
          </p>
        </div>

        <Suspense
          fallback={
            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
              {[...Array(6)].map((_, i) => (
                <div
                  key={i}
                  className="h-48 rounded-2xl shimmer"
                />
              ))}
            </div>
          }
        >
          <PluginsList searchParams={searchParams} />
        </Suspense>
      </div>
    </div>
  );
}
