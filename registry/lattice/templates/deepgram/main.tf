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
    apt-get update && apt-get install -y python3 python3-pip ffmpeg portaudio19-dev

    # Install Deepgram SDK
    pip3 install deepgram-sdk pyaudio websockets

    # Create sample agent script
    cat > /home/wirtual/deepgram_agent.py <<'EOF'
from deepgram import Deepgram
import asyncio
import os

async def transcribe_audio_file(file_path: str):
    """Transcribe an audio file using Deepgram."""
    dg_client = Deepgram(os.getenv('DEEPGRAM_API_KEY'))
    
    with open(file_path, 'rb') as audio:
        source = {'buffer': audio, 'mimetype': 'audio/wav'}
        response = await dg_client.transcription.prerecorded(source, {
            'punctuate': True,
            'model': 'nova-2',
            'language': 'en-US'
        })
        
    return response['results']['channels'][0]['alternatives'][0]['transcript']

async def transcribe_realtime():
    """Transcribe audio in real-time using WebSocket."""
    dg_client = Deepgram(os.getenv('DEEPGRAM_API_KEY'))
    
    async def handle_transcript(transcript):
        print(f"Transcript: {transcript}")
    
    # Set up WebSocket connection
    deepgram_socket = await dg_client.transcription.live({
        'punctuate': True,
        'interim_results': True,
        'model': 'nova-2',
        'language': 'en-US'
    })
    
    deepgram_socket.register_handler(deepgram_socket.event.TRANSCRIPT_RECEIVED, handle_transcript)
    
    return deepgram_socket

if __name__ == "__main__":
    print("Deepgram STT Agent Ready!")
    print("Available functions: transcribe_audio_file(), transcribe_realtime()")
EOF

    echo "Deepgram agent ready. Run: python3 /home/wirtual/deepgram_agent.py"
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
