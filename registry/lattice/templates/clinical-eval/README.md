---
display_name: Clinical Feedback (General)
description: AI-powered clinical transcript feedback with ACGME competency-based 6-pass analysis
icon: ../../.icons/1f468-200d-2695-fe0f.png
maintainer_github: lattice
verified: true
tags: [evaluation, healthcare, clinical, acgme]
---

# Clinical Feedback Template

A non-provisioned evaluation template that configures the AI feedback pipeline for clinical transcripts. Uses a 6-pass analysis architecture to score transcripts across multiple dimensions.

## Analysis Passes

| Pass | Weight | What it evaluates |
|------|--------|-------------------|
| Clinical Quality | 35% | History taking, physical exam, differential diagnosis, diagnostic/treatment plan |
| Communication | 25% | Rapport, active listening, explanations, shared decision making |
| Clinical Reasoning | 20% | Diagnostic reasoning, data integration, risk stratification |
| Professionalism | 15% | Documentation, time management, resource stewardship |
| Patient Safety | 5%* | Red flags, safety checks, follow-up planning |
| Synthesis | — | Combines all passes into overall score and narrative |

*Patient safety can override the overall rating if critical issues are found.

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
- **temperature**: 0.0-1.0 (default: 0.3 for consistent scoring)
- **system_prompt**: AI evaluator identity and principles
- **context_prompt**: Clinical setting and learner context
- **analysis_passes**: JSON array defining the scoring pipeline
- **score_thresholds**: Performance level classification rules
- **validation_rules**: Cross-pass consistency checks

## Requirements

The server must have an AI provider API key set:
- `ANTHROPIC_API_KEY` for Claude models
- `OPENAI_API_KEY` for GPT models
