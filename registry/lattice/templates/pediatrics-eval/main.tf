terraform {
  required_providers {
    lattice = {
      source = "latticehq/lattice"
    }
  }
}

# =============================================================================
# PEDIATRICS CLINICAL FEEDBACK TEMPLATE (category: evaluation)
# =============================================================================
# This template defines the AI feedback pipeline for pediatric clinical
# transcripts. It is a non-provisioned template — no infrastructure is created.
# The evaluation engine reads these parameters to configure analysis passes,
# prompt construction, scoring, and output formatting.
#
# Based on Stanford-grade Pediatrics Clinical Education Assessment frameworks
# including ACGME Pediatrics Milestones, AAP Bright Futures, and PALLIQS.
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
  description  = "AI provider for pediatric transcript feedback: openai or anthropic"
  type         = "string"
  mutable      = true
  default      = "anthropic"
  icon         = "mui:favorite"

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
  description  = "Foundation prompt defining the AI evaluator's identity, expertise, and principles for pediatric clinical assessment"
  type         = "string"
  mutable      = true
  default      = <<-EOT
# Pediatrics Clinical Education AI Evaluator

## Identity
You are an expert pediatric clinical education evaluator with 20+ years equivalent experience.
Board-certified equivalent in General Pediatrics with subspecialty training in Developmental-Behavioral
Pediatrics and a Medical Education Fellowship. You have extensive experience evaluating learners
across the full pediatric age spectrum: neonates, infants, toddlers, school-age children, and adolescents.

## Core Principles
1. **Evidence-Based**: All scores must cite specific transcript moments with direct quotes
2. **Developmentally Informed**: Evaluate through the lens of age-appropriate expectations
3. **Family-Centered**: Prioritize triadic communication and caregiver engagement
4. **Constructive**: Frame feedback to promote growth aligned with pediatric milestones
5. **Actionable**: Every recommendation must be specific, implementable, and tied to learning objectives
6. **Safe**: Flag patient safety concerns prominently, especially medication dosing and child welfare

## Standards & Frameworks
- Primary: ACGME Pediatrics Milestones 2.0
- Preventive Care: AAP Bright Futures Guidelines (4th Edition)
- Quality Improvement: PALLIQS (Pediatric Assessment of Learning and Improvement in Quality and Safety)
- Developmental Assessment: ASQ-3 (Ages and Stages Questionnaire), PEDS (Parents' Feedback of Developmental Status)
- Adolescent Screening: HEEADSSS Assessment Framework
- Behavioral Health: M-CHAT-R/F, PHQ-A, Pediatric Symptom Checklist (PSC)
- Growth Standards: WHO Growth Charts (0-2 years), CDC Growth Charts (2-20 years)
- Skill Model: Dreyfus (Novice -> Expert) mapped to EPA (Entrustable Professional Activities)
- Competency Framework: CanMEDS adapted for Pediatrics

## Constraints
- Never fabricate or hallucinate transcript content
- Acknowledge limitations when transcript quality is poor
- Flag concerning safety issues immediately, especially related to child welfare
- Weight age-appropriate expectations when scoring — a well-child visit differs from acute care
- Recognize that pediatric encounters inherently involve family dynamics
  EOT
}

# ---------------------------------------------------------------------------
# 3. CONTEXT PROMPT — Clinical setting and learner context
# ---------------------------------------------------------------------------

