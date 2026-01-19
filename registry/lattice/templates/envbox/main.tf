terraform {
  required_providers {
    wirtual = {
      source = "wirtualdev/wirtual"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

data "wirtual_parameter" "home_disk" {
  name        = "Disk Size"
  description = "How large should the disk storing the home directory be?"
  icon        = "https://cdn-icons-png.flaticon.com/512/2344/2344147.png"
  type        = "number"
  default     = 10
  mutable     = true
  validation {
    min = 10
    max = 100
  }
}

variable "use_kubeconfig" {
  type        = bool
  default     = true
  description = <<-EOF
  Use host kubeconfig? (true/false)
  Set this to false if the Wirtual host is itself running as a Pod on the same
  Kubernetes cluster as you are deploying workspaces to.
  Set this to true if the Wirtual host is running outside the Kubernetes cluster
  for workspaces.  A valid "~/.kube/config" must be present on the Wirtual host.
  EOF
}

provider "wirtual" {
}

variable "namespace" {
  type        = string
  description = "The namespace to create workspaces in (must exist prior to creating workspaces)"
}

variable "create_tun" {
  type        = bool
  description = "Add a TUN device to the workspace."
  default     = false
}

variable "create_fuse" {
  type        = bool
  description = "Add a FUSE device to the workspace."
  default     = false
}

variable "max_cpus" {
  type        = string
  description = "Max number of CPUs the workspace may use (e.g. 2)."
}

variable "min_cpus" {
  type        = string
  description = "Minimum number of CPUs the workspace may use (e.g. .1)."
}

variable "max_memory" {
  type        = string
  description = "Maximum amount of memory to allocate the workspace (in GB)."
}

variable "min_memory" {
  type        = string
  description = "Minimum amount of memory to allocate the workspace (in GB)."
}

provider "kubernetes" {
  # Authenticate via ~/.kube/config or a Wirtual-specific ServiceAccount, depending on admin preferences
  config_path = var.use_kubeconfig == true ? "~/.kube/config" : null
}

data "wirtual_workspace" "me" {}
data "wirtual_workspace_owner" "me" {}

resource "wirtual_agent" "main" {
  os             = "linux"
  arch           = "amd64"
  startup_script = <<EOT
    #!/bin/bash
    # home folder can be empty, so copying default bash settings
    if [ ! -f ~/.profile ]; then
      cp /etc/skel/.profile $HOME
    fi
    if [ ! -f ~/.bashrc ]; then
      cp /etc/skel/.bashrc $HOME
    fi

    # Install the latest code-server.
    # Append "--version x.x.x" to install a specific version of code-server.
    curl -fsSL https://code-server.dev/install.sh | sh -s -- --method=standalone --prefix=/tmp/code-server

    # Start code-server in the background.
    /tmp/code-server/bin/code-server --auth none --port 13337 >/tmp/code-server.log 2>&1 &
  EOT
}

# code-server
resource "wirtual_app" "code-server" {
  agent_id     = wirtual_agent.main.id
  slug         = "code-server"
  display_name = "code-server"
  icon         = "/icon/code.svg"
  url          = "http://localhost:13337?folder=/home/wirtual"
  subdomain    = false
  share        = "owner"

  healthcheck {
    url       = "http://localhost:13337/healthz"
    interval  = 3
    threshold = 10
  }
}

resource "kubernetes_persistent_volume_claim" "home" {
  metadata {
    name      = "wirtual-${lower(data.wirtual_workspace_owner.me.name)}-${lower(data.wirtual_workspace.me.name)}-home"
    namespace = var.namespace
  }
  wait_until_bound = false
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "${data.wirtual_parameter.home_disk.value}Gi"
      }
    }
  }
}

resource "kubernetes_pod" "main" {
  count = data.wirtual_workspace.me.start_count

  metadata {
    name      = "wirtual-${lower(data.wirtual_workspace_owner.me.name)}-${lower(data.wirtual_workspace.me.name)}"
    namespace = var.namespace
  }

  spec {
    restart_policy = "Never"

    container {
      name = "dev"
      # We highly recommend pinning this to a specific release of envbox, as the latest tag may change.
      image             = "docker.io/onchainengineer/envbox:latest"
      image_pull_policy = "Always"
      command           = ["/envbox", "docker"]

      security_context {
        privileged = true
      }

      resources {
        requests = {
          "cpu" : "${var.min_cpus}"
          "memory" : "${var.min_memory}G"
        }

        limits = {
          "cpu" : "${var.max_cpus}"
          "memory" : "${var.max_memory}G"
        }
      }

      env {
        name  = "WIRTUAL_AGENT_TOKEN"
        value = wirtual_agent.main.token
      }

      env {
        name  = "WIRTUAL_AGENT_URL"
        value = data.wirtual_workspace.me.access_url
      }

      env {
        name  = "WIRTUAL_INNER_IMAGE"
        value = "index.docker.io/wirtualcom/enterprise-base:ubuntu-20240812"
      }

      env {
        name  = "WIRTUAL_INNER_USERNAME"
        value = "wirtual"
      }

      env {
        name  = "WIRTUAL_BOOTSTRAP_SCRIPT"
        value = wirtual_agent.main.init_script
      }

      env {
        name  = "WIRTUAL_MOUNTS"
        value = "/home/wirtual:/home/wirtual"
      }

      env {
        name  = "WIRTUAL_ADD_FUSE"
        value = var.create_fuse
      }

      env {
        name  = "WIRTUAL_INNER_HOSTNAME"
        value = data.wirtual_workspace.me.name
      }

      env {
        name  = "WIRTUAL_ADD_TUN"
        value = var.create_tun
      }

      env {
        name = "WIRTUAL_CPUS"
        value_from {
          resource_field_ref {
            resource = "limits.cpu"
          }
        }
      }

      env {
        name = "WIRTUAL_MEMORY"
        value_from {
          resource_field_ref {
            resource = "limits.memory"
          }
        }
      }

      volume_mount {
        mount_path = "/home/wirtual"
        name       = "home"
        read_only  = false
        sub_path   = "home"
      }

      volume_mount {
        mount_path = "/var/lib/wirtual/docker"
        name       = "home"
        sub_path   = "cache/docker"
      }

      volume_mount {
        mount_path = "/var/lib/wirtual/containers"
        name       = "home"
        sub_path   = "cache/containers"
      }

      volume_mount {
        mount_path = "/var/lib/sysbox"
        name       = "sysbox"
      }

      volume_mount {
        mount_path = "/var/lib/containers"
        name       = "home"
        sub_path   = "envbox/containers"
      }

      volume_mount {
        mount_path = "/var/lib/docker"
        name       = "home"
        sub_path   = "envbox/docker"
      }

      volume_mount {
        mount_path = "/usr/src"
        name       = "usr-src"
      }

      volume_mount {
        mount_path = "/lib/modules"
        name       = "lib-modules"
      }
    }

    volume {
      name = "home"
      persistent_volume_claim {
        claim_name = kubernetes_persistent_volume_claim.home.metadata.0.name
        read_only  = false
      }
    }

    volume {
      name = "sysbox"
      empty_dir {}
    }

    volume {
      name = "usr-src"
      host_path {
        path = "/usr/src"
        type = ""
      }
    }

    volume {
      name = "lib-modules"
      host_path {
        path = "/lib/modules"
        type = ""
      }
    }
  }
}
