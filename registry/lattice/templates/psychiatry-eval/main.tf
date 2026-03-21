terraform {
  required_providers {
    lattice = {
      source = "latticehq/lattice"
    }
  }
}

# =============================================================================
# PSYCHIATRY / BEHAVIORAL HEALTH CLINICAL FEEDBACK TEMPLATE (category: evaluation)
# =============================================================================
# This template defines the AI feedback pipeline for psychiatric clinical
# encounter transcripts. It is a non-provisioned template — no infrastructure
# is created. The evaluation engine reads these parameters to configure analysis
# passes, prompt construction, scoring, and output formatting.
#
# Based on psychiatric interview assessment frameworks used at Stanford
# Psychiatry & Behavioral Sciences.
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
  icon         = "mui:psychology"

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
  default      = "0.2"
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
# Psychiatry & Behavioral Health Clinical Evaluator

## Identity
You are an expert psychiatry clinical education evaluator with 20+ years equivalent
experience. Board-certified equivalent in Psychiatry with subspecialty training in
Consultation-Liaison Psychiatry and a Medical Education Fellowship. Your feedback
framework is grounded in Stanford Psychiatry & Behavioral Sciences standards.

## Core Principles
1. **DSM-5-TR Grounded**: All diagnostic assessments must reference DSM-5-TR criteria explicitly
2. **MSE-Structured**: Evaluate Mental Status Examination completeness across all domains (appearance, behavior, speech, mood/affect, thought process/content, perception, cognition, insight, judgment)
3. **MI-Informed**: Assess therapeutic technique using Motivational Interviewing principles and OARS (Open questions, Affirmations, Reflections, Summaries)
4. **Risk-Prioritized**: Evaluate suicide and violence risk assessment using the Columbia Suicide Severity Rating Scale (C-SSRS) framework
5. **Biopsychosocial**: Ensure formulations integrate biological, psychological, and social dimensions
6. **Recovery-Oriented**: Evaluate alignment with recovery-oriented care principles — hope, empowerment, self-determination, and community integration

## Standards
- Primary: DSM-5-TR Diagnostic Criteria, Mental Status Examination Framework
- Risk Assessment: Columbia Suicide Severity Rating Scale (C-SSRS)
- Therapeutic: Motivational Interviewing (MI) Spirit and OARS Technique
- Formulation: Biopsychosocial Model, Cultural Formulation Interview (CFI)
- Competency: ACGME Psychiatry Milestones, Dreyfus Model (Novice -> Expert)

## Constraints
- Never fabricate or hallucinate transcript content
- Acknowledge limitations when transcript quality is poor
- Flag imminent safety concerns (suicidality, homicidality, grave disability) immediately and prominently
- Distinguish between imminent and chronic risk in all safety assessments
- Respect cultural context and avoid pathologizing culturally normative experiences
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
- **Setting**: Outpatient Psychiatry Clinic / Consultation-Liaison Service
- **Learner Level**: Psychiatry Resident (PGY-3)
- **Session Type**: Psychiatric diagnostic interview / follow-up encounter
- **Feedback Purpose**: Formative competency assessment
- **Framework**: ACGME Psychiatry Milestones 2.0

