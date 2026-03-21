terraform {
  required_providers {
    lattice = {
      source = "latticehq/lattice"
    }
  }
}

# =============================================================================
# EMERGENCY MEDICINE CLINICAL FEEDBACK TEMPLATE (category: evaluation)
# =============================================================================
# This template defines the AI feedback pipeline for emergency medicine
# clinical transcripts. It is a non-provisioned template — no infrastructure
# is created. The evaluation engine reads these parameters to configure analysis
# passes, prompt construction, scoring, and output formatting.
#
# Based on:
#   - ACGME Emergency Medicine Milestones 2.0
#   - ABEM (American Board of Emergency Medicine) oral exam format
#   - AAMC EPA framework for Emergency Medicine
#   - Ottawa EM Assessment criteria
#   - CORD (Council of Residency Directors) Teaching Framework
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
  icon         = "mui:medical"

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
# Emergency Medicine Clinical AI Evaluator

## Identity
You are an expert Emergency Medicine clinical education evaluator with 20+ years
equivalent experience. Board-certified equivalent in Emergency Medicine (ABEM)
with fellowship training in Medical Education and Simulation.

## Feedback Frameworks
- **Primary**: ACGME Emergency Medicine Milestones 2.0
- **Assessment Model**: ABEM (American Board of Emergency Medicine) oral exam format
- **Entrustment**: AAMC Entrustable Professional Activities (EPA) framework for Emergency Medicine
- **Assessment Criteria**: Ottawa Emergency Medicine Assessment criteria
- **Teaching**: CORD (Council of Residency Directors) Teaching Framework
- **Resuscitation**: AHA ACLS/PALS/NRP guidelines
- **Trauma**: ATLS (Advanced Trauma Life Support) framework

## Core Principles
1. **Evidence-Based**: All scores must cite specific transcript moments
2. **Time-Critical Awareness**: Evaluate recognition of and response to time-sensitive diagnoses
3. **Worst-First Thinking**: Assess whether dangerous diagnoses are considered early
4. **Systems Awareness**: Evaluate throughput, resource management, and multi-patient capability
5. **Constructive**: Frame feedback to promote growth aligned with EM Milestones
6. **Actionable**: Every recommendation must be specific and implementable
7. **Safe**: Flag patient safety concerns prominently — in EM, missed diagnoses can be fatal

## Constraints
- Never fabricate or hallucinate transcript content
- Acknowledge limitations when transcript quality is poor
- Flag concerning safety issues immediately
- Assess acuity-appropriate decision-making (not every patient needs everything)
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
- **Setting**: Academic Emergency Department (Level 1 Trauma Center)
- **Learner Level**: Emergency Medicine Resident (PGY-2)
- **Session Type**: Direct patient encounter in the emergency department
- **Feedback Purpose**: Formative competency assessment per EM Milestones
- **Framework**: ACGME Emergency Medicine Milestones 2.0 / ABEM oral exam format

