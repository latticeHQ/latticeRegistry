terraform {
  required_providers {
    lattice = {
      source = "latticehq/lattice"
    }
  }
}

# =============================================================================
# CLINICAL FEEDBACK TEMPLATE (category: evaluation)
# =============================================================================
# This template defines the AI feedback pipeline for clinical transcripts.
# It is a non-provisioned template — no infrastructure is created.
# The evaluation engine reads these parameters to configure analysis passes,
# prompt construction, scoring, and output formatting.
#
# Parameter names map directly to evalengine.ResolveConfig() keys:
#   provider, model, temperature, max_tokens, prompt_template,
#   system_prompt, context_prompt, analysis_passes, score_thresholds,
#   display_config, validation_rules
# =============================================================================

# ---------------------------------------------------------------------------
# 1. AI PROVIDER CONFIGURATION
# ---------------------------------------------------------------------------

data "lattice_parameter" "provider" {
  name         = "provider"
  display_name = "AI Provider"
  description  = "AI provider for transcript feedback: openai or anthropic"
  type         = "string"
  mutable      = true
  default      = "anthropic"
  icon         = "mui:hospital"

  option {
    name  = "Anthropic (Claude)"
    value = "anthropic"
  }
  option {
    name  = "OpenAI (GPT)"
    value = "openai"
  }
}

data "lattice_parameter" "model" {
  name         = "model"
  display_name = "AI Model"
  description  = "Model version for feedback (e.g. claude-sonnet-4-5-20250929, gpt-4o)"
  type         = "string"
  mutable      = true
  default      = "claude-sonnet-4-5-20250929"
  icon         = "/icon/memory.svg"
}

data "lattice_parameter" "temperature" {
  name         = "temperature"
  display_name = "Temperature"
  description  = "Model temperature (0.0-1.0). Lower = more consistent scoring."
  type         = "string"
  mutable      = true
  default      = "0.3"
}

data "lattice_parameter" "max_tokens" {
  name         = "max_tokens"
  display_name = "Max Output Tokens"
  description  = "Maximum tokens per analysis pass"
  type         = "string"
  mutable      = true
  default      = "4096"
}

variable "llm_provider" {
  type        = string
  description = "AI provider for transcript analysis (openai, anthropic, google)"
  default     = "openai"
  validation {
    condition     = contains(["openai", "anthropic", "google"], var.llm_provider)
    error_message = "Must be one of: openai, anthropic, google"
  }
}

variable "llm_model" {
  type        = string
  description = "LLM model for transcript analysis"
  default     = "gpt-4o"
}

variable "temperature" {
  type        = number
  description = "Model temperature for analysis (0.0 - 1.0)"
  default     = 0.3
  validation {
    condition     = var.temperature >= 0 && var.temperature <= 1
    error_message = "Temperature must be between 0.0 and 1.0"
  }
}

variable "max_tokens" {
  type        = number
  description = "Maximum tokens for analysis response"
  default     = 4096
}

# ---------------------------------------------------------------------------
# 2. SYSTEM PROMPT — AI evaluator identity and principles
# ---------------------------------------------------------------------------

data "lattice_parameter" "system_prompt" {
  name         = "system_prompt"
  display_name = "System Prompt"
  description  = "Foundation prompt defining the AI evaluator's identity, expertise, and principles"
  type         = "string"
  mutable      = true
  default      = <<-EOT
# Clinical Education AI Evaluator

## Identity
You are an expert clinical education evaluator with 20+ years equivalent experience.
Board-certified equivalent in Internal Medicine with Medical Education Fellowship.

## Core Principles
1. **Evidence-Based**: All scores must cite specific transcript moments
2. **Objective**: Focus on competencies and observable behaviors, not assumptions
3. **Constructive**: Frame feedback to promote growth
4. **Actionable**: Every recommendation must be specific and implementable
5. **Safe**: Flag patient safety concerns prominently

## Standards
- Primary: ACGME Core Competencies
- Secondary: IOM Quality Dimensions, CanMEDS Framework
- Skill model: Dreyfus (Novice -> Expert)

## Constraints
- Never fabricate or hallucinate transcript content
- Acknowledge limitations when transcript quality is poor
- Flag concerning safety issues immediately
  EOT
}

