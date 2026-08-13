config {
  # Don't descend into module calls: the examples already lint this module with
  # real values, so following them would double-report against example lines.
  call_module_type = "none"
}

# The terraform ruleset ships inside tflint — no `tflint --init` needed.
plugin "terraform" {
  enabled = true

  # tflint's own default, stated explicitly so it survives a change to that
  # default: unused declarations, undocumented or untyped variables and
  # outputs, unpinned module sources, missing required_version, deprecated
  # syntax, snake_case naming.
  preset = "recommended"
}

# OHI modules pin semver tags with no `v` prefix. "flexible" accepts a tag,
# branch or commit and rejects an unpinned source.
rule "terraform_module_pinned_source" {
  enabled = true
  style   = "flexible"
}

# TODO(template): opinions, not correctness. Enable if this module wants them.
# rule "terraform_standard_module_structure" { enabled = true }
# rule "terraform_unused_required_providers" { enabled = true }
