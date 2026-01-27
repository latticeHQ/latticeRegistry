terraform {
  required_providers {
    lattice = {
      source = "latticehq/lattice"
    }
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

# Container image configuration
variable "agent_image" {
  type        = string
  description = "Pre-built workplace employee agent container image"
  default     = "ghcr.io/carecollaborative/workplace-employee-agent:latest"
}

variable "agent_name" {
  type        = string
  description = "Display name for this workplace employee agent"
  default     = "Workplace Employee Simulator"
}

# API credentials
variable "openai_api_key" {
  type        = string
  description = "OpenAI API key for LLM and TTS"
  sensitive   = true
}

variable "livekit_url" {
  type        = string
  description = "LiveKit server URL (e.g., wss://your-app.livekit.cloud)"
}

variable "livekit_api_key" {
  type        = string
  description = "LiveKit API key"
  sensitive   = true
}

variable "livekit_api_secret" {
  type        = string
  description = "LiveKit API secret"
  sensitive   = true
}

# Optional Tavus avatar configuration
variable "tavus_enabled" {
  type        = bool
  description = "Enable Tavus avatar for visual employee representation"
  default     = false
}

variable "tavus_api_key" {
  type        = string
  description = "Tavus API key (required if tavus_enabled)"
  sensitive   = true
  default     = ""
}

variable "tavus_replica_id" {
  type        = string
  description = "Tavus replica ID for avatar"
  default     = ""
}

variable "tavus_persona_id" {
  type        = string
  description = "Tavus persona ID for avatar"
  default     = ""
}

# LLM/Voice configuration
variable "llm_model" {
  type        = string
  description = "OpenAI model for employee responses"
  default     = "gpt-4o"
}

variable "stt_model" {
  type        = string
  description = "OpenAI model for speech-to-text"
  default     = "gpt-4o-transcribe"
}

variable "tts_voice" {
  type        = string
  description = "OpenAI TTS voice (alloy, echo, fable, onyx, nova, shimmer)"
  default     = "nova"
}

variable "temperature" {
  type        = number
  description = "LLM temperature (0.0-1.0, higher = more creative)"
  default     = 0.8
}

# Employee profile - Basic demographics
variable "employee_name" {
  type        = string
  description = "Employee's name"
  default     = "Sarah Chen"
}

variable "employee_age" {
  type        = number
  description = "Employee's age"
  default     = 34
}

variable "employee_gender" {
  type        = string
  description = "Employee's gender"
  default     = "female"
}

variable "employee_cultural_background" {
  type        = string
  description = "Employee's cultural background"
  default     = "Asian-American"
}

variable "employee_occupation" {
  type        = string
  description = "Employee's occupation"
  default     = "Software Engineer"
}

variable "employee_job_title" {
  type        = string
  description = "Employee's job title"
  default     = "Senior Developer"
}

variable "employee_department" {
  type        = string
  description = "Employee's department"
  default     = "Engineering"
}

variable "employee_tenure" {
  type        = string
  description = "How long the employee has been at the company"
  default     = "3 years"
}

# Workplace scenario details
variable "scenario_type" {
  type        = string
  description = "Type of workplace scenario (e.g., Sexual Harassment, Performance Feedback, Conflict Resolution)"
  default     = "Sexual Harassment"
}

variable "employee_situation" {
  type        = string
  description = "Detailed description of the workplace situation"
  default     = "Reporting inappropriate comments and unwanted advances from a senior colleague during team meetings and after-hours communications."
}

variable "employee_role" {
  type        = string
  description = "Employee's role in the scenario (complainant, manager, bystander, etc.)"
  default     = "Complainant"
}

variable "employee_concerns" {
  type        = list(string)
  description = "Key concerns the employee has about the situation"
  default     = ["Retaliation from the accused", "Not being believed", "Impact on career advancement", "Workplace relationships changing"]
}

variable "employee_desired_outcome" {
  type        = string
  description = "What the employee hopes will happen"
  default     = "The behavior stops, appropriate action is taken, and I can continue working without fear of retaliation."
}

variable "company_policies" {
  type        = list(string)
  description = "Relevant company policies that apply to the situation"
  default     = ["Anti-harassment policy", "Code of conduct", "Retaliation prevention policy", "Confidentiality guidelines"]
}

variable "previous_incidents" {
  type        = string
  description = "History of related incidents, if any"
  default     = "Two previous informal complaints to direct supervisor that were not documented or addressed."
}

# Psychological aspects
variable "employee_personality" {
  type        = string
  description = "Employee's personality traits"
  default     = "Introverted, detail-oriented, conflict-averse but principled"
}

variable "employee_emotional_state" {
  type        = string
  description = "Employee's current emotional state"
  default     = "Anxious but determined to report. Frustrated that previous informal attempts were ignored."
}

variable "employee_coping_mechanisms" {
  type        = string
  description = "How the employee copes with stress"
  default     = "Documenting everything, seeking support from trusted friends outside work, maintaining professional composure"
}

variable "employee_stress_level" {
  type        = string
  description = "Employee's current stress level"
  default     = "High - affecting sleep and work performance"
}

variable "employee_communication_style" {
  type        = string
  description = "Employee's communication style"
  default     = "Precise and factual, may downplay emotions, prefers written communication"
}

# Communication characteristics
variable "employee_vocabulary_level" {
  type        = string
  description = "Employee's vocabulary level"
  default     = "Professional - uses technical terms from their field"
}

variable "employee_communication_challenges" {
  type        = string
  description = "Any communication challenges"
  default     = "May struggle to assert boundaries, tends to over-explain or justify feelings"
}

variable "employee_non_verbal_cues" {
  type        = string
  description = "Non-verbal communication cues"
  default     = "Maintains professional posture, limited eye contact when discussing difficult topics, fidgets when anxious"
}

variable "employee_professional_rapport" {
  type        = string
  description = "Relationships with colleagues involved"
  default     = "Good relationships with team members, professional but distant with the accused, respects HR but unsure if they will help"
}

# Cultural and organizational factors
variable "employee_cultural_work_values" {
  type        = string
  description = "Cultural values affecting workplace views"
  default     = "Values harmony and avoiding confrontation, but also believes in fairness and proper process"
}

variable "employee_generational_factors" {
  type        = string
  description = "Generational factors affecting perspective"
  default     = "Millennial - expects professional workplace, familiar with reporting processes, values documentation"
}

variable "employee_power_dynamics" {
  type        = string
  description = "Power dynamics in the situation"
  default     = "Accused is a senior team lead with more tenure and influence in the organization"
}

variable "employee_identity_factors" {
  type        = string
  description = "Identity factors relevant to the situation"
  default     = "One of few women in the engineering department, first-generation professional"
}

# Scenario context
variable "current_stage" {
  type        = string
  description = "Current stage of the scenario (e.g., Initial Complaint, Follow-up Meeting)"
  default     = "Initial Complaint"
}

variable "scenario_context" {
  type        = string
  description = "Broader organizational context"
  default     = "Fast-growing tech startup with developing HR processes, recent company-wide harassment training"
}

variable "key_conflict_points" {
  type        = list(string)
  description = "Areas where tension or disagreement exists"
  default     = ["Whether the behavior constitutes harassment", "Credibility of accounts", "Appropriate response from management"]
}

variable "legal_implications" {
  type        = string
  description = "Any potential legal considerations"
  default     = "Potential Title VII implications, duty to investigate, documentation requirements"
}

# Voice characteristics
variable "employee_voice_baseline" {
  type        = string
  description = "Baseline voice characteristics"
  default     = "Calm and measured, professional tone, speaks clearly"
}

variable "employee_voice_emotional_patterns" {
  type        = string
  description = "How voice changes with emotions"
  default     = "Voice tightens when recounting incidents, speaks faster when anxious, pauses before difficult admissions"
}

# Introduction
variable "employee_introduction" {
  type        = string
  description = "Employee's opening line when session starts"
  default     = "Thank you for meeting with me. I've been putting this off, but I need to formally report something that's been happening. I'm not sure exactly where to start."
}

# Lattice provider configuration
data "lattice_provisioner" "me" {}

provider "docker" {}

data "lattice_agent" "me" {}
data "lattice_agent_owner" "me" {}

# Build workplace profile JSON for the agent
locals {
  workplace_profile_json = jsonencode({
    # Basic demographics
    name                  = var.employee_name
    age                   = var.employee_age
    gender                = var.employee_gender
    cultural_background   = var.employee_cultural_background
    occupation            = var.employee_occupation
    job_title             = var.employee_job_title
    department            = var.employee_department
    tenure                = var.employee_tenure

    # Workplace scenario details
    scenario_type         = var.scenario_type
    situation             = var.employee_situation
    role                  = var.employee_role
    concerns              = var.employee_concerns
    desired_outcome       = var.employee_desired_outcome
    company_policies      = var.company_policies
    previous_incidents    = var.previous_incidents

    # Psychological aspects
    personality           = var.employee_personality
    emotional_state       = var.employee_emotional_state
    coping_mechanisms     = var.employee_coping_mechanisms
    stress_level          = var.employee_stress_level
    communication_style   = var.employee_communication_style

    # Communication characteristics
    vocabulary_level      = var.employee_vocabulary_level
    communication_challenges = var.employee_communication_challenges
    non_verbal_cues       = var.employee_non_verbal_cues
    professional_rapport  = var.employee_professional_rapport

    # Cultural and organizational factors
    cultural_work_values  = var.employee_cultural_work_values
    generational_factors  = var.employee_generational_factors
    power_dynamics        = var.employee_power_dynamics
    identity_factors      = var.employee_identity_factors

    # Scenario context
    current_stage         = var.current_stage
    scenario_context      = var.scenario_context
    key_conflict_points   = var.key_conflict_points
    legal_implications    = var.legal_implications

    # Voice characteristics
    voice_baseline        = var.employee_voice_baseline
    voice_emotional_patterns = var.employee_voice_emotional_patterns

    # Introduction
    introduction          = var.employee_introduction

    # Session type marker
    session_type          = "workplace"
  })
}

# Agent resource
resource "lattice_agent" "main" {
  arch = data.lattice_provisioner.me.arch
  os   = "linux"

  metadata {
    display_name = var.agent_name
    key          = "type"
    value        = "workplace-employee"
  }

  metadata {
    display_name = "Employee"
    key          = "employee_name"
    value        = var.employee_name
  }

  metadata {
    display_name = "Scenario"
    key          = "scenario_type"
    value        = var.scenario_type
  }

  metadata {
    display_name = "Role"
    key          = "employee_role"
    value        = var.employee_role
  }
}

# Pull the pre-built agent image
resource "docker_image" "main" {
  name         = var.agent_image
  keep_locally = true
}

# Docker volume for persistent data
resource "docker_volume" "home_volume" {
  name = "lattice-${data.lattice_agent.me.id}-home"
  lifecycle {
    ignore_changes = all
  }
  labels {
    label = "lattice.owner"
    value = data.lattice_agent_owner.me.name
  }
  labels {
    label = "lattice.owner_id"
    value = data.lattice_agent_owner.me.id
  }
  labels {
    label = "lattice.workspace_id"
    value = data.lattice_agent.me.id
  }
}

# Docker container running the pre-built agent
resource "docker_container" "workspace" {
  count = data.lattice_agent.me.start_count
  image = docker_image.main.image_id
  name  = "lattice-${data.lattice_agent_owner.me.name}-${lower(data.lattice_agent.me.name)}"

  hostname = data.lattice_agent.me.name

  entrypoint = ["sh", "-c", replace(lattice_agent.main.init_script, "/localhost|127\\.0\\.0\\.1/", "host.docker.internal")]

  env = [
    "LATTICE_SIDECAR_TOKEN=${lattice_agent.main.token}",
    # API credentials
    "OPENAI_API_KEY=${var.openai_api_key}",
    "LIVEKIT_URL=${var.livekit_url}",
    "LIVEKIT_API_KEY=${var.livekit_api_key}",
    "LIVEKIT_API_SECRET=${var.livekit_api_secret}",
    # LLM/Voice configuration
    "PERSONA_LLM_MODEL=${var.llm_model}",
    "PERSONA_STT_MODEL=${var.stt_model}",
    "PERSONA_TTS_VOICE=${var.tts_voice}",
    "PERSONA_TEMPERATURE=${var.temperature}",
    # Tavus avatar configuration
    "TAVUS_ENABLED=${var.tavus_enabled}",
    "TAVUS_API_KEY=${var.tavus_api_key}",
    "TAVUS_REPLICA_ID=${var.tavus_replica_id}",
    "TAVUS_PERSONA_ID=${var.tavus_persona_id}",
    # Session configuration
    "SESSION_TYPE=workplace",
    # Workplace profile as JSON (agent reads from env)
    "WORKPLACE_PROFILE_JSON=${local.workplace_profile_json}",
  ]

  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }

  volumes {
    container_path = "/home/lattice"
    volume_name    = docker_volume.home_volume.name
    read_only      = false
  }
}

# Outputs
output "sidecar_id" {
  value       = lattice_agent.main.id
  description = "The ID of the workplace employee agent"
}

output "employee_name" {
  value       = var.employee_name
  description = "The name of the simulated employee"
}

output "scenario_type" {
  value       = var.scenario_type
  description = "The type of workplace scenario"
}

output "employee_role" {
  value       = var.employee_role
  description = "The employee's role in the scenario"
}

output "workplace_profile" {
  value       = local.workplace_profile_json
  description = "The full workplace profile as JSON"
  sensitive   = true
}

output "session_type" {
  value       = "workplace"
  description = "The type of training session"
}
