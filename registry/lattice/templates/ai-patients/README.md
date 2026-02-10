---
display_name: AI Patients for Medical Training
description: Interactive AI patient simulations for medical students to practice clinical skills
icon: ../../.icons/1f468-200d-2695-fe0f.png
maintainer_github: lattice
verified: true
tags: [docker, healthcare, education]
---

# AI Patients for Medical Training

Deploy AI-powered patient simulation agents for medical education and clinical skills practice.

## Features

- **Realistic Patient Interactions**: AI agents simulate diverse patient scenarios
- **Clinical Skills Practice**: Medical students practice history-taking, diagnosis, and treatment planning
- **Safe Learning Environment**: Risk-free practice before real patient encounters
- **Adaptive Scenarios**: Dynamic patient responses based on student interactions
- **Performance Tracking**: Automated assessment and feedback on clinical skills

## Prerequisites

### Infrastructure

The VM you run Lattice on must have a running Docker socket and the `lattice` user must be added to the Docker group:

```sh
# Add lattice user to Docker group
sudo adduser lattice docker

# Restart Lattice server
sudo systemctl restart lattice

# Test Docker
sudo -u lattice docker ps
```

### AI Models

Configure your preferred AI model for patient simulation:

```sh
export OPENAI_API_KEY="your-api-key-here"
# or use other models like Claude, Gemini, etc.
```

## Architecture

This agent definition provisions the following resources:

- Docker container with patient simulation environment
- Persistent storage for case histories and student progress
- Web-based interface for clinical interactions
- Assessment and feedback tracking system

This means, when the workspace restarts, all patient cases and student progress are preserved in the home directory.

> **Note**
> This template is designed to be a starting point! Edit the Terraform to extend the template to support your medical education use case.

## Use Cases

- **Medical Student Training**: Practice clinical interviews and examinations
- **OSCE Preparation**: Standardized patient encounters for exam preparation
- **Communication Skills**: Improve bedside manner and patient communication
- **Diagnostic Reasoning**: Practice differential diagnosis and clinical decision-making
- **Continuous Learning**: Track improvement across multiple patient encounters

## Getting Started

1. Create a new workspace from this template
2. Configure your AI model credentials
3. Launch the patient simulation interface
4. Select a patient scenario to practice
5. Review feedback and performance metrics

Built for medical education and clinical skills training.
