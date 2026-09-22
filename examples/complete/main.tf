terraform {
  required_version = ">= 1.9.0"
}

# The caller owns the label: it states where it deploys and where it sits in the
# ohi:* hierarchy, and hands the resolved context to every module it calls.
module "label" {
  source = "github.com/OmronHealthCare-OHI/terraform-null-label?ref=1.0.0"

  namespace  = "vlt"
  region     = "us"
  stage      = "dev"
  aws_region = "us-west-2" # tag only; not part of the id

  application = "platform"
  module      = "example" # -> ohi:module = platform-example; not in the id
  owner       = "cloud-foundations"

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
# name, so sibling resources stay under one namespace/application.
module "child_label" {
  source = "github.com/OmronHealthCare-OHI/terraform-null-label?ref=1.0.0"

  context = module.example.label_context
  name    = "child"
}

output "id" {
  description = "Name the module composed, e.g. vlt-us-dev-platform-example"
  value       = module.example.id
}

output "child_id" {
  description = "Name a child label composes from the module's exported context"
  value       = module.child_label.id
}
