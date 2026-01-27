terraform {
  required_providers {
    lattice = {
      source = "latticehq/lattice"
    }
    incus = {
      source = "lxc/incus"
    }
  }
}

data "lattice_provisioner" "me" {}

provider "incus" {}

data "lattice_agent" "me" {}
data "lattice_agent_owner" "me" {}

data "lattice_parameter" "image" {
  name         = "image"
  display_name = "Image"
  description  = "The container image to use. Be sure to use a variant with cloud-init installed!"
  default      = "ubuntu/jammy/cloud/amd64"
  icon         = "/icon/image.svg"
  mutable      = true
}

data "lattice_parameter" "cpu" {
  name         = "cpu"
  display_name = "CPU"
  description  = "The number of CPUs to allocate to the workspace (1-8)"
  type         = "number"
  default      = "1"
  icon         = "https://raw.githubusercontent.com/matifali/logos/main/cpu-3.svg"
  mutable      = true
  validation {
    min = 1
    max = 8
  }
}

data "lattice_parameter" "memory" {
  name         = "memory"
  display_name = "Memory"
  description  = "The amount of memory to allocate to the workspace in GB (up to 16GB)"
  type         = "number"
  default      = "2"
  icon         = "/icon/memory.svg"
  mutable      = true
  validation {
    min = 1
    max = 16
  }
}

data "lattice_parameter" "git_repo" {
  type        = "string"
  name        = "Git repository"
  default     = "https://github.com/latticehq/latticeruntime"
  description = "Clone a git repo into [base directory]"
  mutable     = true
}

data "lattice_parameter" "repo_base_dir" {
  type        = "string"
  name        = "Repository Base Directory"
  default     = "~"
  description = "The directory specified will be created (if missing) and the specified repo will be cloned into [base directory]/{repo}🪄."
  mutable     = true
}

resource "lattice_agent" "main" {
  count = data.lattice_agent.me.start_count
  arch  = data.lattice_provisioner.me.arch
  os    = "linux"
  dir   = "/home/${local.workspace_user}"
  env = {
    LATTICE_AGENT_ID = data.lattice_agent.me.id
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
    script       = "lattice stat disk --path /home/${lower(data.lattice_agent_owner.me.name)}"
    interval     = 60
    timeout      = 1
  }
}

module "git-clone" {
  source   = "registry.latticeruntime.com/modules/git-clone/lattice"
  version  = "1.0.2"
  sidecar_id = local.sidecar_id
  url      = data.lattice_parameter.git_repo.value
  base_dir = local.repo_base_dir
}

module "code-server" {
  source   = "registry.latticeruntime.com/modules/code-server/lattice"
  version  = "1.0.2"
  sidecar_id = local.sidecar_id
  folder   = local.repo_base_dir
}

module "filebrowser" {
  source   = "registry.latticeruntime.com/modules/filebrowser/lattice"
  version  = "1.0.2"
  sidecar_id = local.sidecar_id
}

module "lattice-login" {
  source   = "registry.latticeruntime.com/modules/lattice-login/lattice"
  version  = "1.0.2"
  sidecar_id = local.sidecar_id
}

resource "incus_volume" "home" {
  name = "lattice-${data.lattice_agent.me.id}-home"
  pool = local.pool
}

resource "incus_volume" "docker" {
  name = "lattice-${data.lattice_agent.me.id}-docker"
  pool = local.pool
}

resource "incus_cached_image" "image" {
  source_remote = "images"
  source_image  = data.lattice_parameter.image.value
}

resource "incus_instance_file" "sidecar_token" {
  count              = data.lattice_agent.me.start_count
  instance           = incus_instance.dev.name
  content            = <<EOF
LATTICE_SIDECAR_TOKEN=${local.sidecar_token}
EOF
  create_directories = true
  target_path        = "/opt/lattice/init.env"
}

