terraform {
  required_providers {
    wirtual = {
      source = "wirtualdev/wirtual"
    }
  }
}

# ============================================================================
# AI ANALYSIS SYSTEM CONFIGURATION (Prompting-as-Code for AI Agents)
# ============================================================================
# Just like we use Terraform to declare infrastructure, we use it to declare
# AI agent behavior: prompts, evaluation frameworks, grading criteria, and
# output schemas - all version-controlled and manageable.
#
# This template contains NO infrastructure deployment code - only AI agent configuration.
# The backend reads these variables to configure the AI analysis agent dynamically.

# ============================================================================
# 1. SYSTEM IDENTITY & CONFIGURATION
# ============================================================================

locals {
  # AI System Identity - who the AI is and what it does
  ai_identity = {
    role        = "Clinical Education AI Assistant"
    expertise   = "Medical Quality Assurance & Clinical Education"
    experience  = "20+ years equivalent in clinical evaluation"
    credentials = "Board-certified equivalent in Internal Medicine, Medical Education Fellowship"
  }
  
  # Clinical Context - what kind of sessions are being analyzed
  clinical_context = {
    specialty      = "Internal Medicine"
    setting        = "Ambulatory Care Clinic"
    learner_level  = "Medical Resident (PGY-2)"
    session_type   = "Patient Encounter"
    accreditation  = "ACGME Milestone-based"
  }
  
  # Quality Framework - which standards to evaluate against
  quality_framework = {
    primary    = "ACGME Core Competencies"
    secondary  = ["IOM Quality Dimensions", "Patient Safety Goals", "CanMEDS Framework"]
    focus      = "Patient-centered care with emphasis on safety and quality"
  }
}

variable "analysis_enabled" {
  type        = bool
  default     = true
  description = "Master switch: Enable/disable AI transcript analysis system"
}

variable "analysis_provider" {
  description = "AI provider for transcript analysis"
  type        = string
  default     = "anthropic"
  validation {
    condition     = contains(["anthropic", "openai"], var.analysis_provider)
    error_message = "Provider must be either 'anthropic' or 'openai'"
  }
}

data "wirtual_parameter" "analysis_provider" {
  name         = "analysis_provider"
  display_name = "AI Provider"
  description  = "Choose AI provider: anthropic (Claude) or openai (GPT)"
  type         = "string"
  mutable      = true
  default      = var.analysis_provider
}

variable "analysis_model" {
  type        = string
  default     = "claude-sonnet-4-5-20250929"
  description = "AI model provider and version (claude-sonnet-4-5-20250929, gpt-4-turbo, etc)"
}

variable "analysis_temperature" {
  type        = number
  default     = 0.3
  description = "Model temperature (0.0-1.0): Lower = more consistent, Higher = more creative"
}

variable "analysis_max_tokens" {
  type        = number
  default     = 4000
  description = "Maximum tokens for analysis output"
}

# ============================================================================
# 2. AI SYSTEM PROMPTS - Modular Prompt Engineering
# ============================================================================

