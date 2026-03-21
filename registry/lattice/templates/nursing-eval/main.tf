terraform {
  required_providers {
    lattice = {
      source = "latticehq/lattice"
    }
  }
}

# =============================================================================
# NURSING CLINICAL COMPETENCY FEEDBACK TEMPLATE (category: evaluation)
# =============================================================================
# This template defines the AI feedback pipeline for nursing clinical
# transcripts. It is a non-provisioned template — no infrastructure is created.
# The evaluation engine reads these parameters to configure analysis passes,
# prompt construction, scoring, and output formatting.
#
# Standards: AACN Essentials, QSEN Competencies, Benner's Novice to Expert
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
  description  = "AI provider for nursing transcript feedback: openai or anthropic"
  type         = "string"
  mutable      = true
  default      = "anthropic"
  icon         = "mui:monitor-heart"

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
  default      = "0.25"
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
# Nursing Clinical Competency AI Evaluator

## Identity
You are an expert nursing clinical education evaluator with 20+ years equivalent
experience in nursing education and practice. Board-certified equivalent as a
Clinical Nurse Specialist (CNS) with a Doctor of Nursing Practice (DNP) in
Advanced Clinical Education.

## Core Principles
1. **Evidence-Based**: All scores must cite specific transcript moments
2. **Objective**: Focus on nursing competencies and observable behaviors, not assumptions
3. **Constructive**: Frame feedback to promote professional growth along Benner's continuum
4. **Actionable**: Every recommendation must be specific, implementable, and tied to learning objectives
5. **Safe**: Flag patient safety concerns prominently — safety is non-negotiable in nursing

## Standards
- Primary: American Association of Colleges of Nursing (AACN) Essentials
- Secondary: QSEN (Quality and Safety Education for Nurses) Competencies
- Skill Model: Benner's Novice to Expert Framework
- Communication: SBAR (Situation-Background-Assessment-Recommendation) Model
- Clinical Judgment: Tanner's Clinical Judgment Model (Noticing, Interpreting, Responding, Reflecting)

## Constraints
- Never fabricate or hallucinate transcript content
- Acknowledge limitations when transcript quality is poor
- Flag concerning safety issues immediately
- Evaluate within the appropriate scope of nursing practice
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
- **Setting**: Acute Care Medical-Surgical Unit
- **Learner Level**: Pre-licensure BSN Student (Senior Practicum)
- **Session Type**: Direct patient care clinical encounter
- **Feedback Purpose**: Formative nursing competency assessment
- **Framework**: AACN Essentials / QSEN Competencies / Benner's Model

## Expected Senior BSN Competency (Advanced Beginner to Competent)
- Performs systematic assessments with emerging pattern recognition
- Applies clinical judgment using Tanner's model with guidance
- Demonstrates safe medication administration and infection control
- Communicates effectively using SBAR for handoffs and reporting
- Recognizes scope of practice boundaries, seeks preceptor guidance
- Developing prioritization and delegation skills
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
  description  = "JSON array of analysis passes. Each pass scores a dimension of the nursing transcript."
  type         = "string"
  mutable      = true
  default      = <<-EOT
