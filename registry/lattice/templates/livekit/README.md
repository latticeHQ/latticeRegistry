---
display_name: Agent Definition with LiveKit
description: Deploy real-time voice/video agents with LiveKit infrastructure
icon: ../../.icons/livekit.svg
maintainer_github: latticeHQ
verified: true
tags: [voice, framework, realtime]
---

# Agent Definition with LiveKit

Deploy real-time voice and video agents using LiveKit's open-source WebRTC infrastructure.

## Features

- **Real-Time Communication**: Ultra-low latency voice and video
- **Scalable Infrastructure**: Production-ready WebRTC SFU
- **Agent Framework**: Built-in support for AI agents with voice
- **Multi-Modal**: Combine voice, video, and data streams

## Prerequisites

### Infrastructure

Requires Docker for running LiveKit server locally, or use LiveKit Cloud.

```sh
# Add lattice user to Docker group
sudo adduser lattice docker
sudo systemctl restart lattice
```

### API Keys

Set your LiveKit credentials:

```sh
export LIVEKIT_URL="wss://your-livekit.livekit.cloud"
export LIVEKIT_API_KEY="your-api-key"
export LIVEKIT_API_SECRET="your-api-secret"
```

## Architecture

This agent definition provisions:

- LiveKit server (local or cloud)
- Python environment with livekit-agents SDK
- Pre-configured voice pipeline (STT, LLM, TTS)
- WebRTC infrastructure for real-time audio

> **Note**: Edit the Terraform to customize the LiveKit agent pipeline and voice models.

## Getting Started

1. Create a new workspace from this template
2. Configure your LiveKit credentials
3. Deploy voice-enabled AI agents

Built with [LiveKit](https://livekit.io) - YC W21