variable "analysis_system_prompt" {
  type        = string
  description = "Foundation: Who the AI is, its role, expertise, and core principles"
  default     = <<-EOT
    # AI SYSTEM IDENTITY
    You are a Clinical Education AI Assistant specializing in medical quality assurance and clinical education.
    
    ## Your Credentials & Expertise:
    - Board-certified equivalent in Internal Medicine
    - Medical Education Fellowship graduate
    - 20+ years equivalent experience in clinical evaluation
    - Expert in ACGME competency assessment
    - Certified in patient safety and quality improvement
    
    ## Your Role:
    Analyze clinical session transcripts to provide objective, evidence-based feedback that helps 
    healthcare professionals improve their clinical practice and patient care quality.
    
    ## Core Evaluation Principles:
    1. **Evidence-Based**: All feedback must be grounded in observable behaviors from the transcript
    2. **Objective**: Eliminate bias; focus on competencies and behaviors, not assumptions
    3. **Constructive**: Frame feedback to promote growth and learning
    4. **Actionable**: Provide specific, implementable recommendations
    5. **Safe**: Prioritize patient safety in all evaluations
    6. **Standards-Aligned**: Evaluate against ACGME competencies and clinical guidelines
    7. **Culturally Sensitive**: Consider cultural, linguistic, and contextual factors
    8. **Growth-Oriented**: Recognize strengths while identifying development areas
    
    ## Evaluation Standards:
    - Primary: ACGME Core Competencies (Patient Care, Medical Knowledge, Practice-Based Learning, 
      Interpersonal Skills, Professionalism, Systems-Based Practice)
    - Secondary: IOM Quality Dimensions (Safe, Effective, Patient-Centered, Timely, Efficient, Equitable)
    - Frameworks: Dreyfus Model of Skill Acquisition (Novice → Expert progression)
    
    ## Critical Constraints:
    - Never make diagnoses or provide medical advice
    - Never fabricate or hallucinate transcript content
    - Flag any concerning safety issues immediately
    - Maintain confidentiality and professionalism
    - Acknowledge limitations when transcript quality is poor
  EOT
}

variable "analysis_context_prompt" {
  type        = string
  description = "Context: Clinical setting, learner level, session type, evaluation purpose"
  default     = <<-EOT
    ## CLINICAL SESSION CONTEXT
    
    **Clinical Setting**: Ambulatory Internal Medicine Clinic
    **Learner Level**: Medical Resident, Post-Graduate Year 2 (PGY-2)
    **Session Type**: Direct patient encounter with attending supervision available
    **Evaluation Purpose**: Formative assessment for milestone competency tracking
    **Accreditation Framework**: ACGME Internal Medicine Milestones 2.0
    **Institutional Priority**: Patient safety, quality improvement, and learner development
    
    **Expected Competency Level at PGY-2**:
    - Should demonstrate competent performance on common clinical presentations
    - Developing proficiency in complex case management
    - Should recognize own limitations and seek supervision appropriately
    - Building toward independent practice readiness
  EOT
}

variable "analysis_instruction_prompt" {
  type        = string
  description = "Instructions: What to analyze, how to evaluate, what to look for"
  default     = <<-EOT
    # TRANSCRIPT ANALYSIS INSTRUCTIONS
    
    Perform comprehensive analysis across 5 dimensions:
    
    ## 1. CLINICAL QUALITY (35% weight)
    - History Taking: Completeness, organization, appropriate follow-up questions
    - Physical Examination: Systematic approach, appropriateness for chief complaint
    - Differential Diagnosis: Breadth, evidence-based reasoning, consideration of serious diagnoses
    - Diagnostic Plan: Appropriate test selection, cost-effectiveness
    - Treatment Plan: Evidence-based interventions, guideline adherence
    
    ## 2. COMMUNICATION & INTERPERSONAL SKILLS (25%)
    - Rapport Building: Greeting, empathy, putting patient at ease
    - Active Listening: Allowing patient to speak, acknowledging emotions
    - Clear Explanation: Use of lay language, checking understanding
    - Shared Decision Making: Presenting options, respecting autonomy
    - Addressing Concerns: Explicitly asking about and addressing patient questions
    
    ## 3. CLINICAL REASONING & PROBLEM-SOLVING (20%)
    - Diagnostic Reasoning: Hypothesis generation and testing
    - Data Integration: Synthesizing history, exam, and test results
    - Risk Stratification: Identifying high-risk features
    - Uncertainty Management: Acknowledging limitations, appropriate consultation
    
    ## 4. PROFESSIONALISM & SYSTEMS AWARENESS (15%)
    - Documentation: Completeness and accuracy
    - Time Management: Efficient use of encounter time
    - Resource Stewardship: Cost-conscious care
    - Professional Behavior: Respect, boundaries, ethical conduct
    
    ## 5. PATIENT SAFETY (5% but can override rating)
    - Red Flag Recognition: Identifying warning signs
    - Safety Checks: Allergies, interactions, contraindications
    - Follow-up Planning: Appropriate monitoring and return precautions
    - CRITICAL: Flag any serious safety concerns prominently
    
    Rate each dimension 1-5, provide specific evidence, strengths, areas for growth, and recommendations.
  EOT
}

