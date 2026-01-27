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
  # Defaulting to null if the variable is an empty string lets us have an optional variable without having to set our own default
  host = var.docker_socket != "" ? var.docker_socket : null
}

data "lattice_provisioner" "me" {}
data "lattice_agent" "me" {}
data "lattice_agent_owner" "me" {}

resource "lattice_sidecar" "main" {
  arch           = data.lattice_provisioner.me.arch
  os             = "linux"
  startup_script = <<-EOT
    set -e

    # Prepare user home with default files on first start.
    if [ ! -f ~/.init_done ]; then
      cp -rT /etc/skel ~
      touch ~/.init_done
    fi

    # Install the latest code-server.
    # Append "--version x.x.x" to install a specific version of code-server.
    curl -fsSL https://code-server.dev/install.sh | sh -s -- --method=standalone --prefix=/tmp/code-server

    # Start code-server in the background.
    /tmp/code-server/bin/code-server --auth none --port 13337 >/tmp/code-server.log 2>&1 &
  EOT

  # These environment variables allow you to make Git commits right away after creating a
  # workspace. Note that they take precedence over configuration defined in ~/.gitconfig!
  # You can remove this block if you'd prefer to configure Git manually or using
  # dotfiles. (see docs/dotfiles.md)
  env = {
    GIT_AUTHOR_NAME     = coalesce(data.lattice_agent_owner.me.full_name, data.lattice_agent_owner.me.name)
    GIT_AUTHOR_EMAIL    = "${data.lattice_agent_owner.me.email}"
    GIT_COMMITTER_NAME  = coalesce(data.lattice_agent_owner.me.full_name, data.lattice_agent_owner.me.name)
    GIT_COMMITTER_EMAIL = "${data.lattice_agent_owner.me.email}"
  }

  # The following metadata blocks are optional. They are used to display
  # information about your workspace in the dashboard. You can remove them
  # if you don't want to display any information.
  # For basic resources, you can use the `lattice stat` command.
  # If you need more control, you can write your own script.
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

  metadata {
    display_name = "CPU Usage (Host)"
    key          = "4_cpu_usage_host"
    script       = "lattice stat cpu --host"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Memory Usage (Host)"
    key          = "5_mem_usage_host"
    script       = "lattice stat mem --host"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Load Average (Host)"
    key          = "6_load_host"
    # get load avg scaled by number of cores
    script   = <<EOT
      echo "`cat /proc/loadavg | awk '{ print $1 }'` `nproc`" | awk '{ printf "%0.2f", $1/$2 }'
    EOT
    interval = 60
    timeout  = 1
  }

  metadata {
    display_name = "Swap Usage (Host)"
    key          = "7_swap_host"
    script       = <<EOT
      free -b | awk '/^Swap/ { printf("%.1f/%.1f", $3/1024.0/1024.0/1024.0, $2/1024.0/1024.0/1024.0) }'
    EOT
    interval     = 10
    timeout      = 1
  }

  # LiveKit agent configuration for dynamic agent switching
  metadata {
    display_name = "LiveKit Agent Config"
    key          = "livekit_sidecar_config"
    script       = <<EOT
      cat <<'SIDECAR_CONFIG'
${jsonencode({
  agents = [
    {
      id                     = "clinical-instructor"
      name                   = "Clinical Instructor"
      dispatch_name          = "clinical-instructor-v1"
      participant_identities = ["agent-instructor", "instructor-bot"]
      description            = "Primary clinical teaching agent with emphasis on formative feedback"
      always_on              = true
    },
    {
      id                     = "patient-safety-monitor"
      name                   = "Patient Safety Monitor"
      dispatch_name          = "safety-monitor-v1"
      participant_identities = ["agent-safety", "safety-bot"]
      description            = "Specialized agent focused on patient safety and quality indicators"
      always_on              = false
    },
    {
      id                     = "communication-coach"
      name                   = "Communication Coach"
      dispatch_name          = "communication-coach-v1"
      participant_identities = ["agent-communication", "coach-bot"]
      description            = "Expert in therapeutic communication and patient-centered interviewing"
      always_on              = false
    }
  ]
})}
SIDECAR_CONFIG
    EOT
    interval     = 0
    timeout      = 1
  }
}

resource "lattice_app" "code-server" {
  sidecar_id     = lattice_sidecar.main.id
  slug         = "code-server"
  display_name = "code-server"
  url          = "http://localhost:13337/?folder=/home/${local.username}"
  icon         = "/icon/code.svg"
  subdomain    = false
  share        = "owner"

  healthcheck {
    url       = "http://localhost:13337/healthz"
    interval  = 5
    threshold = 6
  }
}

resource "docker_volume" "home_volume" {
  name = "lattice-${data.lattice_agent.me.id}-home"
  # Protect the volume from being deleted due to changes in attributes.
  lifecycle {
    ignore_changes = all
  }
  # Add labels in Docker to keep track of orphan resources.
  labels {
    label = "lattice.owner"
    value = data.lattice_agent_owner.me.name
  }
  labels {
    label = "lattice.owner_id"
    value = data.lattice_agent_owner.me.id
  }
  labels {
    label = "lattice.workspace_id"
    value = data.lattice_agent.me.id
  }
  # This field becomes outdated if the workspace is renamed but can
  # be useful for debugging or cleaning out dangling volumes.
  labels {
    label = "lattice.workspace_name_at_creation"
    value = data.lattice_agent.me.name
  }
}

resource "docker_container" "workspace" {
  count = data.lattice_agent.me.start_count
  image = "latticecom/enterprise-base:ubuntu"
  # Uses lower() to avoid Docker restriction on container names.
  name = "lattice-${data.lattice_agent_owner.me.name}-${lower(data.lattice_agent.me.name)}"
  # Hostname makes the shell more user friendly: lattice@my-workspace:~$
  hostname = data.lattice_agent.me.name
  # Use the docker gateway if the access URL is 127.0.0.1
  entrypoint = ["sh", "-c", replace(lattice_sidecar.main.init_script, "/localhost|127\\.0\\.0\\.1/", "host.docker.internal")]
  env        = ["LATTICE_SIDECAR_TOKEN=${lattice_sidecar.main.token}"]
  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }
  volumes {
    container_path = "/home/${local.username}"
    volume_name    = docker_volume.home_volume.name
    read_only      = false
  }

  # Add labels in Docker to keep track of orphan resources.
  labels {
    label = "lattice.owner"
    value = data.lattice_agent_owner.me.name
  }
  labels {
    label = "lattice.owner_id"
    value = data.lattice_agent_owner.me.id
  }
  labels {
    label = "lattice.workspace_id"
    value = data.lattice_agent.me.id
  }
  labels {
    label = "lattice.workspace_name"
    value = data.lattice_agent.me.name
  }
}
