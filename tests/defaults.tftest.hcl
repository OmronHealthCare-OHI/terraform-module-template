# The seed module's contract: names and tags are composed by the shared label,
# and the exported context withholds the leaf name.
#
# TODO(template): replace these with tests for the resources this module owns.
# `command = plan` needs no credentials, so most assertions belong there; use
# `command = apply` with mocked providers only where a value is not known until
# apply. See terraform-aws-lambda-service/tests/defaults.tftest.hcl.

run "composes_the_label_id" {
  command = plan

  variables {
    name = "example"
    context = {
      country     = "us"
      aws_region  = "us-west-2"
      non_prd     = true
      project     = "vlt"
      application = "platform"
      attributes  = ["test"]
    }
  }

  assert {
    condition     = output.id == "usnp-usw2-vlt-platform-example-test"
    error_message = "id should be {prefix}-{project}-{application}-{name}-{attributes}, got ${output.id}"
  }

  assert {
    condition     = output.tags["ohi:project"] == "vlt"
    error_message = "the ohi:* tags should come from the label context"
  }

  assert {
    condition     = output.label_context.name == null
    error_message = "label_context must withhold the leaf name so child labels set their own"
  }
}

run "merges_extra_tags" {
  command = plan

  variables {
    name = "example"
    context = {
      country     = "us"
      aws_region  = "us-west-2"
      non_prd     = true
      project     = "vlt"
      application = "platform"
      attributes  = ["test"]
    }
    extra_tags = {
      managed-by = "terraform"
    }
  }

  assert {
    condition     = output.tags["managed-by"] == "terraform"
    error_message = "extra_tags should be merged on top of the label's own tags"
  }
}
