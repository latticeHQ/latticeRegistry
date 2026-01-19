terraform {
  required_providers {
    wirtual = {
      source = "wirtualdev/wirtual"
    }
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

locals {
  username = data.wirtual_workspace_owner.me.name
}

variable "docker_socket" {
  default     = ""
  description = "(Optional) Docker socket URI"
  type        = string
}

provider "docker" {
  host = var.docker_socket != "" ? var.docker_socket : null
}

data "wirtual_provisioner" "me" {}
data "wirtual_workspace" "me" {}
data "wirtual_workspace_owner" "me" {}

resource "wirtual_agent" "main" {
  arch           = data.wirtual_provisioner.me.arch
  os             = "linux"
  startup_script = <<-EOT
    set -e

    # Prepare user home with default files on first start.
    if [ ! -f ~/.init_done ]; then
      cp -rT /etc/skel ~
      touch ~/.init_done
    fi

    # Install Python and dependencies
    apt-get update && apt-get install -y python3 python3-pip ffmpeg

    # Install ElevenLabs SDK
    pip3 install elevenlabs

    # Create sample agent script
    cat > /home/wirtual/elevenlabs_agent.py <<'EOF'
from elevenlabs import generate, play, stream, voices, Voice
import os

def text_to_speech(text: str, voice_id: str = "21m00Tcm4TlvDq8ikWAM"):
    """Convert text to speech using ElevenLabs."""
    audio = generate(
        text=text,
        voice=voice_id,
        model="eleven_monolingual_v1"
    )
    return audio

def stream_text_to_speech(text: str, voice_id: str = "21m00Tcm4TlvDq8ikWAM"):
    """Stream text to speech for low latency."""
    audio_stream = stream(
        text=text,
        voice=voice_id,
        model="eleven_monolingual_v1"
    )
    return audio_stream

def list_available_voices():
    """List all available voices."""
    return voices()

if __name__ == "__main__":
    # Example usage
    print("ElevenLabs TTS Agent Ready!")
    print("Available functions: text_to_speech(), stream_text_to_speech(), list_available_voices()")
EOF

    echo "ElevenLabs agent ready. Run: python3 /home/wirtual/elevenlabs_agent.py"
  EOT

  env = {
    GIT_AUTHOR_NAME     = coalesce(data.wirtual_workspace_owner.me.full_name, data.wirtual_workspace_owner.me.name)
    GIT_AUTHOR_EMAIL    = "${data.wirtual_workspace_owner.me.email}"
    GIT_COMMITTER_NAME  = coalesce(data.wirtual_workspace_owner.me.full_name, data.wirtual_workspace_owner.me.name)
    GIT_COMMITTER_EMAIL = "${data.wirtual_workspace_owner.me.email}"
  }

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
}
