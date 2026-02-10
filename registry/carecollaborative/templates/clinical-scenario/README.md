---
display_name: Clinical AI Patient
description: AI patient simulator for medical education and clinical skills training
icon: ../../.icons/1f468-200d-2695-fe0f.png
maintainer_github: carecollaborative
verified: true
tags: [healthcare, education, livekit, voice, avatar]
---

# Clinical AI Patient Simulator

Deploy AI-powered patient simulations for medical students to practice clinical skills including history-taking, diagnosis, and treatment planning.

## Features

- **Realistic Patient Interactions**: AI agents simulate diverse patient scenarios with authentic emotional responses
- **Voice-First Interface**: Natural conversational practice via LiveKit real-time audio
- **Cultural Competency**: Patients with diverse backgrounds and health beliefs
- **Avatar Support**: Optional Tavus avatar for visual patient representation
- **Dynamic Profiles**: Load different patient personas for varied training scenarios

## Prerequisites

### Infrastructure

The VM you run Lattice on must have a running Docker socket:

```sh
# Add lattice user to Docker group
sudo adduser lattice docker
sudo systemctl restart lattice
```

### API Keys

Configure your AI and voice providers:

```sh
# Required
export OPENAI_API_KEY="your-openai-key"
export LIVEKIT_URL="wss://your-livekit.livekit.cloud"
export LIVEKIT_API_KEY="your-livekit-key"
export LIVEKIT_API_SECRET="your-livekit-secret"

# Optional - for avatar support
export TAVUS_API_KEY="your-tavus-key"
export TAVUS_REPLICA_ID="your-replica-id"
export TAVUS_PERSONA_ID="your-persona-id"
```

## Architecture

This template provisions:

- Pre-built container image with LiveKit agents SDK
- Voice pipeline (STT, LLM, TTS) configured via environment variables
- Dynamic patient persona injected at runtime via Terraform variables
- Optional Tavus avatar integration
- Persistent storage for session data

## Patient Profile Configuration

Customize the patient persona via Terraform variables:

```hcl
# terraform.tfvars
patient_name               = "Maria Santos"
patient_age                = 58
patient_gender             = "female"
patient_cultural_background = "Filipino-American"
patient_diagnosis          = "Type 2 Diabetes with hypertension"
patient_emotional_state    = "Anxious about medication side effects"
patient_health_literacy    = "Moderate"
patient_symptoms           = ["fatigue", "increased thirst", "frequent urination"]
patient_medical_history    = ["Hypertension diagnosed 5 years ago"]
patient_medications        = ["Lisinopril 10mg daily"]
patient_allergies          = ["Penicillin - causes rash"]
patient_introduction       = "Hello doctor. I'm here because my sugar levels are too high."
```

## Use Cases

- **Medical Student Training**: Practice clinical interviews and examinations
- **OSCE Preparation**: Standardized patient encounters for exam preparation
- **Communication Skills**: Improve bedside manner and patient communication
- **Diagnostic Reasoning**: Practice differential diagnosis and clinical decision-making

## Getting Started

1. Create a new workspace from this template
2. Configure your API credentials in the workspace
3. Optionally customize `persona.json` with your patient profile
4. Launch the agent to start clinical simulations

Built for medical education and clinical skills training.
