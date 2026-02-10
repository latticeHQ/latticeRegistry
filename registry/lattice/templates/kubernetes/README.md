---
display_name: Agent Definition on Kubernetes
description: Deploy containerized agents on Kubernetes
icon: ../../.icons/k8s.png
maintainer_github: lattice
verified: true
tags: [kubernetes]
---

# Agent Definition on Kubernetes

Deploy containerized AI agents on Kubernetes with this agent definition template.

<!-- TODO: Add screenshot -->

## Prerequisites

### Infrastructure

**Cluster**: This template requires an existing Kubernetes cluster

**Container Image**: This template uses the [latticecom/enterprise-base:ubuntu image](https://github.com/latticeHQ/enterprise-images/tree/main/images/base) with some dev tools preinstalled. To add additional tools, extend this image or build it yourself.

### Authentication

This template authenticates using a `~/.kube/config`, if present on the server, or via built-in authentication if the Lattice provisioner is running on Kubernetes with an authorized ServiceAccount. To use another [authentication method](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#authentication), edit the template.

## Architecture

This agent definition provisions the following resources:

- Kubernetes pod (ephemeral)
- Kubernetes persistent volume claim (persistent on `/home/lattice`)

When the workspace restarts, any tools or files outside of the home directory are not persisted. To pre-bake tools into the agent environment (e.g. `python3`), modify the container image.

> **Note**
> This template is designed to be a starting point! Edit the Terraform to extend the template to support your agent use case.
