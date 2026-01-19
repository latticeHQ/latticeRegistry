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
      <div className="mb-10">
        <form className="relative">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-500" />
          <Input
            name="q"
            placeholder="Search templates..."
            defaultValue={params.q}
            className="pl-12 h-12 text-base bg-slate-900/50 border-slate-700 focus:border-orange-500/50"
          />
        </form>
      </div>

      {/* Results */}
      {filteredTemplates.length > 0 ? (
        <>
          <div className="flex items-center justify-between mb-6">
            <p className="text-sm text-slate-500">
              <span className="text-orange-400 font-semibold">{filteredTemplates.length}</span>{" "}
              template{filteredTemplates.length !== 1 && "s"}
              {params.q && <span className="text-slate-400"> matching &quot;{params.q}&quot;</span>}
            </p>
            <a
              href="https://github.com/latticeHQ/registry"
              target="_blank"
              rel="noopener noreferrer"
              className="text-sm text-slate-500 hover:text-orange-400 transition-colors flex items-center gap-1.5"
            >
              <GitBranch className="h-3.5 w-3.5" />
              Contribute
            </a>
          </div>
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {filteredTemplates.map((template) => (
              <ModuleCard key={template.slug} module={template} type="template" />
            ))}
          </div>
        </>
      ) : (
        <div className="text-center py-20 card-base">
          <div className="icon-container-lg mx-auto mb-6">
            <Box className="h-8 w-8 text-orange-400" />
          </div>
          <h3 className="text-xl font-semibold text-slate-100 mb-3">
            No templates found
          </h3>
          <p className="text-slate-500 max-w-md mx-auto mb-6">
            {params.q
              ? `No templates match "${params.q}". Try a different search term.`
              : "No templates available yet. Be the first to contribute!"}
          </p>
          <a
            href="https://github.com/latticeHQ/registry/blob/main/CONTRIBUTING.md"
            target="_blank"
            rel="noopener noreferrer"
          >
            <Button>
              Contribute a Template
              <ArrowUpRight className="ml-2 h-4 w-4" />
            </Button>
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
        <div className="absolute inset-0 grid-pattern opacity-30" />
        <div className="absolute bottom-1/4 left-0 w-96 h-96 bg-orange-500/5 rounded-full blur-3xl" />
      </div>

      <div className="relative mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-12 md:py-16">
        {/* Header */}
        <div className="mb-12">
          <div className="flex items-center gap-3 mb-4">
            <div className="icon-container">
              <Boxes className="h-5 w-5 text-orange-400" />
            </div>
            <Badge variant="secondary">Registry</Badge>
          </div>
          <h1 className="text-3xl sm:text-4xl font-bold text-slate-100 mb-4">
            Templates
          </h1>
          <p className="text-lg text-slate-400 max-w-2xl">
            Pre-configured agent workspace definitions for Lattice Runtime.
            Complete configurations to accelerate your AI agent deployments.
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
          <TemplatesList searchParams={searchParams} />
        </Suspense>
      </div>
    </div>
  );
}
