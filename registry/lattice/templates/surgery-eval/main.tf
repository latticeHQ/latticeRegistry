terraform {
  required_providers {
    lattice = {
      source = "latticehq/lattice"
    }
  }
}

# =============================================================================
# SURGICAL SKILLS & PRE-OPERATIVE ASSESSMENT TEMPLATE (category: evaluation)
# =============================================================================
# This template defines the AI feedback pipeline for surgical skills and
# pre-operative assessment transcripts. It is a non-provisioned template —
# no infrastructure is created.
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
  description  = "AI provider for surgical feedback: openai or anthropic"
  type         = "string"
  mutable      = true
  default      = "anthropic"
  icon         = "mui:health-safety"

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
# Surgical Skills & Pre-operative Assessment AI Evaluator

## Identity
You are an expert surgical education evaluator with 20+ years equivalent experience.
Board-certified equivalent in General Surgery with subspecialty fellowship training
and advanced expertise in surgical education and assessment.

## Core Principles
1. **Evidence-Based**: All scores must cite specific transcript moments
2. **Objective**: Focus on competencies and observable behaviors, not assumptions
3. **Constructive**: Frame feedback to promote growth along the surgical training continuum
4. **Actionable**: Every recommendation must be specific and implementable
5. **Safe**: Flag patient safety concerns prominently — surgical safety is paramount

## Standards
- Primary: ACGME Surgery Milestones 2.0
- Entrustment: Entrustable Professional Activities (EPAs) for Surgery
- Safety: WHO Surgical Safety Checklist (2009)
- Non-Technical: NOTSS (Non-Technical Skills for Surgeons) framework
- Consent: Surgical timeout and informed consent frameworks
- Skill model: EPA Entrustment Scale (Level 1-5)

## Constraints
- Never fabricate or hallucinate transcript content
- Acknowledge limitations when transcript quality is poor
- Flag concerning safety issues immediately
- Evaluate both technical decision-making and non-technical surgical skills
- Consider surgical timeout and consent as critical safety elements
  EOT
}

# ---------------------------------------------------------------------------
# 3. CONTEXT PROMPT — Surgical setting and learner context
# ---------------------------------------------------------------------------

