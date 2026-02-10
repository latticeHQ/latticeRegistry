import { notFound } from "next/navigation";
import Link from "next/link";
import { getPlugin, getNamespace } from "@/lib/registry";
import { Badge } from "@/components/ui/badge";
import {
  CheckCircle2,
  Github,
  ArrowLeft,
  ArrowUpRight,
} from "lucide-react";
import { ContributorAvatar } from "@/components/contributor-avatar";
import { ModuleIcon } from "@/components/module-icon";

interface PageProps {
  params: Promise<{
    namespace: string;
    plugin: string;
  }>;
}

export async function generateMetadata({ params }: PageProps) {
  const { namespace, plugin: pluginName } = await params;
  const pluginData = await getPlugin(namespace, pluginName);

  if (!pluginData) {
    return { title: "Plugin Not Found - Lattice Registry" };
  }

  return {
    title: `${pluginData.frontmatter.display_name || pluginData.name} - Lattice Registry`,
    description: pluginData.frontmatter.description,
  };
}

export default async function PluginPage({ params }: PageProps) {
  const { namespace, plugin: pluginName } = await params;
  const pluginData = await getPlugin(namespace, pluginName);
  const namespaceData = await getNamespace(namespace);

  if (!pluginData) {
    notFound();
  }

  const githubUsername = namespaceData?.frontmatter.github || namespace;

  const sourceUrl = `https://github.com/latticeHQ/registry/tree/main/registry/${namespace}/plugins/${pluginName}`;

  function getIconPath(iconRelativePath: string): string {
    const iconName = iconRelativePath.split('/').pop() || 'default.svg';
    return `/icons/${iconName}`;
  }

  const iconPath = pluginData.frontmatter.icon ? getIconPath(pluginData.frontmatter.icon) : null;

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
            href="/plugins"
            className="inline-flex items-center text-sm font-medium transition-colors text-[#666666] hover:text-[#d97706]"
          >
            <ArrowLeft className="h-4 w-4 mr-2" />
            Back to Plugins
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
                  displayName={pluginData.frontmatter.display_name || pluginData.name}
                />
              </div>
              <div className="flex-1">
                <div className="flex items-center gap-3 mb-2">
                  <h1 className="text-4xl font-bold text-[#1a1a1a] tracking-tight">
                    {pluginData.frontmatter.display_name || pluginData.name}
                  </h1>
                  {pluginData.frontmatter.verified && (
                    <CheckCircle2 className="h-6 w-6 text-[#10b981]" />
                  )}
                </div>
                <p className="text-[#666666] font-mono text-sm">
                  {namespace}/{pluginName}
                </p>
              </div>
            </div>

            {/* Description */}
            <p className="text-base text-[#666666] mb-8 leading-relaxed">
              {pluginData.frontmatter.description}
            </p>

            {/* Tags */}
            {pluginData.frontmatter.tags && pluginData.frontmatter.tags.length > 0 && (
              <div className="flex gap-2 mb-10">
                {pluginData.frontmatter.tags.map((tag) => (
                  <Link key={tag} href={`/plugins?category=${tag}`}>
                    <div
                      className="badge-base transition-smooth hover:border-[rgba(217,119,6,0.3)] hover:bg-[rgba(217,119,6,0.1)]"
                    >
                      {tag}
                    </div>
                  </Link>
                ))}
              </div>
            )}

            {/* Content */}
            <div className="card-base p-6">
              <div
                className="prose prose-sm max-w-none"
                dangerouslySetInnerHTML={{ __html: pluginData.htmlContent }}
              />
            </div>
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
                    href={sourceUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-2 text-sm p-2 rounded-lg transition-all text-[#666666] hover:text-[#d97706] hover:bg-[rgba(217,119,6,0.1)]"
                  >
                    <Github className="h-4 w-4" />
                    View Source
                    <ArrowUpRight className="h-3 w-3 ml-auto" />
                  </a>
                  <a
                    href={`https://github.com/latticeHQ/registry/issues/new?title=Issue%20with%20${namespace}/${pluginName}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-2 text-sm p-2 rounded-lg transition-all text-[#666666] hover:text-[#d97706] hover:bg-[rgba(217,119,6,0.1)]"
                  >
                    Report Issue
                    <ArrowUpRight className="h-3 w-3 ml-auto" />
                  </a>
                </div>
              </div>

              {/* Install hint */}
              <div className="card-base overflow-hidden" style={{ background: "rgba(217, 119, 6, 0.1)", borderColor: "rgba(217, 119, 6, 0.2)" }}>
                <div className="p-5">
                  <p className="text-sm text-[#666666] mb-2 font-medium">
                    Enable in Lattice Workbench:
                  </p>
                  <p className="text-xs text-[#999999]">
                    Settings → Plugin Packs → Enable "{pluginData.frontmatter.display_name}"
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