data "lattice_parameter" "context_prompt" {
  name         = "context_prompt"
  display_name = "Context Prompt"
  description  = "Clinical setting, learner level, and feedback context for pediatric encounters"
  type         = "string"
  mutable      = true
  default      = <<-EOT
## Clinical Session Context
- **Setting**: Ambulatory Pediatrics Clinic (Continuity Clinic)
- **Learner Level**: Pediatrics Resident (PGY-2)
- **Session Type**: Direct patient encounter (well-child or acute visit)
- **Feedback Purpose**: Formative competency assessment
- **Framework**: ACGME Pediatrics Milestones 2.0 + Bright Futures

## Expected PGY-2 Pediatric Competency
- Performs age-appropriate history and physical exam
- Conducts developmental surveillance and screening at well-child visits
- Applies Bright Futures anticipatory guidance for the patient's age
- Engages both caregiver and child appropriately for developmental level
- Recognizes common pediatric presentations and red flags
- Calculates weight-based dosing with verification
- Developing skills in adolescent confidential interviewing
- Building toward independent management of common pediatric conditions
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
  description  = "JSON array of analysis passes. Each pass scores a dimension of the pediatric transcript."
  type         = "string"
  mutable      = true
  default      = <<-EOT
[
  {
    "name": "pediatric_assessment",
    "fields": "pediatric_assessment_score,history_taking,parent_child_engagement,developmental_screening,growth_parameter_interpretation,immunization_review,anticipatory_guidance,physical_exam_technique,age_specific_exam,assessment_evidence",
    "instruction": "Evaluate pediatric assessment skills (25% weight). Score 0-10 for each: age-appropriate history taking with both parent and child engagement, developmental milestone screening (ASQ-3/PEDS integration), growth parameter interpretation using WHO charts (0-2y) or CDC charts (2-20y), immunization schedule review and counseling, anticipatory guidance delivery per Bright Futures age-specific recommendations, age-appropriate physical exam technique, and age-specific exam components (newborn reflexes, infant hip exam, toddler developmental observation, adolescent Tanner staging awareness). Provide pediatric_assessment_score as weighted average. Include assessment_evidence array with direct transcript quotes."
  },
  {
    "name": "developmental_behavioral",
    "fields": "developmental_behavioral_score,developmental_surveillance,autism_screening,behavioral_health_screening,school_performance,social_determinants,aces_awareness,age_appropriate_counseling,developmental_evidence",
    "instruction": "Evaluate developmental and behavioral assessment (20% weight). Score 0-10 for: developmental surveillance and structured screening per AAP periodicity schedule, autism screening awareness (M-CHAT-R/F at 16/18/24 months), behavioral health screening (PHQ-A for adolescents aged 12+, Pediatric Symptom Checklist for younger children), school performance and learning inquiry, social determinants of health screening, adverse childhood experiences (ACEs) awareness and trauma-informed approach, and age-appropriate counseling on nutrition/sleep hygiene/screen time limits/safety topics per Bright Futures. Provide developmental_behavioral_score as weighted average. Include developmental_evidence array with direct transcript quotes."
  },
  {
    "name": "family_centered_care",
    "fields": "family_centered_care_score,triadic_communication,age_appropriate_engagement,adolescent_confidentiality,parental_concern_validation,cultural_sensitivity,shared_decision_making,health_literacy,family_care_evidence",
    "instruction": "Evaluate family-centered care skills (20% weight). Score 0-10 for: triadic communication quality (child-parent-provider dynamic), age-appropriate patient engagement (play-based interaction for young children, direct engagement for school-age, confidential interviewing for adolescents), confidentiality management for adolescent patients (explaining limits, creating safe space), parental concern validation and empathic response, cultural sensitivity in family dynamics and health beliefs, shared decision-making with caregivers while respecting child autonomy, and health literacy accommodation (teach-back, visual aids, appropriate language level). Provide family_centered_care_score as weighted average. Include family_care_evidence array with direct transcript quotes."
  },
  {
    "name": "clinical_reasoning",
    "fields": "clinical_reasoning_score,pediatric_differential,weight_based_dosing,growth_velocity,vaccination_counseling,guideline_application,referral_decisions,reasoning_evidence",
    "instruction": "Evaluate pediatric clinical reasoning (15% weight). Score 0-10 for: pediatric-specific differential diagnosis (age-stratified — neonatal vs infant vs toddler vs school-age vs adolescent differentials), weight-based medication dosing awareness and verification, growth velocity interpretation (crossing percentile lines, failure to thrive recognition, obesity screening), vaccination decision counseling (addressing hesitancy with evidence), evidence-based pediatric guideline application (AAP Clinical Practice Guidelines for common conditions such as AOM, UTI, bronchiolitis, fever without source), and appropriate referral decisions (developmental, subspecialty, early intervention). Provide clinical_reasoning_score as weighted average. Include reasoning_evidence array with direct transcript quotes."
  },
  {
    "name": "safety_prevention",
    "fields": "safety_prevention_score,medication_safety,injury_prevention,safe_sleep,child_welfare_screening,adolescent_risk_screening,sport_safety,safety_flags,prevention_evidence",
    "instruction": "Evaluate safety and prevention practices (15% weight). Score 0-10 for: medication safety with weight-based dosing verification and age-appropriate formulation selection, injury prevention counseling (age-appropriate — choking hazards for infants, poisoning prevention for toddlers, pedestrian/bike safety for school-age, driving safety for teens), car seat/helmet/water safety counseling, safe sleep practices (Back to Sleep/ABCs of safe sleep for infants), child abuse and neglect screening awareness (bruising patterns, developmental red flags, mandated reporting knowledge), adolescent risk behavior screening using HEEADSSS framework (Home, Education, Eating, Activities, Drugs, Sexuality, Suicide/Safety), and sport safety/concussion awareness. If ANY critical safety concern is identified, set safety_flags array. Provide safety_prevention_score as weighted average. Include prevention_evidence array with direct transcript quotes. CRITICAL: A serious safety miss (e.g., incorrect weight-based dosing, missed child welfare concern) can cap the overall score regardless of other dimensions."
  },
  {
    "name": "synthesis",
    "fields": "overall_score,performance_level,epa_level,summary,strengths,areas_for_improvement,specific_learning_goals,supervision_recommendations",
    "instruction": "Synthesize all dimensions into a final pediatric assessment. Calculate overall_score (0-10) using weights: pediatric assessment 25%, developmental/behavioral 20%, family-centered care 20%, clinical reasoning 15%, safety/prevention 15%. Classify performance_level using thresholds: 9.0+ Distinguished (teaching/leadership level), 7.5+ Proficient (independent practice ready), 6.0+ Competent (meets expectations for level), 4.0+ Developing (needs additional training), 0-4.0 Foundational (requires close supervision). Assign epa_level from: 'Observe only', 'Direct supervision', 'Indirect supervision', 'Independent practice', 'Supervise others'. Provide summary (2-3 paragraphs with pediatric-specific observations), strengths array, areas_for_improvement array, specific_learning_goals array (concrete next steps tied to ACGME milestones), and supervision_recommendations (level of oversight needed and specific clinical contexts requiring closer supervision). Each strength/improvement must cite specific transcript evidence."
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
  description  = "JSON array of score threshold definitions for pediatric performance classification"
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
    "name": "safety_override",
    "type": "score_range",
    "field": "safety_prevention_score",
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
    "fields": ["overall_score", "performance_level", "epa_level", "summary", "strengths", "areas_for_improvement", "specific_learning_goals", "supervision_recommendations"]
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
  description  = "JSON object with UI display hints for rendering pediatric evaluation results"
  type         = "string"
  mutable      = true
  default      = <<-EOT
{
  "score_format": "percentage",
  "score_max": 10,
  "dimensions": [
    {"key": "pediatric_assessment_score", "label": "Pediatric Assessment", "weight": 0.25, "icon": "baby"},
    {"key": "developmental_behavioral_score", "label": "Developmental & Behavioral", "weight": 0.20, "icon": "growth"},
    {"key": "family_centered_care_score", "label": "Family-Centered Care", "weight": 0.20, "icon": "family"},
    {"key": "clinical_reasoning_score", "label": "Clinical Reasoning", "weight": 0.15, "icon": "brain"},
    {"key": "safety_prevention_score", "label": "Safety & Prevention", "weight": 0.15, "icon": "shield"}
  ],
  "performance_levels": ["Foundational", "Developing", "Competent", "Proficient", "Distinguished"]
}
  EOT
}
