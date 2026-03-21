terraform {
  required_providers {
    lattice = {
      source = "latticehq/lattice"
    }
  }
}

# =============================================================================
# OSCE FEEDBACK TEMPLATE (category: evaluation)
# =============================================================================
# Stanford-grade Objective Structured Clinical Examination (OSCE) feedback
# template. This is a non-provisioned template — no infrastructure is created.
# The evaluation engine reads these parameters to configure analysis passes,
# prompt construction, scoring, and output formatting.
#
# Based on:
#   - Stanford Medicine Clinical Skills Assessment criteria
#   - Kalamazoo Communication Assessment model
#   - Calgary-Cambridge Guide to the Medical Interview
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
  description  = "AI provider for OSCE feedback: openai or anthropic"
  type         = "string"
  mutable      = true
  default      = "anthropic"
  icon         = "mui:fact-check"

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
  description  = "Model version for OSCE feedback (e.g. claude-sonnet-4-5-20250929, gpt-4o)"
  type         = "string"
  mutable      = true
  default      = "claude-sonnet-4-5-20250929"
  icon         = "/icon/memory.svg"
}

data "lattice_parameter" "temperature" {
  name         = "temperature"
  display_name = "Temperature"
  description  = "Model temperature (0.0-1.0). Set low for consistent OSCE scoring."
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
  description  = "Foundation prompt defining the OSCE evaluator's identity, expertise, and principles"
  type         = "string"
  mutable      = true
  default      = <<-EOT
# OSCE Clinical Skills Evaluator

## Identity
You are an expert OSCE examiner calibrated to Stanford Medicine's Clinical
Skills Assessment standards. You have 20+ years equivalent experience in
structured clinical examination design and scoring, with board-certified
equivalent expertise in Internal Medicine and Medical Education.

## Examination Format
You evaluate learner performance within the OSCE framework:
- **Timed stations** with standardized patient encounters
- **Standardized patients (SPs)** portraying defined clinical scenarios
- **Structured checklists** combined with global rating scales
- **Multi-station assessment** covering breadth of clinical competency

## Communication Frameworks
- **Kalamazoo Communication Assessment**: Builds rapport, opens discussion,
  gathers information, understands patient perspective, shares information,
  reaches agreement, provides closure
- **Calgary-Cambridge Guide to the Medical Interview**: Initiating the session,
  gathering information, providing structure, building the relationship,
  explanation and planning, closing the session

## Core Principles
1. **Standardized**: Apply scoring criteria uniformly across all encounters
2. **Evidence-Based**: All scores must cite specific observable behaviors
3. **Checklist-Anchored**: Score against defined competency checklists
4. **Constructive**: Frame feedback to promote clinical skill development
5. **Actionable**: Every recommendation must be specific and implementable
6. **Safety-First**: Flag patient safety concerns prominently

## Standards
- Primary: Stanford Clinical Skills Assessment Criteria
- Communication: Kalamazoo Consensus Statement, Calgary-Cambridge Guide
- Clinical: ACGME Core Competencies, CanMEDS Framework
- Skill model: Dreyfus (Novice -> Expert)

## Constraints
- Never fabricate or hallucinate transcript content
- Acknowledge limitations when encounter data is incomplete
- Flag concerning safety issues immediately
- Score only what is directly observable in the encounter
  EOT
}

# ---------------------------------------------------------------------------
# 3. CONTEXT PROMPT — OSCE station and learner context
# ---------------------------------------------------------------------------

data "lattice_parameter" "context_prompt" {
  name         = "context_prompt"
  display_name = "Context Prompt"
  description  = "OSCE station setting, learner level, and feedback context"
  type         = "string"
  mutable      = true
  default      = <<-EOT
## OSCE Station Context
- **Setting**: Standardized Patient Encounter (OSCE Station)
- **Station Duration**: 15 minutes (10 encounter + 5 post-encounter)
- **Learner Level**: Medical Student / Resident
- **Station Type**: Integrated clinical skills assessment
- **Feedback Purpose**: Summative competency assessment
- **Framework**: Stanford Clinical Skills Assessment / ACGME Milestones 2.0

## Expected Competency Targets
- Systematic and patient-centered history taking
- Focused and appropriate physical examination
- Sound clinical reasoning with justified differentials
- Effective communication per Calgary-Cambridge and Kalamazoo models
- Safe and evidence-based patient management planning
  EOT
}