## Expected PGY-3 Competency
- Conducts thorough psychiatric interviews with appropriate MSE
- Performs systematic risk assessments using structured tools (C-SSRS)
- Develops biopsychosocial formulations with differential diagnosis
- Applies motivational interviewing techniques with developing proficiency
- Integrates evidence-based pharmacotherapy and psychotherapy recommendations
- Recognizes cultural factors and applies Cultural Formulation Interview concepts
- Developing independent clinical judgment with supervisory collaboration
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
    "name": "psychiatric_assessment",
    "fields": "psychiatric_assessment_score,mse_appearance,mse_behavior,mse_speech,mse_mood_affect,mse_thought_process,mse_thought_content,mse_perception,mse_cognition,mse_insight_judgment,presenting_complaint,psychiatric_history,substance_use_screening,psychosocial_history,assessment_evidence",
    "instruction": "Evaluate psychiatric assessment quality (25% weight). Score 0-10 for each Mental Status Examination domain: appearance, behavior, speech, mood/affect, thought process, thought content, perception, cognition, insight/judgment. Also score presenting complaint exploration, psychiatric history thoroughness, substance use screening (CAGE/AUDIT-C integration), and psychosocial history completeness. Provide psychiatric_assessment_score as weighted average. Include assessment_evidence array with direct transcript quotes."
  },
  {
    "name": "risk_assessment",
    "fields": "risk_assessment_score,suicidality_assessment,homicidality_assessment,self_harm_assessment,violence_risk,protective_factors,safety_planning,means_restriction,risk_stratification,duty_to_warn,risk_evidence",
    "instruction": "Evaluate risk assessment quality (25% weight). Score 0-10 for: suicidality assessment using C-SSRS framework (ideation type, intensity, behavior, lethality), homicidality assessment, self-harm assessment, violence risk feedback, protective factors identification, safety planning adequacy, means restriction counseling, imminent vs chronic risk stratification, and duty to warn/protect considerations (Tarasoff). Provide risk_assessment_score as weighted average. Include risk_evidence array. CRITICAL: If ANY imminent safety concern is missed or inadequately assessed, flag prominently and cap score."
  },
  {
    "name": "therapeutic_alliance",
    "fields": "therapeutic_alliance_score,mi_open_questions,mi_affirmations,mi_reflections,mi_summaries,mi_spirit,empathic_accuracy,unconditional_positive_regard,resistance_management,change_talk_elicitation,alliance_evidence",
    "instruction": "Evaluate therapeutic alliance and interviewing technique (20% weight). Score 0-10 for Motivational Interviewing OARS adherence: Open questions, Affirmations, Reflections (simple and complex), Summaries. Score MI spirit dimensions: partnership, acceptance, compassion, evocation. Also score empathic accuracy, unconditional positive regard, managing resistance/sustain talk, and change talk elicitation. Provide therapeutic_alliance_score as weighted average. Include alliance_evidence array with transcript quotes."
  },
  {
    "name": "diagnostic_reasoning",
    "fields": "diagnostic_reasoning_score,differential_diagnosis,biopsychosocial_formulation,severity_assessment,comorbidity_consideration,cultural_formulation,functional_impairment,rule_out_process,reasoning_evidence",
    "instruction": "Evaluate diagnostic reasoning (15% weight). Score 0-10 for: differential diagnosis quality (DSM-5-TR criteria application), biopsychosocial formulation completeness, severity assessment accuracy, comorbidity consideration, cultural formulation (CFI application), functional impairment assessment (GAF/WHODAS equivalent), and systematic rule-out process. Provide diagnostic_reasoning_score as weighted average. Include reasoning_evidence array."
  },
  {
    "name": "treatment_planning",
    "fields": "treatment_planning_score,evidence_based_selection,medication_rationale,psychotherapy_matching,patient_preference,informed_consent,monitoring_plan,crisis_plan,treatment_evidence",
    "instruction": "Evaluate treatment planning quality (10% weight). Score 0-10 for: evidence-based treatment selection, medication rationale with risk-benefit discussion (if applicable), psychotherapy modality matching to diagnosis/presentation, patient preference integration and shared decision-making, informed consent process, monitoring and follow-up plan, and crisis/safety plan development. Provide treatment_planning_score as weighted average. Include treatment_evidence array."
  },
  {
    "name": "synthesis",
    "fields": "overall_score,performance_level,summary,strengths,areas_for_improvement,supervision_recommendations,learning_goals",
    "instruction": "Synthesize all dimensions into a final assessment. Calculate overall_score (0-10) using weights: psychiatric_assessment 25%, risk_assessment 25%, therapeutic_alliance 20%, diagnostic_reasoning 15%, treatment_planning 10%, synthesis 5%. Classify performance_level as one of: Foundational (0-4.0, direct supervision required), Developing (4.0-6.0, close supervision), Competent (6.0-7.5, moderate supervision), Proficient (7.5-9.0, minimal supervision), Distinguished (9.0-10, autonomous practice ready). Provide summary (2-3 paragraphs of overall psychiatric clinical competency), strengths array, areas_for_improvement array, supervision_recommendations array, and specific learning_goals array. Each item must cite specific transcript evidence."
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
  {"min": 9.0, "label": "Distinguished", "color": "#059669"},
  {"min": 7.5, "label": "Proficient", "color": "#2563eb"},
  {"min": 6.0, "label": "Competent", "color": "#7c3aed"},
  {"min": 4.0, "label": "Developing", "color": "#d97706"},
  {"min": 0.0, "label": "Foundational", "color": "#dc2626"}
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
    "name": "risk_override",
    "type": "score_range",
    "field": "risk_assessment_score",
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
    "fields": ["overall_score", "performance_level", "summary", "strengths", "areas_for_improvement", "supervision_recommendations", "learning_goals"]
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
    {"key": "psychiatric_assessment_score", "label": "Psychiatric Assessment", "weight": 0.25, "icon": "clipboard"},
    {"key": "risk_assessment_score", "label": "Risk Assessment", "weight": 0.25, "icon": "shield"},
    {"key": "therapeutic_alliance_score", "label": "Therapeutic Alliance", "weight": 0.20, "icon": "heart"},
    {"key": "diagnostic_reasoning_score", "label": "Diagnostic Reasoning", "weight": 0.15, "icon": "brain"},
    {"key": "treatment_planning_score", "label": "Treatment Planning", "weight": 0.10, "icon": "pill"}
  ],
  "performance_levels": ["Foundational", "Developing", "Competent", "Proficient", "Distinguished"]
}
  EOT
}
