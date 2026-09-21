# terraform-module-template

GitHub template for **reusable OHI Terraform modules**. It ships the repo
scaffolding — validation and release workflows, PR labeling, pre-commit hooks,
Checkov, tflint, terraform-docs — plus a seed module that already passes CI, so
a new module repo starts green and you replace the body rather than assemble the
plumbing.

Modules created from this template are **consumed by pinned ref, never copied**:

```hcl
module "thing" {
  source = "github.com/OmronHealthCare-OHI/terraform-{provider}-{name}?ref=0.1.0"

  name    = "thing"
  context = module.label.context
}
```

## What's in the repo

```
├── main.tf                  # seed module — replace with your resources
├── variables.tf             # `name`, `context` (the null-label contract), `extra_tags`
├── outputs.tf               # `id`, `tags`, `label_context`
├── versions.tf              # required_version; required_providers commented out
├── tests/
│   └── defaults.tftest.hcl  # 2 plan-only runs, green out of the box
├── examples/
│   ├── basic/               # minimum call
│   └── complete/            # every input, plus child-label chaining
├── .github/
│   ├── workflows/           # validate, pull-request, safe-change, pre-release,
│   │                        # release, promote-release
│   ├── labeler.yml          # branch / title / path / size → PR labels
│   ├── release-drafter.yml  # draft notes + version resolver
│   └── dependabot.yml       # github-actions monthly, terraform weekly
├── .pre-commit-config.yaml  # fmt, validate, docs, tflint, checkov, test
├── .tflint.hcl              # recommended preset + pinned-source style
├── .checkov-config.yml      # two generic skips; add your own under a fence
├── .terraform-docs.yml      # injects the block at the bottom of this README
├── CONTRIBUTING.md          # versioning, release flow, commit conventions
└── LICENSE                  # MIT
```

No `.terraform.lock.hcl` ships: the seed module declares no providers, so there
is nothing to lock yet. Commit the one `terraform init` writes once you declare
providers in `versions.tf`, so dependabot can bump them.

## Creating a module repo from this template

1. Use the **"Use this template"** button on GitHub. Name the repo
   `terraform-{provider}-{name}` (for example `terraform-aws-lambda-service`);
   use `null` as the provider for a provider-free module.
2. Make it **public** — `terraform init` then fetches it with no credentials.
3. Resolve every `TODO(template)` marker. The full list is
   `grep -rn "TODO(template)" .`; today it covers:
   - [ ] `versions.tf` — set `required_version`, declare `required_providers`,
         and commit the resulting `.terraform.lock.hcl`.
   - [ ] `main.tf` — replace the seed body with the resources the module owns.
         Keep the `label` module, the `context` input and the `label_context`
         output.
   - [ ] `variables.tf` — decide whether the module needs a stage-collision
         validation. Two contexts erase the stage from the id: an unset `stage`
         emits no segment, and `stage = "np"` covers the whole non-prod set.
   - [ ] `outputs.tf` — one output per address a consumer needs, each described.
   - [ ] `tests/defaults.tftest.hcl` — tests for those resources.
   - [ ] `examples/complete/main.tf` — add a `provider` block once the module
         declares one.
   - [ ] `.checkov-config.yml` — add the module's conscious skips under a fence,
         each with its reason.
   - [ ] `.tflint.hcl` — enable the commented opt-in rules if you want them.
   - [ ] This `README.md` — describe the module. Keep the `BEGIN_TF_DOCS` block.
4. Register the **SOUP** entry. The label module wraps
   [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0)
   `0.25.0`, so `terraform init` pulls one third-party module from the Terraform
   Registry. Nothing in the code marks this — it is a register entry, not a
   `TODO(template)` — but every repo generated from this template inherits the
   dependency. `.checkov-config.yml` already sets `download-external-modules`,
   so it is scanned.
5. Create the repo labels the workflows expect (see **Labels**), then set
   squash-only merging and delete-branch-on-merge.
6. Protect `main`. Repository rulesets are not copied by "Use this template", so
   without this step CI is advisory and a `safe-change` label is enough to merge
   a red PR — the auto-approval satisfies the required review on its own. Require
   a pull request, and require these checks to pass:
   - `validate / terraform`
   - `validate / examples`

## What the scaffolding gives you

Running in CI, on every PR:

- **`pull-request.yml`** — runs the labeler, then calls `validate.yml`.
- **`validate.yml`** — `terraform fmt -check -recursive`, `init`, `validate`,
  `terraform test` with JUnit results published as a PR comment, tflint, Checkov
  and a terraform-docs freshness check. A second job validates every directory
  under `examples/`, since each is its own root module the first job never loads.
  Reusable: a `workflow_call` with a `terraform_directory` input.