# ---------------------------------------------------------------------------
# 4. ANALYSIS PASSES — Multi-dimensional OSCE scoring pipeline
# ---------------------------------------------------------------------------
# Each pass runs independently through the AI with its own instruction.
# Results from all passes are merged and scored.

data "lattice_parameter" "analysis_passes" {
  name         = "analysis_passes"
  display_name = "Analysis Passes"
  description  = "JSON array of OSCE analysis passes. Each pass scores a dimension of the clinical encounter."
  type         = "string"
  mutable      = true
  default      = <<-EOT
[
  {
    "name": "data_gathering",
    "fields": "data_gathering_score,history_completeness,question_technique,review_of_systems,mnemonic_coverage,red_flag_screening,data_gathering_evidence",
    "instruction": "Evaluate data gathering / history taking (30% weight). Score 0-10 for each: history_completeness (thoroughness of HPI, PMH, medications, allergies, social/family history), question_technique (open-to-closed cone, appropriate use of facilitation, no leading questions), review_of_systems (systematic ROS coverage relevant to chief complaint), mnemonic_coverage (use of OLDCARTS or OPQRST frameworks for symptom characterization), red_flag_screening (identification and pursuit of alarm features). Provide data_gathering_score as weighted average. Include data_gathering_evidence array with direct transcript quotes demonstrating each scored behavior."
  },
  {
    "name": "physical_examination",
    "fields": "physical_examination_score,exam_technique,systems_examined,patient_comfort,hygiene_draping,finding_interpretation,physical_exam_evidence",
    "instruction": "Evaluate physical examination skills (15% weight). Score 0-10 for each: exam_technique (correct maneuvers, systematic approach, proper instrument use), systems_examined (appropriate systems for the differential, focused yet thorough), patient_comfort (explaining steps, asking permission, minimizing discomfort), hygiene_draping (hand hygiene mention, appropriate draping, privacy respect), finding_interpretation (correct interpretation of elicited findings, correlation with history). Provide physical_examination_score as weighted average. Include physical_exam_evidence array with transcript quotes."
  },
  {
    "name": "clinical_reasoning",
    "fields": "clinical_reasoning_score,differential_quality,pretest_probability,bayesian_updating,diagnostic_plan,evidence_based_approach,clinical_reasoning_evidence",
    "instruction": "Evaluate clinical reasoning (20% weight). Score 0-10 for each: differential_quality (breadth of differential, appropriate ranking by likelihood, inclusion of must-not-miss diagnoses), pretest_probability (explicit or implicit estimation of disease likelihood based on epidemiology and presentation), bayesian_updating (revision of differential as new data gathered, appropriate test selection to discriminate between diagnoses), diagnostic_plan (justified workup, cost-conscious ordering, appropriate urgency), evidence_based_approach (reasoning aligned with current guidelines and evidence). Provide clinical_reasoning_score as weighted average. Include clinical_reasoning_evidence array."
  },
  {
    "name": "communication",
    "fields": "communication_score,calgary_cambridge_markers,kalamazoo_items,empathy_nurse,health_literacy,teach_back,communication_evidence",
    "instruction": "Evaluate communication and interpersonal skills (20% weight). Score 0-10 for each: calgary_cambridge_markers (session initiation, information gathering, relationship building, explanation/planning, session closure per Calgary-Cambridge Guide), kalamazoo_items (rapport, open discussion, information gathering, patient perspective, information sharing, agreement, closure per Kalamazoo Consensus), empathy_nurse (Naming emotion, Understanding, Respecting, Supporting, Exploring per NURSE framework), health_literacy (appropriate language level, avoidance of jargon, checking understanding), teach_back (verification that patient can restate key information in own words). Provide communication_score as weighted average. Include communication_evidence array."
  },
  {
    "name": "patient_management",
    "fields": "patient_management_score,treatment_plan,patient_education,safety_netting,followup_planning,shared_decision_making,patient_management_evidence",
    "instruction": "Evaluate patient management and planning (10% weight). Score 0-10 for each: treatment_plan (appropriate interventions, guideline concordance, consideration of patient factors), patient_education (clear explanation of diagnosis, prognosis, and plan), safety_netting (explicit return precautions, red flags to watch for, when to seek urgent care), followup_planning (appropriate follow-up interval, contingency planning, referrals if needed), shared_decision_making (eliciting patient preferences, discussing options, incorporating patient values). Provide patient_management_score as weighted average. Include patient_management_evidence array."
  },
  {
    "name": "synthesis",
    "fields": "overall_score,station_result,global_rating,summary,strengths,areas_for_improvement,recommendations",
    "instruction": "Synthesize all dimensions into a final OSCE assessment. Calculate overall_score (0-10) using weights: data_gathering 30%, physical_examination 15%, clinical_reasoning 20%, communication 20%, patient_management 10%, plus 5% holistic global impression. Determine station_result as one of: Honors (9.0+), Pass with Distinction (7.5+), Pass (6.0+), Borderline (4.5+), Below Expectations (0-4.5). Assign global_rating on same scale reflecting overall clinical competence impression. Provide summary (2-3 paragraphs of narrative assessment), strengths array, areas_for_improvement array, and recommendations array. Each strength/improvement must cite specific encounter evidence. Recommendations should be concrete, actionable steps for skill development."
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

### OSCE Encounter Transcript
{{.Transcript}}

Respond ONLY with a valid JSON object containing the requested fields. No markdown, no explanation outside the JSON.
  EOT
}

# ---------------------------------------------------------------------------
# 6. SCORE THRESHOLDS — OSCE performance level classification
# ---------------------------------------------------------------------------

data "lattice_parameter" "score_thresholds" {
  name         = "score_thresholds"
  display_name = "Score Thresholds"
  description  = "JSON array of OSCE score threshold definitions for performance classification"
  type         = "string"
  mutable      = true
  default      = <<-EOT
[
  {"min": 9.0, "label": "Honors", "color": "#059669"},
  {"min": 7.5, "label": "Pass with Distinction", "color": "#2563eb"},
  {"min": 6.0, "label": "Pass", "color": "#7c3aed"},
  {"min": 4.5, "label": "Borderline", "color": "#d97706"},
  {"min": 0.0, "label": "Below Expectations", "color": "#dc2626"}
]
  EOT
}

# ---------------------------------------------------------------------------
# 7. VALIDATION RULES — Cross-pass consistency checks
# ---------------------------------------------------------------------------

data "lattice_parameter" "validation_rules" {
  name         = "validation_rules"
  display_name = "Validation Rules"
  description  = "JSON array of cross-validation rules to check for OSCE scoring consistency"
  type         = "string"
  mutable      = true
  default      = <<-EOT
[
  {
    "name": "data_gathering_range",
    "type": "score_range",
    "field": "data_gathering_score",
    "min": 0,
    "max": 10
  },
  {
    "name": "physical_exam_range",
    "type": "score_range",
    "field": "physical_examination_score",
    "min": 0,
    "max": 10
  },
  {
    "name": "clinical_reasoning_range",
    "type": "score_range",
    "field": "clinical_reasoning_score",
    "min": 0,
    "max": 10
  },
  {
    "name": "communication_range",
    "type": "score_range",
    "field": "communication_score",
    "min": 0,
    "max": 10
  },
  {
    "name": "patient_management_range",
    "type": "score_range",
    "field": "patient_management_score",
    "min": 0,
    "max": 10
  },
  {
    "name": "overall_score_range",
    "type": "score_range",
    "field": "overall_score",
    "min": 0,
    "max": 10
  },
  {
    "name": "required_synthesis_fields",
    "type": "required_fields",
    "fields": ["overall_score", "station_result", "global_rating", "summary", "strengths", "areas_for_improvement"]
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
  description  = "JSON object with UI display hints for rendering OSCE evaluation results"
  type         = "string"
  mutable      = true
  default      = <<-EOT
{
  "score_format": "percentage",
  "score_max": 10,
  "dimensions": [
    {"key": "data_gathering_score", "label": "Data Gathering", "weight": 0.30, "icon": "clipboard"},
    {"key": "physical_examination_score", "label": "Physical Examination", "weight": 0.15, "icon": "stethoscope"},
    {"key": "clinical_reasoning_score", "label": "Clinical Reasoning", "weight": 0.20, "icon": "brain"},
    {"key": "communication_score", "label": "Communication", "weight": 0.20, "icon": "chat"},
    {"key": "patient_management_score", "label": "Patient Management", "weight": 0.10, "icon": "heart"},
    {"key": "global_rating", "label": "Global Rating", "weight": 0.05, "icon": "star"}
  ],
  "performance_levels": ["Below Expectations", "Borderline", "Pass", "Pass with Distinction", "Honors"]
}
  EOT
}
