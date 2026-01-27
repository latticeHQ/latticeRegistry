terraform {
  required_version = ">= 1.0"

  required_providers {
    lattice = {
      source  = "latticeHQ/lattice"
      version = ">= 0.1.0"
    }
  }
}

variable "sidecar_id" {
  type        = string
  description = "The ID of the Lattice agent"
}

variable "policies" {
  type = list(object({
    name       = string
    effect     = string
    actions    = list(string)
    conditions = optional(map(string), {})
  }))
  description = "List of policy definitions"
  default     = []
}

variable "default_effect" {
  type        = string
  description = "Default policy effect (allow/deny)"
  default     = "deny"

  validation {
    condition     = contains(["allow", "deny"], var.default_effect)
    error_message = "Default effect must be 'allow' or 'deny'"
  }
}

variable "enable_audit" {
  type        = bool
  description = "Enable audit logging for policy decisions"
  default     = true
}

variable "audit_retention_days" {
  type        = number
  description = "Number of days to retain audit logs"
  default     = 30
}

data "lattice_agent" "current" {}

resource "lattice_sidecar_metadata" "policy_mode" {
  sidecar_id = var.sidecar_id
  key      = "policy_default_effect"
  value    = var.default_effect
}

resource "lattice_sidecar_metadata" "audit_enabled" {
  sidecar_id = var.sidecar_id
  key      = "policy_audit_enabled"
  value    = tostring(var.enable_audit)
}

resource "lattice_sidecar_metadata" "policies" {
  sidecar_id = var.sidecar_id
  key      = "policies"
  value    = jsonencode(var.policies)
}

output "policy_endpoint" {
  description = "The policy evaluation endpoint"
  value       = "${data.lattice_agent.current.access_url}/api/v1/policy/evaluate"
}

output "audit_endpoint" {
  description = "The audit log endpoint"
  value       = "${data.lattice_agent.current.access_url}/api/v1/policy/audit"
}
