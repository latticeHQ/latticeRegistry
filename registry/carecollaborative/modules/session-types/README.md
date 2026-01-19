---
display_name: "Session Types"
description: "Evaluation session type definitions for clinical, workplace, and observation scenarios"
icon: "../../../../.icons/layout.svg"
verified: false
tags: ["sessions", "healthcare", "education", "training", "evaluation"]
---

# Session Types

This module defines the evaluation session types supported by the CareCollaborative platform. Each session type configures the available features, required agents, and role permissions.

## Features

- Pre-defined session types for clinical, workplace, and observation scenarios
- Role-based access control per session type
- Feature flags for transcript, assessment, feedback, and avatar support
- JSON output for API consumption

## Usage

### Basic Usage

```tf
module "session_types" {
  source  = "registry.latticeruntime.com/carecollaborative/session-types/lattice"
  version = "1.0.0"
}

# Get all session types as JSON
output "all_session_types" {
  value = module.session_types.session_types_json
}
```

### Custom Session Types

```tf
module "custom_sessions" {
  source  = "registry.latticeruntime.com/carecollaborative/session-types/lattice"
  version = "1.0.0"

  session_types = [
    {
      id              = "nursing-skills"
      name            = "Nursing Skills Lab"
      description     = "Nursing student procedural skills training"
      icon            = "clipboard"
      requires_persona = true
      has_transcriber = true
      has_avatar      = false
      default_agents  = ["transcriber-v1"]
      allowed_roles   = ["nursing-student", "faculty", "admin"]
      features        = ["transcript", "checklist", "skills-assessment"]
    }
  ]
}
```

## Default Session Types

| ID | Name | Description |
|----|------|-------------|
| `clinical` | Clinical Training | Student-AI patient interaction for medical education |
| `workplace` | Workplace Training | Employee-AI employee training simulation |
| `observation` | Faculty Observation | Faculty-student interaction with transcription only |

## Session Type Schema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Unique identifier |
| `name` | string | yes | Display name |
| `description` | string | yes | Brief description |
| `icon` | string | yes | Icon identifier |
| `requires_persona` | bool | yes | Whether persona selection is required |
| `has_transcriber` | bool | yes | Whether transcriber agent is included |
| `has_avatar` | bool | yes | Whether Tavus avatar is enabled |
| `default_agents` | list(string) | yes | Agents auto-dispatched to sessions |
| `allowed_roles` | list(string) | yes | Roles permitted to create sessions |
| `features` | list(string) | no | Feature flags for the session |

## Outputs

| Name | Description |
|------|-------------|
| `session_types` | List of session type objects |
| `session_types_json` | JSON string for API consumption |
| `session_type_ids` | List of session type IDs |
| `session_type_lookup` | Map for looking up by ID |
| `persona_required_types` | Session types requiring persona selection |
| `avatar_enabled_types` | Session types with avatar support |

## Integration Example

```go
// Go backend - serve session types from terraform output
func getSessionTypes(w http.ResponseWriter, r *http.Request) {
    sessionTypes := terraformOutput["session_types_json"]
    w.Header().Set("Content-Type", "application/json")
    w.Write([]byte(sessionTypes))
}
```

```typescript
// Frontend - fetch session types dynamically
const sessionTypes = await fetch('/api/session-types').then(r => r.json());

// Check if persona selection is needed
const needsPersona = sessionTypes.find(st => st.id === selectedType)?.requires_persona;
```
