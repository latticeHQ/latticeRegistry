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

variable "enable_voice" {
  type        = bool
  description = "Enable voice communication"
  default     = true
}

variable "enable_video" {
  type        = bool
  description = "Enable video communication"
  default     = false
}

variable "room_prefix" {
  type        = string
  description = "Prefix for LiveKit room names"
  default     = "lattice"
}

variable "sample_rate" {
  type        = number
  description = "Audio sample rate in Hz"
  default     = 48000

  validation {
    condition     = contains([16000, 24000, 48000], var.sample_rate)
    error_message = "Sample rate must be one of: 16000, 24000, 48000"
  }
}

variable "channels" {
  type        = number
  description = "Number of audio channels"
  default     = 1

  validation {
    condition     = var.channels >= 1 && var.channels <= 2
    error_message = "Channels must be 1 (mono) or 2 (stereo)"
  }
}

variable "capabilities" {
  type        = list(string)
  description = "List of agent capabilities"
  default     = []
}

data "lattice_agent" "current" {}

resource "lattice_sidecar_metadata" "integration" {
  sidecar_id = var.sidecar_id
  key      = "livekit_enabled"
  value    = "true"
}

resource "lattice_sidecar_metadata" "voice" {
  sidecar_id = var.sidecar_id
  key      = "livekit_voice"
  value    = tostring(var.enable_voice)
}

resource "lattice_sidecar_metadata" "video" {
  sidecar_id = var.sidecar_id
  key      = "livekit_video"
  value    = tostring(var.enable_video)
}

resource "lattice_sidecar_metadata" "audio_config" {
  sidecar_id = var.sidecar_id
  key      = "livekit_audio_config"
  value    = jsonencode({
    sample_rate = var.sample_rate
    channels    = var.channels
  })
}

resource "lattice_sidecar_metadata" "capabilities" {
  count    = length(var.capabilities) > 0 ? 1 : 0
  sidecar_id = var.sidecar_id
  key      = "livekit_capabilities"
  value    = jsonencode(var.capabilities)
}

output "room_url" {
  description = "The LiveKit room connection URL"
  value       = "${data.lattice_agent.current.access_url}/api/v1/integrations/livekit/room/${var.room_prefix}"
}

output "websocket_endpoint" {
  description = "The WebSocket endpoint for real-time communication"
  value       = "${data.lattice_agent.current.access_url}/api/v1/integrations/livekit/ws"
}
