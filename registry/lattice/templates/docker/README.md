---
display_name: Agent Definition with Docker
description: Deploy containerized agents using Docker
icon: ../../.icons/docker.png
maintainer_github: lattice
verified: true
tags: [docker]
---

# Agent Definition with Docker

Deploy containerized AI agents using Docker with this agent definition template.

<!-- TODO: Add screenshot -->

## Prerequisites

### Infrastructure

The VM you run Lattice on must have a running Docker socket and the `lattice` user must be added to the Docker group:

```sh
# Add lattice user to Docker group
sudo adduser lattice docker

# Restart Lattice server
sudo systemctl restart lattice

# Test Docker
sudo -u lattice docker ps
```

## Architecture

This agent definition provisions the following resources:

- Docker image (built by Docker socket and kept locally)
- Docker container pod (ephemeral execution environment)
- Docker volume (persistent on `/home/lattice`)

This means, when the workspace restarts, any tools or files outside of the home directory are not persisted. To pre-bake tools into the agent container (e.g. `python3`), modify the container image.

> **Note**
> This template is designed to be a starting point! Edit the Terraform to extend the template to support your agent use case.

### Editing the image

Edit the `Dockerfile` and run `lattice templates push` to update agent definitions.
