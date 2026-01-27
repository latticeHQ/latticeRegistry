mock_provider "lattice" {}

variables {
  sidecar_id      = "test-agent-001"
  provider_type = "oidc"
  issuer_url    = "https://auth.example.com"
  client_id     = "test-client"
}

run "default_configuration" {
  command = plan

  assert {
    condition     = var.provider_type == "oidc"
    error_message = "Default provider type should be oidc"
  }

  assert {
    condition     = var.token_lifetime == 3600
    error_message = "Default token lifetime should be 3600"
  }
}

run "validates_provider_type" {
  command = plan

  variables {
    provider_type = "apikey"
  }

  assert {
    condition     = var.provider_type == "apikey"
    error_message = "Provider type should accept apikey"
  }
}
