mock_provider "lattice" {}

variables {
  sidecar_id      = "test-agent-001"
  enable_voice  = true
  enable_video  = false
  room_prefix   = "lattice"
  sample_rate   = 48000
  channels      = 1
  capabilities  = ["voice", "transcription"]
}

run "default_configuration" {
  command = plan

  assert {
    condition     = var.enable_voice == true
    error_message = "Voice should be enabled by default"
  }

  assert {
    condition     = var.enable_video == false
    error_message = "Video should be disabled by default"
  }

  assert {
    condition     = var.sample_rate == 48000
    error_message = "Default sample rate should be 48000 Hz"
  }
}

run "audio_configuration" {
  command = plan

  assert {
    condition     = var.channels >= 1 && var.channels <= 2
    error_message = "Channels must be 1 (mono) or 2 (stereo)"
  }

  assert {
    condition     = contains([16000, 24000, 48000], var.sample_rate)
    error_message = "Sample rate must be one of: 16000, 24000, 48000"
  }
}

run "capabilities_check" {
  command = plan

  assert {
    condition     = length(var.capabilities) == 2
    error_message = "Should have two capabilities configured"
  }

  assert {
    condition     = contains(var.capabilities, "voice")
    error_message = "Voice capability should be enabled"
  }
}
