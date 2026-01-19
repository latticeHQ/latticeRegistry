---
display_name: Agent Definition with Cartesia
description: Deploy ultra-fast voice agents with Cartesia neural TTS
icon: ../.icons/cartesia.svg
maintainer_github: wirtualdev
verified: true
tags: [voice, tts, realtime]
---

# Agent Definition with Cartesia

Deploy ultra-fast voice agents using Cartesia's neural voice synthesis with sub-100ms latency.

## Features

- **Ultra-Low Latency**: Sub-100ms time-to-first-audio
- **Real-Time Streaming**: Perfect for conversational agents
- **Natural Voices**: High-quality neural voice synthesis
- **Sonic Framework**: Built on state-of-the-art voice models

## Prerequisites

### Infrastructure

Requires Docker-enabled environment or cloud VM.

```sh
# Add wirtual user to Docker group
sudo adduser wirtual docker
sudo systemctl restart wirtual
```

### API Keys

Set your Cartesia API key:

```sh
export CARTESIA_API_KEY="your-api-key-here"
```

Get your API key from: https://cartesia.ai

## Architecture

This agent definition provisions:

- Python environment with Cartesia SDK
- Pre-configured ultra-fast TTS pipeline
- WebSocket support for streaming audio
- Sample agent code for real-time voice synthesis

> **Note**: Edit the Terraform to customize voice models and synthesis parameters.

## Getting Started

1. Create a new workspace from this template
2. Configure your Cartesia API key
3. Build ultra-responsive voice agents

Built with [Cartesia](https://cartesia.ai) - YC W24
