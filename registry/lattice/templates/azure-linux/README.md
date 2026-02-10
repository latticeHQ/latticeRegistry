---
display_name: Agent Definition on Azure (Linux)
description: Deploy Linux-based agents on Azure VMs
icon: ../../.icons/azure.png
maintainer_github: lattice
verified: true
tags: [linux, azure]
---

# Agent Definition on Azure (Linux)

Deploy Linux-based AI agents on Azure VMs with this agent definition template.

<!-- TODO: Add screenshot -->

## Prerequisites

### Authentication

This template assumes that latticed is run in an environment that is authenticated
with Azure. For example, run `az login` then `az account set --subscription=<id>`
to import credentials on the system and user running latticed. For other ways to
authenticate, [consult the Terraform docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure).

## Architecture

This agent definition provisions the following resources:

- Azure VM (ephemeral, deleted on stop)
- Managed disk (persistent, mounted to `/home/lattice`)

When the workspace restarts, any tools or files outside of the home directory are not persisted. To pre-bake tools into the agent environment (e.g. `python3`), modify the VM image or use a [startup script](https://registry.terraform.io/providers/latticehq/lattice/latest/docs/resources/script).

> **Note**
> This template is designed to be a starting point! Edit the Terraform to extend the template to support your agent use case.