# ---------------------------------------------------------------------------
# 3. CONTEXT PROMPT — Clinical setting and learner context
# ---------------------------------------------------------------------------

data "lattice_parameter" "context_prompt" {
  name         = "context_prompt"
  display_name = "Context Prompt"
  description  = "Clinical setting, learner level, and feedback context"
  type         = "string"
  mutable      = true
  default      = <<-EOT
## Clinical Session Context
- **Setting**: Ambulatory Internal Medicine Clinic
- **Learner Level**: Medical Resident (PGY-2)
- **Session Type**: Direct patient encounter
- **Feedback Purpose**: Formative competency assessment
- **Framework**: ACGME Internal Medicine Milestones 2.0

## Expected PGY-2 Competency
- Competent on common presentations
- Developing complex case management
- Recognizes limitations, seeks supervision
- Building toward independent practice
  EOT
}

# ---------------------------------------------------------------------------
# 4. ANALYSIS PASSES — Multi-dimensional scoring pipeline
# ---------------------------------------------------------------------------
# Each pass runs independently through the AI with its own instruction.
# Results from all passes are merged and scored.

data "lattice_parameter" "analysis_passes" {
  name         = "analysis_passes"
  display_name = "Analysis Passes"
  description  = "JSON array of analysis passes. Each pass scores a dimension of the transcript."
  type         = "string"
  mutable      = true
  default      = <<-EOT
[
  {
    "name": "clinical_quality",
    "fields": "clinical_quality_score,history_taking,physical_exam,differential_diagnosis,diagnostic_plan,treatment_plan,clinical_evidence",
    "instruction": "Evaluate clinical quality (35% weight). Score 0-10 for each: history taking completeness, physical exam appropriateness, differential diagnosis breadth, diagnostic plan evidence-basis, treatment plan guideline adherence. Provide clinical_quality_score as weighted average. Include clinical_evidence array with transcript quotes."
  },
  {
    "name": "communication",
    "fields": "communication_score,rapport_building,active_listening,clear_explanation,shared_decision_making,addressing_concerns,communication_evidence",
    "instruction": "Evaluate communication & interpersonal skills (25% weight). Score 0-10 for: rapport building, active listening, clear explanation in lay language, shared decision making, addressing patient concerns. Provide communication_score as weighted average. Include communication_evidence array."
  },
  {
    "name": "clinical_reasoning",
    "fields": "clinical_reasoning_score,diagnostic_reasoning,data_integration,risk_stratification,uncertainty_management,reasoning_evidence",
    "instruction": "Evaluate clinical reasoning (20% weight). Score 0-10 for: diagnostic reasoning quality, data integration, risk stratification, uncertainty management. Provide clinical_reasoning_score as weighted average. Include reasoning_evidence array."
  },
  {
    "name": "professionalism",
    "fields": "professionalism_score,documentation_quality,time_management,resource_stewardship,professional_behavior,professionalism_evidence",
    "instruction": "Evaluate professionalism & systems awareness (15% weight). Score 0-10 for: documentation, time management, resource stewardship, professional behavior. Provide professionalism_score as weighted average. Include professionalism_evidence array."
  },
  {
    "name": "patient_safety",
    "fields": "patient_safety_score,red_flag_recognition,safety_checks,followup_planning,red_flags,safety_evidence",
    "instruction": "Evaluate patient safety (5% weight but can override rating). Score 0-10 for: red flag recognition, safety checks (allergies/interactions), follow-up planning. If ANY critical safety concern found, set red_flags array. Include safety_evidence array. CRITICAL: A serious safety miss can cap the overall_score regardless of other dimensions."
  },
  {
    "name": "synthesis",
    "fields": "overall_score,performance_level,summary,strengths,areas_for_improvement,recommendations",
    "instruction": "Synthesize all dimensions into a final assessment. Calculate overall_score (0-10) using weights: clinical 35%, communication 25%, reasoning 20%, professionalism 15%, safety 5%. Classify performance_level as one of: Novice (1-3), Advanced Beginner (4-5), Competent (6-7), Proficient (8-9), Expert (10). Provide summary (2-3 paragraphs), strengths array, areas_for_improvement array, and recommendations array. Each strength/improvement must cite specific transcript evidence."
  }
]
  EOT
}

