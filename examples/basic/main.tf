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

  # Two pipeline stages share the non-prod account, so the stage keeps their
  # resource names apart.
  attributes = ["test"]
}

module "example" {
  source = "../.."

  name    = "example"
  context = module.label.context
}
