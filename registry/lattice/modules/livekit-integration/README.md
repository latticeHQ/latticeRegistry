---
display_name: "LiveKit Integration"
description: "Real-time audio/video communication for AI agents with Lattice Runtime"
icon: "../../../../.icons/livekit.svg"
verified: true
tags: ["integration", "livekit", "realtime", "voice", "video", "webrtc"]
---

# LiveKit Integration

This module provides seamless integration between Lattice Runtime and LiveKit for building real-time voice and video AI agent applications.

## Features

- Real-time voice AI agent support
- Video streaming capabilities
- WebRTC infrastructure integration
- Agent-to-agent communication
- Low-latency audio processing

## Usage

```tf
module "livekit" {
  source   = "registry.latticeruntime.com/lattice/livekit-integration/lattice"
  version  = "1.0.0"
  sidecar_id = lattice_agent.main.id

  # Configure LiveKit integration
  enable_voice     = true
  enable_video     = false
  room_prefix      = "agent"

  # Audio configuration
  sample_rate      = 48000
  channels         = 1

  # Agent capabilities
  capabilities = [
    "voice_activity_detection",
    "speech_to_text",
    "text_to_speech"
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `sidecar_id` | The ID of the Lattice agent | `string` | - | yes |
| `enable_voice` | Enable voice communication | `bool` | `true` | no |
| `enable_video` | Enable video communication | `bool` | `false` | no |
| `room_prefix` | Prefix for LiveKit room names | `string` | `"lattice"` | no |
| `sample_rate` | Audio sample rate in Hz | `number` | `48000` | no |
| `channels` | Number of audio channels | `number` | `1` | no |
| `capabilities` | List of agent capabilities | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| `room_url` | The LiveKit room connection URL |
| `websocket_endpoint` | The WebSocket endpoint for real-time communication |
