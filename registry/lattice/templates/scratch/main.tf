terraform {
  required_providers {
    wirtual = {
      source = "wirtualdev/wirtual"
    }
  }
}

data "wirtual_provisioner" "me" {}

data "wirtual_workspace" "me" {}

resource "wirtual_agent" "main" {
  arch = data.wirtual_provisioner.me.arch
  os   = data.wirtual_provisioner.me.os

  metadata {
    display_name = "CPU Usage"
    key          = "0_cpu_usage"
    script       = "wirtual stat cpu"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "RAM Usage"
    key          = "1_ram_usage"
    script       = "wirtual stat mem"
    interval     = 10
    timeout      = 1
  }
}

# Use this to set environment variables in your workspace
# details: https://registry.terraform.io/providers/wirtual/wirtual/latest/docs/resources/env
resource "wirtual_env" "welcome_message" {
  agent_id = wirtual_agent.main.id
  name     = "WELCOME_MESSAGE"
  value    = "Welcome to your Wirtual workspace!"
}

# Adds code-server
# See all available modules at https://registry.wirtual.dev
module "code-server" {
  source   = "registry.wirtual.dev/modules/code-server/wirtual"
  version  = "1.0.2"
  agent_id = wirtual_agent.main.id
}

# Runs a script at workspace start/stop or on a cron schedule
# details: https://registry.terraform.io/providers/wirtual/wirtual/latest/docs/resources/script
resource "wirtual_script" "startup_script" {
  agent_id           = wirtual_agent.main.id
  display_name       = "Startup Script"
  script             = <<-EOF
    #!/bin/sh
    set -e
    # Run programs at workspace startup
  EOF
  run_on_start       = true
  start_blocks_login = true
}
