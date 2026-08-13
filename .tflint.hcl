config {
  # Modules are linted through their examples, which call this one with real
  # values. Following the call would lint the same files twice and report every
  # finding against the example's line numbers.
  call_module_type = "none"
}

# The terraform ruleset ships inside tflint, so no `tflint --init` is needed
# before the pre-commit hook or a local run.
plugin "terraform" {
  enabled = true

  # "recommended" is the ruleset's own curated set: unused declarations,
  # undocumented or untyped variables and outputs, unpinned module sources,
  # missing required_version, deprecated syntax, snake_case naming.
  preset = "recommended"
}

# Every module source must be pinned. The default "flexible" style accepts a
# tag, a branch or a commit; OHI modules pin tags with no `v` prefix, so a
# semver tag is what this should see.
rule "terraform_module_pinned_source" {
  enabled = true
  style   = "flexible"
}

# TODO(template): the rules below are off by default because they are opinions,
# not correctness. Turn them on if this module wants them.
#
# rule "terraform_standard_module_structure" {
#   # main.tf / variables.tf / outputs.tf, and variables/outputs declared in
#   # their own file rather than wherever they were first needed.
#   enabled = true
# }
#
# rule "terraform_unused_required_providers" {
#   enabled = true
# }
