import { notFound } from "next/navigation";
import Link from "next/link";
import { getPreset, getNamespaces, getNamespace } from "@/lib/registry";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  ArrowLeft,
  Github,
  ArrowUpRight,
  Copy,
  Sparkles,
  Clock,
  BarChart3,
  FileCode,
  Mic,
  Brain,
  BookOpen,
} from "lucide-react";
import { ContributorAvatar } from "@/components/contributor-avatar";

interface PageProps {
  params: Promise<{
    namespace: string;
    preset: string;
  }>;
}

export async function generateStaticParams() {
  const namespaces = await getNamespaces();
  const params: { namespace: string; preset: string }[] = [];

  for (const ns of namespaces) {
    for (const preset of ns.presets) {
      params.push({
        namespace: ns.name,
        preset: preset.name,
      });
    }
  }

  return params;
}

export async function generateMetadata({ params }: PageProps) {
  const { namespace, preset: presetName } = await params;
  const preset = await getPreset(namespace, presetName);

  if (!preset) {
    return { title: "Preset Not Found - Lattice Registry" };
  }

  return {
    title: `${preset.frontmatter.display_name} - Lattice Registry`,
    description: preset.frontmatter.description,
  };
}

export default async function PresetPage({ params }: PageProps) {
  const { namespace, preset: presetName } = await params;
  const preset = await getPreset(namespace, presetName);
  const namespaceData = await getNamespace(namespace);

  if (!preset) {
    notFound();
  }

  const githubUsername = namespaceData?.frontmatter.github || namespace;
  const repoUrl = `https://github.com/latticeHQ/registry/tree/main/registry/${namespace}/presets/${presetName}`;

  const difficultyColors: Record<string, string> = {
    beginner: "#10b981",
    intermediate: "#d97706",
    advanced: "#ef4444",
  };

  const difficultyColor = difficultyColors[preset.frontmatter.difficulty || "intermediate"] || "#d97706";

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
            href="/presets"
            className="inline-flex items-center text-sm transition-colors"
            style={{ color: "#666666" }}
          >
            <ArrowLeft className="h-4 w-4 mr-2" />
            Back to Presets
          </Link>
        </div>

        <div className="grid lg:grid-cols-3 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-2">
            {/* Header */}
            <div className="mb-8">
              <div className="flex items-start gap-4 mb-4">
                <div className="icon-container-lg">
                  <Sparkles className="h-7 w-7" style={{ color: "#d97706" }} />
                </div>
                <div className="flex-1">
                  <div className="flex items-center gap-3 flex-wrap mb-2">
                    <h1 className="text-2xl font-bold" style={{ color: "#1a1a1a" }}>
                      {preset.frontmatter.display_name}
                    </h1>
                  </div>
                  <p className="text-lg" style={{ color: "#666666" }}>
                    {preset.frontmatter.description}
                  </p>
                </div>
              </div>

              {/* Meta Info */}
              <div className="flex items-center gap-4 mb-4 text-sm">
                {preset.frontmatter.difficulty && (
                  <div className="flex items-center gap-1.5">
                    <BarChart3 className="h-4 w-4" style={{ color: difficultyColor }} />
                    <span style={{ color: difficultyColor }} className="capitalize font-medium">
                      {preset.frontmatter.difficulty}
                    </span>
                  </div>
                )}
                {preset.frontmatter.duration && (
                  <div className="flex items-center gap-1.5" style={{ color: "#666666" }}>
                    <Clock className="h-4 w-4" />
                    <span>{preset.frontmatter.duration}</span>
                  </div>
                )}
              </div>

              {/* Category and Domain badges */}
              <div className="flex flex-wrap gap-2 mb-6">
                {preset.frontmatter.category && (
                  <Badge variant="secondary" style={{ background: "rgba(217, 119, 6, 0.1)", color: "#d97706" }}>
                    {preset.frontmatter.category}
                  </Badge>
                )}
                {preset.frontmatter.domain && (
                  <Badge variant="secondary">
                    {preset.frontmatter.domain}
                  </Badge>
                )}
                {preset.frontmatter.tags?.map((tag) => (
                  <Badge key={tag} variant="secondary">
                    {tag}
                  </Badge>
                ))}
              </div>

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
                  Copy Preset
                </Button>
              </div>
            </div>

            {/* Instructions */}
            {preset.instructions && (
              <div className="card-base mb-8">
                <div className="p-6" style={{ borderBottom: "1px solid #e0e0d8" }}>
                  <div className="flex items-center gap-2">
                    <BookOpen className="h-5 w-5" style={{ color: "#d97706" }} />
                    <h2 className="text-lg font-semibold" style={{ color: "#1a1a1a" }}>
                      Instructions
                    </h2>
                  </div>
                </div>
                <div className="p-6">
                  <div className="terminal-body max-h-96 overflow-auto">
                    <pre className="whitespace-pre-wrap text-sm" style={{ color: "#666666" }}>
                      {preset.instructions}
                    </pre>
                  </div>
                </div>
              </div>
            )}

            {/* Documentation */}
            <div className="card-base">
              <div className="p-6" style={{ borderBottom: "1px solid #e0e0d8" }}>
                <div className="flex items-center gap-2">
                  <FileCode className="h-5 w-5" style={{ color: "#d97706" }} />
                  <h2 className="text-lg font-semibold" style={{ color: "#1a1a1a" }}>
                    Documentation
                  </h2>
                </div>
              </div>
              <div className="p-8">
                <div className="max-w-4xl">
                  <div
                    className="prose-custom"
                    dangerouslySetInnerHTML={{ __html: preset.htmlContent }}
                  />
                </div>
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

            {/* Preset Info Card */}
            <div className="card-base">
              <div className="p-4" style={{ borderBottom: "1px solid #e0e0d8" }}>
                <h4 className="text-xs uppercase tracking-wide font-medium" style={{ color: "#999999" }}>
                  Preset Info
                </h4>
              </div>
              <div className="p-4">
                <dl className="space-y-4">
                  <div>
                    <dt className="text-sm" style={{ color: "#666666" }}>
                      Preset Name
                    </dt>
                    <dd className="mt-1 font-mono text-sm" style={{ color: "#1a1a1a" }}>
                      {presetName}
                    </dd>
                  </div>
                  <div>
                    <dt className="text-sm" style={{ color: "#666666" }}>
                      Full Reference
                    </dt>
                    <dd className="mt-1 font-mono text-sm px-2 py-1 rounded" style={{ backgroundColor: "#ebe9e1", color: "#666666" }}>
                      {namespace}/{presetName}
                    </dd>
                  </div>
                  {preset.frontmatter.sidecar_id && (
                    <div>
                      <dt className="text-sm" style={{ color: "#666666" }}>
                        Sidecar ID
                      </dt>
                      <dd className="mt-1 font-mono text-sm" style={{ color: "#1a1a1a" }}>
                        {preset.frontmatter.sidecar_id}
                      </dd>
                    </div>
                  )}
                </dl>
              </div>
            </div>

            {/* Voice Settings */}
            {preset.frontmatter.voice_settings && Object.keys(preset.frontmatter.voice_settings).length > 0 && (
              <div className="card-base">
                <div className="p-4" style={{ borderBottom: "1px solid #e0e0d8" }}>
                  <div className="flex items-center gap-2">
                    <Mic className="h-4 w-4" style={{ color: "#d97706" }} />
                    <h4 className="text-xs uppercase tracking-wide font-medium" style={{ color: "#999999" }}>
                      Voice Settings
                    </h4>
                  </div>
                </div>
                <div className="p-4">
                  <dl className="space-y-2 text-sm">
                    {preset.frontmatter.voice_settings.voice_id && (
                      <div className="flex justify-between">
                        <dt style={{ color: "#666666" }}>Voice ID</dt>
                        <dd className="font-mono" style={{ color: "#1a1a1a" }}>{preset.frontmatter.voice_settings.voice_id}</dd>
                      </div>
                    )}
                    {preset.frontmatter.voice_settings.speed && (
                      <div className="flex justify-between">
                        <dt style={{ color: "#666666" }}>Speed</dt>
                        <dd style={{ color: "#1a1a1a" }}>{preset.frontmatter.voice_settings.speed}</dd>
                      </div>
                    )}
                    {preset.frontmatter.voice_settings.pitch && (
                      <div className="flex justify-between">
                        <dt style={{ color: "#666666" }}>Pitch</dt>
                        <dd style={{ color: "#1a1a1a" }}>{preset.frontmatter.voice_settings.pitch}</dd>
                      </div>
                    )}
                    {preset.frontmatter.voice_settings.stability && (
                      <div className="flex justify-between">
                        <dt style={{ color: "#666666" }}>Stability</dt>
                        <dd style={{ color: "#1a1a1a" }}>{preset.frontmatter.voice_settings.stability}</dd>
                      </div>
                    )}
                  </dl>
                </div>
              </div>
            )}

            {/* Model Settings */}
            {preset.frontmatter.model_settings && Object.keys(preset.frontmatter.model_settings).length > 0 && (
              <div className="card-base">
                <div className="p-4" style={{ borderBottom: "1px solid #e0e0d8" }}>
                  <div className="flex items-center gap-2">
                    <Brain className="h-4 w-4" style={{ color: "#d97706" }} />
                    <h4 className="text-xs uppercase tracking-wide font-medium" style={{ color: "#999999" }}>
                      Model Settings
                    </h4>
                  </div>
                </div>
                <div className="p-4">
                  <dl className="space-y-2 text-sm">
                    {preset.frontmatter.model_settings.model_id && (
                      <div className="flex justify-between">
                        <dt style={{ color: "#666666" }}>Model</dt>
                        <dd className="font-mono" style={{ color: "#1a1a1a" }}>{preset.frontmatter.model_settings.model_id}</dd>
                      </div>
                    )}
                    {preset.frontmatter.model_settings.temperature && (
                      <div className="flex justify-between">
                        <dt style={{ color: "#666666" }}>Temperature</dt>
                        <dd style={{ color: "#1a1a1a" }}>{preset.frontmatter.model_settings.temperature}</dd>
                      </div>
                    )}
                    {preset.frontmatter.model_settings.max_tokens && (
                      <div className="flex justify-between">
                        <dt style={{ color: "#666666" }}>Max Tokens</dt>
                        <dd style={{ color: "#1a1a1a" }}>{preset.frontmatter.model_settings.max_tokens}</dd>
                      </div>
                    )}
                  </dl>
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
                  href="https://docs.latticeruntime.com/presets"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center gap-2 text-sm transition-colors"
                  style={{ color: "#666666" }}
                >
                  <Sparkles className="h-4 w-4" />
                  Preset Documentation
                  <ArrowUpRight className="h-3 w-3 ml-auto" />
                </a>
                <a
                  href={`https://github.com/latticeHQ/registry/issues/new?title=Issue%20with%20${namespace}/${presetName}`}
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
