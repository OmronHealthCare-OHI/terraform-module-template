terraform {
  required_version = ">= 1.9.0"
}

# The caller owns the label: it states where it deploys and where it sits in the
# ohi:* hierarchy, and hands the resolved context to every module it calls.
module "label" {
  source = "github.com/OmronHealthCare-OHI/terraform-null-label?ref=0.1.2"

  country    = "us"
  aws_region = "us-west-2"
  non_prd    = true # -> prefix usnp-usw2

  project     = "vlt"
  application = "platform"
  module      = "example"
  owner       = "cloud-foundations"

  attributes = ["test"]

  tags = {
    managed-by = "terraform"
  }
}

# TODO(template): a provider block belongs here once the module declares one.
# Set allowed_account_ids and default_tags = module.label.tags, so anything the
# example creates outside the module carries the same tags the module applies to
# its own resources. See terraform-aws-lambda-service/examples/complete/main.tf.

module "example" {
  source = "../.."

  name    = "example"
  context = module.label.context

  extra_tags = {
    cost-centre = "platform"
  }
}

# Chaining: a child label inherits the module's hierarchy and sets its own leaf
# name, so sibling resources stay under one project/application.
module "child_label" {
  source = "github.com/OmronHealthCare-OHI/terraform-null-label?ref=0.1.2"

  context = module.example.label_context
  name    = "child"
}

output "id" {
  description = "Name the module composed, e.g. usnp-usw2-vlt-platform-example-test"
  value       = module.example.id
}

output "child_id" {
  description = "Name a child label composes from the module's exported context"
  value       = module.child_label.id
}
