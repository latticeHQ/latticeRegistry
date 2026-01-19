import { notFound } from "next/navigation";
import Link from "next/link";
import { getNamespace } from "@/lib/registry";
import { ModuleCard } from "@/components/module-card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  ArrowLeft,
  Github,
  Globe,
  Linkedin,
  Mail,
  Package,
  Box,
  CheckCircle2,
  ArrowUpRight,
} from "lucide-react";
import { ContributorAvatar } from "@/components/contributor-avatar";

interface PageProps {
  params: Promise<{
    namespace: string;
  }>;
}

export async function generateMetadata({ params }: PageProps) {
  const { namespace } = await params;
  const ns = await getNamespace(namespace);

  if (!ns) {
    return { title: "Contributor Not Found - Lattice Registry" };
  }

  return {
    title: `${ns.frontmatter.display_name || namespace} - Lattice Registry`,
    description: ns.frontmatter.bio,
  };
}

export default async function ContributorPage({ params }: PageProps) {
  const { namespace } = await params;
  const ns = await getNamespace(namespace);

  if (!ns) {
    notFound();
  }

  // Use the github field if available, otherwise fall back to namespace name
  const githubUsername = ns.frontmatter.github || namespace;

  return (
    <div className="relative min-h-screen">
      {/* Background */}
      <div className="fixed inset-0 pointer-events-none">
        <div className="absolute inset-0 grid-pattern opacity-30" />
        <div className="absolute top-1/4 right-1/4 w-[500px] h-[500px] bg-orange-500/5 rounded-full blur-3xl" />
      </div>

      <div className="relative mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-12">
        {/* Breadcrumb */}
        <div className="mb-8">
          <Link
            href="/contributors"
            className="inline-flex items-center text-sm text-slate-400 hover:text-orange-400 transition-colors"
          >
            <ArrowLeft className="h-4 w-4 mr-2" />
            Back to Contributors
          </Link>
        </div>

        {/* Profile Header */}
        <div className="card-base p-8 mb-8">
          <div className="flex flex-col md:flex-row items-start gap-6">
            {/* Avatar */}
            <div className="relative flex-shrink-0">
              <ContributorAvatar
                githubUsername={githubUsername}
                displayName={ns.frontmatter.display_name || namespace}
                size="lg"
              />
              {ns.frontmatter.status === "official" && (
                <div className="absolute -bottom-1 -right-1 bg-slate-900 rounded-full p-1">
                  <CheckCircle2 className="h-5 w-5 text-orange-400" />
                </div>
              )}
            </div>

            <div className="flex-1">
              <div className="flex items-center gap-3 mb-2">
                <h1 className="text-3xl font-bold text-slate-100">
                  {ns.frontmatter.display_name || namespace}
                </h1>
                {ns.frontmatter.status === "official" && (
                  <Badge variant="default">Official</Badge>
                )}
                {ns.frontmatter.status === "partner" && (
                  <Badge variant="success">Partner</Badge>
                )}
                {ns.frontmatter.status === "community" && (
                  <Badge variant="secondary">Community</Badge>
                )}
              </div>

              <div className="flex items-center gap-1.5 text-sm text-slate-500 mb-4">
                <Github className="h-4 w-4" />
                <span className="font-mono">@{githubUsername}</span>
              </div>

              {ns.frontmatter.bio && (
                <p className="text-lg text-slate-400 mb-6 leading-relaxed">
                  {ns.frontmatter.bio}
                </p>
              )}

              {/* Links */}
              <div className="flex flex-wrap gap-3">
                {ns.frontmatter.github && (
                  <a
                    href={`https://github.com/${ns.frontmatter.github}`}
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    <Button variant="outline" size="sm" className="group">
                      <Github className="h-4 w-4 mr-2" />
                      GitHub
                      <ArrowUpRight className="h-3 w-3 ml-1 opacity-50 group-hover:opacity-100 transition-opacity" />
                    </Button>
                  </a>
                )}
                {ns.frontmatter.website && (
                  <a
                    href={ns.frontmatter.website}
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    <Button variant="outline" size="sm" className="group">
                      <Globe className="h-4 w-4 mr-2" />
                      Website
                      <ArrowUpRight className="h-3 w-3 ml-1 opacity-50 group-hover:opacity-100 transition-opacity" />
                    </Button>
                  </a>
                )}
                {ns.frontmatter.linkedin && (
                  <a
                    href={ns.frontmatter.linkedin}
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    <Button variant="outline" size="sm" className="group">
                      <Linkedin className="h-4 w-4 mr-2" />
                      LinkedIn
                      <ArrowUpRight className="h-3 w-3 ml-1 opacity-50 group-hover:opacity-100 transition-opacity" />
                    </Button>
                  </a>
                )}
                {ns.frontmatter.support_email && (
                  <a href={`mailto:${ns.frontmatter.support_email}`}>
                    <Button variant="outline" size="sm">
                      <Mail className="h-4 w-4 mr-2" />
                      Contact
                    </Button>
                  </a>
                )}
              </div>
            </div>
          </div>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-2 gap-4 mb-12">
          <div className="card-base p-6">
            <div className="flex items-center gap-4">
              <div className="p-3 rounded-xl bg-orange-500/10 border border-orange-500/20">
                <Package className="h-6 w-6 text-orange-400" />
              </div>
              <div>
                <div className="text-3xl font-bold text-slate-100">
                  {ns.modules.length}
                </div>
                <div className="text-sm text-slate-500">
                  Modules
                </div>
              </div>
            </div>
          </div>
          <div className="card-base p-6">
            <div className="flex items-center gap-4">
              <div className="p-3 rounded-xl bg-orange-500/10 border border-orange-500/20">
                <Box className="h-6 w-6 text-orange-400" />
              </div>
              <div>
                <div className="text-3xl font-bold text-slate-100">
                  {ns.templates.length}
                </div>
                <div className="text-sm text-slate-500">
                  Templates
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Modules */}
        {ns.modules.length > 0 && (
          <section className="mb-12">
            <div className="flex items-center gap-3 mb-6">
              <div className="icon-container">
                <Package className="h-5 w-5 text-orange-400" />
              </div>
              <h2 className="text-2xl font-bold text-slate-100">
                Modules
              </h2>
            </div>
            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
              {ns.modules.map((module) => (
                <ModuleCard key={module.slug} module={module} type="module" />
              ))}
            </div>
          </section>
        )}

        {/* Templates */}
        {ns.templates.length > 0 && (
          <section className="mb-12">
            <div className="flex items-center gap-3 mb-6">
              <div className="icon-container">
                <Box className="h-5 w-5 text-orange-400" />
              </div>
              <h2 className="text-2xl font-bold text-slate-100">
                Templates
              </h2>
            </div>
            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
              {ns.templates.map((template) => (
                <ModuleCard key={template.slug} module={template} type="template" />
              ))}
            </div>
          </section>
        )}

        {/* Empty state */}
        {ns.modules.length === 0 && ns.templates.length === 0 && (
          <div className="text-center py-16 card-base">
            <div className="icon-container-lg mx-auto mb-6">
              <Package className="h-8 w-8 text-orange-400" />
            </div>
            <h3 className="text-xl font-semibold text-slate-100 mb-3">
              No modules or templates yet
            </h3>
            <p className="text-slate-500 max-w-md mx-auto">
              This contributor hasn&apos;t published any modules or templates yet.
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
