---
display_name: Psychiatry & Behavioral Health
description: AI-powered psychiatric feedback using DSM-5-TR, C-SSRS, and Motivational Interviewing frameworks
icon: ../../.icons/1f468-200d-2695-fe0f.png
maintainer_github: lattice
verified: true
tags: [evaluation, healthcare, psychiatry, behavioral-health]
---

# Psychiatry / Behavioral Health Clinical Feedback Template

A non-provisioned evaluation template for assessing psychiatric clinical encounter transcripts. Grounded in Stanford Psychiatry & Behavioral Sciences standards.

## Category

`evaluation` — no infrastructure is provisioned. The evaluation engine reads template parameters to configure the analysis pipeline.

## Frameworks Referenced

- **DSM-5-TR** diagnostic criteria for differential diagnosis
- **Mental Status Examination (MSE)** structured assessment across all domains
- **Motivational Interviewing (MI)** principles and OARS technique
- **Columbia Suicide Severity Rating Scale (C-SSRS)** for suicide risk assessment
- **Biopsychosocial formulation model** for comprehensive case conceptualization
- **Cultural Formulation Interview (CFI)** for culturally informed assessment
- **Recovery-oriented care** principles

## Analysis Passes

| Pass | Weight | Focus |
|------|--------|-------|
| Psychiatric Assessment | 25% | MSE completeness, history, substance screening |
| Risk Assessment | 25% | C-SSRS, safety planning, risk stratification |
| Therapeutic Alliance | 20% | MI adherence (OARS), empathic accuracy |
| Diagnostic Reasoning | 15% | DSM-5-TR differentials, biopsychosocial formulation |
| Treatment Planning | 10% | Evidence-based selection, crisis planning |
| Synthesis | 5% | Overall competency, supervision recommendations |

## Score Thresholds

| Score | Level | Supervision |
|-------|-------|-------------|
| 9.0+ | Distinguished | Autonomous practice ready |
| 7.5+ | Proficient | Minimal supervision |
| 6.0+ | Competent | Moderate supervision |
| 4.0+ | Developing | Close supervision |
| 0-4.0 | Foundational | Direct supervision required |

## Defaults

- **Provider**: Anthropic
- **Model**: claude-sonnet-4-5-20250929
- **Temperature**: 0.2
