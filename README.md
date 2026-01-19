# Lattice Registry

[Registry Site](https://registry.latticeruntime.com) • [Lattice Runtime](https://github.com/latticeHQ/lattice) • [Docs](https://docs.latticeruntime.com)

Lattice Registry is a community-driven platform for extending your Lattice Runtime deployments. Publish reusable Terraform modules for AI agent infrastructure, identity management, and runtime enforcement.

## Overview

Lattice Runtime provides runtime enforcement and identity infrastructure for autonomous AI agents. The registry extends this with reusable modules for:

- **Identity & Auth**: OAuth, OIDC, and API key management for AI agents
- **Policy Templates**: Authorization rules and deployment constraints
- **Integrations**: Connections to AI frameworks (LiveKit, MCP, A2A)
- **Monitoring**: Audit logging, tracing, and observability configurations
- **Agent Templates**: Pre-configured agent workspace definitions

## Getting Started

The easiest way to discover modules is by visiting [the Lattice Registry website](https://registry.latticeruntime.com/).

### Using a Module

To use a module, add the import snippet to your Lattice template:

```tf
module "agent-identity" {
  source   = "registry.latticeruntime.com/lattice/agent-identity/lattice"
  version  = "1.0.0"
  agent_id = lattice_agent.main.id

  # Configure identity provider
  provider_type = "oidc"
  issuer_url    = "https://auth.example.com"
}
```

Include the snippet in your Lattice template, define any dependencies, and the functionality will be available in your next deployment.

## Module Categories

| Category | Description |
|----------|-------------|
| `identity` | Authentication and authorization for AI agents |
| `policy` | Runtime enforcement rules and constraints |
| `integration` | Connections to external services and AI frameworks |
| `monitoring` | Logging, tracing, and audit capabilities |
| `templates` | Complete agent workspace configurations |

## Contributing

We welcome contributions! See our [contributing guide](./CONTRIBUTING.md) for more information.

### Quick Start

1. Fork and clone the repository
2. Create your namespace: `mkdir -p registry/[your-username]`
3. Generate module scaffolding: `./scripts/new_module.sh [your-username]/[module-name]`
4. Implement, test, and document your module
5. Submit a pull request

## For Maintainers

Guidelines for maintainers reviewing PRs and managing releases. [See the maintainer guide](./MAINTAINER.md).

## License

Apache 2.0 - See [LICENSE](./LICENSE) for details.