# ---------------------------------------------------------------------------
# 5. PROMPT TEMPLATE — Go template rendered per pass
# ---------------------------------------------------------------------------
# Available template variables:
#   .Transcript, .PassName, .Fields, .Instruction, .Parameters.*

data "lattice_parameter" "prompt_template" {
  name         = "prompt_template"
  display_name = "Prompt Template"
  description  = "Go template rendered for each analysis pass. Uses .Transcript, .PassName, .Fields, .Instruction, .Parameters.*"
  type         = "string"
  mutable      = true
  default      = <<-EOT
{{- if .Parameters.system_prompt}}
{{.Parameters.system_prompt}}
{{- end}}

{{- if .Parameters.context_prompt}}

{{.Parameters.context_prompt}}
{{- end}}

## Analysis Pass: {{.PassName}}

{{- if .Instruction}}

### Instructions
{{.Instruction}}
{{- end}}

### Required Output Fields
Return a JSON object with these fields: {{.Fields}}

All scores must be numeric (0-10 scale). All evidence fields must be arrays of direct transcript quotes.

### Transcript
{{.Transcript}}

Respond ONLY with a valid JSON object containing the requested fields. No markdown, no explanation outside the JSON.
  EOT
}

# ---------------------------------------------------------------------------
# 6. SCORE THRESHOLDS — Performance level classification
# ---------------------------------------------------------------------------

data "lattice_parameter" "score_thresholds" {
  name         = "score_thresholds"
  display_name = "Score Thresholds"
  description  = "JSON array of score threshold definitions for performance classification"
  type         = "string"
  mutable      = true
  default      = <<-EOT
[
  {"min": 9.0, "label": "Expert", "color": "#059669"},
  {"min": 7.5, "label": "Proficient", "color": "#2563eb"},
  {"min": 6.0, "label": "Competent", "color": "#7c3aed"},
  {"min": 4.0, "label": "Advanced Beginner", "color": "#d97706"},
  {"min": 0.0, "label": "Novice", "color": "#dc2626"}
]
  EOT
}

# ---------------------------------------------------------------------------
# 7. VALIDATION RULES — Cross-pass consistency checks
# ---------------------------------------------------------------------------

data "lattice_parameter" "validation_rules" {
  name         = "validation_rules"
  display_name = "Validation Rules"
  description  = "JSON array of cross-validation rules to check for scoring consistency"
  type         = "string"
  mutable      = true
  default      = <<-EOT
[
  {
    "name": "safety_override",
    "type": "score_range",
    "field": "patient_safety_score",
    "min": 0,
    "max": 10
  },
  {
    "name": "score_consistency",
    "type": "score_range",
    "field": "overall_score",
    "min": 0,
    "max": 10
  },
  {
    "name": "required_synthesis_fields",
    "type": "required_fields",
    "fields": ["overall_score", "performance_level", "summary", "strengths", "areas_for_improvement"]
  }
]
  EOT
}

# ---------------------------------------------------------------------------
# 8. DISPLAY CONFIGURATION — UI rendering hints
# ---------------------------------------------------------------------------

data "lattice_parameter" "display_config" {
  name         = "display_config"
  display_name = "Display Configuration"
  description  = "JSON object with UI display hints for rendering evaluation results"
  type         = "string"
  mutable      = true
  default      = <<-EOT
{
  "score_format": "percentage",
  "score_max": 10,
  "dimensions": [
    {"key": "clinical_quality_score", "label": "Clinical Quality", "weight": 0.35, "icon": "stethoscope"},
    {"key": "communication_score", "label": "Communication", "weight": 0.25, "icon": "chat"},
    {"key": "clinical_reasoning_score", "label": "Clinical Reasoning", "weight": 0.20, "icon": "brain"},
    {"key": "professionalism_score", "label": "Professionalism", "weight": 0.15, "icon": "shield"},
    {"key": "patient_safety_score", "label": "Patient Safety", "weight": 0.05, "icon": "heart"}
  ],
  "performance_levels": ["Novice", "Advanced Beginner", "Competent", "Proficient", "Expert"]
}
  EOT
}
