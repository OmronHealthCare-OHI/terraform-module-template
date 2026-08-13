terraform {
  # TODO(template): set the floor your module actually needs. >= 1.9.0 matches
  # terraform-aws-lambda-service; terraform-null-label sits at >= 1.3.0, the
  # floor for optional() object attributes.
  required_version = ">= 1.9.0"

  # TODO(template): declare the providers this module uses, then commit the
  # .terraform.lock.hcl that `terraform init` writes so dependabot can bump
  # them. The seed module is provider-free, so neither exists yet.
  #
  # required_providers {
  #   aws = {
  #     source  = "hashicorp/aws"
  #     version = ">= 5.0"
  #   }
  # }
}
