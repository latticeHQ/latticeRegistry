---
display_name: Pediatrics Clinical Feedback
description: AI-powered pediatric feedback using Bright Futures, PALLIQS, and HEEADSSS frameworks
icon: ../../.icons/1f468-200d-2695-fe0f.png
maintainer_github: lattice
verified: true
tags: [evaluation, healthcare, pediatrics, bright-futures]
---

# Pediatrics Clinical Feedback Template

A non-provisioned evaluation template that configures the AI feedback pipeline for pediatric clinical transcripts. Uses a 6-pass analysis architecture grounded in ACGME Pediatrics Milestones, AAP Bright Futures guidelines, and PALLIQS frameworks.

## Analysis Passes

| Pass | Weight | What it evaluates |
|------|--------|-------------------|
| Pediatric Assessment | 25% | Age-appropriate history taking, developmental screening (ASQ-3/PEDS), growth parameters (WHO/CDC), immunizations, anticipatory guidance (Bright Futures), physical exam technique |
| Developmental & Behavioral | 20% | Developmental surveillance, autism screening (M-CHAT-R), behavioral health (PHQ-A/PSC), school performance, social determinants, ACEs awareness, age-appropriate counseling |
| Family-Centered Care | 20% | Triadic communication, age-appropriate engagement, adolescent confidentiality, parental concern validation, cultural sensitivity, shared decision-making, health literacy |
| Clinical Reasoning | 15% | Age-stratified differentials, weight-based dosing, growth velocity interpretation, vaccination counseling, AAP guideline application, referral decisions |
| Safety & Prevention | 15%* | Medication safety, injury prevention, safe sleep, child welfare screening, HEEADSSS adolescent screening, sport/concussion safety |
| Synthesis | --- | Overall score, EPA level, strengths, improvements, learning goals, supervision recommendations |

*Safety & prevention can override the overall rating if critical issues are found (e.g., dosing errors, missed child welfare concerns).

## Score Thresholds

| Score | Level | Description |
|-------|-------|-------------|
| 9.0+  | Distinguished | Teaching/leadership level |
| 7.5+  | Proficient | Independent practice ready |
| 6.0+  | Competent | Meets expectations for level |
| 4.0+  | Developing | Needs additional training |
| 0-4.0 | Foundational | Requires close supervision |

## Setup

```bash
export LATTICE_URL=https://access.latticeruntime.com
export LATTICE_TOKEN=$(lattice tokens create)
./scripts/setup-evaluation-template.sh
```

## Configuration

All parameters are mutable and can be overridden per evaluation run:

- **provider**: `anthropic` or `openai`
- **model**: e.g. `claude-sonnet-4-5-20250929`, `gpt-4o`
- **temperature**: 0.0-1.0 (default: 0.25 for consistent scoring)
- **system_prompt**: AI evaluator identity and pediatric expertise
- **context_prompt**: Clinical setting and learner context
- **analysis_passes**: JSON array defining the 6-pass scoring pipeline
- **score_thresholds**: Performance level classification rules
- **validation_rules**: Cross-pass consistency checks

## Requirements

The server must have an AI provider API key set:
- `ANTHROPIC_API_KEY` for Claude models
- `OPENAI_API_KEY` for GPT models
