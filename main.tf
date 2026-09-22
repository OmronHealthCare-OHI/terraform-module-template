# TODO(template): replace the body below with the resources this module owns.
#
# Three things should survive that replacement, because they are the contract
# every OHI module shares:
#
#   1. the `label` module — naming and tags are composed here, never assembled
#      from strings, so a caller states where it deploys once and passes the
#      resolved context down;
#   2. the `context` input — the caller's label context, reproduced as an
#      object type in variables.tf;
#   3. the `label_context` output — so a consumer can chain a child label off
#      this module's hierarchy.
#
# Name every resource from `local.id` and tag it with `local.tags`. Where a
# service has a cap the label cannot know about (IAM's 64 characters, a
# charset), assert it with a `precondition` on the resource that carries the
# name rather than a `validation` on the input: the composed name only exists
# once the label has resolved. See terraform-aws-lambda-service/main.tf for a
# worked example.

module "label" {
  source = "github.com/OmronHealthCare-OHI/terraform-null-label?ref=1.0.0"

  context = var.context
  name    = var.name
  tags    = var.extra_tags
}

locals {
  # {namespace}-{region}-{stage}-{application}-{name}-{attributes}, e.g.
  # vlt-us-dev-platform-example. The AWS region is not in the id; it is the
  # ohi:aws-region tag.
  id = module.label.id

  # The label's generated ohi:* set and Name, merged with extra_tags.
  tags = module.label.tags
}
