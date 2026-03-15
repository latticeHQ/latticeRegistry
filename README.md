<div align="center">

# Lattice Registry

### Community ecosystem for Lattice Runtime

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg?style=flat-square)](./LICENSE)

**Terraform modules, templates, and stacks. Community-powered.**

[Registry Site](https://registry.latticeruntime.com) · [Lattice Runtime](https://github.com/latticeHQ/latticeRuntime) · [Discussions](https://github.com/latticeHQ/latticeRuntime/discussions)

</div>

---

## Why a Registry

[Lattice Runtime](https://github.com/latticeHQ/latticeRuntime) is the open-source coordination layer for institutional AI — identity, authorization, audit, and budget for every agent in the organization. Runtime provides the enforcement primitives. The Registry provides the building blocks.

Every institution that deploys AI agents at scale encounters the same infrastructure requirements: identity providers need connecting, authorization policies need expressing, audit systems need configuring, deployment environments need provisioning. Without a shared ecosystem of reusable components, every team rebuilds this infrastructure from scratch.

Lattice Registry is the community-driven collection of Terraform modules, deployment templates, and stack configurations that make Runtime deployments production-ready in hours instead of weeks.

---

## What's In the Registry

### Modules (Building Blocks)

Modules are individual Terraform components that solve specific infrastructure problems:

| Category | Description | Examples |
|----------|-------------|---------|
| **Identity & Auth** | Authentication and authorization for AI agents | OAuth 2.0, OIDC, API key management |
| **Policy** | Runtime enforcement rules and constraints | Spend limits, access boundaries, time windows |
| **Integration** | Connections to external services and AI frameworks | GitHub, Slack, cloud providers |
| **Monitoring** | Logging, tracing, and audit capabilities | Prometheus, OpenTelemetry configs |
| **Agent Templates** | Pre-configured agent deployment environments | Dev containers, GPU agents, secure sandboxes |
| **Stack Templates** | Domain-specific stack configurations | Engineering, Clinical, Legal, Finance |

### Templates (One-Click Deployments)

Templates are complete Lattice Runtime workspace configurations for specific platforms:

| Category | Templates |
|----------|-----------|
| **Infrastructure** | Docker, Kubernetes, AWS Linux, GCP Linux, Azure Linux, Azure Windows |
| **AI Services** | Voice, speech-to-text, TTS integrations |
| **Developer Tools** | IDE integrations, development environments |

### Plugins (Workbench Skill Packs)

Plugins provide domain-specific AI agent skills and MCP server integrations for [Lattice Workbench](https://github.com/latticeHQ/latticeWorkbench).

---

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

---

## How It Works with the Ecosystem

### With Lattice Runtime
Registry templates deploy pre-configured Runtime environments. Every template includes identity, authorization, and audit — enforcement is built into every deployment by default. When an agent is provisioned through a Registry template, it inherits Runtime's four enforcement gates (Identity → Authorization → Constraints → Audit) without the deployer writing any enforcement code.

### With Lattice Inference
Templates can include Inference configuration — model selections, cluster settings, and resource budgets. Deploy agents with local inference pre-configured so sensitive data never leaves the network.

### With Lattice Workbench
Workbench uses Registry templates when deploying agents. Templates create governed agent environments that inherit Runtime's coordination policies. Plugins extend Workbench with domain-specific skills.

### With Terraform Provider
The [Terraform Provider](https://github.com/latticeHQ/terraform-provider-lattice) is the interface between Terraform and Runtime. Registry modules use the provider to declare agent infrastructure — the provider translates those declarations into Runtime API calls.

---

## Contributing

We welcome contributions from the community. Whether you're building a module for a new integration, a template for a new platform, or a plugin for a new domain — the Registry grows through contributions.

See [CONTRIBUTING.md](./CONTRIBUTING.md) for the full guide.

### Quick Start

1. Fork and clone the repository
2. Create your namespace: `mkdir -p registry/[your-username]`
3. Generate module scaffolding: `./scripts/new_module.sh [your-username]/[module-name]`
4. Implement, test, and document your module
5. Submit a pull request

Every module includes Terraform tests:

```bash
terraform init -upgrade
terraform test -verbose
```

---

## Ecosystem

| Component | Role | Repository |
|-----------|------|------------|
| [**Enterprise**](https://github.com/latticeHQ/latticeEnterprise) | Enterprise administration and governance | Coming soon |
| [**Homebrew**](https://github.com/latticeHQ/latticeHomebrew) | One-line install on macOS and Linux | [latticeHomebrew](https://github.com/latticeHQ/latticeHomebrew) |
| [**Inference**](https://github.com/latticeHQ/latticeInference) | Local AI serving — MLX on Apple Silicon, zero-config clustering | [latticeInference](https://github.com/latticeHQ/latticeInference) |
| [**Operator**](https://github.com/latticeHQ/latticeOperator) | Self-hosted deployment management for Lattice infrastructure | [latticeOperator](https://github.com/latticeHQ/latticeOperator) |
| [**Public**](https://github.com/latticeHQ/lattice) | Website + binary releases | [lattice](https://github.com/latticeHQ/lattice) |
| **Registry** (this repo) | Community ecosystem — Terraform modules, templates, stacks | You are here |
| [**Runtime**](https://github.com/latticeHQ/latticeRuntime) | Coordination layer — identity, authorization, audit, budget | [latticeRuntime](https://github.com/latticeHQ/latticeRuntime) |
| [**SDK**](https://github.com/latticeHQ/latticeSDK) | Go SDK for building Department Stacks | [latticeSDK](https://github.com/latticeHQ/latticeSDK) |
| [**Terraform Provider**](https://github.com/latticeHQ/terraform-provider-lattice) | Infrastructure as code for Lattice deployments | [terraform-provider-lattice](https://github.com/latticeHQ/terraform-provider-lattice) |
| [**Toolbox**](https://github.com/latticeHQ/latticeToolbox) | macOS app manager for Lattice products | [latticeToolbox](https://github.com/latticeHQ/latticeToolbox) |
| [**Workbench**](https://github.com/latticeHQ/latticeWorkbench) | Reference Engineering Stack — multi-model agent workspace | [latticeWorkbench](https://github.com/latticeHQ/latticeWorkbench) |

## For Maintainers

Guidelines for maintainers reviewing PRs and managing releases. [See the maintainer guide](./MAINTAINER.md).

## License

Apache 2.0 — See [LICENSE](./LICENSE) for details.

---

<div align="center">

**[latticeruntime.com](https://latticeruntime.com)** — The open-source coordination layer for institutional AI.

</div>
