# terraform-module-template

GitHub template for **reusable OHI Terraform modules**. It ships the repo
scaffolding — validation and release workflows, labeling, pre-commit, Checkov,
terraform-docs — plus a seed module that already passes CI, so a new module repo
starts green and you replace the body rather than assemble the plumbing.

Modules created from this template are **consumed by pinned ref, never copied**:

```hcl
module "thing" {
  source = "github.com/OmronHealthCare-OHI/terraform-{provider}-{name}?ref=0.1.0"

  name    = "thing"
  context = module.label.context
}
```

## Creating a module repo from this template

1. Use the **"Use this template"** button on GitHub. Name the repo
   `terraform-{provider}-{name}` (for example `terraform-aws-lambda-service`);
   use `null` as the provider for a provider-free module.
2. Make it **public** — `terraform init` then fetches it with no credentials.
3. Resolve every `TODO(template)` marker. The complete list comes from
   `grep -rn "TODO(template)" .`. At minimum:
   - [ ] `versions.tf` — set `required_version`, declare `required_providers`,
         and commit the `.terraform.lock.hcl` that `terraform init` writes.
   - [ ] `main.tf` — replace the seed body with the resources the module owns.
         Keep the `label` module, the `context` input and the `label_context`
         output.
   - [ ] `variables.tf` / `outputs.tf` — the module's real inputs and outputs,
         each with a description (terraform-docs renders them below).
   - [ ] `tests/defaults.tftest.hcl` — tests for those resources.
   - [ ] `examples/basic` and `examples/complete` — both are validated in CI.
   - [ ] `.checkov-config.yml` — add the module's conscious skips under a fence,
         each with its reason.
   - [ ] This `README.md` — describe the module. Keep the `BEGIN_TF_DOCS` block.
4. Create the repo labels the workflows expect (see **Labels** below), then set
   squash-only merging and delete-branch-on-merge.

## What the scaffolding gives you

- **`validate.yml`** — `terraform fmt -check -recursive`, `init`, `validate`,
  `terraform test` with JUnit results published to the PR, and Checkov. A second
  job validates every directory under `examples/`, since each is its own root
  module the first job never loads. Reusable: it is a `workflow_call` with a
  `terraform_directory` input.
- **`pull-request.yml`** — runs the labeler, then calls `validate.yml`.
- **`safe-change.yml`** — auto-approves PRs carrying the `safe-change` label.
- **`pre-release.yml` / `release.yml` / `promote-release.yml`** — Release Drafter
  keeps a draft up to date on every push to `main`; publishing it tags the
  version and moves the `major` / `minor` / `latest` tags. See
  [CONTRIBUTING.md](CONTRIBUTING.md).
- **`dependabot.yml`** — github-actions monthly, terraform weekly.
- **`.pre-commit-config.yaml`** — fmt, validate, terraform-docs, tflint, Checkov
  and `terraform test` before each commit.

## Labels

`srvaroa/labeler` runs with `continue-on-error: true`, so labels that do not
exist fail silently and the version resolver falls back to `patch`. Create:

`version: major`, `version: minor`, `version: patch`, `feature`, `bug`, `fix`,
`chore`, `maintenance`, `documentation`, `examples`, `infrastructure`,
`build definition`, `dependencies`, `github_actions`, `terraform`,
`safe-change`, `skip-changelog`, `internal`, `AI: instructions`, `AI: agents`,
`PR-Size: S`, `PR-Size: M`, `PR-Size: L`.

## Local development

Install the toolchain (via [mise](https://mise.jdx.dev):
`mise use -g terraform tflint terraform-docs checkov pre-commit`), then:

```sh
pre-commit install
terraform init -backend=false
terraform validate
terraform test
pre-commit run --all-files
```

## The seed module

A provider-free placeholder that demonstrates the shared contract: it takes a
`context` from the caller's [terraform-null-label](https://github.com/OmronHealthCare-OHI/terraform-null-label)
instance, composes `local.id` and `local.tags` from it, and re-exports
`label_context` for child labels. Replace it; keep the contract.

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |

### Providers

No providers.

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_label"></a> [label](#module\_label) | github.com/OmronHealthCare-OHI/terraform-null-label | 0.1.1 |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_context"></a> [context](#input\_context) | Label context from the caller's terraform-null-label instance. Supplies the <country><stage>-<region> prefix, the ohi:* tag hierarchy and any attributes. | <pre>object({<br/>    enabled              = optional(bool, true)<br/>    country              = optional(string, null)<br/>    stage                = optional(string, null)<br/>    aws_region           = optional(string, null)<br/>    deployment_region    = optional(string, null)<br/>    project              = optional(string, null)<br/>    application          = optional(string, null)<br/>    module               = optional(string, null)<br/>    stack_suffix         = optional(string, null)<br/>    stack_name_enabled   = optional(bool, true)<br/>    owner                = optional(string, null)<br/>    name                 = optional(string, null)<br/>    attributes           = optional(list(string), [])<br/>    non_prd              = optional(bool, false)<br/>    delimiter            = optional(string, "-")<br/>    prefix_enabled       = optional(bool, true)<br/>    tag_prefix           = optional(string, "ohi")<br/>    tag_delimiter        = optional(string, ":")<br/>    id_length_limit      = optional(number, null)<br/>    max_tag_key_length   = optional(number, null)<br/>    max_tag_value_length = optional(number, null)<br/>    tags                 = optional(map(string), {})<br/>  })</pre> | n/a | yes |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | Additional tags merged on top of the label's generated ohi:* and Name tags. Passed through the label module, so its AWS tag constraints apply. | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Leaf name for this module's resources. Becomes the label's name segment. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The name the label composed for this module's resources |
| <a name="output_label_context"></a> [label\_context](#output\_label\_context) | The context this module's label resolved to, for composing child labels that inherit its naming hierarchy. The leaf name is withheld: the label has a single name slot, so a child that inherited it would compose an id identical to this module's. Child labels must set their own name, and it replaces this one rather than nesting under it, so keep child names unique within the project/application hierarchy. |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags applied to every resource here: the label's ohi:* set and Name, merged with extra\_tags |
<!-- END_TF_DOCS -->
