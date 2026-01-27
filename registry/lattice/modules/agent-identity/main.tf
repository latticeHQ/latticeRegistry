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

variable "provider_type" {
  type        = string
  description = "Identity provider type (oidc, oauth2, apikey)"
  default     = "oidc"

  validation {
    condition     = contains(["oidc", "oauth2", "apikey"], var.provider_type)
    error_message = "Provider type must be one of: oidc, oauth2, apikey"
  }
}

variable "issuer_url" {
  type        = string
  description = "OIDC issuer URL"
  default     = ""
}

variable "client_id" {
  type        = string
  description = "OAuth client ID"
  default     = ""
}

variable "enable_api_keys" {
  type        = bool
  description = "Enable API key generation for the agent"
  default     = false
}

variable "token_lifetime" {
  type        = number
  description = "JWT token lifetime in seconds"
  default     = 3600
}

data "lattice_agent" "current" {}

resource "lattice_sidecar_metadata" "identity" {
  sidecar_id = var.sidecar_id
  key      = "identity_provider"
  value    = var.provider_type
}

resource "lattice_sidecar_metadata" "issuer" {
  count    = var.provider_type == "oidc" ? 1 : 0
  sidecar_id = var.sidecar_id
  key      = "oidc_issuer"
  value    = var.issuer_url
}

output "identity_endpoint" {
  description = "The identity service endpoint"
  value       = "${data.lattice_agent.current.access_url}/api/v1/identity"
}

output "token_endpoint" {
  description = "The token issuance endpoint"
  value       = "${data.lattice_agent.current.access_url}/api/v1/identity/token"
}
