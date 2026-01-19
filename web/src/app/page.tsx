import Link from "next/link";
import { getAllModules, getAllTemplates, getNamespaces } from "@/lib/registry";
import { ModuleCard } from "@/components/module-card";
import { Button } from "@/components/ui/button";
import { AnimatedTerminal } from "@/components/animated-terminal";
import {
  ArrowRight,
  Shield,
  FileCheck,
  Lock,
  Fingerprint,
  ArrowUpRight,
  CheckCircle2,
  Zap,
  Code2,
  GitBranch,
  Package,
  Box,
  Cpu,
  Network,
  Layers,
  Activity,
  Server,
} from "lucide-react";

export default async function HomePage() {
  const modules = await getAllModules();
  const templates = await getAllTemplates();
  const namespaces = await getNamespaces();

  const capabilities = [
    {
      name: "Identity",
      description: "Verifies who or what is requesting an action across cloud, self-hosted, and air-gapped environments",
      icon: Fingerprint,
    },
    {
      name: "Authorization",
      description: "Evaluates whether an authenticated principal is allowed to perform a specific action",
      icon: Shield,
    },
    {
      name: "Audit",
      description: "Generates tamper-evident records of all enforcement decisions and agent actions",
      icon: FileCheck,
    },
    {
      name: "Deployment Constraints",
      description: "Ensures agents run only within approved boundaries and configurations",
      icon: Lock,
    },
  ];

  const features = [
    { text: "Runtime enforcement—violations blocked by design", icon: Fingerprint },
    { text: "Provable and auditable enforcement decisions", icon: Shield },
    { text: "Independent of application code", icon: FileCheck },
    { text: "Deployment constraints within approved boundaries", icon: Lock },
    { text: "LiveKit, MCP, A2A, and enterprise integrations", icon: Code2 },
    { text: "Open-core: runtime is Apache 2.0 licensed", icon: Zap },
  ];

  const stats = [
    { value: modules.length.toString(), label: "Modules", icon: Package },
    { value: templates.length.toString(), label: "Templates", icon: Box },
    { value: namespaces.length.toString(), label: "Contributors", icon: GitBranch },
  ];

  const featuredModules = modules.slice(0, 6);

  return (
    <div className="relative overflow-hidden">
      {/* Clean background - Anthropic style */}
      <div className="fixed inset-0 pointer-events-none" style={{ background: "#f5f5f0" }} />

      {/* Hero Section - True Anthropic style */}
      <section className="relative pt-24 pb-16">
        <div className="mx-auto max-w-6xl px-6">
          <div className="grid lg:grid-cols-2 gap-20 items-start">
            {/* Hero Content */}
            <div className="space-y-6">
              {/* Heading - Large Anthropic style */}
              <h1 style={{ fontSize: "56px", lineHeight: "1.1", letterSpacing: "-0.02em", fontWeight: "400", color: "#1a1a1a" }}>
                Modules and templates that extend Lattice Runtime
              </h1>

              <p style={{ fontSize: "18px", lineHeight: "1.6", color: "#666666" }}>
                Lattice Registry is a community-driven repository for modules and templates. Identity management, policy templates, AI framework integrations, and monitoring.
              </p>

              {/* CTA Buttons */}
              <div className="flex gap-3 pt-4">
                <Link href="/modules" className="btn-primary px-5 py-2.5 text-sm">
                  Browse modules
                </Link>
                <a
                  href="https://docs.latticeruntime.com"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="btn-secondary px-5 py-2.5 text-sm"
                >
                  Read documentation
                </a>
              </div>
            </div>

            {/* Info Card - Anthropic style */}
            <div className="hidden lg:block">
              <div className="rounded-xl p-8" style={{ background: "#ebe9e1", border: "1px solid #d0d0c8" }}>
                <h3 className="text-lg font-medium mb-6" style={{ color: "#1a1a1a" }}>
                  Learn more
                </h3>
                <div className="space-y-4">
                  <a
                    href="/modules"
                    className="block p-4 rounded-lg transition-colors"
                    style={{ background: "#ffffff", border: "1px solid #e0e0d8" }}
                  >
                    <div className="flex items-center justify-between">
                      <span className="font-medium" style={{ color: "#1a1a1a" }}>Browse all modules</span>
                      <ArrowUpRight className="h-4 w-4" style={{ color: "#666666" }} />
                    </div>
                  </a>
                  <a
                    href="/templates"
                    className="block p-4 rounded-lg transition-colors"
                    style={{ background: "#ffffff", border: "1px solid #e0e0d8" }}
                  >
                    <div className="flex items-center justify-between">
                      <span className="font-medium" style={{ color: "#1a1a1a" }}>Explore templates</span>
                      <ArrowUpRight className="h-4 w-4" style={{ color: "#666666" }} />
                    </div>
                  </a>
                  <a
                    href="https://docs.latticeruntime.com"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="block p-4 rounded-lg transition-colors"
                    style={{ background: "#ffffff", border: "1px solid #e0e0d8" }}
                  >
                    <div className="flex items-center justify-between">
                      <span className="font-medium" style={{ color: "#1a1a1a" }}>View documentation</span>
                      <ArrowUpRight className="h-4 w-4" style={{ color: "#666666" }} />
                    </div>
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Stats Section - Anthropic style */}
      <section className="relative py-20" style={{ borderTop: "1px solid #e0e0d8", borderBottom: "1px solid #e0e0d8", background: "#ffffff" }}>
        <div className="mx-auto max-w-6xl px-6">
          <div className="grid grid-cols-3 gap-16">
            {stats.map((stat, index) => (
              <div key={index}>
                <div style={{ fontSize: "40px", fontWeight: "400", color: "#1a1a1a", letterSpacing: "-0.01em", marginBottom: "8px" }} className="tabular-nums">
                  {stat.value}
                </div>
                <div style={{ fontSize: "15px", color: "#666666" }}>
                  {stat.label}
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Capabilities Section - Anthropic style */}
      <section className="relative py-24">
        <div className="mx-auto max-w-6xl px-6">
          <div className="mb-16">
            <h2 style={{ fontSize: "40px", lineHeight: "1.2", letterSpacing: "-0.02em", fontWeight: "400", color: "#1a1a1a", marginBottom: "16px" }}>
              What Lattice enforces
            </h2>
            <p style={{ fontSize: "18px", lineHeight: "1.6", color: "#666666", maxWidth: "700px" }}>
              Lattice sits in the execution path, so violations are blocked by design—not by application code.
            </p>
          </div>

          <div className="grid md:grid-cols-2 gap-8">
            {capabilities.map((capability, index) => (
              <div
                key={index}
                className="p-8 rounded-xl"
                style={{ background: "#ebe9e1", border: "1px solid #d0d0c8" }}
              >
                <capability.icon className="h-7 w-7 mb-5" style={{ color: "#d97706" }} />
                <h3 style={{ fontSize: "20px", fontWeight: "500", letterSpacing: "-0.01em", color: "#1a1a1a", marginBottom: "12px" }}>
                  {capability.name}
                </h3>
                <p style={{ fontSize: "15px", lineHeight: "1.6", color: "#666666" }}>
                  {capability.description}
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Featured Modules - Anthropic style */}
      <section className="relative py-24" style={{ background: "#ffffff", borderTop: "1px solid #e0e0d8" }}>
        <div className="mx-auto max-w-6xl px-6">
          <div className="mb-12">
            <h2 style={{ fontSize: "32px", lineHeight: "1.2", letterSpacing: "-0.02em", fontWeight: "400", color: "#1a1a1a", marginBottom: "12px" }}>
              Featured
            </h2>
            <p style={{ fontSize: "15px", color: "#666666" }}>
              Popular modules from the community
            </p>
          </div>

          <div className="space-y-2">
            {featuredModules.map((module) => (
              <Link
                key={module.slug}
                href={`/modules/${module.namespace}/${module.name}`}
                className="block p-5 rounded-lg transition-colors"
                style={{ background: "#f5f5f0", border: "1px solid #e0e0d8" }}
              >
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <h3 className="text-base font-medium mb-1" style={{ color: "#1a1a1a" }}>
                      {module.frontmatter.display_name || module.name}
                    </h3>
                    <p className="text-sm mb-3" style={{ color: "#666666" }}>
                      {module.frontmatter.description}
                    </p>
                    <div className="flex gap-2">
                      {module.frontmatter.tags?.slice(0, 3).map((tag) => (
                        <span
                          key={tag}
                          className="text-xs px-2 py-1 rounded"
                          style={{ background: "#ebe9e1", color: "#666666" }}
                        >
                          {tag}
                        </span>
                      ))}
                    </div>
                  </div>
                  <ArrowUpRight className="h-5 w-5 ml-4 flex-shrink-0" style={{ color: "#999999" }} />
                </div>
              </Link>
            ))}
          </div>

          <div className="mt-8">
            <Link
              href="/modules"
              className="inline-flex items-center gap-2 text-sm font-medium"
              style={{ color: "#1a1a1a" }}
            >
              View all modules
              <ArrowRight className="h-4 w-4" />
            </Link>
          </div>
        </div>
      </section>

      {/* CTA Section - Anthropic style */}
      <section className="relative py-32" style={{ borderTop: "1px solid #e0e0d8" }}>
        <div className="mx-auto max-w-4xl px-6 text-center">
          <h2 style={{ fontSize: "40px", lineHeight: "1.2", letterSpacing: "-0.02em", fontWeight: "400", color: "#1a1a1a", marginBottom: "20px" }}>
            Want to help build the Lattice ecosystem?
          </h2>

          <div className="flex flex-col sm:flex-row gap-3 justify-center mt-10">
            <a
              href="https://github.com/latticeHQ/registry/blob/main/CONTRIBUTING.md"
              target="_blank"
              rel="noopener noreferrer"
              className="btn-primary px-6 py-3 text-sm"
            >
              Start contributing
            </a>
            <Link href="/contributors" className="btn-secondary px-6 py-3 text-sm">
              Meet contributors
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}
