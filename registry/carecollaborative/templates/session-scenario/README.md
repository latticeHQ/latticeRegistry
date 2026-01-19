---
display_name: Session Transcriber & Evaluator
description: Multi-participant transcription and session analysis for training evaluations
icon: ../.icons/1f4cb.png
maintainer_github: carecollaborative
verified: true
tags: [transcription, evaluation, livekit, analytics, s3]
---

# Session Transcriber & Evaluator

Deploy real-time multi-participant transcription for training sessions with automatic analysis, metrics, and cloud storage integration for faculty evaluation workflows.

## Features

- **Multi-Participant Transcription**: Simultaneously transcribe audio from multiple participants
- **Real-Time Processing**: LiveKit-powered streaming transcription with Deepgram Nova 3
- **Speaker Attribution**: Track who said what with timestamped transcripts
- **Conversation Analysis**: Automatic metrics including speaking balance, turn-taking, and duration
- **Cloud Storage**: Session recordings and transcripts saved to S3-compatible storage (R2, AWS S3, MinIO)
- **Noise Cancellation**: Background voice removal for cleaner transcription
- **Session Reports**: Comprehensive JSON reports for downstream LLM analysis

## Prerequisites

### Infrastructure

The VM you run Wirtual on must have a running Docker socket:

```sh
# Add wirtual user to Docker group
sudo adduser wirtual docker
sudo systemctl restart wirtual
```

### API Keys

Configure your transcription and storage providers:

```sh
# Required - LiveKit
export LIVEKIT_URL="wss://your-livekit.livekit.cloud"
export LIVEKIT_API_KEY="your-livekit-key"
export LIVEKIT_API_SECRET="your-livekit-secret"

# Required - S3-Compatible Storage (R2, AWS S3, MinIO)
export S3_ENDPOINT="https://your-account.r2.cloudflarestorage.com"
export S3_BUCKET="your-bucket-name"
export S3_KEY_ID="your-access-key-id"
export S3_KEY_SECRET="your-secret-access-key"
export S3_REGION="auto"  # Use "auto" for R2, or specific region for AWS
```

## Architecture

This template provisions:

- Pre-built container image with LiveKit agents SDK
- Deepgram Nova 3 multilingual speech-to-text
- Background voice cancellation for cleaner audio
- Automatic session recording to S3/R2
- Comprehensive session reports with conversation analysis

## Storage Structure

Session artifacts are organized hierarchically:

```
sessions/
  {room_name}/
    {timestamp}/
      recording.ogg        # Full audio recording
      session_report.json  # Complete session data
      conversation.txt     # Human-readable transcript
      conversation.json    # Clean JSON for LLM processing
      analysis.json        # Metrics and speaking analysis
```

## Session Report Contents

The `session_report.json` includes:

- **Participants**: Chat history and transcripts per participant
- **Speaking Metrics**: Words, turns, timing per speaker
- **Conversation Timeline**: Chronological transcript with timestamps
- **Turn-Taking Analysis**: Speaker changes and balance
- **Duration**: Total session length

## Configuration

Customize the transcriber via Terraform variables:

```hcl
# terraform.tfvars
agent_name              = "Training Session Transcriber"
stt_model               = "deepgram/nova-3"
stt_language            = "multi"  # Multilingual support
noise_cancellation      = true
enable_recording        = true
recording_format        = "ogg"
```

## Use Cases

- **Clinical Training Sessions**: Transcribe student-patient simulations
- **Workplace Training**: Record and analyze HR training scenarios
- **Faculty Observation**: Document faculty-student interactions
- **OSCE Examinations**: Capture standardized patient encounters
- **Competency Assessment**: Analyze communication patterns and skills

## Output Files

### conversation.txt (Human-Readable)
```
Session: training-room-123
Date: 2024-01-15T14:30:00
Duration: 1200.5 seconds
Participants: student-001, ai-patient

--- CONVERSATION ---

[14:30:05] student-001: Good morning, I'm Dr. Smith. What brings you in today?
[14:30:12] ai-patient: Hello doctor. I've been having chest pain for the past few days.
...
```

### analysis.json (For LLM Processing)
```json
{
  "metrics": {
    "total_participants": 2,
    "total_utterances": 45,
    "total_words": 1250,
    "duration_seconds": 1200.5
  },
  "speaking_balance": {
    "student-001": 650,
    "ai-patient": 600
  }
}
```

## Getting Started

1. Create a new workspace from this template
2. Configure your LiveKit and S3 credentials
3. Join participants to the room
4. Transcription begins automatically
5. Session data is saved on disconnect

Built for training evaluation and session analysis workflows.
