---
display_name: Feedback & Evaluation System
description: AI-powered assessment platform for faculty to evaluate and provide feedback on student performance
icon: ../.icons/1f4cb.png
maintainer_github: wirtual
verified: true
tags: [docker, healthcare, education]
---

# Feedback & Evaluation System

AI-powered evaluation platform for medical faculty to assess student performance and provide structured feedback.

## Features

- **Automated Assessment**: AI-assisted evaluation of student clinical interactions
- **Structured Feedback**: Template-based feedback forms aligned with competencies
- **Performance Analytics**: Track student progress across multiple evaluations
- **Faculty Collaboration**: Share evaluations and calibrate assessments
- **OSCE Support**: Digital scoring and feedback for objective structured clinical examinations

## Prerequisites

### Infrastructure

The VM you run Wirtual on must have a running Docker socket and the `wirtual` user must be added to the Docker group:

```sh
# Add wirtual user to Docker group
sudo adduser wirtual docker

# Restart Wirtual server
sudo systemctl restart wirtual

# Test Docker
sudo -u wirtual docker ps
```

### AI Models

Configure your AI model for assisted evaluation:

```sh
export OPENAI_API_KEY="your-api-key-here"
# or use other models like Claude, Gemini, etc.
```

## Architecture

This agent definition provisions the following resources:

- Docker container with evaluation dashboard
- Persistent storage for evaluations and feedback
- Web-based interface for faculty assessment
- Analytics and reporting system
- Student performance database

This means, when the workspace restarts, all evaluations and feedback data are preserved.

> **Note**
> This template is designed to be a starting point! Edit the Terraform to extend the template to support your evaluation workflow.

## Use Cases

- **Clinical Skills Assessment**: Evaluate student performance in patient encounters
- **OSCE Examinations**: Digital scoring and feedback for standardized exams
- **Competency-Based Assessment**: Track student progress toward clinical competencies
- **Formative Feedback**: Provide timely, constructive feedback for learning
- **Summative Evaluation**: Final assessments for course grades and promotion
- **Faculty Development**: Calibrate evaluation standards across faculty members

## Getting Started

1. Create a new workspace from this template
2. Configure your AI model credentials
3. Launch the evaluation dashboard
4. Review student clinical interactions
5. Provide structured feedback using evaluation forms
6. Generate performance reports and analytics

Built for medical education assessment and faculty evaluation workflows.
