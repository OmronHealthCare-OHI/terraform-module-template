variable "name" {
  type        = string
  description = "Leaf name for this module's resources. Becomes the label's name segment."

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.name))
    error_message = "name may only contain letters, digits, hyphens and underscores."
  }
}

# Naming and tags come from the shared label module. Its context object is
# reproduced here verbatim so callers can pass `context = module.label.context`
# and the module inherits country/stage/region and the ohi:* hierarchy. Keep
# this block in step with terraform-null-label: it is the contract, not a
# convenience.
variable "context" {
  description = "Label context from the caller's terraform-null-label instance. Supplies the <country><stage>-<region> prefix, the ohi:* tag hierarchy and any attributes."
  type = object({
    enabled              = optional(bool, true)
    country              = optional(string, null)
    stage                = optional(string, null)
    aws_region           = optional(string, null)
    deployment_region    = optional(string, null)
    project              = optional(string, null)
    application          = optional(string, null)
    module               = optional(string, null)
    stack_suffix         = optional(string, null)
    stack_name_enabled   = optional(bool, true)
    owner                = optional(string, null)
    name                 = optional(string, null)
    attributes           = optional(list(string), [])
    non_prd              = optional(bool, false)
    delimiter            = optional(string, "-")
    prefix_enabled       = optional(bool, true)
    tag_prefix           = optional(string, "ohi")
    tag_delimiter        = optional(string, ":")
    id_length_limit      = optional(number, null)
    max_tag_key_length   = optional(number, null)
    max_tag_value_length = optional(number, null)
    tags                 = optional(map(string), {})
  })
  # No default: every resource here is named from the label, and a caller
  # without a context has nothing this module can name. Required so that is an
  # input error rather than a precondition failure mid-plan.
  nullable = false

  # TODO(template): if two deployments of this module can share one AWS account,
  # the names must differ. The prefix is the only place a stage reaches a name,
  # and two settings erase it there: non_prd = true collapses every non-prod
  # stage into <country>np, and leaving stage unset does the same for the rest.
  # terraform-aws-lambda-service adds a validation here rejecting such a
  # context; copy it if this module's resources are per-stage.
}

variable "extra_tags" {
  type        = map(string)
  description = "Additional tags merged on top of the label's generated ohi:* and Name tags. Passed through the label module, so its AWS tag constraints apply."
  default     = {}
}
