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

provider "wirtual" {
}

variable "use_kubeconfig" {
  type        = bool
  description = <<-EOF
  Use host kubeconfig? (true/false)

  Set this to false if the Wirtual host is itself running as a Pod on the same
  Kubernetes cluster as you are deploying workspaces to.

  Set this to true if the Wirtual host is running outside the Kubernetes cluster
  for workspaces.  A valid "~/.kube/config" must be present on the Wirtual host.
  EOF
  default     = false
}

variable "namespace" {
  type        = string
  description = "The Kubernetes namespace to create workspaces in (must exist prior to creating workspaces). If the Wirtual host is itself running as a Pod on the same Kubernetes cluster as you are deploying workspaces to, set this to the same namespace."
}

data "wirtual_parameter" "cpu" {
  name         = "cpu"
  display_name = "CPU"
  description  = "The number of CPU cores"
  default      = "2"
  icon         = "/icon/memory.svg"
  mutable      = true
  option {
    name  = "2 Cores"
    value = "2"
  }
  option {
    name  = "4 Cores"
    value = "4"
  }
  option {
    name  = "6 Cores"
    value = "6"
  }
  option {
    name  = "8 Cores"
    value = "8"
  }
}

data "wirtual_parameter" "memory" {
  name         = "memory"
  display_name = "Memory"
  description  = "The amount of memory in GB"
  default      = "2"
  icon         = "/icon/memory.svg"
  mutable      = true
  option {
    name  = "2 GB"
    value = "2"
  }
  option {
    name  = "4 GB"
    value = "4"
  }
  option {
    name  = "6 GB"
    value = "6"
  }
  option {
    name  = "8 GB"
    value = "8"
  }
}

data "wirtual_parameter" "home_disk_size" {
  name         = "home_disk_size"
  display_name = "Home disk size"
  description  = "The size of the home disk in GB"
  default      = "10"
  type         = "number"
  icon         = "/emojis/1f4be.png"
  mutable      = false
  validation {
    min = 1
    max = 99999
  }
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
  startup_script = <<-EOT
    set -e

    # Install the latest code-server.
    # Append "--version x.x.x" to install a specific version of code-server.
    curl -fsSL https://code-server.dev/install.sh | sh -s -- --method=standalone --prefix=/tmp/code-server

    # Start code-server in the background.
    /tmp/code-server/bin/code-server --auth none --port 13337 >/tmp/code-server.log 2>&1 &
  EOT

  # The following metadata blocks are optional. They are used to display
  # information about your workspace in the dashboard. You can remove them
  # if you don't want to display any information.
  # For basic resources, you can use the `wirtual stat` command.
  # If you need more control, you can write your own script.
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

  metadata {
    display_name = "Home Disk"
    key          = "3_home_disk"
    script       = "wirtual stat disk --path $${HOME}"
    interval     = 60
    timeout      = 1
  }

  metadata {
    display_name = "CPU Usage (Host)"
    key          = "4_cpu_usage_host"
    script       = "wirtual stat cpu --host"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Memory Usage (Host)"
    key          = "5_mem_usage_host"
    script       = "wirtual stat mem --host"
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
    name      = "wirtual-${data.wirtual_workspace.me.id}-home"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name"     = "wirtual-pvc"
      "app.kubernetes.io/instance" = "wirtual-pvc-${data.wirtual_workspace.me.id}"
      "app.kubernetes.io/part-of"  = "wirtual"
      //Wirtual-specific labels.
      "com.wirtual.resource"       = "true"
      "com.wirtual.workspace.id"   = data.wirtual_workspace.me.id
      "com.wirtual.workspace.name" = data.wirtual_workspace.me.name
      "com.wirtual.user.id"        = data.wirtual_workspace_owner.me.id
      "com.wirtual.user.username"  = data.wirtual_workspace_owner.me.name
    }
    annotations = {
      "com.wirtual.user.email" = data.wirtual_workspace_owner.me.email
    }
  }
  wait_until_bound = false
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "${data.wirtual_parameter.home_disk_size.value}Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "main" {
  count = data.wirtual_workspace.me.start_count
  depends_on = [
    kubernetes_persistent_volume_claim.home
  ]
  wait_for_rollout = false
  metadata {
    name      = "wirtual-${data.wirtual_workspace.me.id}"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name"     = "wirtual-workspace"
      "app.kubernetes.io/instance" = "wirtual-workspace-${data.wirtual_workspace.me.id}"
      "app.kubernetes.io/part-of"  = "wirtual"
      "com.wirtual.resource"         = "true"
      "com.wirtual.workspace.id"     = data.wirtual_workspace.me.id
      "com.wirtual.workspace.name"   = data.wirtual_workspace.me.name
      "com.wirtual.user.id"          = data.wirtual_workspace_owner.me.id
      "com.wirtual.user.username"    = data.wirtual_workspace_owner.me.name
    }
    annotations = {
      "com.wirtual.user.email" = data.wirtual_workspace_owner.me.email
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        "app.kubernetes.io/name"     = "wirtual-workspace"
        "app.kubernetes.io/instance" = "wirtual-workspace-${data.wirtual_workspace.me.id}"
        "app.kubernetes.io/part-of"  = "wirtual"
        "com.wirtual.resource"         = "true"
        "com.wirtual.workspace.id"     = data.wirtual_workspace.me.id
        "com.wirtual.workspace.name"   = data.wirtual_workspace.me.name
        "com.wirtual.user.id"          = data.wirtual_workspace_owner.me.id
        "com.wirtual.user.username"    = data.wirtual_workspace_owner.me.name
      }
    }
    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"     = "wirtual-workspace"
          "app.kubernetes.io/instance" = "wirtual-workspace-${data.wirtual_workspace.me.id}"
          "app.kubernetes.io/part-of"  = "wirtual"
          "com.wirtual.resource"         = "true"
          "com.wirtual.workspace.id"     = data.wirtual_workspace.me.id
          "com.wirtual.workspace.name"   = data.wirtual_workspace.me.name
          "com.wirtual.user.id"          = data.wirtual_workspace_owner.me.id
          "com.wirtual.user.username"    = data.wirtual_workspace_owner.me.name
        }
      }
      spec {
        security_context {
          run_as_user = 1000
          fs_group    = 1000
        }

        container {
          name              = "dev"
          image             = "wirtualcom/enterprise-base:ubuntu"
          image_pull_policy = "Always"
          command           = ["sh", "-c", wirtual_agent.main.init_script]
          security_context {
            run_as_user = "1000"
          }
          env {
            name  = "WIRTUAL_AGENT_TOKEN"
            value = wirtual_agent.main.token
          }
          resources {
            requests = {
              "cpu"    = "250m"
              "memory" = "512Mi"
            }
            limits = {
              "cpu"    = "${data.wirtual_parameter.cpu.value}"
              "memory" = "${data.wirtual_parameter.memory.value}Gi"
            }
          }
          volume_mount {
            mount_path = "/home/wirtual"
            name       = "home"
            read_only  = false
          }
        }

        volume {
          name = "home"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.home.metadata.0.name
            read_only  = false
          }
        }

        affinity {
          // This affinity attempts to spread out all workspace pods evenly across
          // nodes.
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 1
              pod_affinity_term {
                topology_key = "kubernetes.io/hostname"
                label_selector {
                  match_expressions {
                    key      = "app.kubernetes.io/name"
                    operator = "In"
                    values   = ["wirtual-workspace"]
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