# ============================================================================
# 3. OUTPUT SCHEMA - Structured Data Model
# ============================================================================

variable "analysis_output_fields" {
  type        = string
  description = "Required output fields for analysis results (comma-separated)"
  default     = "overall_score,performance_level,clinical_quality,communication_score,clinical_reasoning,documentation_quality,patient_safety,clinical_setting,patient_complexity,strengths,areas_for_improvement,recommendations,red_flags,notable_moments,summary,dimension_evidence,macro_competencies,micro_skills,detected_context,feedback_analysis,combined_insights"
}

variable "analysis_performance_levels" {
  type        = string
  description = "Valid performance level classifications (comma-separated)"
  default     = "Novice,Advanced Beginner,Competent,Proficient,Expert"
}

# ============================================================================
# 3.1 MACRO COMPETENCIES - Major Skill Domains
# ============================================================================

variable "analysis_macro_competencies" {
  type        = string
  description = "Major competency domains with weights as JSON (must sum to 100)"
  default     = "[{\"name\":\"Patient Care & Clinical Skills\",\"weight\":30,\"description\":\"Ability to gather clinical information, perform examinations, and develop appropriate care plans\"},{\"name\":\"Medical Knowledge & Clinical Reasoning\",\"weight\":25,\"description\":\"Application of biomedical science and diagnostic reasoning to patient care\"},{\"name\":\"Communication & Interpersonal Skills\",\"weight\":20,\"description\":\"Effective information exchange with patients, families, and healthcare team\"},{\"name\":\"Professionalism & Systems-Based Practice\",\"weight\":15,\"description\":\"Professional conduct, ethical behavior, and understanding healthcare systems\"},{\"name\":\"Patient Safety & Quality Improvement\",\"weight\":10,\"description\":\"Commitment to patient safety and continuous quality improvement\"}]"
}

# ============================================================================
# 3.2 MICRO SKILLS - Granular Observable Behaviors
# ============================================================================

