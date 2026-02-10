---
display_name: Workplace Employee Simulator
description: AI employee simulator for HR training and workplace scenario practice
icon: ../../.icons/1f4bc.png
maintainer_github: carecollaborative
verified: true
tags: [workplace, hr, training, livekit, voice, avatar]
---

# Workplace Employee Simulator

Deploy AI-powered employee simulations for HR professionals and managers to practice workplace scenarios including harassment complaints, performance feedback, conflict resolution, and more.

## Features

- **Realistic Employee Interactions**: AI agents simulate diverse workplace scenarios with authentic emotional responses
- **Voice-First Interface**: Natural conversational practice via LiveKit real-time audio
- **Cultural Competency**: Employees with diverse backgrounds and workplace perspectives
- **Avatar Support**: Optional Tavus avatar for visual employee representation
- **Dynamic Profiles**: Load different employee personas for varied training scenarios
- **Scenario Types**: Sexual harassment, performance feedback, conflict resolution, microaggressions, and more

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
- Dynamic employee persona injected at runtime via Terraform variables
- Optional Tavus avatar integration
- Persistent storage for session data

## Employee Profile Configuration

Customize the employee persona via Terraform variables:

```hcl
# terraform.tfvars
employee_name               = "Sarah Chen"
employee_age                = 34
employee_gender             = "female"
employee_cultural_background = "Asian-American"
employee_occupation         = "Software Engineer"
employee_job_title          = "Senior Developer"
employee_department         = "Engineering"
employee_tenure             = "3 years"
scenario_type               = "Sexual Harassment"
employee_role               = "Complainant"
employee_situation          = "Reporting inappropriate comments from a colleague"
employee_emotional_state    = "Anxious but determined to report"
employee_concerns           = ["Retaliation", "Not being believed", "Career impact"]
```

## Scenario Types

The simulator supports various workplace training scenarios:

- **Sexual Harassment**: Filing or responding to complaints, conducting interviews
- **Performance Feedback**: Delivering or receiving difficult feedback
- **Conflict Resolution**: Mediating disagreements between colleagues
- **Workplace Microaggressions**: Experiencing or addressing subtle bias
- **Political Discussions**: Navigating inappropriate political conversations
- **Ethical Dilemmas**: Handling situations with competing interests
- **Change Management**: Responding to organizational changes
- **Onboarding**: New employee orientation scenarios

## Use Cases

- **HR Professional Training**: Practice conducting sensitive workplace investigations
- **Manager Development**: Improve skills in delivering feedback and handling complaints
- **Compliance Training**: Realistic scenarios for workplace policy training
- **Leadership Development**: Practice difficult conversations and conflict resolution
- **DEI Training**: Cultural competency and bias awareness practice

## Getting Started

1. Create a new workspace from this template
2. Configure your API credentials in the workspace
3. Customize the employee profile variables for your scenario
4. Launch the agent to start workplace simulations

Built for HR training and workplace scenario practice.
