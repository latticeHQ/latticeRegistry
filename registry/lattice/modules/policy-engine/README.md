---
display_name: "Policy Engine"
description: "Runtime policy enforcement and authorization rules for AI agents"
icon: "../../../../.icons/shield.svg"
verified: true
tags: ["policy", "authorization", "enforcement", "security", "agent"]
---

# Policy Engine

This module configures runtime policy enforcement for AI agents in Lattice Runtime.

## Features

- Define authorization policies for agent actions
- Rate limiting and resource quotas
- Action allowlists and blocklists
- Audit logging for policy decisions

## Usage

```tf
module "policy-engine" {
  source   = "registry.latticeruntime.com/lattice/policy-engine/lattice"
  version  = "1.0.0"
  sidecar_id = lattice_agent.main.id

  # Define policies
  policies = [
    {
      name   = "api-rate-limit"
      effect = "allow"
      actions = ["api:*"]
      conditions = {
        rate_limit = "100/minute"
      }
    },
    {
      name   = "deny-destructive"
      effect = "deny"
      actions = ["system:delete", "system:shutdown"]
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `sidecar_id` | The ID of the Lattice agent | `string` | - | yes |
| `policies` | List of policy definitions | `list(object)` | `[]` | no |
| `default_effect` | Default policy effect (allow/deny) | `string` | `"deny"` | no |
| `enable_audit` | Enable audit logging for policy decisions | `bool` | `true` | no |
| `audit_retention_days` | Number of days to retain audit logs | `number` | `30` | no |

## Outputs

| Name | Description |
|------|-------------|
| `policy_endpoint` | The policy evaluation endpoint |
| `audit_endpoint` | The audit log endpoint |
