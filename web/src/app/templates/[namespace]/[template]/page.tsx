import { notFound } from "next/navigation";
import Link from "next/link";
import { getTemplate, getNamespaces, getNamespace } from "@/lib/registry";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  ArrowLeft,
  Github,
  ArrowUpRight,
  Copy,
  Box,
  Terminal,
  Package,
  FileCode,
} from "lucide-react";
import { ContributorAvatar } from "@/components/contributor-avatar";

interface PageProps {
  params: Promise<{
    namespace: string;
    template: string;
  }>;
}

export async function generateStaticParams() {
  const namespaces = await getNamespaces();
  const params: { namespace: string; template: string }[] = [];

  for (const ns of namespaces) {
    for (const template of ns.templates) {
      params.push({
        namespace: ns.name,
        template: template.name,
      });
    }
  }

  return params;
}

export async function generateMetadata({ params }: PageProps) {
  const { namespace, template: templateName } = await params;
  const template = await getTemplate(namespace, templateName);

  if (!template) {
    return { title: "Template Not Found - Lattice Registry" };
  }

  return {
    title: `${template.frontmatter.display_name} - Lattice Registry`,
    description: template.frontmatter.description,
  };
}

export default async function TemplatePage({ params }: PageProps) {
  const { namespace, template: templateName } = await params;
  const template = await getTemplate(namespace, templateName);
  const namespaceData = await getNamespace(namespace);

  if (!template) {
    notFound();
  }

  // Use the github field if available, otherwise fall back to namespace name
  const githubUsername = namespaceData?.frontmatter.github || namespace;

  const repoUrl = `https://github.com/latticeHQ/registry/tree/main/registry/${namespace}/templates/${templateName}`;

  return (
    <div className="relative min-h-screen" style={{ backgroundColor: "#f5f5f0" }}>
      {/* Background */}
      <div className="fixed inset-0 pointer-events-none">
        <div className="absolute inset-0 grid-pattern opacity-20" />
      </div>

      <div className="relative mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-12">
        {/* Breadcrumb */}
        <div className="mb-8">
          <Link
            href="/templates"
            className="inline-flex items-center text-sm transition-colors"
            style={{ color: "#666666" }}
          >
            <ArrowLeft className="h-4 w-4 mr-2" />
            Back to Templates
          </Link>
        </div>

        <div className="grid lg:grid-cols-3 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-2">
            {/* Header */}
            <div className="mb-8">
              <div className="flex items-start gap-4 mb-4">
                <div className="icon-container-lg">
                  <Box className="h-7 w-7" style={{ color: "#d97706" }} />
                </div>
                <div className="flex-1">
                  <div className="flex items-center gap-3 flex-wrap mb-2">
                    <h1 className="text-2xl font-bold" style={{ color: "#1a1a1a" }}>
                      {template.frontmatter.display_name}
                    </h1>
                    {template.frontmatter.verified && (
                      <Badge variant="success">Verified</Badge>
                    )}
                  </div>
                  <p className="text-lg" style={{ color: "#666666" }}>
                    {template.frontmatter.description}
                  </p>
                </div>
              </div>

              {/* Tags */}
              {template.frontmatter.tags &&
                template.frontmatter.tags.length > 0 && (
                  <div className="flex flex-wrap gap-2 mb-6">
                    {template.frontmatter.tags.map((tag) => (
                      <Badge key={tag} variant="secondary">
                        {tag}
                      </Badge>
                    ))}
                  </div>
                )}

              {/* Quick Actions */}
              <div className="flex flex-wrap gap-3">
                <a href={repoUrl} target="_blank" rel="noopener noreferrer">
                  <Button>
                    <Github className="h-4 w-4 mr-2" />
                    View on GitHub
                  </Button>
                </a>
                <Button variant="outline">
                  <Copy className="h-4 w-4 mr-2" />
                  Copy Template
                </Button>
              </div>
            </div>

            {/* Usage */}
            <div className="card-base mb-8">
              <div className="p-6" style={{ borderBottom: "1px solid #e0e0d8" }}>
                <div className="flex items-center gap-2">
                  <Terminal className="h-5 w-5" style={{ color: "#d97706" }} />
                  <h2 className="text-lg font-semibold" style={{ color: "#1a1a1a" }}>
                    Quick Start
                  </h2>
                </div>
              </div>
              <div className="p-6">
                <div className="terminal-body">
                  <code style={{ color: "#059669" }}>
                    lattice template use {namespace}/{templateName}
                  </code>
                </div>
                <p className="mt-4 text-sm" style={{ color: "#666666" }}>
                  This will create a new workspace using this template
                  configuration.
                </p>
              </div>
            </div>

            {/* Terraform Code */}
            {template.terraformCode && (
              <div className="card-base mb-8">
                <div className="p-6" style={{ borderBottom: "1px solid #e0e0d8" }}>
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <FileCode className="h-5 w-5" style={{ color: "#d97706" }} />
                      <h2 className="text-lg font-semibold" style={{ color: "#1a1a1a" }}>
                        Template Configuration
                      </h2>
                    </div>
                    <Button variant="ghost" size="sm">
                      <Copy className="h-4 w-4 mr-2" />
                      Copy
                    </Button>
                  </div>
                </div>
                <div className="p-6">
                  <div className="terminal-body max-h-96 overflow-auto">
                    <pre style={{ color: "#666666" }}>{template.terraformCode}</pre>
                  </div>
                </div>
              </div>
            )}

            {/* Documentation */}
            <div className="card-base">
              <div className="p-6" style={{ borderBottom: "1px solid #e0e0d8" }}>
                <h2 className="text-lg font-semibold" style={{ color: "#1a1a1a" }}>Documentation</h2>
              </div>
              <div className="p-6">
                <div
                  className="prose prose-orange max-w-none"
                  style={{ color: "#666666" }}
                  dangerouslySetInnerHTML={{ __html: template.htmlContent }}
                />
              </div>
            </div>
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Publisher Info */}
            {namespaceData && (
              <div className="card-base">
                <div className="p-4" style={{ borderBottom: "1px solid #e0e0d8" }}>
                  <h4 className="text-xs uppercase tracking-wide font-medium" style={{ color: "#999999" }}>
                    Published by
                  </h4>
                </div>
                <div className="p-4">
                  <Link
                    href={`/contributors/${namespace}`}
                    className="flex items-center gap-3 -m-2 p-2 rounded-lg transition-colors group hover:bg-[rgba(217,119,6,0.05)]"
                  >
                    <ContributorAvatar
                      githubUsername={githubUsername}
                      displayName={namespaceData.frontmatter.display_name || namespace}
                      size="sm"
                    />
                    <div>
                      <div className="font-medium group-hover:text-[#d97706] transition-colors" style={{ color: "#1a1a1a" }}>
                        {namespaceData.frontmatter.display_name || namespace}
                      </div>
                      <div className="text-sm flex items-center gap-1" style={{ color: "#666666" }}>
                        <Github className="h-3 w-3" />
                        @{githubUsername}
                      </div>
                    </div>
                  </Link>
                </div>
              </div>
            )}

            {/* Template Info Card */}
            <div className="card-base">
              <div className="p-4" style={{ borderBottom: "1px solid #e0e0d8" }}>
                <h4 className="text-xs uppercase tracking-wide font-medium" style={{ color: "#999999" }}>
                  Template Info
                </h4>
              </div>
              <div className="p-4">
                <dl className="space-y-4">
                  <div>
                    <dt className="text-sm" style={{ color: "#666666" }}>
                      Template Name
                    </dt>
                    <dd className="mt-1 font-mono text-sm" style={{ color: "#1a1a1a" }}>
                      {templateName}
                    </dd>
                  </div>
                  <div>
                    <dt className="text-sm" style={{ color: "#666666" }}>
                      Full Reference
                    </dt>
                    <dd className="mt-1 font-mono text-sm px-2 py-1 rounded" style={{ backgroundColor: "#ebe9e1", color: "#666666" }}>
                      {namespace}/{templateName}
                    </dd>
                  </div>
                </dl>
              </div>
            </div>

            {/* Inputs Summary */}
            {template.inputs && template.inputs.length > 0 && (
              <div className="card-base">
                <div className="p-4" style={{ borderBottom: "1px solid #e0e0d8" }}>
                  <h4 className="text-xs uppercase tracking-wide font-medium" style={{ color: "#999999" }}>
                    Required Inputs
                  </h4>
                </div>
                <div className="p-4">
                  <ul className="space-y-2">
                    {template.inputs
                      .filter((input) => input.required)
                      .slice(0, 5)
                      .map((input) => (
                        <li
                          key={input.name}
                          className="flex items-start gap-2 text-sm"
                        >
                          <code className="px-1.5 py-0.5 rounded font-mono" style={{ backgroundColor: "#ebe9e1", color: "#d97706" }}>
                            {input.name}
                          </code>
                          <span style={{ color: "#666666" }}>
                            ({input.type})
                          </span>
                        </li>
                      ))}
                  </ul>
                  {template.inputs.filter((input) => input.required).length >
                    5 && (
                    <p className="text-sm mt-2" style={{ color: "#666666" }}>
                      +
                      {template.inputs.filter((input) => input.required)
                        .length - 5}{" "}
                      more required inputs
                    </p>
                  )}
                </div>
              </div>
            )}

            {/* Related Links */}
            <div className="card-base">
              <div className="p-4" style={{ borderBottom: "1px solid #e0e0d8" }}>
                <h4 className="text-xs uppercase tracking-wide font-medium" style={{ color: "#999999" }}>
                  Resources
                </h4>
              </div>
              <div className="p-4 space-y-3">
                <a
                  href={repoUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center gap-2 text-sm transition-colors"
                  style={{ color: "#666666" }}
                >
                  <Github className="h-4 w-4" />
                  View Source
                  <ArrowUpRight className="h-3 w-3 ml-auto" />
                </a>
                <a
                  href="https://docs.latticeruntime.com/templates"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center gap-2 text-sm transition-colors"
                  style={{ color: "#666666" }}
                >
                  <Package className="h-4 w-4" />
                  Template Documentation
                  <ArrowUpRight className="h-3 w-3 ml-auto" />
                </a>
                <a
                  href={`https://github.com/latticeHQ/registry/issues/new?title=Issue%20with%20${namespace}/${templateName}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center gap-2 text-sm transition-colors"
                  style={{ color: "#666666" }}
                >
                  Report an Issue
                  <ArrowUpRight className="h-3 w-3 ml-auto" />
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
