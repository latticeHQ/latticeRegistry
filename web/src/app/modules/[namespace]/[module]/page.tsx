import { notFound } from "next/navigation";
import Link from "next/link";
import { getModule, getNamespace } from "@/lib/registry";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  CheckCircle2,
  Github,
  ArrowLeft,
  ArrowUpRight,
} from "lucide-react";
import { ContributorAvatar } from "@/components/contributor-avatar";
import { ModuleTabs } from "@/components/module-tabs";
import { CodeBlock } from "@/components/code-block";
import { ModuleIcon } from "@/components/module-icon";

interface PageProps {
  params: Promise<{
    namespace: string;
    module: string;
  }>;
}

export async function generateMetadata({ params }: PageProps) {
  const { namespace, module: moduleName } = await params;
  const moduleData = await getModule(namespace, moduleName);

  if (!moduleData) {
    return { title: "Module Not Found - Lattice Registry" };
  }

  return {
    title: `${moduleData.frontmatter.display_name || moduleData.name} - Lattice Registry`,
    description: moduleData.frontmatter.description,
  };
}

export default async function ModulePage({ params }: PageProps) {
  const { namespace, module: moduleName } = await params;
  const moduleData = await getModule(namespace, moduleName);
  const namespaceData = await getNamespace(namespace);

  if (!moduleData) {
    notFound();
  }

  // Use the github field if available, otherwise fall back to namespace name
  const githubUsername = namespaceData?.frontmatter.github || namespace;

  const usageCode = `module "${moduleName}" {
  source   = "registry.latticeruntime.com/${namespace}/${moduleName}/lattice"
  version  = "1.0.0"

  # Configure module inputs
  sidecar_id = lattice_agent.main.id
}`;

  const sourceUrl = `https://github.com/latticeHQ/registry/tree/main/registry/${namespace}/modules/${moduleName}`;

  // Get icon path
  function getIconPath(iconRelativePath: string): string {
    const iconName = iconRelativePath.split('/').pop() || 'default.svg';
    return `/icons/${iconName}`;
  }

  const iconPath = moduleData.frontmatter.icon ? getIconPath(moduleData.frontmatter.icon) : null;

  return (
    <div className="relative min-h-screen">
      {/* Background */}
      <div className="fixed inset-0 pointer-events-none">
        <div className="absolute inset-0 bg-grid-subtle" />
        <div className="absolute top-1/4 right-0 w-96 h-96 bg-gradient-radial blur-3xl" />
      </div>

      <div className="relative mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-16">
        {/* Breadcrumb */}
        <div className="mb-10">
          <Link
            href="/modules"
            className="inline-flex items-center text-sm font-medium transition-colors text-[#666666] hover:text-[#d97706]"
          >
            <ArrowLeft className="h-4 w-4 mr-2" />
            Back to Modules
          </Link>
        </div>

        <div className="grid lg:grid-cols-3 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-2">
            {/* Header */}
            <div className="flex items-start gap-5 mb-8">
              <div className="icon-container-lg">
                <ModuleIcon
                  iconPath={iconPath}
                  displayName={moduleData.frontmatter.display_name || moduleData.name}
                />
              </div>
              <div className="flex-1">
                <div className="flex items-center gap-3 mb-2">
                  <h1 className="text-4xl font-bold text-[#1a1a1a] tracking-tight">
                    {moduleData.frontmatter.display_name || moduleData.name}
                  </h1>
                  {moduleData.frontmatter.verified && (
                    <CheckCircle2 className="h-6 w-6 text-[#10b981]" />
                  )}
                </div>
                <p className="text-[#666666] font-mono text-sm">
                  {namespace}/{moduleName}
                </p>
              </div>
            </div>

            {/* Description */}
            <p className="text-base text-[#666666] mb-8 leading-relaxed">
              {moduleData.frontmatter.description}
            </p>

            {/* Tags */}
            {moduleData.frontmatter.tags && moduleData.frontmatter.tags.length > 0 && (
              <div className="flex gap-2 mb-10">
                {moduleData.frontmatter.tags.map((tag) => (
                  <Link key={tag} href={`/modules?category=${tag}`}>
                    <div
                      className="badge-base transition-smooth hover:border-[rgba(217,119,6,0.3)] hover:bg-[rgba(217,119,6,0.1)]"
                    >
                      {tag}
                    </div>
                  </Link>
                ))}
              </div>
            )}

            {/* Usage */}
            <div className="card-base p-6 mb-8">
              <h3 className="text-sm font-semibold text-[#1a1a1a] mb-4">Quick Start</h3>
              <CodeBlock code={usageCode} />
            </div>

            {/* Tabbed Content */}
            <ModuleTabs
              readme={moduleData.htmlContent}
              variables={{
                inputs: moduleData.inputs || [],
                outputs: moduleData.outputs || [],
              }}
              sourceUrl={sourceUrl}
            />
          </div>

          {/* Sidebar */}
          <div className="lg:col-span-1">
            <div className="sticky top-24 space-y-5">
              {/* Contributor */}
              {namespaceData && (
                <div className="card-base overflow-hidden">
                  <div className="p-4 border-b" style={{ borderColor: "#e0e0d8" }}>
                    <h4 className="text-xs uppercase tracking-wide font-semibold" style={{ color: "#999999" }}>
                      Published by
                    </h4>
                  </div>
                  <div className="p-4">
                    <Link
                      href={`/contributors/${namespace}`}
                      className="flex items-center gap-3 -m-2 p-2 rounded-lg transition-all group hover:bg-[#ebe9e1]"
                    >
                      <ContributorAvatar
                        githubUsername={githubUsername}
                        displayName={namespaceData.frontmatter.display_name || namespace}
                        size="sm"
                      />
                      <div>
                        <div className="font-medium text-[#1a1a1a] group-hover:text-[#d97706] transition-colors">
                          {namespaceData.frontmatter.display_name || namespace}
                        </div>
                        <div className="text-sm text-[#666666] flex items-center gap-1">
                          <Github className="h-3 w-3" />
                          @{githubUsername}
                        </div>
                      </div>
                    </Link>
                  </div>
                </div>
              )}

              {/* Links */}
              <div className="card-base overflow-hidden">
                <div className="p-4 border-b" style={{ borderColor: "#e0e0d8" }}>
                  <h4 className="text-xs uppercase tracking-wide font-semibold" style={{ color: "#999999" }}>
                    Links
                  </h4>
                </div>
                <div className="p-4 space-y-2">
                  <a
                    href={`https://github.com/latticeHQ/registry/tree/main/registry/${namespace}/modules/${moduleName}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-2 text-sm p-2 rounded-lg transition-all text-[#666666] hover:text-[#d97706] hover:bg-[rgba(217,119,6,0.1)]"
                  >
                    <Github className="h-4 w-4" />
                    View Source
                    <ArrowUpRight className="h-3 w-3 ml-auto" />
                  </a>
                  <a
                    href={`https://github.com/latticeHQ/registry/issues/new?title=Issue%20with%20${namespace}/${moduleName}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-2 text-sm p-2 rounded-lg transition-all text-[#666666] hover:text-[#d97706] hover:bg-[rgba(217,119,6,0.1)]"
                  >
                    Report Issue
                    <ArrowUpRight className="h-3 w-3 ml-auto" />
                  </a>
                </div>
              </div>

              {/* Install */}
              <div className="card-base overflow-hidden" style={{ background: "rgba(217, 119, 6, 0.1)", borderColor: "rgba(217, 119, 6, 0.2)" }}>
                <div className="p-5">
                  <p className="text-sm text-[#666666] mb-4 font-medium">
                    Add to your template:
                  </p>
                  <CodeBlock code={`source = "registry.latticeruntime.com/${namespace}/${moduleName}/lattice"`} />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
