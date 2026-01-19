mock_provider "lattice" {}

variables {
  agent_id       = "test-agent-001"
  default_effect = "deny"
  enable_audit   = true
  policies = [
    {
      name    = "test-policy"
      effect  = "allow"
      actions = ["api:read"]
    }
  ]
}

run "default_configuration" {
  command = plan

  assert {
    condition     = var.default_effect == "deny"
    error_message = "Default effect should be deny"
  }

  assert {
    condition     = var.enable_audit == true
    error_message = "Audit should be enabled by default"
  }

  assert {
    condition     = var.audit_retention_days == 30
    error_message = "Default retention should be 30 days"
  }
}

run "policy_validation" {
  command = plan

  assert {
    condition     = length(var.policies) == 1
    error_message = "Should have one policy defined"
  }

  assert {
    condition     = var.policies[0].name == "test-policy"
    error_message = "Policy name should match"
  }
}
