# Lattice Registry

### Community ecosystem for [Lattice Runtime](https://github.com/latticeHQ/latticeRuntime)

**Terraform modules, templates, and stacks. Community-powered.**

[Registry Site](https://registry.latticeruntime.com) · [Lattice Runtime](https://github.com/latticeHQ/latticeRuntime) · [GitHub Discussions](https://github.com/latticeHQ/latticeRuntime/discussions)

## Part of the Lattice Ecosystem

[Lattice Runtime](https://github.com/latticeHQ/latticeRuntime) is the open-source coordination layer for institutional AI. Lattice Registry is the community-driven ecosystem of reusable modules and templates that extend Runtime deployments.

| Component | Role | Repository |
|-----------|------|------------|
| [**Runtime**](https://github.com/latticeHQ/latticeRuntime) | Coordination layer — identity, authorization, audit, budget | [latticeRuntime](https://github.com/latticeHQ/latticeRuntime) |
| [**Workbench**](https://github.com/latticeHQ/latticeWorkbench) | Reference Engineering Stack — multi-model agent workspace | [latticeWorkbench](https://github.com/latticeHQ/latticeWorkbench) |
| [**Inference**](https://github.com/latticeHQ/latticeInference) | Local AI serving — MLX on Apple Silicon, zero-config clustering | [latticeInference](https://github.com/latticeHQ/latticeInference) |
| **Registry** (this repo) | Community ecosystem — Terraform modules, templates, stacks | You are here |

## Overview

Lattice Registry extends the platform with reusable Terraform modules for AI agent infrastructure:

- **Identity & Auth**: OAuth, OIDC, and API key management for AI agents
- **Policy Templates**: Authorization rules and deployment constraints
- **Integrations**: Connections to AI frameworks and external services
- **Monitoring**: Audit logging, tracing, and observability configurations
- **Agent Templates**: Pre-configured agent deployment environments
- **Stack Templates**: Domain-specific stack configurations (Engineering, Clinical, Legal, etc.)

## Getting Started

The easiest way to discover modules is by visiting [the Registry website](https://registry.latticeruntime.com/).

### Using a Module

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

### Deploying with Templates

```bash
# Deploy an agent on Kubernetes with identity and audit
lattice templates apply kubernetes --with-module agent-identity --with-module policy-engine

# Deploy on Docker for local development
lattice templates apply docker --with-module agent-identity
```

## What's Available

### Modules (Building Blocks)

| Module | Description |
|--------|-------------|
| `agent-identity` | OAuth 2.0, OIDC, API key management for agents |
| `policy-engine` | Runtime enforcement rules and constraints |

### Templates (One-Click Deployments)

| Category | Templates |
|----------|-----------|
| **Infrastructure** | Docker, Kubernetes, AWS Linux, GCP Linux, Azure Linux, Azure Windows |
| **AI Services** | Voice, speech-to-text, TTS integrations |
| **Developer Tools** | IDE integrations |

## How It Works with the Ecosystem

### With Lattice Runtime
Registry templates deploy pre-configured Runtime environments. Every template includes identity, authorization, and audit — enforcement is built into every deployment by default.

### With Lattice Inference
Templates can include Inference configuration — model selections, cluster settings, and resource budgets.

### With Lattice Workbench
Workbench uses Registry templates when deploying agents. Templates create governed agent environments that inherit Runtime's coordination policies.

## Contributing

We welcome contributions! See our [contributing guide](./CONTRIBUTING.md).

### Quick Start

1. Fork and clone the repository
2. Create your namespace: `mkdir -p registry/[your-username]`
3. Generate module scaffolding: `./scripts/new_module.sh [your-username]/[module-name]`
4. Implement, test, and document your module
5. Submit a pull request

Every module includes Terraform tests:

```bash
terraform test -verbose
```

## Module Categories

| Category | Description |
|----------|-------------|
| `identity` | Authentication and authorization for AI agents |
| `policy` | Runtime enforcement rules and constraints |
| `integration` | Connections to external services and AI frameworks |
| `monitoring` | Logging, tracing, and audit capabilities |
| `templates` | Complete agent workspace configurations |
| `stacks` | Domain-specific stack configurations |

## For Maintainers

Guidelines for maintainers reviewing PRs and managing releases. [See the maintainer guide](./MAINTAINER.md).

## License

Apache 2.0 — See [LICENSE](./LICENSE) for details.

---

<div align="center">

**[latticeruntime.com](https://latticeruntime.com)**

</div>