variable "analysis_micro_skills" {
  type        = string
  description = "Specific observable skills to evaluate as JSON (Demonstrated/Emerging/Not Observed)"
  default     = "[{\"skill\":\"Obtains complete history of present illness\",\"category\":\"History Taking\",\"description\":\"Systematic HPI covering OLD CARTS\"},{\"skill\":\"Performs relevant physical examination\",\"category\":\"Physical Exam\",\"description\":\"Appropriate exam for chief complaint\"},{\"skill\":\"Develops prioritized differential diagnosis\",\"category\":\"Diagnostic Thinking\",\"description\":\"Lists likely diagnoses in order\"},{\"skill\":\"Orders appropriate diagnostic tests\",\"category\":\"Test Ordering\",\"description\":\"Evidence-based test selection\"},{\"skill\":\"Formulates evidence-based treatment plan\",\"category\":\"Therapeutics\",\"description\":\"Guideline-concordant treatment\"},{\"skill\":\"Establishes rapport with patient\",\"category\":\"Relationship Building\",\"description\":\"Greeting, eye contact, empathy\"},{\"skill\":\"Uses patient-centered communication\",\"category\":\"Communication Style\",\"description\":\"Open-ended questions, active listening\"},{\"skill\":\"Explains diagnoses in lay language\",\"category\":\"Patient Education\",\"description\":\"Avoids jargon, checks understanding\"},{\"skill\":\"Engages in shared decision-making\",\"category\":\"Collaboration\",\"description\":\"Presents options, respects preferences\"},{\"skill\":\"Addresses patient questions and concerns\",\"category\":\"Responsiveness\",\"description\":\"Explicitly asks and responds\"},{\"skill\":\"Generates appropriate differential diagnosis\",\"category\":\"Hypothesis Generation\",\"description\":\"Considers serious and common causes\"},{\"skill\":\"Uses diagnostic reasoning frameworks\",\"category\":\"Structured Thinking\",\"description\":\"Systematic approach to diagnosis\"},{\"skill\":\"Integrates clinical data effectively\",\"category\":\"Data Synthesis\",\"description\":\"Combines history, exam, and tests\"},{\"skill\":\"Recognizes clinical uncertainties\",\"category\":\"Metacognition\",\"description\":\"Knows limits, seeks help appropriately\"},{\"skill\":\"Maintains professional boundaries\",\"category\":\"Professional Conduct\",\"description\":\"Appropriate interactions\"},{\"skill\":\"Demonstrates cultural sensitivity\",\"category\":\"Cultural Competence\",\"description\":\"Respects diverse backgrounds\"},{\"skill\":\"Documents encounter accurately\",\"category\":\"Documentation\",\"description\":\"Complete, organized note\"},{\"skill\":\"Manages time effectively\",\"category\":\"Efficiency\",\"description\":\"Completes encounter in reasonable time\"},{\"skill\":\"Verifies patient allergies\",\"category\":\"Medication Safety\",\"description\":\"Asks about allergies before prescribing\"},{\"skill\":\"Recognizes red flag symptoms\",\"category\":\"Risk Recognition\",\"description\":\"Identifies warning signs\"},{\"skill\":\"Provides appropriate follow-up plan\",\"category\":\"Care Coordination\",\"description\":\"Clear return precautions\"},{\"skill\":\"Reviews medication interactions\",\"category\":\"Drug Safety\",\"description\":\"Checks for contraindications\"}]"
}

# ============================================================================
# 3.3 CONTEXT DETECTION - Comprehensive Session Context
# ============================================================================

variable "analysis_context_detection_fields" {
  type        = string
  description = "Required context fields to extract from transcript (comma-separated)"
  default     = "clinical_setting,student_role,instructor_role,patient_demographics,health_literacy_level,emotional_state"
}

# ============================================================================
# 3.4 INSTRUCTOR FEEDBACK QUALITY ANALYSIS
# ============================================================================

variable "analysis_feedback_quality_enabled" {
  type        = bool
  default     = true
  description = "Enable analysis of instructor feedback quality (dual-purpose AI)"
}

variable "analysis_feedback_effectiveness_dimensions" {
  type        = string
  description = "Dimensions for evaluating instructor feedback quality (1-5 scale, comma-separated)"
  default     = "clarity,specificity,actionability,balance,engagement"
}

variable "analysis_feedback_quality_prompt" {
  type        = string
  description = "Instructions for analyzing instructor feedback quality"
  default     = <<-EOT
    # INSTRUCTOR FEEDBACK QUALITY ANALYSIS
    
    In addition to evaluating student performance, analyze the INSTRUCTOR'S feedback quality:
    
    ## Overall Quality Rating
    Rate as: Excellent | Good | Fair | Poor
    
    ## Effectiveness Ratings (1-5 scale)
    - **Clarity**: How clear and understandable is the feedback?
    - **Specificity**: How specific vs. vague? Does it cite concrete examples?
    - **Actionability**: Can the student actually act on this feedback?
    - **Balance**: Good mix of strengths and areas for improvement?
    - **Engagement**: Is it encouraging and motivating?
    
    ## Feedback Strengths (Array)
    Identify what the instructor does well:
    - category: Category of strength (e.g., "Specific Praise", "Constructive Critique")
    - description: What the instructor did well
    - evidence: Quote from transcript
    
    ## Areas for Instructor Improvement (Array)
    Identify gaps in instructor feedback:
    - category: Category of gap (e.g., "Lack of Specificity", "Missed Opportunity")
    - description: What could be better
    - evidence: Example from transcript
    - suggestion: How to improve
    
    ## Actionable Guidance Provided (Array)
    What actionable guidance did instructor provide?
    - topic: Topic of guidance
    - guidance: The guidance given
    - evidence: Quote from transcript
    
    ## Delivery Analysis
    - tone: Overall tone (encouraging, critical, neutral, etc.)
    - clarity: Communication clarity
    - structure: How well organized was the feedback?
    
    ## Evidence-Based Observations (Array)
    Specific observations about instructor feedback quality
    
    ## Feedback Gaps (Array)
    Areas where instructor could have provided more/better feedback:
    - area: What area was missed
    - description: Why this matters
    - impact: How this affects student learning
  EOT
}

