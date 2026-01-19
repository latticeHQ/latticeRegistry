---
display_name: Agent Definition with Cursor
description: Deploy AI agents with Cursor IDE pre-configured
icon: ../.icons/cursor.svg
maintainer_github: wirtualdev
verified: true
tags: [ide, vibe-coding]
---

# Agent Definition with Cursor

Deploy AI coding agents with Cursor, the AI-first code editor built on VSCode.

## Features

- **AI-First Editing**: Native AI integration with Cmd+K for inline editing
- **Codebase Context**: AI that understands your entire codebase
- **Multi-Model Support**: Switch between GPT-4, Claude, and other models
- **VSCode Compatible**: All your favorite extensions work out of the box

## Prerequisites

### Infrastructure

Requires a Docker-enabled environment. The VM running Wirtual must have:

```sh
# Add wirtual user to Docker group
sudo adduser wirtual docker
sudo systemctl restart wirtual
```

### API Keys

Set your Cursor API key as an environment variable:

```sh
export CURSOR_API_KEY="your-api-key-here"
```

## Architecture

This agent definition provisions:

- Docker container with Cursor IDE pre-installed
- Pre-configured AI settings and preferences
- Persistent home directory for projects and settings
- Web-based access to Cursor IDE

> **Note**: Edit the Terraform to customize the Cursor configuration for your specific use case.

## Getting Started

1. Create a new workspace from this template
2. Configure your Cursor API key
3. Start coding with AI assistance

Built with [Cursor](https://cursor.sh) - YC W23
