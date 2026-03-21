---
display_name: Surgical Skills Assessment
description: AI-powered surgical feedback using ACGME Surgery Milestones, WHO Checklist, and NOTSS
icon: ../../.icons/1f468-200d-2695-fe0f.png
maintainer_github: lattice
verified: true
tags: [evaluation, healthcare, surgery, epa]
---

# Surgery Evaluation Template

Stanford-grade Surgical Skills & Pre-operative Assessment feedback template.

## Category

`evaluation` (non-provisioned, no infrastructure)

## Overview

This template configures an AI feedback pipeline for surgical skills and pre-operative assessment transcripts. It uses a multi-pass analysis approach based on established surgical education frameworks:

- **ACGME Surgery Milestones 2.0** for competency benchmarking
- **Entrustable Professional Activities (EPAs) for Surgery** for entrustment-level classification
- **WHO Surgical Safety Checklist** for safety systems feedback
- **NOTSS (Non-Technical Skills for Surgeons)** for non-technical skill assessment
- **Surgical timeout and informed consent frameworks** for procedural safety

## Analysis Passes

| Pass | Weight | Focus |
|------|--------|-------|
| Preoperative Assessment | 25% | Surgical history, indications, ASA classification, consent elements, NPO, medications, thromboprophylaxis |
| Surgical Decision-Making | 25% | Indication appropriateness, timing, approach selection, evidence-based planning, risk stratification |
| Communication & Consent | 20% | Stanford 5-element informed consent, patient understanding, family communication, surgical brief, teach-back |
| Safety Systems | 15% | WHO checklist, patient ID, site marking, antibiotics, equipment, blood availability, time-out, fire risk |
| Postoperative Planning | 10% | Post-op orders, pain management, DVT prophylaxis, diet, activity, wound care, follow-up, discharge criteria |
| Synthesis | 5% | Overall EPA entrustment level, NOTSS equivalent, strengths, improvements, learning goals |

## EPA Entrustment Levels

| Score | Level | Description |
|-------|-------|-------------|
| 9.0+  | 5 | Can supervise others |
| 7.5+  | 4 | Can practice independently |
| 6.0+  | 3 | Can execute with reactive supervision |
| 4.0+  | 2 | Can execute with proactive supervision |
| 0-4.0 | 1 | Observation only |

## Default Configuration

- **Model**: claude-sonnet-4-5-20250929
- **Temperature**: 0.2
- **Max Tokens**: 4096
