import { Suspense } from "react";
import { getAllPresets } from "@/lib/registry";
import { PresetCard } from "@/components/preset-card";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Search, Sparkles, ArrowUpRight } from "lucide-react";

export const metadata = {
  title: "Presets - Lattice Registry",
  description: "Browse AI presets for training and evaluation sessions",
};

async function PresetsList({
  searchParams,
}: {
  searchParams: Promise<{ category?: string; domain?: string; q?: string }>;
}) {
  const params = await searchParams;
  const presets = await getAllPresets();

  let filteredPresets = presets;

  // Filter by category
  if (params.category) {
    filteredPresets = filteredPresets.filter(
      (p) => p.frontmatter.category?.toLowerCase() === params.category!.toLowerCase()
    );
  }

  // Filter by domain
  if (params.domain) {
    filteredPresets = filteredPresets.filter(
      (p) => p.frontmatter.domain?.toLowerCase() === params.domain!.toLowerCase()
    );
  }

  // Filter by search query
  if (params.q) {
    const query = params.q.toLowerCase();
    filteredPresets = filteredPresets.filter(
      (p) =>
        p.name.toLowerCase().includes(query) ||
        p.frontmatter.display_name.toLowerCase().includes(query) ||
        p.frontmatter.description.toLowerCase().includes(query) ||
        p.frontmatter.tags?.some((tag) => tag.toLowerCase().includes(query))
    );
  }

  // Get unique categories and domains
  const allCategories = Array.from(
    new Set(presets.map((p) => p.frontmatter.category).filter(Boolean))
  ).sort();

  const allDomains = Array.from(
    new Set(presets.map((p) => p.frontmatter.domain).filter(Boolean))
  ).sort();

  return (
    <div>
      {/* Search and Filters */}
      <div className="mb-8">
        <form className="relative mb-6">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4" style={{ color: "#999999" }} />
          <Input
            name="q"
            placeholder="Search presets..."
            defaultValue={params.q}
            className="pl-11 h-11 text-sm"
            style={{ background: "#ffffff", border: "1px solid #e0e0d8", color: "#1a1a1a" }}
          />
        </form>

        {/* Category Filters */}
        {allCategories.length > 0 && (
          <div className="mb-4">
            <p className="text-xs uppercase tracking-wide font-medium mb-2" style={{ color: "#999999" }}>
              Category
            </p>
            <div className="flex items-center gap-2 flex-wrap">
              <a href="/presets">
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
              {allCategories.map((category) => (
                <a key={category} href={`/presets?category=${category}`}>
                  <Badge
                    variant={params.category === category ? "default" : "outline"}
                    className="cursor-pointer text-xs"
                    style={{
                      background: params.category === category ? "#d97706" : "transparent",
                      borderColor: "#e0e0d8",
                      color: params.category === category ? "#ffffff" : "#666666"
                    }}
                  >
                    {category}
                  </Badge>
                </a>
              ))}
            </div>
          </div>
        )}

        {/* Domain Filters */}
        {allDomains.length > 0 && (
          <div>
            <p className="text-xs uppercase tracking-wide font-medium mb-2" style={{ color: "#999999" }}>
              Domain
            </p>
            <div className="flex items-center gap-2 flex-wrap">
              <a href={params.category ? `/presets?category=${params.category}` : "/presets"}>
                <Badge
                  variant={!params.domain ? "default" : "outline"}
                  className="cursor-pointer text-xs"
                  style={{
                    background: !params.domain ? "#d97706" : "transparent",
                    borderColor: "#e0e0d8",
                    color: !params.domain ? "#ffffff" : "#666666"
                  }}
                >
                  All
                </Badge>
              </a>
              {allDomains.map((domain) => (
                <a
                  key={domain}
                  href={params.category ? `/presets?category=${params.category}&domain=${domain}` : `/presets?domain=${domain}`}
                >
                  <Badge
                    variant={params.domain === domain ? "default" : "outline"}
                    className="cursor-pointer text-xs"
                    style={{
                      background: params.domain === domain ? "#d97706" : "transparent",
                      borderColor: "#e0e0d8",
                      color: params.domain === domain ? "#ffffff" : "#666666"
                    }}
                  >
                    {domain}
                  </Badge>
                </a>
              ))}
            </div>
          </div>
        )}
      </div>

      {/* Results */}
      {filteredPresets.length > 0 ? (
        <>
          <div className="flex items-center justify-between mb-5">
            <p className="text-xs" style={{ color: "#666666" }}>
              Displaying <span style={{ color: "#1a1a1a", fontWeight: "500" }}>{filteredPresets.length}</span>{" "}
              preset{filteredPresets.length !== 1 && "s"}
            </p>
          </div>
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-5">
            {filteredPresets.map((preset) => (
              <PresetCard key={preset.slug} preset={preset} />
            ))}
          </div>
        </>
      ) : (
        <div className="text-center py-20 card-base">
          <div className="icon-container-lg mx-auto mb-6">
            <Sparkles className="h-8 w-8" style={{ color: "#d97706" }} />
          </div>
          <h3 className="text-xl font-semibold mb-3" style={{ color: "#1a1a1a" }}>
            No presets found
          </h3>
          <p className="max-w-md mx-auto mb-6" style={{ color: "#666666" }}>
            {params.q
              ? `No presets match "${params.q}". Try a different search term.`
              : "No presets available yet. Be the first to contribute!"}
          </p>
          <a
            href="https://github.com/latticeHQ/registry/blob/main/CONTRIBUTING.md"
            target="_blank"
            rel="noopener noreferrer"
            className="btn-primary inline-flex items-center gap-2"
          >
            Contribute a Preset
            <ArrowUpRight className="h-4 w-4" />
          </a>
        </div>
      )}
    </div>
  );
}

export default async function PresetsPage({
  searchParams,
}: {
  searchParams: Promise<{ category?: string; domain?: string; q?: string }>;
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
            <span style={{ color: "#e0e0d8" }}>&rarr;</span>
            <span className="text-sm" style={{ color: "#666666" }}>Presets</span>
          </div>
          <h1 className="text-5xl sm:text-6xl font-bold mb-5 tracking-tight" style={{ color: "#1a1a1a" }}>
            Presets
          </h1>
          <p className="text-lg max-w-3xl leading-relaxed" style={{ color: "#666666" }}>
            AI presets for training and evaluation sessions. Pre-configured scenarios,
            personas, and instructions to accelerate your agent training workflows.
          </p>
        </div>

        <Suspense
          fallback={
            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-5">
              {[...Array(6)].map((_, i) => (
                <div
                  key={i}
                  className="h-48 rounded-xl card-base animate-pulse"
                />
              ))}
            </div>
          }
        >
          <PresetsList searchParams={searchParams} />
        </Suspense>
      </div>
    </div>
  );
}
