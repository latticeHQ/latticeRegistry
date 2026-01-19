---
display_name: "Agent Identity"
description: "Configure identity and authentication for AI agents in Lattice Runtime"
icon: "../../../../.icons/key.svg"
verified: true
tags: ["identity", "authentication", "oauth", "oidc", "agent"]
---

# Agent Identity

This module configures identity and authentication for AI agents running in Lattice Runtime.

## Features

- OAuth 2.0 and OIDC provider integration
- API key management for agent-to-service communication
- JWT token issuance and validation
- Identity federation across multiple providers

## Usage

```tf
module "agent-identity" {
  source   = "registry.latticeruntime.com/lattice/agent-identity/lattice"
  version  = "1.0.0"
  agent_id = lattice_agent.main.id

  # Configure identity provider
  provider_type = "oidc"
  issuer_url    = "https://auth.example.com"
  client_id     = var.oidc_client_id

  # Optional: Enable API key generation
  enable_api_keys = true
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `agent_id` | The ID of the Lattice agent | `string` | - | yes |
| `provider_type` | Identity provider type (oidc, oauth2, apikey) | `string` | `"oidc"` | no |
| `issuer_url` | OIDC issuer URL | `string` | `""` | no |
| `client_id` | OAuth client ID | `string` | `""` | no |
| `enable_api_keys` | Enable API key generation for the agent | `bool` | `false` | no |
| `token_lifetime` | JWT token lifetime in seconds | `number` | `3600` | no |

## Outputs

| Name | Description |
|------|-------------|
| `identity_endpoint` | The identity service endpoint |
| `token_endpoint` | The token issuance endpoint |