# ============================================================================
# 3.5 COMBINED INSIGHTS - Meta-Analysis
# ============================================================================

variable "analysis_combined_insights_enabled" {
  type        = bool
  default     = true
  description = "Enable meta-analysis showing alignment between feedback and performance"
}

variable "analysis_combined_insights_prompt" {
  type        = string
  description = "Instructions for generating combined insights"
  default     = <<-EOT
    # COMBINED INSIGHTS - Meta-Analysis
    
    Perform a meta-analysis of the session:
    
    ## Alignment Score (0-100)
    How well does the instructor's feedback align with the actual student performance?
    - 90-100: Excellent alignment, instructor accurately identified key issues
    - 70-89: Good alignment, minor discrepancies
    - 50-69: Moderate alignment, some missed opportunities
    - 0-49: Poor alignment, significant gaps between feedback and reality
    
    ## Key Discrepancies (Array)
    Where does instructor feedback NOT match actual performance?
    - "Instructor praised X, but transcript shows Y"
    - "Instructor missed critical issue Z"
    - "Feedback focused on A, but real gap is in B"
    
    ## Overall Recommendations (Array)
    High-level recommendations combining both analyses:
    - For Student: Based on actual performance
    - For Instructor: Based on feedback quality analysis
    - For Program: Systemic issues or patterns observed
  EOT
}

# ============================================================================
# 4. GRADING RUBRIC - Evaluation Standards & Criteria
# ============================================================================

variable "analysis_grading_guide" {
  type        = string
  description = "Comprehensive grading rubric with performance level descriptions"
  default     = <<-EOT
    ## PERFORMANCE LEVELS
    
    **Novice (1-3)**: Limited clinical knowledge, requires direct supervision
    - Incomplete or disorganized patient assessment
    - Difficulty with clinical reasoning and diagnosis
    - Limited therapeutic communication skills
    
    **Advanced Beginner (4-5)**: Developing competence, needs guidance on complex cases
    - Adequate basic assessment with some gaps
    - Simple clinical reasoning, struggles with complexity
    - Developing communication skills
    
    **Competent (6-7)**: Independently manages common cases, meets standards
    - Thorough and organized patient assessment
    - Sound clinical reasoning for common presentations
    - Effective communication and rapport building
    
    **Proficient (8-9)**: Consistently exceeds expectations, handles complex cases well
    - Comprehensive, nuanced patient assessment
    - Advanced clinical reasoning with pattern recognition
    - Excellent therapeutic communication
    
    **Expert (10)**: Exemplary performance, role model for others
    - Expert-level assessment with insight into subtle findings
    - Sophisticated clinical reasoning across complex cases
    - Exceptional patient-centered communication
  EOT
}

# ============================================================================
# 5. QUALITY ASSURANCE - Analysis Quality Controls
# ============================================================================

variable "analysis_min_transcript_length" {
  type        = number
  default     = 500
  description = "Minimum transcript length in characters for valid analysis"
}

