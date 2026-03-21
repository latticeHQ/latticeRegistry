---
display_name: OSCE Clinical Examination
description: AI-powered OSCE station feedback using Calgary-Cambridge and Kalamazoo frameworks
icon: ../../.icons/1f468-200d-2695-fe0f.png
maintainer_github: lattice
verified: true
tags: [evaluation, healthcare, osce, clinical-skills]
---

# OSCE Feedback Template

Stanford-grade Objective Structured Clinical Examination (OSCE) feedback template for the Lattice evaluation engine.

## Category

`evaluation` — non-provisioned, no infrastructure created.

## Overview

This template configures an AI-powered OSCE examiner that scores standardized patient encounters across six dimensions, calibrated to Stanford Medicine's Clinical Skills Assessment standards.

## Frameworks

- Stanford Medicine Clinical Skills Assessment criteria
- Kalamazoo Communication Assessment model
- Calgary-Cambridge Guide to the Medical Interview
- ACGME Core Competencies
- NURSE empathy framework

## Analysis Passes

| Pass | Weight | Focus |
|------|--------|-------|
| Data Gathering | 30% | History taking, question technique, OLDCARTS/OPQRST, red flag screening |
| Physical Examination | 15% | Exam technique, systems examined, patient comfort, finding interpretation |
| Clinical Reasoning | 20% | Differential quality, Bayesian updating, diagnostic plan, evidence-based approach |
| Communication | 20% | Calgary-Cambridge markers, Kalamazoo items, NURSE empathy, teach-back |
| Patient Management | 10% | Treatment plan, safety netting, follow-up, shared decision-making |
| Synthesis | 5% | Overall score, station pass/fail, global rating, recommendations |

## Score Thresholds

| Score | Classification |
|-------|---------------|
| 9.0+ | Honors |
| 7.5+ | Pass with Distinction |
| 6.0+ | Pass |
| 4.5+ | Borderline |
| 0-4.5 | Below Expectations |

## Defaults

- **Provider**: Anthropic
- **Model**: claude-sonnet-4-5-20250929
- **Temperature**: 0.2
