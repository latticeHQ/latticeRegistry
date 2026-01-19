terraform {
  required_version = ">= 1.0"

  required_providers {
    lattice = {
      source  = "latticeHQ/lattice"
      version = ">= 0.1.0"
    }
  }
}

# Session type: clinical, workplace, observation
variable "session_type" {
  type        = string
  description = "Type of evaluation session"
  default     = "clinical"

  validation {
    condition     = contains(["clinical", "workplace", "observation"], var.session_type)
    error_message = "Session type must be one of: clinical, workplace, observation"
  }
}

# Enable filtering by tags
variable "filter_tags" {
  type        = list(string)
  description = "Optional tags to filter personas"
  default     = []
}

# Persona definitions - the core data structure
# In a real deployment, this would be loaded from external JSON files
variable "personas" {
  type = list(object({
    id           = string
    dispatch_name = string
    name         = string
    description  = string
    session_type = string
    icon         = optional(string, "")
    avatar_id    = optional(string, "")
    tags         = optional(list(string), [])
    demographics = optional(object({
      age        = optional(number)
      gender     = optional(string)
      ethnicity  = optional(string)
      occupation = optional(string)
    }))
    config = optional(object({
      model        = optional(string, "gpt-4o")
      temperature  = optional(number, 0.7)
      max_tokens   = optional(number, 4000)
      instructions = optional(string, "")
      voice        = optional(string, "alloy")
    }))
  }))
  description = "List of persona definitions"
  default = [
    # Clinical Personas (AI Patients)
    {
      id           = "clinical-v1"
      dispatch_name = "clinical-v1"
      name         = "Clinical Patient"
      description  = "Standard clinical patient for medical training"
      session_type = "clinical"
      icon         = "hospital"
      tags         = ["patient", "clinical", "general"]
      demographics = {
        age    = 45
        gender = "female"
      }
      config = {
        model        = "gpt-4o"
        temperature  = 0.7
        instructions = "You are a patient presenting with symptoms. Respond naturally to medical questions."
        voice        = "nova"
      }
    },
    {
      id           = "clinical-cardiac-v1"
      dispatch_name = "clinical-v1"
      name         = "Cardiac Patient"
      description  = "Patient presenting with cardiac symptoms"
      session_type = "clinical"
      icon         = "heart"
      tags         = ["patient", "clinical", "cardiology", "chest-pain"]
      demographics = {
        age        = 58
        gender     = "male"
        occupation = "accountant"
      }
      config = {
        model        = "gpt-4o"
        temperature  = 0.6
        instructions = "You are a patient with chest pain and shortness of breath. You have a history of hypertension."
        voice        = "echo"
      }
    },
    {
      id           = "clinical-pediatric-v1"
      dispatch_name = "clinical-v1"
      name         = "Pediatric Patient Parent"
      description  = "Parent of a pediatric patient"
      session_type = "clinical"
      icon         = "child"
      tags         = ["patient", "clinical", "pediatrics", "parent"]
      demographics = {
        age    = 32
        gender = "female"
      }
      config = {
        model        = "gpt-4o"
        temperature  = 0.8
        instructions = "You are a concerned parent bringing your 5-year-old child in for evaluation. You are worried and anxious."
        voice        = "shimmer"
      }
    },
    # Workplace Personas (AI Employees)
    {
      id           = "workplace-v1"
      dispatch_name = "workplace-v1"
      name         = "Workplace Employee"
      description  = "Standard workplace employee for training scenarios"
      session_type = "workplace"
      icon         = "briefcase"
      tags         = ["employee", "workplace", "general"]
      demographics = {
        age        = 35
        gender     = "male"
        occupation = "software engineer"
      }
      config = {
        model        = "gpt-4o"
        temperature  = 0.7
        instructions = "You are an employee in a workplace training scenario. Respond naturally to professional interactions."
        voice        = "onyx"
      }
    },
    {
      id           = "workplace-difficult-v1"
      dispatch_name = "workplace-v1"
      name         = "Difficult Conversation"
      description  = "Employee scenario for practicing difficult conversations"
      session_type = "workplace"
      icon         = "alert"
      tags         = ["employee", "workplace", "difficult", "hr"]
      demographics = {
        age        = 42
        gender     = "female"
        occupation = "senior manager"
      }
      config = {
        model        = "gpt-4o"
        temperature  = 0.75
        instructions = "You are an employee who is upset about being passed over for promotion. Express frustration professionally."
        voice        = "nova"
      }
    },
    {
      id           = "workplace-onboarding-v1"
      dispatch_name = "workplace-v1"
      name         = "New Hire Onboarding"
      description  = "New employee for onboarding practice"
      session_type = "workplace"
      icon         = "user-plus"
      tags         = ["employee", "workplace", "onboarding", "new-hire"]
      demographics = {
        age        = 24
        gender     = "non-binary"
        occupation = "junior developer"
      }
      config = {
        model        = "gpt-4o"
        temperature  = 0.8
        instructions = "You are a new employee on your first day. Ask questions and show enthusiasm while learning."
        voice        = "alloy"
      }
    }
  ]
}

# Filter personas by session type and optional tags
locals {
  filtered_by_type = [
    for persona in var.personas : persona
    if persona.session_type == var.session_type
  ]

  filtered_personas = length(var.filter_tags) > 0 ? [
    for persona in local.filtered_by_type : persona
    if length(setintersection(toset(coalesce(persona.tags, [])), toset(var.filter_tags))) > 0
  ] : local.filtered_by_type

  # Create a map for easy lookup
  persona_map = {
    for persona in var.personas : persona.id => persona
  }
}

# Output filtered personas as JSON for API consumption
output "personas" {
  description = "List of personas filtered by session type and tags"
  value       = local.filtered_personas
}

output "personas_json" {
  description = "JSON representation of filtered personas for API consumption"
  value       = jsonencode(local.filtered_personas)
}

output "persona_ids" {
  description = "List of persona IDs"
  value       = [for p in local.filtered_personas : p.id]
}

output "persona_count" {
  description = "Number of personas matching the filter"
  value       = length(local.filtered_personas)
}

# Output for direct persona lookup by ID
output "persona_lookup" {
  description = "Map of persona ID to persona definition"
  value       = local.persona_map
}