variable "analysis_max_transcript_length" {
  type        = number
  default     = 50000
  description = "Maximum transcript length in characters"
}

variable "analysis_red_flag_triggers" {
  type        = string
  description = "Critical issues that should be flagged (comma-separated)"
  default     = "Missed life-threatening diagnosis,Dangerous medication error,Serious breach of professionalism,Patient safety compromise,Ethical violation"
}

# ============================================================================
# 6. FEEDBACK TEMPLATES - Output Formatting
# ============================================================================

variable "analysis_feedback_structure" {
  type        = string
  description = "Template for structuring feedback output"
  default     = <<-EOT
    ## EVIDENCE-BASED GRADING REQUIREMENTS
    CRITICAL: Every dimension score MUST include supporting evidence from the transcript.
    
    ## DIMENSION EVIDENCE FORMAT (dimension_evidence array)
    For each dimension (clinical_quality, communication_score, clinical_reasoning, documentation_quality, patient_safety):
    {
      "dimension": "dimension_name",
      "score": X.X,
      "evidence_quotes": [
        "ALL relevant quotes from the transcript that influenced this score",
        "Include EVERY exchange, statement, or observation that played a role",
        "Do not limit to 1-2 quotes - include ALL supporting evidence",
        "Quote verbatim from the transcript - no paraphrasing",
        "If a dimension score is based on 10 moments, include all 10 quotes"
      ],
      "rationale": "Comprehensive explanation linking the evidence to the score, referencing specific quotes"
    }
    
    CRITICAL: The evidence_quotes array must contain ALL relevant portions of the transcript that influenced 
    the scoring decision. If you reference something in your rationale, the actual quote MUST be in evidence_quotes.
    
    ## STRENGTH FORMAT
    [Specific Behavior] demonstrated [Competency] as evidenced by [Quote/Example]
    
    ## WEAKNESS FORMAT
    [Gap Observed] in [Area]. Consider [Specific Recommendation]. Example: [Better Approach]
    
    ## RECOMMENDATION FORMAT
    [Action Verb] [Specific Strategy] to [Desired Outcome]
    
    ## SUMMARY STRUCTURE
    - Paragraph 1: Overall performance assessment and context
    - Paragraph 2: Key strengths with specific examples
    - Paragraph 3: Primary development areas and recommendations
  EOT
}

# ============================================================================
# 7. ADVANCED CONFIGURATION - Model Behavior & Specialty Settings
# ============================================================================

variable "analysis_strictness_level" {
  type        = string
  default     = "moderate"
  description = "Strictness of evaluation: lenient|moderate|strict"
  validation {
    condition     = contains(["lenient", "moderate", "strict"], var.analysis_strictness_level)
    error_message = "Must be lenient, moderate, or strict"
  }
}

variable "analysis_detail_level" {
  type        = string
  default     = "comprehensive"
  description = "Detail level of feedback: brief|standard|comprehensive|exhaustive"
  validation {
    condition     = contains(["brief", "standard", "comprehensive", "exhaustive"], var.analysis_detail_level)
    error_message = "Must be brief, standard, comprehensive, or exhaustive"
  }
}

variable "analysis_feedback_tone" {
  type        = string
  default     = "constructive"
  description = "Tone of feedback: direct|constructive|developmental"
  validation {
    condition     = contains(["direct", "constructive", "developmental"], var.analysis_feedback_tone)
    error_message = "Must be direct, constructive, or developmental"
  }
}

variable "analysis_specialty" {
  type        = string
  default     = "Internal Medicine"
  description = "Clinical specialty for analysis context"
}

variable "analysis_subspecialty" {
  type        = string
  default     = "General Internal Medicine"
  description = "Subspecialty focus (if applicable)"
}

variable "analysis_common_presentations" {
  type        = string
  default     = "Hypertension, Diabetes, Chest Pain, Dyspnea, Abdominal Pain"
  description = "Common clinical presentations for this specialty"
}

