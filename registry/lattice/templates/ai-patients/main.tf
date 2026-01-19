terraform {
  required_providers {
    wirtual = {
      source = "wirtualdev/wirtual"
    }
  }
}

# AI Model Configuration for Transcript Analysis
variable "analysis_model" {
  description = "AI model for transcript analysis"
  type        = string
  default     = "gpt-4.1"
  validation {
    condition = contains([
      "gpt-4.1",
      "gpt-4o",
      "claude-sonnet-4.5-20250110",
      "claude-sonnet-4-20250514",
      "claude-sonnet-4-5-20250929"
    ], var.analysis_model)
    error_message = "Must be a valid AI model: gpt-4.1, gpt-4o, claude-sonnet-4.5-20250110, claude-sonnet-4-20250514, or claude-SONNET-4-5-20250929"
  }
}

variable "analysis_max_tokens" {
  description = "Maximum tokens for AI analysis response"
  type        = number
  default     = 4000
  validation {
    condition     = var.analysis_max_tokens >= 1000 && var.analysis_max_tokens <= 16000
    error_message = "Max tokens must be between 1000 and 16000"
  }
}

variable "analysis_temperature" {
  description = "Temperature for AI analysis (0.0-1.0, lower is more focused)"
  type        = number
  default     = 0.3
  validation {
    condition     = var.analysis_temperature >= 0.0 && var.analysis_temperature <= 1.0
    error_message = "Temperature must be between 0.0 and 1.0"
  }
}

variable "analysis_provider" {
  description = "AI provider for transcript analysis (anthropic or openai)"
  type        = string
  default     = "anthropic"
  validation {
    condition     = contains(["anthropic", "openai"], var.analysis_provider)
    error_message = "Provider must be either 'anthropic' or 'openai'"
  }
}

# Template parameters for transcript analysis configuration
data "wirtual_parameter" "analysis_model" {
  name         = "analysis_model"
  display_name = "AI Analysis Model"
  description  = "Model name: gpt-4.1, gpt-4o, claude-sonnet-4.5-20250110, claude-sonnet-4-20250514, claude-SONNET-4-5-20250929"
  type         = "string"
  mutable      = true
  default      = var.analysis_model
}

data "wirtual_parameter" "analysis_max_tokens" {
  name         = "analysis_max_tokens"
  display_name = "Max Analysis Tokens"
  description  = "Maximum tokens for AI response (1000-16000)"
  type         = "number"
  mutable      = true
  default      = tostring(var.analysis_max_tokens)
  validation {
    min = 1000
    max = 16000
  }
}

data "wirtual_parameter" "analysis_temperature" {
  name         = "analysis_temperature"
  display_name = "Analysis Temperature"
  description  = "Creativity level (0.0=focused, 1.0=creative)"
  type         = "string"
  mutable      = true
  default      = tostring(var.analysis_temperature)
}

data "wirtual_parameter" "analysis_provider" {
  name         = "analysis_provider"
  display_name = "AI Provider"
  description  = "Choose AI provider: anthropic (Claude) or openai (GPT)"
  type         = "string"
  mutable      = true
  default      = var.analysis_provider
}