data "lattice_parameter" "context_prompt" {
  name         = "context_prompt"
  display_name = "Context Prompt"
  description  = "Surgical setting, learner level, and feedback context"
  type         = "string"
  mutable      = true
  default      = <<-EOT
## Surgical Session Context
- **Setting**: Academic Medical Center — Surgical Service
- **Learner Level**: Surgical Resident (PGY-3)
- **Session Type**: Pre-operative assessment and surgical planning encounter
- **Feedback Purpose**: Formative surgical competency assessment
- **Framework**: ACGME Surgery Milestones 2.0 + EPA Entrustment Levels

## Expected PGY-3 Surgical Competency
- Competent in common pre-operative assessments
- Developing independent operative decision-making
- Demonstrates awareness of WHO Surgical Safety Checklist elements
- Applies informed consent framework (diagnosis, procedure, risks, benefits, alternatives)
- Recognizes when to escalate to attending surgeon
- Building toward EPA Level 3-4 (reactive to independent supervision)
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
  description  = "JSON array of analysis passes. Each pass scores a dimension of the surgical transcript."
  type         = "string"
  mutable      = true
  default      = <<-EOT
[
  {
    "name": "preoperative_assessment",
    "fields": "preoperative_assessment_score,surgical_history_taking,indications_contraindications,asa_classification,informed_consent_elements,preoperative_optimization,npo_status,medication_management,thromboprophylaxis_planning,preop_evidence",
    "instruction": "Evaluate preoperative assessment (25% weight). Score 0-10 for each: surgical history taking focused on indications, contraindications assessment, ASA physical status classification awareness, informed consent elements (risks/benefits/alternatives/expected outcome), preoperative optimization strategies, NPO status verification, perioperative medication management, thromboprophylaxis planning. Provide preoperative_assessment_score as weighted average. Include preop_evidence array with transcript quotes."
  },
  {
    "name": "surgical_decision_making",
    "fields": "surgical_decision_making_score,indication_appropriateness,timing_assessment,approach_selection,evidence_based_planning,risk_benefit_analysis,patient_risk_stratification,alternative_treatment_consideration,decision_evidence",
    "instruction": "Evaluate surgical decision-making (25% weight). Score 0-10 for: indication appropriateness, timing assessment (urgent vs elective), surgical approach selection rationale, evidence-based operative planning, risk-benefit analysis, patient risk stratification (ACS NSQIP equivalent scoring), alternative treatment consideration. Provide surgical_decision_making_score as weighted average. Include decision_evidence array with transcript quotes."
  },
  {
    "name": "communication_consent",
    "fields": "communication_consent_score,informed_consent_quality,patient_understanding,family_communication,interprofessional_handoff,teach_back_postop,consent_evidence",
    "instruction": "Evaluate communication and informed consent (20% weight). Score 0-10 for: informed consent quality using Stanford 5-element model (diagnosis, proposed treatment, risks, benefits, alternatives), patient understanding verification, family communication, interprofessional handoff quality (surgical brief), teach-back on post-operative expectations. Provide communication_consent_score as weighted average. Include consent_evidence array with transcript quotes."
  },
  {
    "name": "safety_systems",
    "fields": "safety_systems_score,who_checklist_adherence,patient_identification,site_marking,allergies_antibiotics,equipment_needs,blood_availability,complication_planning,timeout_elements,fire_risk_assessment,safety_evidence",
    "instruction": "Evaluate safety systems awareness (15% weight). Score 0-10 for: WHO Surgical Safety Checklist adherence awareness, patient identification protocols, surgical site marking, allergies and antibiotic prophylaxis, equipment needs anticipation, blood availability planning, anticipated complications planning, time-out elements, fire risk assessment. Provide safety_systems_score as weighted average. Include safety_evidence array with transcript quotes. CRITICAL: A serious safety miss can cap the overall_score regardless of other dimensions."
  },
  {
    "name": "postoperative_planning",
    "fields": "postoperative_planning_score,postop_orders,pain_management,dvt_prophylaxis,diet_advancement,activity_restrictions,wound_care,followup_planning,complication_education,discharge_criteria,postop_evidence",
    "instruction": "Evaluate postoperative planning (10% weight). Score 0-10 for: post-operative orders completeness, pain management plan, DVT prophylaxis, diet advancement plan, activity restrictions, wound care instructions, follow-up planning, complication recognition education for patient, discharge criteria. Provide postoperative_planning_score as weighted average. Include postop_evidence array with transcript quotes."
  },
  {
    "name": "synthesis",
    "fields": "overall_score,epa_entrustment_level,notss_equivalent,performance_level,summary,strengths,areas_for_improvement,recommendations,learning_goals",
    "instruction": "Synthesize all dimensions into a final surgical assessment. Calculate overall_score (0-10) using weights: preoperative assessment 25%, surgical decision-making 25%, communication/consent 20%, safety systems 15%, postoperative planning 10%. Determine epa_entrustment_level (1-5): Level 5 = Can supervise others (9.0+), Level 4 = Can practice independently (7.5+), Level 3 = Can execute with reactive supervision (6.0+), Level 2 = Can execute with proactive supervision (4.0+), Level 1 = Observation only (0-4.0). Provide notss_equivalent assessment of non-technical surgical skills. Classify performance_level matching the EPA level label. Provide summary (2-3 paragraphs), strengths array, areas_for_improvement array, recommendations array, and learning_goals array with specific next steps. Each strength/improvement must cite specific transcript evidence."
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
# 6. SCORE THRESHOLDS — EPA Entrustment Level classification
# ---------------------------------------------------------------------------

data "lattice_parameter" "score_thresholds" {
  name         = "score_thresholds"
  display_name = "Score Thresholds"
  description  = "JSON array of score threshold definitions for EPA entrustment level classification"
  type         = "string"
  mutable      = true
  default      = <<-EOT
[
  {"min": 9.0, "label": "Level 5: Can supervise others", "color": "#059669"},
  {"min": 7.5, "label": "Level 4: Can practice independently", "color": "#2563eb"},
  {"min": 6.0, "label": "Level 3: Can execute with reactive supervision", "color": "#7c3aed"},
  {"min": 4.0, "label": "Level 2: Can execute with proactive supervision", "color": "#d97706"},
  {"min": 0.0, "label": "Level 1: Observation only", "color": "#dc2626"}
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
    "field": "safety_systems_score",
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
    "fields": ["overall_score", "epa_entrustment_level", "performance_level", "summary", "strengths", "areas_for_improvement"]
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
    {"key": "preoperative_assessment_score", "label": "Preoperative Assessment", "weight": 0.25, "icon": "clipboard"},
    {"key": "surgical_decision_making_score", "label": "Surgical Decision-Making", "weight": 0.25, "icon": "scalpel"},
    {"key": "communication_consent_score", "label": "Communication & Consent", "weight": 0.20, "icon": "chat"},
    {"key": "safety_systems_score", "label": "Safety Systems", "weight": 0.15, "icon": "shield"},
    {"key": "postoperative_planning_score", "label": "Postoperative Planning", "weight": 0.10, "icon": "calendar"}
  ],
  "performance_levels": ["Level 1: Observation only", "Level 2: Proactive supervision", "Level 3: Reactive supervision", "Level 4: Independent practice", "Level 5: Can supervise others"]
}
  EOT
}
