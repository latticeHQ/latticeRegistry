---
display_name: "Docker Container"
description: "Develop in a container on a Docker host"
icon: "https://github.com/latticeHQ/registry/pull/599.jpeg"
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
```
