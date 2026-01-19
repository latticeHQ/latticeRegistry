import { getNamespaces } from "@/lib/registry";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Users, ArrowUpRight, GitBranch } from "lucide-react";
import { ContributorCard } from "@/components/contributor-card";

export const metadata = {
  title: "Contributors - Lattice Registry",
  description: "Meet the contributors who build modules for Lattice Runtime",
};

export default async function ContributorsPage() {
  const namespaces = await getNamespaces();

  return (
    <div className="relative min-h-screen">
      {/* Background */}
      <div className="fixed inset-0 pointer-events-none">
        <div className="absolute inset-0 grid-pattern opacity-30" />
        <div className="absolute top-1/3 right-1/4 w-[500px] h-[500px] bg-orange-500/5 rounded-full blur-3xl" />
      </div>

      <div className="relative mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-12 md:py-16">
        {/* Header */}
        <div className="mb-12">
          <div className="flex items-center gap-3 mb-4">
            <div className="icon-container">
              <Users className="h-5 w-5 text-orange-400" />
            </div>
            <Badge variant="secondary">Community</Badge>
          </div>
          <h1 className="text-3xl sm:text-4xl font-bold text-slate-100 mb-4">
            Contributors
          </h1>
          <p className="text-lg text-slate-400 max-w-2xl">
            Meet the people and organizations building infrastructure modules for Lattice Runtime.
            Contributors publish modules under their GitHub username.
          </p>
        </div>

        {namespaces.length > 0 ? (
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {namespaces.map((ns) => (
              <ContributorCard key={ns.name} namespace={ns} />
            ))}
          </div>
        ) : (
          <div className="text-center py-20 card-base">
            <div className="icon-container-lg mx-auto mb-6">
              <Users className="h-8 w-8 text-orange-400" />
            </div>
            <h3 className="text-xl font-semibold text-slate-100 mb-3">
              No contributors yet
            </h3>
            <p className="text-slate-500 max-w-md mx-auto mb-6">
              Be the first to contribute to the Lattice Registry!
              Share your modules with the community.
            </p>
            <div className="flex flex-col sm:flex-row gap-3 justify-center">
              <a
                href="https://github.com/latticeHQ/registry/blob/main/CONTRIBUTING.md"
                target="_blank"
                rel="noopener noreferrer"
              >
                <Button>
                  Read Contributing Guide
                  <ArrowUpRight className="ml-2 h-4 w-4" />
                </Button>
              </a>
              <a
                href="https://github.com/latticeHQ/registry"
                target="_blank"
                rel="noopener noreferrer"
              >
                <Button variant="outline">
                  <GitBranch className="mr-2 h-4 w-4" />
                  Fork Repository
                </Button>
              </a>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
