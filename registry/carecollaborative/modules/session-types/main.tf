terraform {
  required_version = ">= 1.0"

  required_providers {
    lattice = {
      source  = "latticeHQ/lattice"
      version = ">= 0.1.0"
    }
  }
}

# Session type definitions for evaluation platform
variable "session_types" {
  type = list(object({
    id              = string
    name            = string
    description     = string
    icon            = string
    requires_persona = bool
    has_transcriber = bool
    has_avatar      = bool
    default_agents  = list(string)
    allowed_roles   = list(string)
    features        = optional(list(string), [])
  }))
  description = "List of session type definitions"
  default = [
    {
      id              = "clinical"
      name            = "Clinical Training"
      description     = "Student-AI patient interaction for medical education"
      icon            = "stethoscope"
      requires_persona = true
      has_transcriber = true
      has_avatar      = true
      default_agents  = ["transcriber-v1"]
      allowed_roles   = ["student", "faculty", "admin"]
      features        = ["transcript", "assessment", "feedback", "avatar"]
    },
    {
      id              = "workplace"
      name            = "Workplace Training"
      description     = "Employee-AI employee training simulation"
      icon            = "briefcase"
      requires_persona = true
      has_transcriber = true
      has_avatar      = true
      default_agents  = ["transcriber-v1"]
      allowed_roles   = ["employee", "manager", "hr", "admin"]
      features        = ["transcript", "assessment", "feedback", "avatar"]
    },
    {
      id              = "observation"
      name            = "Faculty Observation"
      description     = "Faculty-student interaction with transcription only"
      icon            = "eye"
      requires_persona = false
      has_transcriber = true
      has_avatar      = false
      default_agents  = ["transcriber-v1"]
      allowed_roles   = ["student", "faculty", "admin"]
      features        = ["transcript", "assessment"]
    }
  ]
}

# Create a map for easy lookup
locals {
  session_type_map = {
    for st in var.session_types : st.id => st
  }

  # List of session types that require persona selection
  persona_required_types = [
    for st in var.session_types : st.id if st.requires_persona
  ]

  # List of session types with avatar support
  avatar_enabled_types = [
    for st in var.session_types : st.id if st.has_avatar
  ]
}

# Output session types as JSON for API
output "session_types" {
  description = "List of all session type definitions"
  value       = var.session_types
}

output "session_types_json" {
  description = "JSON representation of session types for API consumption"
  value       = jsonencode(var.session_types)
}

output "session_type_ids" {
  description = "List of session type IDs"
  value       = [for st in var.session_types : st.id]
}

output "session_type_lookup" {
  description = "Map of session type ID to definition"
  value       = local.session_type_map
}

output "persona_required_types" {
  description = "Session types that require persona selection"
  value       = local.persona_required_types
}

output "avatar_enabled_types" {
  description = "Session types that support avatar rendering"
  value       = local.avatar_enabled_types
}