[
  {
    "name": "patient_assessment",
    "fields": "patient_assessment_score,systematic_assessment,vital_signs_interpretation,pain_assessment,abnormal_finding_recognition,nursing_diagnosis,assessment_evidence",
    "instruction": "Evaluate patient assessment competency (25% weight). Score 0-10 for each: systematic nursing assessment (head-to-toe or focused assessment technique), vital signs interpretation (recognition of normal vs abnormal ranges and trends), pain assessment (use of numeric scale, FLACC, or Wong-Baker FACES as appropriate), abnormal finding recognition (identification and escalation of concerning findings), nursing diagnosis formulation (NANDA-I taxonomy accuracy and prioritization). Provide patient_assessment_score as weighted average. Include assessment_evidence array with transcript quotes."
  },
  {
    "name": "clinical_judgment",
    "fields": "clinical_judgment_score,noticing,interpreting,responding,reflecting,priority_setting,anticipatory_planning,deterioration_recognition,delegation,judgment_evidence",
    "instruction": "Evaluate clinical judgment using Tanner's Clinical Judgment Model (25% weight). Score 0-10 for each: Noticing (recognizing salient data and deviations from expected patterns), Interpreting (making sense of data through reasoning — analytical, intuitive, or narrative), Responding (selecting and implementing appropriate nursing interventions), Reflecting (reflection-in-action and reflection-on-action). Also score: priority setting (correct sequencing of interventions), anticipatory planning (proactive identification of potential complications), clinical deterioration recognition (appropriate use of NEWS2/MEWS early warning scores), delegation appropriateness (correct delegation to UAPs within scope). Provide clinical_judgment_score as weighted average. Include judgment_evidence array."
  },
  {
    "name": "safety_quality",
    "fields": "safety_quality_score,medication_safety,fall_prevention,infection_control,patient_identification,handoff_quality,near_miss_recognition,safety_evidence",
    "instruction": "Evaluate safety and quality competency aligned with QSEN safety competencies (20% weight). Score 0-10 for each: medication safety (adherence to the 5 Rights — right patient, drug, dose, route, time — plus documentation), fall prevention (risk assessment and appropriate interventions), infection control (hand hygiene, standard precautions, aseptic technique), patient identification (two-identifier verification before interventions), handoff quality (SBAR structure completeness and accuracy during transitions of care), near-miss recognition (identification of potential errors and system vulnerabilities). Provide safety_quality_score as weighted average. Include safety_evidence array. CRITICAL: A serious safety violation can cap the overall_score regardless of other dimensions."
  },
  {
    "name": "communication",
    "fields": "communication_score,therapeutic_communication,sbar_reporting,patient_education,interprofessional_communication,cultural_sensitivity,de_escalation,communication_evidence",
    "instruction": "Evaluate communication competency (15% weight). Score 0-10 for each: therapeutic communication techniques (active listening, open-ended questions, empathy, validation), SBAR structured reporting (clear Situation-Background-Assessment-Recommendation delivery), patient and family education (use of teach-back method, health literacy appropriate language), interprofessional communication (collaboration with physicians, pharmacists, therapists, and other team members), cultural sensitivity (culturally congruent care, interpreter use, respect for beliefs and preferences), de-escalation skills (managing agitated or distressed patients safely and compassionately). Provide communication_score as weighted average. Include communication_evidence array."
  },
  {
    "name": "professionalism",
    "fields": "professionalism_score,ethical_practice,scope_awareness,documentation_quality,evidence_based_practice,self_reflection,professionalism_evidence",
    "instruction": "Evaluate professionalism (10% weight). Score 0-10 for each: ethical practice (adherence to ANA Code of Ethics, patient advocacy, informed consent, confidentiality), scope of practice awareness (understanding RN vs LPN vs UAP boundaries, appropriate escalation), documentation quality (nursing notes accuracy, timeliness, completeness — follows facility standards), evidence-based practice (integration of current best evidence into clinical decisions), self-reflection (honest self-appraisal, receptiveness to feedback, identification of learning needs). Provide professionalism_score as weighted average. Include professionalism_evidence array."
  },
  {
    "name": "synthesis",
    "fields": "overall_score,benner_level,performance_level,summary,strengths,areas_for_improvement,clinical_learning_plan,recommendations",
    "instruction": "Synthesize all dimensions into a final nursing competency assessment. Calculate overall_score (0-10) using weights: patient_assessment 25%, clinical_judgment 25%, safety_quality 20%, communication 15%, professionalism 10%. Classify benner_level using Benner's Novice to Expert model: Expert (9.0-10), Proficient (7.5-8.9), Competent (6.0-7.4), Advanced Beginner (4.0-5.9), Novice (0-3.9). Set performance_level to the same label. Provide summary (2-3 paragraphs situating the learner on Benner's continuum with specific clinical examples), strengths array, areas_for_improvement array, clinical_learning_plan array (specific objectives, activities, and timeline for progressing to the next Benner level), and recommendations array. Each strength/improvement must cite specific transcript evidence."
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
# 6. SCORE THRESHOLDS — Benner's Novice to Expert classification
# ---------------------------------------------------------------------------

data "lattice_parameter" "score_thresholds" {
  name         = "score_thresholds"
  display_name = "Score Thresholds"
  description  = "JSON array of score threshold definitions for Benner's performance classification"
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
    "field": "safety_quality_score",
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
    "fields": ["overall_score", "benner_level", "performance_level", "summary", "strengths", "areas_for_improvement", "clinical_learning_plan"]
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
    {"key": "patient_assessment_score", "label": "Patient Assessment", "weight": 0.25, "icon": "clipboard"},
    {"key": "clinical_judgment_score", "label": "Clinical Judgment", "weight": 0.25, "icon": "brain"},
    {"key": "safety_quality_score", "label": "Safety & Quality", "weight": 0.20, "icon": "shield"},
    {"key": "communication_score", "label": "Communication", "weight": 0.15, "icon": "chat"},
    {"key": "professionalism_score", "label": "Professionalism", "weight": 0.10, "icon": "heart"}
  ],
  "performance_levels": ["Novice", "Advanced Beginner", "Competent", "Proficient", "Expert"]
}
  EOT
}
