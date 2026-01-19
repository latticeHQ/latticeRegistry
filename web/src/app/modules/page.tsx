import { Suspense } from "react";
import { getAllModules } from "@/lib/registry";
import { ModuleCard } from "@/components/module-card";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Search, Package, Filter, Layers, ArrowUpRight, GitBranch } from "lucide-react";
import Link from "next/link";

export const metadata = {
  title: "Modules - Lattice Registry",
  description: "Browse all Terraform modules for Lattice Runtime deployments",
};

async function ModulesList({
  searchParams,
}: {
  searchParams: Promise<{ category?: string; q?: string }>;
}) {
  const params = await searchParams;
  const modules = await getAllModules();

  let filteredModules = modules;

  // Filter by category
  if (params.category) {
    filteredModules = filteredModules.filter((m) =>
      m.frontmatter.tags?.some((tag) =>
        tag.toLowerCase().includes(params.category!.toLowerCase())
      )
    );
  }

  // Filter by search query
  if (params.q) {
    const query = params.q.toLowerCase();
    filteredModules = filteredModules.filter(
      (m) =>
        m.name.toLowerCase().includes(query) ||
        m.frontmatter.display_name.toLowerCase().includes(query) ||
        m.frontmatter.description.toLowerCase().includes(query) ||
        m.frontmatter.tags?.some((tag) => tag.toLowerCase().includes(query))
    );
  }

  // Get all unique tags
  const allTags = Array.from(
    new Set(modules.flatMap((m) => m.frontmatter.tags || []))
  ).sort();

  return (
    <div>
      {/* Search and Filters */}
      <div className="mb-8">
        <form className="relative mb-6">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4" style={{ color: "#999999" }} />
          <Input
            name="q"
            placeholder="Search modules..."
            defaultValue={params.q}
            className="pl-11 h-11 text-sm"
            style={{ background: "#ffffff", border: "1px solid #e0e0d8", color: "#1a1a1a" }}
          />
        </form>

        {/* Tags */}
        {allTags.length > 0 && (
          <div className="flex items-center gap-2 flex-wrap">
            <a href="/modules">
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
            {allTags.slice(0, 10).map((tag) => (
              <a key={tag} href={`/modules?category=${tag}`}>
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
      {filteredModules.length > 0 ? (
        <>
          <div className="flex items-center justify-between mb-5">
            <p className="text-xs" style={{ color: "#666666" }}>
              Displaying <span style={{ color: "#1a1a1a", fontWeight: "500" }}>{filteredModules.length}</span>{" "}
              module{filteredModules.length !== 1 && "s"}
            </p>
          </div>
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-5">
            {filteredModules.map((module) => (
              <ModuleCard key={module.slug} module={module} type="module" />
            ))}
          </div>
        </>
      ) : (
        <div className="text-center py-20 card-base">
          <div className="icon-container-lg mx-auto mb-6">
            <Package className="h-8 w-8 text-orange-400" />
          </div>
          <h3 className="text-xl font-semibold mb-3" style={{ color: "#1a1a1a" }}>
            No modules found
          </h3>
          <p className="max-w-md mx-auto mb-6" style={{ color: "#666666" }}>
            {params.q
              ? `No modules match "${params.q}". Try a different search term.`
              : "No modules available yet. Be the first to contribute!"}
          </p>
          <a
            href="https://github.com/latticeHQ/registry/blob/main/CONTRIBUTING.md"
            target="_blank"
            rel="noopener noreferrer"
          >
            <Button>
              Contribute a Module
              <ArrowUpRight className="ml-2 h-4 w-4" />
            </Button>
          </a>
        </div>
      )}
    </div>
  );
}

export default async function ModulesPage({
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
            <span className="text-sm" style={{ color: "#666666" }}>Modules</span>
          </div>
          <h1 className="text-5xl sm:text-6xl font-bold mb-5 tracking-tight" style={{ color: "#1a1a1a" }}>
            Modules
          </h1>
          <p className="text-lg max-w-3xl leading-relaxed" style={{ color: "#666666" }}>
            Modules extend Lattice Runtime with reusable components. Deploy identity providers, policy templates,
            AI framework integrations, monitoring systems, and more—all as Infrastructure as Code.
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
          <ModulesList searchParams={searchParams} />
        </Suspense>
      </div>
    </div>
  );
}