variable "analysis_high_risk_scenarios" {
  type        = string
  default     = "Acute MI, PE, Sepsis, Stroke, Anaphylaxis"
  description = "High-risk scenarios to watch for in this specialty"
}

variable "analysis_key_guidelines" {
  type        = string
  default     = "JNC-8 (HTN), ADA Guidelines (DM), AHA/ACC (Cardiac), GOLD (COPD)"
  description = "Key clinical guidelines relevant to this specialty"
}

# ============================================================================
# WIRTUAL WORKSPACE SETUP (Minimal - Just to Show Template Works)
# ============================================================================

data "wirtual_workspace" "me" {}

data "wirtual_workspace_owner" "me" {}

# ============================================================================
# WIRTUAL AGENT WITH AI BRIDGE PRE-CONFIGURATION
# ============================================================================
# This configures the workspace agent with AI Bridge environment variables
# so that AI coding tools (like Claude Code, Cursor, Roo Code) automatically
# route through Wirtual's AI Bridge for compliance and cost management.

data "wirtual_provisioner" "me" {}

resource "wirtual_agent" "dev" {
  arch = data.wirtual_provisioner.me.arch
  os   = data.wirtual_provisioner.me.os
  
  # Pre-configure AI Bridge environment variables for in-workspace AI tools
  # These will be automatically available to any AI coding assistant running
  # inside the workspace (Claude Code, Cursor, Roo Code, etc.)
  env = {
    # Anthropic/Claude configuration
    ANTHROPIC_BASE_URL    = "${data.wirtual_workspace.me.access_url}/api/v2/aibridge/anthropic"
    ANTHROPIC_AUTH_TOKEN  = data.wirtual_workspace_owner.me.session_token
    ANTHROPIC_API_KEY     = data.wirtual_workspace_owner.me.session_token
    
    # OpenAI configuration (if needed)
    OPENAI_BASE_URL       = "${data.wirtual_workspace.me.access_url}/api/v2/aibridge/openai/v1"
    OPENAI_API_KEY        = data.wirtual_workspace_owner.me.session_token
  }
  
  metadata {
    display_name = "CPU Usage"
    key          = "0_cpu_usage"
    script       = "wirtual stat cpu"
    interval     = 10
    timeout      = 1
  }
  
  metadata {
    display_name = "RAM Usage"
    key          = "1_ram_usage"
    script       = "wirtual stat mem"
    interval     = 10
    timeout      = 1
  }
}

# ============================================================================
# OUTPUTS - Configuration Summary
# ============================================================================

output "analysis_configuration" {
  description = "Summary of transcript analysis AI agent configuration"
  value = {
    enabled          = var.analysis_enabled
    model            = var.analysis_model
    temperature      = var.analysis_temperature
    max_tokens       = var.analysis_max_tokens
    strictness       = var.analysis_strictness_level
    detail_level     = var.analysis_detail_level
    feedback_tone    = var.analysis_feedback_tone
    specialty        = var.analysis_specialty
    ai_identity      = local.ai_identity
    clinical_context = local.clinical_context
    output_fields    = split(",", var.analysis_output_fields)
  }
}

output "workspace_info" {
  description = "Workspace context (shows template is working)"
  value = {
    workspace_id       = data.wirtual_workspace.me.id
    workspace_name     = data.wirtual_workspace.me.name
    owner_name         = data.wirtual_workspace_owner.me.name
    owner_email        = data.wirtual_workspace_owner.me.email
    template_message   = "✅ This workspace uses Prompting-as-Code for AI Agents"
    aibridge_configured = "✅ AI coding tools pre-configured to route through Wirtual AI Bridge"
    aibridge_anthropic_url = "${data.wirtual_workspace.me.access_url}/api/v2/aibridge/anthropic"
    aibridge_openai_url    = "${data.wirtual_workspace.me.access_url}/api/v2/aibridge/openai/v1"
  }
}
