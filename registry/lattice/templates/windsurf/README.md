---
display_name: Agent Definition with Windsurf
description: Deploy AI agents with Windsurf and Cascade AI assistant
icon: ../../.icons/windsurf.svg
maintainer_github: latticeHQ
verified: true
tags: [ide, vibe-coding]
---

# Agent Definition with Windsurf

Deploy AI coding agents with Windsurf, Codeium's AI editor featuring the Cascade AI assistant.

## Features

- **Cascade AI**: Multi-step AI reasoning and planning
- **Context Awareness**: Deep understanding of your codebase
- **Real-time Collaboration**: AI pair programming experience
- **Built on VSCode**: Familiar interface with AI superpowers

## Prerequisites

### Infrastructure

Requires a Docker-enabled environment. The VM running Lattice must have:

```sh
# Add lattice user to Docker group
sudo adduser lattice docker
sudo systemctl restart lattice
```

### API Keys

Windsurf uses Codeium's API (free for individual developers):

```sh
export CODEIUM_API_KEY="your-api-key-here"
```

## Architecture

This agent definition provisions:

- Docker container with Windsurf IDE pre-installed
- Pre-configured Cascade AI assistant
- Persistent home directory for projects and settings
- Web-based access to Windsurf IDE

> **Note**: Edit the Terraform to customize the Windsurf configuration for your specific use case.

## Getting Started

1. Create a new workspace from this template
2. Sign in to Codeium (free for individuals)
3. Start coding with Cascade AI assistant

Built with [Windsurf](https://codeium.com/windsurf)
