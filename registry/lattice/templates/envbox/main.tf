terraform {
  required_providers {
    lattice = {
      source = "latticehq/lattice"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

data "lattice_parameter" "home_disk" {
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
  Set this to false if the Lattice host is itself running as a Pod on the same
  Kubernetes cluster as you are deploying workspaces to.
  Set this to true if the Lattice host is running outside the Kubernetes cluster
  for workspaces.  A valid "~/.kube/config" must be present on the Lattice host.
  EOF
}

provider "lattice" {
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
  # Authenticate via ~/.kube/config or a Lattice-specific ServiceAccount, depending on admin preferences
  config_path = var.use_kubeconfig == true ? "~/.kube/config" : null
}

data "lattice_agent" "me" {}
data "lattice_agent_owner" "me" {}

resource "lattice_agent" "main" {
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
resource "lattice_app" "code-server" {
  sidecar_id     = lattice_agent.main.id
  slug         = "code-server"
  display_name = "code-server"
  icon         = "/icon/code.svg"
  url          = "http://localhost:13337?folder=/home/lattice"
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
    name      = "lattice-${lower(data.lattice_agent_owner.me.name)}-${lower(data.lattice_agent.me.name)}-home"
    namespace = var.namespace
  }
  wait_until_bound = false
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "${data.lattice_parameter.home_disk.value}Gi"
      }
    }
  }
}

resource "kubernetes_pod" "main" {
  count = data.lattice_agent.me.start_count

  metadata {
    name      = "lattice-${lower(data.lattice_agent_owner.me.name)}-${lower(data.lattice_agent.me.name)}"
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
        name  = "LATTICE_SIDECAR_TOKEN"
        value = lattice_agent.main.token
      }

      env {
        name  = "LATTICE_SIDECAR_URL"
        value = data.lattice_agent.me.access_url
      }

      env {
        name  = "LATTICE_INNER_IMAGE"
        value = "index.docker.io/latticecom/enterprise-base:ubuntu-20240812"
      }

      env {
        name  = "LATTICE_INNER_USERNAME"
        value = "lattice"
      }

      env {
        name  = "LATTICE_BOOTSTRAP_SCRIPT"
        value = lattice_agent.main.init_script
      }

      env {
        name  = "LATTICE_MOUNTS"
        value = "/home/lattice:/home/lattice"
      }

      env {
        name  = "LATTICE_ADD_FUSE"
        value = var.create_fuse
      }

      env {
        name  = "LATTICE_INNER_HOSTNAME"
        value = data.lattice_agent.me.name
      }

      env {
        name  = "LATTICE_ADD_TUN"
        value = var.create_tun
      }

      env {
        name = "LATTICE_CPUS"
        value_from {
          resource_field_ref {
            resource = "limits.cpu"
          }
        }
      }

      env {
        name = "LATTICE_MEMORY"
        value_from {
          resource_field_ref {
            resource = "limits.memory"
          }
        }
      }

      volume_mount {
        mount_path = "/home/lattice"
        name       = "home"
        read_only  = false
        sub_path   = "home"
      }

      volume_mount {
        mount_path = "/var/lib/lattice/docker"
        name       = "home"
        sub_path   = "cache/docker"
      }

      volume_mount {
        mount_path = "/var/lib/lattice/containers"
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
