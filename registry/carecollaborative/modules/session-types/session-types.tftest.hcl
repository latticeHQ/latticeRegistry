run "default_session_types_exist" {
  command = plan

  assert {
    condition     = length(output.session_type_ids) >= 3
    error_message = "Should have at least 3 default session types"
  }

  assert {
    condition     = contains(output.session_type_ids, "clinical")
    error_message = "Clinical session type should exist"
  }

  assert {
    condition     = contains(output.session_type_ids, "workplace")
    error_message = "Workplace session type should exist"
  }

  assert {
    condition     = contains(output.session_type_ids, "observation")
    error_message = "Observation session type should exist"
  }
}

run "persona_required_types_correct" {
  command = plan

  assert {
    condition     = contains(output.persona_required_types, "clinical")
    error_message = "Clinical should require persona"
  }

  assert {
    condition     = contains(output.persona_required_types, "workplace")
    error_message = "Workplace should require persona"
  }

  assert {
    condition     = !contains(output.persona_required_types, "observation")
    error_message = "Observation should not require persona"
  }
}

run "avatar_enabled_types_correct" {
  command = plan

  assert {
    condition     = contains(output.avatar_enabled_types, "clinical")
    error_message = "Clinical should support avatar"
  }

  assert {
    condition     = contains(output.avatar_enabled_types, "workplace")
    error_message = "Workplace should support avatar"
  }

  assert {
    condition     = !contains(output.avatar_enabled_types, "observation")
    error_message = "Observation should not support avatar"
  }
}

run "session_type_lookup_works" {
  command = plan

  assert {
    condition     = output.session_type_lookup["clinical"].name == "Clinical Training"
    error_message = "Clinical lookup should return correct name"
  }

  assert {
    condition     = output.session_type_lookup["clinical"].requires_persona == true
    error_message = "Clinical lookup should show requires_persona"
  }
}

run "json_output_valid" {
  command = plan

  assert {
    condition     = can(jsondecode(output.session_types_json))
    error_message = "session_types_json should be valid JSON"
  }
}
