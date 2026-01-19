---
display_name: Agent Definition with Continue
description: Deploy AI agents with Continue open-source code assistant
icon: ../.icons/continue.svg
maintainer_github: wirtualdev
verified: true
tags: [ide, vibe-coding, open-source]
---

# Agent Definition with Continue

Deploy AI coding agents with Continue, the open-source AI code assistant for VSCode and JetBrains.

## Features

- **Open Source**: Fully transparent and customizable
- **Model Agnostic**: Use any LLM (OpenAI, Anthropic, local models)
- **Context Control**: Fine-grained control over what the AI sees
- **Privacy First**: Run entirely offline with local models

## Prerequisites

### Infrastructure

Requires a Docker-enabled environment. The VM running Wirtual must have:

```sh
# Add wirtual user to Docker group
sudo adduser wirtual docker
sudo systemctl restart wirtual
```

### API Keys

Configure your preferred LLM provider:

```sh
export OPENAI_API_KEY="your-openai-key"
# or
export ANTHROPIC_API_KEY="your-anthropic-key"
# or use local models (no key needed)
```

## Architecture

This agent definition provisions:

- Docker container with VSCode + Continue extension
- Pre-configured Continue settings
- Support for multiple LLM providers
- Persistent home directory for projects and settings

> **Note**: Edit the Terraform to customize Continue configuration and model preferences.

## Getting Started

1. Create a new workspace from this template
2. Configure your preferred LLM provider
3. Start coding with AI assistance

Built with [Continue](https://continue.dev) - Open Source
