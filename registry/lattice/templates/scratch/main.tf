terraform {
  required_providers {
    lattice = {
      source = "latticehq/lattice"
    }
  }
}

data "lattice_provisioner" "me" {}

data "lattice_agent" "me" {}

resource "lattice_agent" "main" {
  arch = data.lattice_provisioner.me.arch
  os   = data.lattice_provisioner.me.os

  metadata {
    display_name = "CPU Usage"
    key          = "0_cpu_usage"
    script       = "lattice stat cpu"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "RAM Usage"
    key          = "1_ram_usage"
    script       = "lattice stat mem"
    interval     = 10
    timeout      = 1
  }
}

# Use this to set environment variables in your workspace
# details: https://registry.terraform.io/providers/lattice/lattice/latest/docs/resources/env
resource "lattice_env" "welcome_message" {
  sidecar_id = lattice_agent.main.id
  name     = "WELCOME_MESSAGE"
  value    = "Welcome to your Lattice workspace!"
}

# Adds code-server
# See all available modules at https://registry.latticeruntime.com
module "code-server" {
  source   = "registry.latticeruntime.com/modules/code-server/lattice"
  version  = "1.0.2"
  sidecar_id = lattice_agent.main.id
}

# Runs a script at workspace start/stop or on a cron schedule
# details: https://registry.terraform.io/providers/lattice/lattice/latest/docs/resources/script
resource "lattice_script" "startup_script" {
  sidecar_id           = lattice_agent.main.id
  display_name       = "Startup Script"
  script             = <<-EOF
    #!/bin/sh
    set -e
    # Run programs at workspace startup
  EOF
  run_on_start       = true
  start_blocks_login = true
}