- **`safe-change.yml`** — auto-approves non-draft PRs carrying the
  `safe-change` label.

Running on release:

- **`pre-release.yml` / `release.yml` / `promote-release.yml`** — Release
  Drafter keeps a draft up to date on every push to `main`; publishing it tags
  the version and moves the `major` / `minor` / `latest` tags. Tags carry no `v`
  prefix. See [CONTRIBUTING.md](CONTRIBUTING.md).

Running locally only:

- **`.pre-commit-config.yaml`** — YAML and whitespace fixers, workflow-schema
  validation, `terraform fmt` / `validate` / `test`, terraform-docs, tflint and
  Checkov.

Everything the hooks run is also checked in CI. The hooks fix what they can
(formatting, the `BEGIN_TF_DOCS` block); CI only reports, so a PR opened without
`pre-commit install` fails instead of being corrected. Install the hooks.

## Labels

`srvaroa/labeler` runs with `continue-on-error: true`, so labels that do not
exist fail silently and the version resolver falls back to `patch`.

GitHub creates `bug` and `documentation` with a new repo. Create the rest:

`version: major`, `version: minor`, `version: patch`, `feature`, `fix`,
`chore`, `maintenance`, `examples`, `infrastructure`, `build definition`,
`dependencies`, `github_actions`, `terraform`, `safe-change`,
`skip-changelog`, `internal`, `AI: instructions`, `AI: agents`, `PR-Size: S`,
`PR-Size: M`, `PR-Size: L`.

`AI: instructions` and `AI: agents` are for `.github/instructions/` and
`.github/agents/`, which this template does not ship. The rules are kept so a
repo that adds them later labels and excludes them from release notes correctly.

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

`terraform init` and `terraform test` reach GitHub to fetch the label module and
the Terraform Registry for the `cloudposse/label/null` it wraps, so both need
network access.

## The seed module

A provider-free placeholder demonstrating the contract every OHI module shares:
it takes a `context` from the caller's
[terraform-null-label](https://github.com/OmronHealthCare-OHI/terraform-null-label)
instance, composes `local.id` and `local.tags` from it, and re-exports
`label_context` so consumers can chain a child label off its hierarchy. Replace
the resources; keep the contract.

`variable "context"` reproduces the label's own context object. Keep the two in
step: Terraform drops object attributes the target type does not declare instead
of erroring, so a field missing here is lost in silence — a green plan with the
wrong names. `tests/defaults.tftest.hcl` asserts on `Namespace` and
`Environment` for exactly that reason.

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
| <a name="module_label"></a> [label](#module\_label) | github.com/OmronHealthCare-OHI/terraform-null-label | 1.0.0 |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_context"></a> [context](#input\_context) | Label context from the caller's terraform-null-label instance. Supplies the <namespace>-<region>-<stage> id segments, the ohi:* tag hierarchy and any attributes. | <pre>object({<br/>    enabled              = optional(bool, true)<br/>    namespace            = optional(string, null)<br/>    region               = optional(string, null)<br/>    stage                = optional(string, null)<br/>    aws_region           = optional(string, null)<br/>    application          = optional(string, null)<br/>    module               = optional(string, null)<br/>    stack_suffix         = optional(string, null)<br/>    stack_name_enabled   = optional(bool, true)<br/>    owner                = optional(string, null)<br/>    name                 = optional(string, null)<br/>    attributes           = optional(list(string), [])<br/>    delimiter            = optional(string, "-")<br/>    tag_prefix           = optional(string, "ohi")<br/>    tag_delimiter        = optional(string, ":")<br/>    id_length_limit      = optional(number, null)<br/>    max_tag_key_length   = optional(number, null)<br/>    max_tag_value_length = optional(number, null)<br/>    tags                 = optional(map(string), {})<br/>  })</pre> | n/a | yes |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | Additional tags merged with the label's generated ohi:* and CloudPosse tags. On a key collision the GENERATED tags win, so Namespace/Environment/Stage/Name and the ohi:* keys cannot be overridden or cleared. Passed through the label module, so its AWS tag constraints apply — including the 50-tag cap, which counts the generated tags. | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Leaf name for this module's resources. Becomes the label's name segment. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The name the label composed for this module's resources |
| <a name="output_label_context"></a> [label\_context](#output\_label\_context) | The context this module's label resolved to, for composing child labels that inherit its naming hierarchy. The leaf name is withheld: the label has a single name slot, so a child that inherited it would compose an id identical to this module's. Child labels must set their own name, and it replaces this one rather than nesting under it, so keep child names unique within the namespace/application hierarchy. |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags applied to every resource here: the label's ohi:* set and Name, merged with extra\_tags |
<!-- END_TF_DOCS -->
