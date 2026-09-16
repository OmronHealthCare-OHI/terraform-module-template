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
}

module "example" {
  source = "../.."

  name    = "example"
  context = module.label.context
}