resource "incus_instance" "dev" {
  running = data.lattice_agent.me.start_count == 1
  name    = "lattice-${lower(data.lattice_agent_owner.me.name)}-${lower(data.lattice_agent.me.name)}"
  image   = incus_cached_image.image.fingerprint

  config = {
    "security.nesting"                     = true
    "security.syscalls.intercept.mknod"    = true
    "security.syscalls.intercept.setxattr" = true
    "boot.autostart"                       = true
    "cloud-init.user-data"                 = <<EOF
#cloud-config
hostname: ${lower(data.lattice_agent.me.name)}
users:
  - name: ${local.workspace_user}
    uid: 1000
    gid: 1000
    groups: sudo
    packages:
      - curl
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
write_files:
  - path: /opt/lattice/init
    permissions: "0755"
    encoding: b64
    content: ${base64encode(local.agent_init_script)}
  - path: /etc/systemd/system/lattice-agent.service
    permissions: "0644"
    content: |
      [Unit]
      Description=Lattice Agent
      After=network-online.target
      Wants=network-online.target

      [Service]
      User=${local.workspace_user}
      EnvironmentFile=/opt/lattice/init.env
      ExecStart=/opt/lattice/init
      Restart=always
      RestartSec=10
      TimeoutStopSec=90
      KillMode=process

      OOMScoreAdjust=-900
      SyslogIdentifier=lattice-agent

      [Install]
      WantedBy=multi-user.target
  - path: /etc/systemd/system/lattice-agent-watcher.service
    permissions: "0644"
    content: |
      [Unit]
      Description=Lattice Agent Watcher
      After=network-online.target

      [Service]
      Type=oneshot
      ExecStart=/usr/bin/systemctl restart lattice-agent.service

      [Install]
      WantedBy=multi-user.target
  - path: /etc/systemd/system/lattice-agent-watcher.path
    permissions: "0644"
    content: |
      [Path]
      PathModified=/opt/lattice/init.env
      Unit=lattice-agent-watcher.service

      [Install]
      WantedBy=multi-user.target
runcmd:
  - chown -R ${local.workspace_user}:${local.workspace_user} /home/${local.workspace_user}
  - |
    #!/bin/bash
    apt-get update && apt-get install -y curl docker.io
    usermod -aG docker ${local.workspace_user}
    newgrp docker
  - systemctl enable lattice-agent.service lattice-agent-watcher.service lattice-agent-watcher.path
  - systemctl start lattice-agent.service lattice-agent-watcher.service lattice-agent-watcher.path
EOF
  }

  limits = {
    cpu    = data.lattice_parameter.cpu.value
    memory = "${data.lattice_parameter.cpu.value}GiB"
  }

  device {
    name = "home"
    type = "disk"
    properties = {
      path   = "/home/${local.workspace_user}"
      pool   = local.pool
      source = incus_volume.home.name
    }
  }

  device {
    name = "docker"
    type = "disk"
    properties = {
      path   = "/var/lib/docker"
      pool   = local.pool
      source = incus_volume.docker.name
    }
  }

  device {
    name = "root"
    type = "disk"
    properties = {
      path = "/"
      pool = local.pool
    }
  }
}

locals {
  workspace_user    = lower(data.lattice_agent_owner.me.name)
  pool              = "lattice"
  repo_base_dir     = data.lattice_parameter.repo_base_dir.value == "~" ? "/home/${local.workspace_user}" : replace(data.lattice_parameter.repo_base_dir.value, "/^~\\//", "/home/${local.workspace_user}/")
  repo_dir          = module.git-clone.repo_dir
  sidecar_id          = data.lattice_agent.me.start_count == 1 ? lattice_agent.main[0].id : ""
  sidecar_token       = data.lattice_agent.me.start_count == 1 ? lattice_agent.main[0].token : ""
  agent_init_script = data.lattice_agent.me.start_count == 1 ? lattice_agent.main[0].init_script : ""
}

resource "lattice_metadata" "info" {
  count       = data.lattice_agent.me.start_count
  resource_id = incus_instance.dev.name
  item {
    key   = "memory"
    value = incus_instance.dev.limits.memory
  }
  item {
    key   = "cpus"
    value = incus_instance.dev.limits.cpu
  }
  item {
    key   = "instance"
    value = incus_instance.dev.name
  }
  item {
    key   = "image"
    value = "${incus_cached_image.image.source_remote}:${incus_cached_image.image.source_image}"
  }
  item {
    key   = "image_fingerprint"
    value = substr(incus_cached_image.image.fingerprint, 0, 12)
  }
}

