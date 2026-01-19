terraform {
  required_providers {
    wirtual = {
      source = "wirtualdev/wirtual"
    }
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

# Container image configuration
variable "agent_image" {
  type        = string
  description = "Pre-built clinical patient agent container image"
  default     = "ghcr.io/carecollaborative/clinical-patient-agent:latest"
}

variable "agent_name" {
  type        = string
  description = "Display name for this clinical patient agent"
  default     = "Clinical Patient Simulator"
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
  description = "Enable Tavus avatar for visual patient representation"
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
  description = "OpenAI model for patient responses"
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

# Patient profile configuration
variable "patient_name" {
  type        = string
  description = "Patient's name"
  default     = "Maria Santos"
}

variable "patient_age" {
  type        = number
  description = "Patient's age"
  default     = 58
}

variable "patient_gender" {
  type        = string
  description = "Patient's gender"
  default     = "female"
}

variable "patient_cultural_background" {
  type        = string
  description = "Patient's cultural background"
  default     = "Filipino-American"
}

variable "patient_diagnosis" {
  type        = string
  description = "Patient's primary diagnosis"
  default     = "Type 2 Diabetes with hypertension"
}

variable "patient_symptoms" {
  type        = list(string)
  description = "Patient's current symptoms"
  default     = ["fatigue", "increased thirst", "frequent urination", "occasional headaches"]
}

variable "patient_emotional_state" {
  type        = string
  description = "Patient's current emotional state"
  default     = "Anxious about medication side effects and lifestyle changes"
}

variable "patient_health_literacy" {
  type        = string
  description = "Patient's health literacy level"
  default     = "Moderate - understands basic medical terms"
}

variable "patient_introduction" {
  type        = string
  description = "Patient's opening line when session starts"
  default     = "Hello doctor. I'm here because my regular doctor said my sugar levels are too high and I need to see a specialist."
}

variable "patient_medical_history" {
  type        = list(string)
  description = "Patient's medical history"
  default     = ["Hypertension diagnosed 5 years ago", "Gestational diabetes during pregnancy 25 years ago"]
}

variable "patient_medications" {
  type        = list(string)
  description = "Patient's current medications"
  default     = ["Lisinopril 10mg daily for blood pressure"]
}

variable "patient_allergies" {
  type        = list(string)
  description = "Patient's known allergies"
  default     = ["Penicillin - causes rash"]
}

variable "patient_concerns" {
  type        = list(string)
  description = "Patient's health concerns"
  default     = ["Side effects of diabetes medication", "Having to give myself injections", "Changing my diet"]
}

variable "patient_health_beliefs" {
  type        = string
  description = "Patient's cultural health beliefs"
  default     = "Believes in traditional remedies alongside modern medicine. Values family input in health decisions."
}

variable "patient_communication_style" {
  type        = string
  description = "Patient's communication style"
  default     = "Respectful and polite but may not immediately share all concerns. Tends to agree with doctors even when uncertain."
}

# Wirtual provider configuration
data "wirtual_provisioner" "me" {}

provider "docker" {}

data "wirtual_workspace" "me" {}
data "wirtual_workspace_owner" "me" {}

# Build persona JSON for the agent
locals {
  persona_json = jsonencode({
    name                  = var.patient_name
    age                   = var.patient_age
    gender                = var.patient_gender
    cultural_background   = var.patient_cultural_background
    diagnosis             = var.patient_diagnosis
    symptoms              = var.patient_symptoms
    medical_history       = var.patient_medical_history
    medications           = var.patient_medications
    allergies             = var.patient_allergies
    emotional_state       = var.patient_emotional_state
    concerns              = var.patient_concerns
    health_beliefs        = var.patient_health_beliefs
    health_literacy       = var.patient_health_literacy
    communication_style   = var.patient_communication_style
    introduction          = var.patient_introduction
    session_type          = "clinical"
  })
}

# Agent resource
resource "wirtual_agent" "main" {
  arch = data.wirtual_provisioner.me.arch
  os   = "linux"

  metadata {
    display_name = var.agent_name
    key          = "type"
    value        = "clinical-patient"
  }

  metadata {
    display_name = "Patient"
    key          = "patient_name"
    value        = var.patient_name
  }

  metadata {
    display_name = "Diagnosis"
    key          = "diagnosis"
    value        = var.patient_diagnosis
  }
}

# Pull the pre-built agent image
resource "docker_image" "main" {
  name         = var.agent_image
  keep_locally = true
}

# Docker volume for persistent data
resource "docker_volume" "home_volume" {
  name = "wirtual-${data.wirtual_workspace.me.id}-home"
  lifecycle {
    ignore_changes = all
  }
  labels {
    label = "wirtual.owner"
    value = data.wirtual_workspace_owner.me.name
  }
  labels {
    label = "wirtual.owner_id"
    value = data.wirtual_workspace_owner.me.id
  }
  labels {
    label = "wirtual.workspace_id"
    value = data.wirtual_workspace.me.id
  }
}

# Docker container running the pre-built agent
resource "docker_container" "workspace" {
  count = data.wirtual_workspace.me.start_count
  image = docker_image.main.image_id
  name  = "wirtual-${data.wirtual_workspace_owner.me.name}-${lower(data.wirtual_workspace.me.name)}"

  hostname = data.wirtual_workspace.me.name

  entrypoint = ["sh", "-c", replace(wirtual_agent.main.init_script, "/localhost|127\\.0\\.0\\.1/", "host.docker.internal")]

  env = [
    "WIRTUAL_AGENT_TOKEN=${wirtual_agent.main.token}",
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
    "SESSION_TYPE=clinical",
    # Patient persona as JSON (agent reads from env)
    "PERSONA_JSON=${local.persona_json}",
  ]

  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }

  volumes {
    container_path = "/home/wirtual"
    volume_name    = docker_volume.home_volume.name
    read_only      = false
  }
}

# Outputs
output "agent_id" {
  value       = wirtual_agent.main.id
  description = "The ID of the clinical patient agent"
}

output "patient_name" {
  value       = var.patient_name
  description = "The name of the simulated patient"
}

output "patient_profile" {
  value       = local.persona_json
  description = "The full patient profile as JSON"
  sensitive   = true
}

output "session_type" {
  value       = "clinical"
  description = "The type of training session"
}
