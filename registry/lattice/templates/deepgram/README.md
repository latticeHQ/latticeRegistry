---
display_name: Agent Definition with Deepgram
description: Deploy speech-to-text agents with Deepgram real-time API
icon: ../.icons/deepgram.svg
maintainer_github: wirtualdev
verified: true
tags: [voice, stt, realtime]
---

# Agent Definition with Deepgram

Deploy real-time speech-to-text agents using Deepgram's industry-leading transcription API.

## Features

- **Real-Time Transcription**: Ultra-low latency streaming STT
- **High Accuracy**: Best-in-class transcription quality
- **Multi-Language**: Support for 30+ languages
- **Speaker Diarization**: Identify different speakers

## Prerequisites

### Infrastructure

Requires Docker-enabled environment or cloud VM.

```sh
# Add wirtual user to Docker group
sudo adduser wirtual docker
sudo systemctl restart wirtual
```

### API Keys

Set your Deepgram API key:

```sh
export DEEPGRAM_API_KEY="your-api-key-here"
```

Get your API key from: https://console.deepgram.com/

## Architecture

This agent definition provisions:

- Python environment with Deepgram SDK
- Pre-configured real-time transcription pipeline
- WebSocket support for streaming audio
- Sample agent code for speech recognition

> **Note**: Edit the Terraform to customize transcription models and features.

## Getting Started

1. Create a new workspace from this template
2. Configure your Deepgram API key
3. Start building speech-to-text agents

Built with [Deepgram](https://deepgram.com)
