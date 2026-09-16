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
      namespace   = "vlt"
      region      = "us"
      stage       = "dev"
      aws_region  = "us-west-2"
      application = "platform"
    }
  }

  assert {
    condition     = output.id == "vlt-us-dev-platform-example"
    error_message = "id should be {namespace}-{region}-{stage}-{application}-{name}, got ${output.id}"
  }

  assert {
    condition     = output.tags["ohi:application"] == "platform"
    error_message = "the ohi:* tags should come from the label context"
  }

  # namespace and region are the two fields 1.0.0 added. Terraform drops object
  # attributes an input type does not declare instead of erroring, so asserting
  # them here is what catches `variable "context"` drifting behind the label.
  assert {
    condition     = output.tags["Namespace"] == "vlt" && output.tags["Environment"] == "us"
    error_message = "namespace and region must survive the context object; check variable \"context\" against terraform-null-label"
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
      namespace   = "vlt"
      region      = "us"
      stage       = "dev"
      aws_region  = "us-west-2"
      application = "platform"
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
