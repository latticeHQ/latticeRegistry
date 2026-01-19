---
display_name: Agent Definition with ElevenLabs
description: Deploy voice agents with ElevenLabs text-to-speech
icon: ../.icons/elevenlabs.svg
maintainer_github: wirtualdev
verified: true
tags: [voice, tts]
---

# Agent Definition with ElevenLabs

Deploy voice-enabled AI agents using ElevenLabs' industry-leading text-to-speech API.

## Features

- **Natural Voices**: Most realistic AI voices available
- **Voice Cloning**: Create custom voices from samples
- **Multi-Language**: Support for 29+ languages
- **Low Latency**: Streaming TTS for real-time applications

## Prerequisites

### Infrastructure

Requires Docker-enabled environment or cloud VM.

```sh
# Add wirtual user to Docker group
sudo adduser wirtual docker
sudo systemctl restart wirtual
```

### API Keys

Set your ElevenLabs API key:

```sh
export ELEVENLABS_API_KEY="your-api-key-here"
```

Get your API key from: https://elevenlabs.io/app/settings/api-keys

## Architecture

This agent definition provisions:

- Python environment with ElevenLabs SDK
- Pre-configured voice synthesis pipeline
- Sample agent code for voice generation
- WebSocket support for streaming TTS

> **Note**: Edit the Terraform to customize voice IDs and synthesis settings.

## Getting Started

1. Create a new workspace from this template
2. Configure your ElevenLabs API key
3. Start building voice-enabled agents

Built with [ElevenLabs](https://elevenlabs.io)
