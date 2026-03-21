---
display_name: Emergency Medicine Feedback
description: AI-powered emergency medicine feedback using ACGME EM Milestones, ABEM, and Ottawa frameworks
icon: ../../.icons/1f468-200d-2695-fe0f.png
maintainer_github: lattice
verified: true
tags: [evaluation, healthcare, emergency-medicine, milestones]
---

# Emergency Medicine Clinical Feedback Template

A non-provisioned evaluation template that configures the AI feedback pipeline for emergency medicine clinical transcripts. Uses a 6-pass analysis architecture aligned with ACGME Emergency Medicine Milestones 2.0, ABEM oral exam format, AAMC EPA framework, Ottawa EM Assessment criteria, and the CORD Teaching Framework.

## Analysis Passes

| Pass | Weight | What it evaluates |
|------|--------|-------------------|
| Initial Assessment | 25% | ABCDE approach, primary survey, triage acuity, life threat recognition, resuscitation initiation |
| Diagnostic Workup | 20% | Differential breadth, worst-first thinking, time-sensitive diagnoses (STEMI, stroke, sepsis, PE), imaging/lab interpretation |
| Management & Disposition | 20% | Evidence-based ED management, risk stratification tools (HEART, PERC, Wells, CURB-65), disposition decisions, discharge safety |
| Procedural & Communication | 15% | Team communication, SBAR/I-PASS handoff, consultant communication, de-escalation, breaking bad news (SPIKES) |
| Systems & Safety | 15% | Throughput, multi-patient management, medication safety, bounce-back prevention, documentation timeliness |
| Synthesis | 5% | Overall EM competency, Milestone level mapping, entrustability for independent ED shifts, learning goals |

## Score Thresholds (EM Milestones 2.0)

| Score | Milestone Level | Description |
|-------|----------------|-------------|
| 9.0+  | Level 5 | Aspirational — ready for unsupervised practice in complex settings |
| 7.5+  | Level 4 | Ready for unsupervised practice |
| 6.0+  | Level 3 | Advancing — manages most patients with indirect supervision |
| 4.0+  | Level 2 | Developing — requires direct supervision |
| 0-4.0 | Level 1 | Entry level |

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
- **temperature**: 0.0-1.0 (default: 0.2 for consistent scoring)
- **system_prompt**: AI evaluator identity and principles
- **context_prompt**: Clinical setting and learner context
- **analysis_passes**: JSON array defining the scoring pipeline
- **score_thresholds**: Performance level classification rules (EM Milestones)
- **validation_rules**: Cross-pass consistency checks

## Requirements

The server must have an AI provider API key set:
- `ANTHROPIC_API_KEY` for Claude models
- `OPENAI_API_KEY` for GPT models
