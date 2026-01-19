"use client";

import { useState } from "react";
import { FileCode, FileText, Terminal, Github } from "lucide-react";

interface ModuleTabsProps {
  readme: string;
  variables: {
    inputs: Array<{
      name: string;
      description: string;
      type?: string;
      default?: string;
    }>;
    outputs: Array<{
      name: string;
      description: string;
    }>;
  };
  scripts?: string;
  sourceUrl: string;
}

export function ModuleTabs({ readme, variables, scripts, sourceUrl }: ModuleTabsProps) {
  const [activeTab, setActiveTab] = useState<"readme" | "variables" | "scripts" | "source">("readme");

  const tabs = [
    { id: "readme" as const, label: "README", icon: FileText },
    { id: "variables" as const, label: "Variables", icon: FileCode },
    ...(scripts ? [{ id: "scripts" as const, label: "Scripts", icon: Terminal }] : []),
    { id: "source" as const, label: "Source", icon: Github },
  ];

  return (
    <div className="overflow-hidden rounded-xl" style={{ border: "1px solid #e0e0d8", background: "#ffffff" }}>
      {/* Tab Headers - GitHub Premium Style */}
      <div className="border-b" style={{ borderColor: "#e0e0d8", background: "#fafaf8" }}>
        <div className="flex gap-1 px-4 pt-3">
          {tabs.map((tab) => {
            const Icon = tab.icon;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`
                  flex items-center gap-2 px-4 py-2.5 text-sm font-medium transition-all duration-200 relative rounded-t-lg
                  ${
                    activeTab === tab.id
                      ? "text-[#1a1a1a]"
                      : "text-[#666666] hover:text-[#1a1a1a] hover:bg-[#f0f0e8]"
                  }
                `}
                style={{
                  background: activeTab === tab.id ? "#ffffff" : "transparent",
                  borderTop: activeTab === tab.id ? "1px solid #e0e0d8" : "none",
                  borderLeft: activeTab === tab.id ? "1px solid #e0e0d8" : "none",
                  borderRight: activeTab === tab.id ? "1px solid #e0e0d8" : "none",
                  borderBottom: activeTab === tab.id ? "1px solid #ffffff" : "none",
                  marginBottom: activeTab === tab.id ? "-1px" : "0",
                }}
              >
                <Icon className="h-4 w-4" />
                {tab.label}
              </button>
            );
          })}
        </div>
      </div>

      {/* Tab Content */}
      <div className="p-8">
        {activeTab === "readme" && (
          <div
            className="prose-custom"
            dangerouslySetInnerHTML={{ __html: readme }}
          />
        )}

        {activeTab === "variables" && (
          <div className="space-y-8">
            {/* Inputs */}
            {variables.inputs && variables.inputs.length > 0 && (
              <div>
                <h3 className="text-xl font-semibold text-[#1a1a1a] mb-5">Input Variables</h3>
                <div className="space-y-3">
                  {variables.inputs.map((input, i) => (
                    <div
                      key={i}
                      className="card-base p-5 transition-smooth hover:border-[#d0d0c8]"
                    >
                      <div className="flex items-start justify-between mb-3">
                        <code className="text-sm font-semibold text-[#d97706]">{input.name}</code>
                        <code className="text-xs px-2.5 py-1 rounded-md font-medium" style={{
                          background: "#ffffff",
                          color: "#666666",
                        }}>
                          {input.type || "string"}
                        </code>
                      </div>
                      <p className="text-sm text-[#666666] mb-2 leading-relaxed">{input.description}</p>
                      {input.default && (
                        <div className="text-xs mt-3 pt-3" style={{ borderTop: "1px solid #f0f0e8" }}>
                          <span className="text-[#999999]">Default: </span>
                          <code className="text-[#666666]">{input.default}</code>
                        </div>
                      )}
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Outputs */}
            {variables.outputs && variables.outputs.length > 0 && (
              <div>
                <h3 className="text-xl font-semibold text-[#1a1a1a] mb-5">Output Values</h3>
                <div className="space-y-3">
                  {variables.outputs.map((output, i) => (
                    <div
                      key={i}
                      className="card-base p-5 transition-smooth hover:border-[#d0d0c8]"
                    >
                      <code className="text-sm font-semibold text-[#d97706] block mb-3">
                        {output.name}
                      </code>
                      <p className="text-sm text-[#666666] leading-relaxed">{output.description}</p>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {(!variables.inputs || variables.inputs.length === 0) &&
              (!variables.outputs || variables.outputs.length === 0) && (
                <div className="text-center py-12 text-[#666666]">
                  No variables defined for this module.
                </div>
              )}
          </div>
        )}

        {activeTab === "scripts" && scripts && (
          <div>
            <pre className="code-block">
              <code>{scripts}</code>
            </pre>
          </div>
        )}

        {activeTab === "source" && (
          <div className="text-center py-16">
            <div className="icon-container-lg mx-auto mb-6">
              <Github className="h-8 w-8 text-[#d97706]" />
            </div>
            <h3 className="text-xl font-semibold text-[#1a1a1a] mb-3">View on GitHub</h3>
            <p className="text-sm text-[#666666] mb-8 max-w-md mx-auto leading-relaxed">
              Explore the full source code, contribute, or report issues on GitHub.
            </p>
            <a
              href={sourceUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="btn-primary inline-flex items-center gap-2"
            >
              <Github className="h-4 w-4" />
              Open in GitHub
            </a>
          </div>
        )}
      </div>
    </div>
  );
}
