---
display_name: "Docker Container"
description: "Develop in a container on a Docker host"
icon: "../../../../.icons/docker.svg"
verified: true
tags: ["docker", "container"]
supported_os: ["linux", "macos"]
---

# Docker Container

Develop in a Docker container on a remote Docker host.

```tf
terraform {
  required_providers {
    lattice = {
      source  = "latticeHQ/lattice"
      version = "~> 1.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

provider "lattice" {}

data "lattice_agent" "me" {}

resource "lattice_agent" "main" {
  os   = "linux"
  arch = "amd64"
}

resource "docker_container" "workspace" {
  image = "lattice/enterprise-base:ubuntu"
  name  = "lattice-${data.lattice_agent.me.owner}-${data.lattice_agent.me.name}"

  env = ["LATTICE_SIDECAR_TOKEN=${lattice_agent.main.token}"]
}
```

## Getting Started

This template creates a Docker container on your Docker host. You'll need:

- A Docker host accessible from your Lattice deployment
- The Docker provider configured with appropriate credentials

## Customization

You can customize the container image, resources, and configuration to match your needs.
