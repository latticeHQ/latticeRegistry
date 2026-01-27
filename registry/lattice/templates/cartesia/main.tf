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

    # Install Python and dependencies
    apt-get update && apt-get install -y python3 python3-pip ffmpeg

    # Install Cartesia SDK
    pip3 install cartesia websockets

    # Create sample agent script
    cat > /home/lattice/cartesia_agent.py <<'EOF'
import asyncio
import os
from cartesia import Cartesia

async def synthesize_speech(text: str, voice_id: str = "79a125e8-cd45-4c13-8a67-188112f4dd22"):
    """Synthesize speech with Cartesia ultra-fast TTS."""
    client = Cartesia(api_key=os.getenv('CARTESIA_API_KEY'))
    
    # Generate audio
    audio = await client.tts.generate(
        text=text,
        voice_id=voice_id,
        model_id="sonic-english",
        output_format={
            "container": "raw",
            "encoding": "pcm_f32le",
            "sample_rate": 44100
        }
    )
    
    return audio

async def stream_speech(text: str, voice_id: str = "79a125e8-cd45-4c13-8a67-188112f4dd22"):
    """Stream speech synthesis for real-time applications."""
    client = Cartesia(api_key=os.getenv('CARTESIA_API_KEY'))
    
    # Stream audio chunks
    async for audio_chunk in client.tts.stream(
        text=text,
        voice_id=voice_id,
        model_id="sonic-english",
        output_format={
            "container": "raw",
            "encoding": "pcm_f32le",
            "sample_rate": 44100
        }
    ):
        yield audio_chunk

def list_voices():
    """List available Cartesia voices."""
    client = Cartesia(api_key=os.getenv('CARTESIA_API_KEY'))
    return client.voices.list()

if __name__ == "__main__":
    print("Cartesia Ultra-Fast TTS Agent Ready!")
    print("Available functions: synthesize_speech(), stream_speech(), list_voices()")
    print("Latency: < 100ms time-to-first-audio")
EOF

    echo "Cartesia agent ready. Run: python3 /home/lattice/cartesia_agent.py"
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
