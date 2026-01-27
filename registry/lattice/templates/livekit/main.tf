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
    apt-get update && apt-get install -y python3 python3-pip

    # Install LiveKit Agents SDK
    pip3 install livekit livekit-agents livekit-plugins-openai livekit-plugins-deepgram livekit-plugins-elevenlabs

    # Create sample agent script
    cat > /home/lattice/agent.py <<'EOF'
from livekit import agents
from livekit.agents import JobContext, WorkerOptions, cli
from livekit.plugins import openai, deepgram, elevenlabs

async def entrypoint(ctx: JobContext):
    initial_ctx = agents.llm.ChatContext()
    initial_ctx.append(text="You are a helpful voice assistant.")
    
    await ctx.connect()
    participant = await ctx.wait_for_participant()
    
    agent = agents.VoicePipelineAgent(
        vad=agents.silero.VAD.load(),
        stt=deepgram.STT(),
        llm=openai.LLM(),
        tts=elevenlabs.TTS(),
        chat_ctx=initial_ctx,
    )
    
    agent.start(ctx.room, participant)
    await agent.say("Hello! How can I help you today?")

if __name__ == "__main__":
    cli.run_app(WorkerOptions(entrypoint_fnc=entrypoint))
EOF

    echo "LiveKit agent ready. Run: python3 /home/lattice/agent.py dev"
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
