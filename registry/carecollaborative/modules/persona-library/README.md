---
display_name: "Persona Library"
description: "Dynamic AI persona definitions for medical education and workplace training simulations"
icon: "../../../../.icons/users.svg"
verified: false
tags: ["personas", "healthcare", "education", "training", "ai-agents", "livekit"]
---

# Persona Library

This module provides a dynamic persona library for AI-powered training simulations. Define and manage AI patient personas for medical education and AI employee personas for workplace training.

## Features

- Dynamic persona definitions with demographics and configuration
- Filter personas by session type (clinical, workplace, observation)
- Tag-based filtering for specialized scenarios
- JSON output for API consumption
- Supports LiveKit agent dispatch metadata

## Usage

### Basic Usage

```tf
module "personas" {
  source       = "registry.latticeruntime.com/carecollaborative/persona-library/lattice"
  version      = "1.0.0"
  session_type = "clinical"
}

# Get all clinical personas
output "clinical_personas" {
  value = module.personas.personas_json
}
```

### Filter by Tags

```tf
module "cardiac_personas" {
  source       = "registry.latticeruntime.com/carecollaborative/persona-library/lattice"
  version      = "1.0.0"
  session_type = "clinical"
  filter_tags  = ["cardiology"]
}
```

### Custom Personas

```tf
module "custom_personas" {
  source       = "registry.latticeruntime.com/carecollaborative/persona-library/lattice"
  version      = "1.0.0"
  session_type = "clinical"

  personas = [
    {
      id           = "diabetic-patient-v1"
      dispatch_name = "clinical-v1"
      name         = "Diabetic Patient"
      description  = "Patient with Type 2 diabetes for endocrinology training"
      session_type = "clinical"
      icon         = "activity"
      tags         = ["patient", "clinical", "endocrinology", "diabetes"]
      demographics = {
        age        = 52
        gender     = "male"
        ethnicity  = "hispanic"
        occupation = "restaurant owner"
      }
      config = {
        model        = "gpt-4o"
        temperature  = 0.7
        instructions = "You are a patient with poorly controlled Type 2 diabetes. Express concerns about medication side effects."
        voice        = "echo"
      }
    }
  ]
}
```

## Session Types

| Type | Description |
|------|-------------|
| `clinical` | Student-AI patient interactions for medical training |
| `workplace` | Employee-AI employee training simulations |
| `observation` | Faculty-student interactions with transcription only |

## Persona Schema

Each persona definition includes:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Unique identifier for the persona |
| `dispatch_name` | string | yes | LiveKit agent dispatch name |
| `name` | string | yes | Display name |
| `description` | string | yes | Brief description |
| `session_type` | string | yes | One of: clinical, workplace, observation |
| `icon` | string | no | Icon identifier |
| `avatar_id` | string | no | Tavus avatar ID |
| `tags` | list(string) | no | Tags for filtering |
| `demographics` | object | no | Age, gender, ethnicity, occupation |
| `config` | object | no | AI model configuration |

### Config Object

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `model` | string | "gpt-4o" | AI model to use |
| `temperature` | number | 0.7 | Response creativity (0-1) |
| `max_tokens` | number | 4000 | Max response tokens |
| `instructions` | string | "" | System instructions for the persona |
| `voice` | string | "alloy" | TTS voice identifier |

## Outputs

| Name | Description |
|------|-------------|
| `personas` | List of persona objects matching filters |
| `personas_json` | JSON string of filtered personas |
| `persona_ids` | List of persona IDs |
| `persona_count` | Number of matching personas |
| `persona_lookup` | Map for looking up personas by ID |

## Integration with Backend API

The `personas_json` output can be served directly via your backend API:

```go
// Go backend example
func getPersonas(sessionType string) ([]byte, error) {
    // Parse terraform output
    personas := terraformOutput["personas_json"]
    return json.Marshal(personas)
}
```

Your frontend can then fetch personas dynamically:

```typescript
// Frontend example
const personas = await fetch(`/api/personas?session_type=clinical`).then(r => r.json());
```