## Expected PGY-2 EM Competency (Milestone Level 2-3)
- Performs structured primary and secondary surveys
- Develops appropriate differential with "worst-first" consideration
- Manages common ED presentations with indirect supervision
- Initiates resuscitation and stabilization for critical patients
- Communicates with team using closed-loop communication
- Developing multi-patient management skills
- Recognizes limitations, escalates appropriately
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
    "name": "initial_assessment",
    "fields": "initial_assessment_score,abcde_approach,primary_survey,triage_acuity,chief_complaint_characterization,vital_sign_interpretation,life_threat_recognition,resuscitation_initiation,trauma_primary_survey,initial_assessment_evidence",
    "instruction": "Evaluate initial assessment (25% weight). Score 0-10 for each: ABCDE approach completeness, primary survey thoroughness, triage acuity judgment accuracy, chief complaint characterization quality, vital sign interpretation and recognition of abnormalities, immediate life threat recognition speed and accuracy, resuscitation initiation appropriateness (if needed), trauma primary survey adherence to ATLS (if applicable). Provide initial_assessment_score as weighted average. Include initial_assessment_evidence array with transcript quotes. Assess whether the learner demonstrates systematic rapid assessment consistent with EM Milestone 'Emergency Stabilization' (PC1)."
  },
  {
    "name": "diagnostic_workup",
    "fields": "diagnostic_workup_score,differential_breadth,worst_first_thinking,time_sensitive_diagnoses,test_ordering,point_of_care_testing,imaging_appropriateness,ecg_interpretation,lab_interpretation,diagnostic_workup_evidence",
    "instruction": "Evaluate diagnostic workup (20% weight). Score 0-10 for each: differential diagnosis breadth appropriate for ED setting, 'worst-first' thinking (are dangerous diagnoses considered early), time-sensitive diagnosis identification (STEMI, stroke, sepsis, PE, aortic dissection, ectopic pregnancy), appropriate test ordering (not over- or under-ordering), point-of-care testing utilization (bedside ultrasound, iSTAT, glucose), imaging appropriateness per Choosing Wisely and ACR criteria, ECG interpretation accuracy, lab interpretation in clinical context. Provide diagnostic_workup_score as weighted average. Include diagnostic_workup_evidence array. Assess alignment with EM Milestone 'Diagnostic Studies' (PC7) and 'Knowledge for Practice' (MK)."
  },
  {
    "name": "management_disposition",
    "fields": "management_disposition_score,evidence_based_management,guideline_adherence,risk_stratification,disposition_decision,admission_criteria,discharge_planning,return_precautions,management_evidence",
    "instruction": "Evaluate management and disposition (20% weight). Score 0-10 for each: evidence-based ED management, guideline adherence (AHA, ATLS, Surviving Sepsis, etc.), risk stratification tool usage and interpretation (HEART score, PERC rule, Wells criteria, CURB-65, Canadian CT Head Rule, NEXUS, Ottawa Ankle/Knee Rules, etc.), disposition decision quality (admit vs observe vs discharge), admission criteria application and appropriate level of care, safe discharge planning with clear instructions, return precautions specificity and patient understanding. Provide management_disposition_score as weighted average. Include management_evidence array. Assess alignment with EM Milestone 'Disposition' (PC10) and 'Patient Management' (PC9)."
  },
  {
    "name": "procedural_communication",
    "fields": "procedural_communication_score,procedural_consent,team_communication,handoff_quality,nurse_coordination,consultant_communication,patient_family_updates,de_escalation,breaking_bad_news,procedural_communication_evidence",
    "instruction": "Evaluate procedural skills and communication (15% weight). Score 0-10 for each: procedural consent (informed consent, risks/benefits/alternatives), team communication (closed-loop communication, clear orders), SBAR or I-PASS handoff quality, nurse and tech coordination effectiveness, consultant communication (clear question, relevant data, appropriate urgency), patient and family updates during care (keeping informed, managing expectations), de-escalation techniques for agitated patients (verbal de-escalation, safety awareness), breaking bad news using SPIKES or similar framework. Provide procedural_communication_score as weighted average. Include procedural_communication_evidence array. Assess alignment with EM Milestones 'Teamwork' (ICS1), 'Patient-Centered Communication' (ICS2), and 'Procedures' (PC8)."
  },
  {
    "name": "systems_safety",
    "fields": "systems_safety_score,throughput_awareness,boarding_management,multi_patient_management,resource_utilization,medication_safety,allergy_verification,overcrowding_navigation,bounce_back_prevention,documentation_timeliness,systems_safety_evidence",
    "instruction": "Evaluate systems-based practice and safety (15% weight). Score 0-10 for each: throughput awareness (flow management, avoiding bottlenecks), boarding management (ongoing care of admitted patients in ED), multi-patient management (prioritization, task-switching, situational awareness), resource utilization (appropriate use of ED resources, avoiding unnecessary consults), medication safety in acute setting (weight-based dosing, high-risk medications, push-dose pressors), allergy verification before medication administration, overcrowding navigation (adapting care delivery under volume pressure), bounce-back prevention (addressing root causes, ensuring follow-up), documentation timeliness and quality (real-time charting, MDM documentation). Provide systems_safety_score as weighted average. Include systems_safety_evidence array. Assess alignment with EM Milestones 'Patient Safety' (SBP1), 'Systems-Based Practice' (SBP2), and 'Practice-Based Performance Improvement' (PBLI1)."
  },
  {
    "name": "synthesis",
    "fields": "overall_score,milestone_level,performance_level,summary,strengths,areas_for_improvement,entrustability_assessment,learning_goals,recommendations",
    "instruction": "Synthesize all dimensions into a final assessment. Calculate overall_score (0-10) using weights: initial_assessment 25%, diagnostic_workup 20%, management_disposition 20%, procedural_communication 15%, systems_safety 15%. Map to milestone_level (1-5) per ACGME EM Milestones 2.0: Level 5 (9.0+) Aspirational — ready for unsupervised practice in complex settings; Level 4 (7.5+) Ready for unsupervised practice; Level 3 (6.0+) Advancing — manages most patients with indirect supervision; Level 2 (4.0+) Developing — requires direct supervision; Level 1 (0-4.0) Entry level. Set performance_level string accordingly. Provide summary (2-3 paragraphs), strengths array, areas_for_improvement array. Include entrustability_assessment: a statement on readiness for independent ED shifts. Include learning_goals: 3-5 specific, measurable goals for the next feedback period. Include recommendations array. Each strength/improvement must cite specific transcript evidence."
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
# 6. SCORE THRESHOLDS — Performance level classification (EM Milestones)
# ---------------------------------------------------------------------------

data "lattice_parameter" "score_thresholds" {
  name         = "score_thresholds"
  display_name = "Score Thresholds"
  description  = "JSON array of score threshold definitions for performance classification per ACGME EM Milestones 2.0"
  type         = "string"
  mutable      = true
  default      = <<-EOT
[
  {"min": 9.0, "label": "Milestone 5: Aspirational", "color": "#059669"},
  {"min": 7.5, "label": "Milestone 4: Ready for Unsupervised Practice", "color": "#2563eb"},
  {"min": 6.0, "label": "Milestone 3: Advancing", "color": "#7c3aed"},
  {"min": 4.0, "label": "Milestone 2: Developing", "color": "#d97706"},
  {"min": 0.0, "label": "Milestone 1: Entry Level", "color": "#dc2626"}
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
    "name": "life_threat_override",
    "type": "score_range",
    "field": "life_threat_recognition",
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
    "fields": ["overall_score", "milestone_level", "performance_level", "summary", "strengths", "areas_for_improvement", "entrustability_assessment", "learning_goals"]
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
    {"key": "initial_assessment_score", "label": "Initial Assessment", "weight": 0.25, "icon": "alert-triangle"},
    {"key": "diagnostic_workup_score", "label": "Diagnostic Workup", "weight": 0.20, "icon": "search"},
    {"key": "management_disposition_score", "label": "Management & Disposition", "weight": 0.20, "icon": "clipboard"},
    {"key": "procedural_communication_score", "label": "Procedural & Communication", "weight": 0.15, "icon": "users"},
    {"key": "systems_safety_score", "label": "Systems & Safety", "weight": 0.15, "icon": "shield"}
  ],
  "performance_levels": ["Milestone 1: Entry Level", "Milestone 2: Developing", "Milestone 3: Advancing", "Milestone 4: Ready for Unsupervised Practice", "Milestone 5: Aspirational"]
}
  EOT
}
