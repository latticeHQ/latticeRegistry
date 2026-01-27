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
  description = "Pre-built session transcriber agent container image"
  default     = "ghcr.io/carecollaborative/session-transcriber-agent:latest"
}

variable "agent_name" {
  type        = string
  description = "Display name for this transcriber agent"
  default     = "Session Transcriber"
}

# LiveKit credentials
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

# S3-Compatible Storage Configuration
variable "s3_endpoint" {
  type        = string
  description = "S3-compatible endpoint URL (e.g., https://account.r2.cloudflarestorage.com)"
}

variable "s3_bucket" {
  type        = string
  description = "S3 bucket name for session storage"
}

variable "s3_key_id" {
  type        = string
  description = "S3 access key ID"
  sensitive   = true
}

variable "s3_key_secret" {
  type        = string
  description = "S3 secret access key"
  sensitive   = true
}

variable "s3_region" {
  type        = string
  description = "S3 region (use 'auto' for Cloudflare R2)"
  default     = "auto"
}

# Transcription configuration
variable "stt_model" {
  type        = string
  description = "Speech-to-text model (e.g., deepgram/nova-3)"
  default     = "deepgram/nova-3"
}

variable "stt_language" {
  type        = string
  description = "Transcription language (use 'multi' for multilingual)"
  default     = "multi"
}

variable "noise_cancellation" {
  type        = bool
  description = "Enable background voice cancellation"
  default     = true
}

# Recording configuration
variable "enable_recording" {
  type        = bool
  description = "Enable audio recording of sessions"
  default     = true
}

variable "recording_format" {
  type        = string
  description = "Audio recording format (ogg, mp4, webm)"
  default     = "ogg"
}

variable "audio_only_recording" {
  type        = bool
  description = "Record audio only (no video)"
  default     = true
}

# Session report configuration
variable "save_session_report" {
  type        = bool
  description = "Save comprehensive session report JSON"
  default     = true
}

variable "save_conversation_text" {
  type        = bool
  description = "Save human-readable conversation transcript"
  default     = true
}

variable "save_conversation_json" {
  type        = bool
  description = "Save clean conversation JSON for LLM processing"
  default     = true
}

variable "save_analysis_json" {
  type        = bool
  description = "Save analysis metrics JSON"
  default     = true
}

# Lattice provider configuration
data "lattice_provisioner" "me" {}

provider "docker" {}

data "lattice_agent" "me" {}
data "lattice_agent_owner" "me" {}

# Build configuration JSON for the agent
locals {
  transcriber_config_json = jsonencode({
    stt_model              = var.stt_model
    stt_language           = var.stt_language
    noise_cancellation     = var.noise_cancellation
    enable_recording       = var.enable_recording
    recording_format       = var.recording_format
    audio_only_recording   = var.audio_only_recording
    save_session_report    = var.save_session_report
    save_conversation_text = var.save_conversation_text
    save_conversation_json = var.save_conversation_json
    save_analysis_json     = var.save_analysis_json
    session_type           = "transcriber"
  })
}

# Agent resource
resource "lattice_agent" "main" {
  arch = data.lattice_provisioner.me.arch
  os   = "linux"

  metadata {
    display_name = var.agent_name
    key          = "type"
    value        = "session-transcriber"
  }

  metadata {
    display_name = "STT Model"
    key          = "stt_model"
    value        = var.stt_model
  }

  metadata {
    display_name = "Recording"
    key          = "recording_enabled"
    value        = var.enable_recording ? "enabled" : "disabled"
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
    # LiveKit credentials
    "LIVEKIT_URL=${var.livekit_url}",
    "LIVEKIT_API_KEY=${var.livekit_api_key}",
    "LIVEKIT_API_SECRET=${var.livekit_api_secret}",
    # S3 storage configuration
    "S3_ENDPOINT=${var.s3_endpoint}",
    "S3_BUCKET=${var.s3_bucket}",
    "S3_KEY_ID=${var.s3_key_id}",
    "S3_KEY_SECRET=${var.s3_key_secret}",
    "S3_REGION=${var.s3_region}",
    # Transcription configuration
    "STT_MODEL=${var.stt_model}",
    "STT_LANGUAGE=${var.stt_language}",
    "NOISE_CANCELLATION=${var.noise_cancellation}",
    # Recording configuration
    "ENABLE_RECORDING=${var.enable_recording}",
    "RECORDING_FORMAT=${var.recording_format}",
    "AUDIO_ONLY_RECORDING=${var.audio_only_recording}",
    # Session configuration
    "SESSION_TYPE=transcriber",
    # Transcriber config as JSON
    "TRANSCRIBER_CONFIG_JSON=${local.transcriber_config_json}",
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
  description = "The ID of the transcriber agent"
}

output "stt_model" {
  value       = var.stt_model
  description = "The speech-to-text model being used"
}

output "recording_enabled" {
  value       = var.enable_recording
  description = "Whether session recording is enabled"
}

output "storage_bucket" {
  value       = var.s3_bucket
  description = "The S3 bucket for session storage"
}

output "transcriber_config" {
  value       = local.transcriber_config_json
  description = "The full transcriber configuration"
  sensitive   = true
}

output "session_type" {
  value       = "transcriber"
  description = "The type of agent session"
}
