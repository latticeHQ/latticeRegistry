run "filter_clinical_personas" {
  command = plan

  variables {
    session_type = "clinical"
  }

  assert {
    condition     = output.persona_count >= 1
    error_message = "Should have at least one clinical persona"
  }

  assert {
    condition     = alltrue([for p in output.personas : p.session_type == "clinical"])
    error_message = "All filtered personas should be clinical type"
  }
}

run "filter_workplace_personas" {
  command = plan

  variables {
    session_type = "workplace"
  }

  assert {
    condition     = output.persona_count >= 1
    error_message = "Should have at least one workplace persona"
  }

  assert {
    condition     = alltrue([for p in output.personas : p.session_type == "workplace"])
    error_message = "All filtered personas should be workplace type"
  }
}

run "filter_by_tags" {
  command = plan

  variables {
    session_type = "clinical"
    filter_tags  = ["cardiology"]
  }

  assert {
    condition     = output.persona_count >= 1
    error_message = "Should have at least one cardiology persona"
  }
}

run "persona_lookup_map" {
  command = plan

  variables {
    session_type = "clinical"
  }

  assert {
    condition     = contains(keys(output.persona_lookup), "clinical-v1")
    error_message = "Persona lookup should contain clinical-v1"
  }
}

run "default_personas_exist" {
  command = plan

  variables {
    session_type = "clinical"
  }

  assert {
    condition     = contains(output.persona_ids, "clinical-v1")
    error_message = "Default clinical persona should exist"
  }
}
