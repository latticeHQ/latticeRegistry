---
display_name: "Wrong Path"
description: "Test module with wrong icon path format"
icon: "../../../../.icons/invalid.svg"
verified: false
tags: ["test"]
---

# Wrong Path

This should fail validation.

```tf
module "test" {
  source   = "registry.latticeruntime.com/lattice/test/lattice"
  version  = "1.0.0"
  agent_id = lattice_agent.main.id
}
```
