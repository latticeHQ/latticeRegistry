# Lattice Registry

### The Ecosystem of [Lattice — Agent Headquarters](https://latticeruntime.com)

**Deploy agents anywhere in minutes. Community-powered.**

[Registry Site](https://registry.latticeruntime.com) · [Lattice Runtime](https://github.com/latticeHQ/lattice) · [Docs](https://docs.latticeruntime.com)

## Part of the Lattice Ecosystem

Lattice is **Agent Headquarters** — the open-source runtime where AI agents get their identity, their permissions, their compute, and their orders. Lattice Registry is the community-driven ecosystem of reusable modules, templates, and presets.

| Component | Role | Repository |
|-----------|------|------------|
| [**Runtime**](https://github.com/latticeHQ/lattice) | Enforcement kernel — identity, authorization, audit, deployment constraints | [latticeRuntime](https://github.com/latticeHQ/lattice) |
| [**Inference**](https://github.com/latticeHQ/lattice-inference) | Local LLM serving — MLX, CUDA, zero-config clustering, OpenAI-compatible API | [latticeInference](https://github.com/latticeHQ/lattice-inference) |
| [**Workbench**](https://github.com/latticeHQ/lattice-workbench) | Agent IDE & operations console — multi-model chat, monitoring, desktop/web/CLI | [latticeWorkbench](https://github.com/latticeHQ/lattice-workbench) |
| **Registry** (this repo) | Community ecosystem — templates, modules, presets for Docker/K8s/AWS/GCP/Azure | You are here |

```
brew install latticehq/lattice/lattice

```

## Overview

Lattice Registry extends the Lattice platform with reusable Terraform modules for AI agent infrastructure. Publish and discover modules for:

- **Identity & Auth**: OAuth, OIDC, and API key management for AI agents
- **Policy Templates**: Authorization rules and deployment constraints
- **Integrations**: Connections to AI frameworks (LiveKit, Deepgram, ElevenLabs, Cartesia)
- **Monitoring**: Audit logging, tracing, and observability configurations
- **Agent Templates**: Pre-configured agent deployment environments
- **Compliance Presets**: HIPAA, SOC2, and industry-specific configurations

## Getting Started

The easiest way to discover modules is by visiting [the Lattice Registry website](https://registry.latticeruntime.com/).

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

# Deploy healthcare-compliant environment
lattice templates apply kubernetes --with-preset hipaa-compliant
```

## What's Available

### Modules (Building Blocks)

| Module | Description |
|--------|-------------|
| `agent-identity` | OAuth 2.0, OIDC, API key management for agents |
| `policy-engine` | Runtime enforcement rules and constraints |
| `livekit-integration` | Real-time voice/video for AI agents |

### Templates (One-Click Deployments)

| Category | Templates |
|----------|-----------|
| **Infrastructure** | Docker, Kubernetes, AWS Linux, GCP Linux, Azure Linux, Azure Windows |
| **AI Services** | LiveKit (voice), Deepgram (speech-to-text), ElevenLabs (TTS), Cartesia (voice synthesis) |
| **Developer Tools** | Cursor, Windsurf, Continue integrations |
| **Healthcare** | CareCollaborative clinical scenarios, patient simulation |

### Presets (Ready-Made Configurations)

- **Compliance**: HIPAA, SOC2 configurations
- **Development**: Quick-start environments
- **Vertical-Specific**: Healthcare, clinical scenarios

## How It Works with the Ecosystem

### With Lattice Runtime
Registry templates deploy pre-configured Runtime environments. Every template includes identity, authorization, and audit — enforcement is built into every deployment by default.

### With Lattice Inference
Templates can include Inference configuration — model selections, cluster settings, and resource budgets. Healthcare templates can specify on-prem-only models for data sovereignty.

### With Lattice Workbench
Workbench uses Registry templates when deploying agents. `lattice deploy my-agent --template docker` uses the Docker template from Registry to create a governed agent environment.

## Contributing

We welcome contributions! See our [contributing guide](./CONTRIBUTING.md) for more information.

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
| `presets` | Ready-made compliance and vertical configurations |

## For Maintainers

Guidelines for maintainers reviewing PRs and managing releases. [See the maintainer guide](./MAINTAINER.md).

## License

Apache 2.0 — See [LICENSE](./LICENSE) for details.

---

<div align="center">

**[Lattice — Agent Headquarters](https://latticeruntime.com)**

Your agents. Your models. Your rules. Your infrastructure.

`brew install latticehq/lattice/lattice
`

</div>
