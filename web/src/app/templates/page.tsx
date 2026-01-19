import { Suspense } from "react";
import { getAllTemplates } from "@/lib/registry";
import { ModuleCard } from "@/components/module-card";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Search, Box, Boxes, ArrowUpRight, GitBranch } from "lucide-react";

export const metadata = {
  title: "Templates - Lattice Registry",
  description: "Browse complete workspace templates for Lattice Runtime",
};

async function TemplatesList({ searchParams }: { searchParams: Promise<{ q?: string }> }) {
  const params = await searchParams;
  const templates = await getAllTemplates();

  let filteredTemplates = templates;

  if (params.q) {
    const query = params.q.toLowerCase();
    filteredTemplates = filteredTemplates.filter(
      (t) =>
        t.name.toLowerCase().includes(query) ||
        t.frontmatter.display_name.toLowerCase().includes(query) ||
        t.frontmatter.description.toLowerCase().includes(query)
    );
  }

  return (
    <div>
      {/* Search */}
      <div className="mb-8">
        <form className="relative">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4" style={{ color: "#999999" }} />
          <Input
            name="q"
            placeholder="Search templates..."
            defaultValue={params.q}
            className="pl-11 h-11 text-sm"
            style={{ background: "#ffffff", border: "1px solid #e0e0d8", color: "#1a1a1a" }}
          />
        </form>
      </div>

      {/* Results */}
      {filteredTemplates.length > 0 ? (
        <>
          <div className="flex items-center justify-between mb-5">
            <p className="text-xs" style={{ color: "#666666" }}>
              Displaying <span style={{ color: "#1a1a1a", fontWeight: "500" }}>{filteredTemplates.length}</span>{" "}
              template{filteredTemplates.length !== 1 && "s"}
            </p>
          </div>
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-5">
            {filteredTemplates.map((template) => (
              <ModuleCard key={template.slug} module={template} type="template" />
            ))}
          </div>
        </>
      ) : (
        <div className="text-center py-20 card-base">
          <div className="icon-container-lg mx-auto mb-6">
            <Box className="h-8 w-8" style={{ color: "#d97706" }} />
          </div>
          <h3 className="text-xl font-semibold mb-3" style={{ color: "#1a1a1a" }}>
            No templates found
          </h3>
          <p className="max-w-md mx-auto mb-6" style={{ color: "#666666" }}>
            {params.q
              ? `No templates match "${params.q}". Try a different search term.`
              : "No templates available yet. Be the first to contribute!"}
          </p>
          <a
            href="https://github.com/latticeHQ/registry/blob/main/CONTRIBUTING.md"
            target="_blank"
            rel="noopener noreferrer"
            className="btn-primary inline-flex items-center gap-2"
          >
            Contribute a Template
            <ArrowUpRight className="h-4 w-4" />
          </a>
        </div>
      )}
    </div>
  );
}

export default async function TemplatesPage({
  searchParams,
}: {
  searchParams: Promise<{ q?: string }>;
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
            <span className="text-sm" style={{ color: "#666666" }}>Templates</span>
          </div>
          <h1 className="text-5xl sm:text-6xl font-bold mb-5 tracking-tight" style={{ color: "#1a1a1a" }}>
            Templates
          </h1>
          <p className="text-lg max-w-3xl leading-relaxed" style={{ color: "#666666" }}>
            Pre-configured agent workspace definitions for Lattice Runtime.
            Complete configurations to accelerate your AI agent deployments.
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
          <TemplatesList searchParams={searchParams} />
        </Suspense>
      </div>
    </div>
  );
}
