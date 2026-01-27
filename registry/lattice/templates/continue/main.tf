terraform {
  required_providers {
    lattice = {
      source = "latticehq/lattice"
    }
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

locals {
  username = data.lattice_agent_owner.me.name
}

variable "docker_socket" {
  default     = ""
  description = "(Optional) Docker socket URI"
  type        = string
}

provider "docker" {
  host = var.docker_socket != "" ? var.docker_socket : null
}

data "lattice_provisioner" "me" {}
data "lattice_agent" "me" {}
data "lattice_agent_owner" "me" {}

resource "lattice_agent" "main" {
  arch           = data.lattice_provisioner.me.arch
  os             = "linux"
  startup_script = <<-EOT
    set -e

    # Prepare user home with default files on first start.
    if [ ! -f ~/.init_done ]; then
      cp -rT /etc/skel ~
      touch ~/.init_done
    fi

    # Install code-server with Continue extension
    curl -fsSL https://code-server.dev/install.sh | sh -s -- --method=standalone --prefix=/tmp/code-server

    # Install Continue extension
    /tmp/code-server/bin/code-server --install-extension continue.continue

    # Start code-server
    /tmp/code-server/bin/code-server --auth none --port 13337 >/tmp/code-server.log 2>&1 &
  EOT

  env = {
    GIT_AUTHOR_NAME     = coalesce(data.lattice_agent_owner.me.full_name, data.lattice_agent_owner.me.name)
    GIT_AUTHOR_EMAIL    = "${data.lattice_agent_owner.me.email}"
    GIT_COMMITTER_NAME  = coalesce(data.lattice_agent_owner.me.full_name, data.lattice_agent_owner.me.name)
    GIT_COMMITTER_EMAIL = "${data.lattice_agent_owner.me.email}"
  }

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

  metadata {
    display_name = "Home Disk"
    key          = "3_home_disk"
    script       = "lattice stat disk --path $${HOME}"
    interval     = 60
    timeout      = 1
  }
}

resource "lattice_app" "continue" {
  sidecar_id     = lattice_agent.main.id
  slug         = "continue"
  display_name = "Continue (VSCode)"
  url          = "http://localhost:13337"
  icon         = "/icon/continue.svg"
  subdomain    = false
  share        = "owner"

  healthcheck {
    url       = "http://localhost:13337/healthz"
    interval  = 5
    threshold = 6
  }
}
