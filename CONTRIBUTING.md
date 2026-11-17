# Contributing

## Versioning and releases

Semantic versioning. Git tags have **no `v` prefix** (for example `0.1.0`). On
each release the moving tags `0` (major), `0.1` (minor), and `latest` are moved
to the release too, so consumers can pin at the level they want.

Consumers pin a tag and never reference `main`:

```hcl
source = "github.com/OmronHealthCare-OHI/terraform-{provider}-{name}?ref=0.1.0"
```

You can also pin a moving tag (`?ref=0`, `?ref=0.1`, or `?ref=latest`) for
automatic updates at that level. While a module is in `0.x`, minor releases may
still break, so prefer exact pins until `1.0.0`.

- **MAJOR**: breaking. A removed or renamed variable or output, or a change that
  forces resource replacement or a provider major bump.
- **MINOR**: backwards compatible additions (a new optional variable or output).
- **PATCH**: backwards compatible fixes.

## How a release happens

1. Open a PR. The labeler (`label-pull-request.yml`) adds a
   `version: major|minor|patch` label from your PR title, or from the branch
   name when the title has no conventional prefix. It runs again when you edit
   the title.
2. Merge to `main`. Release Drafter keeps a draft release updated with the next
   version and the notes.
3. Publish the draft in the Releases tab. That creates the version tag, and the
   moving `major` / `minor` / `latest` tags follow automatically.

The notes and the version come from the shared base in
[OmronHealthCare-OHI/.github](https://github.com/OmronHealthCare-OHI/.github#release-notes),
which `.github/release-drafter.yml` extends. It lists each PR once, under the
first category its labels match, and reads the bump from the title as well as
the labels:
- major: a `!` title (`feat!:`, `fix!:`) or the `version: major` label
- minor: a `feat:` title or the `version: minor` label
- patch: everything else

`.github/labeler.yml` is a copy of the base's rules; change them there first.

Until a repo has one published release, Release Drafter has no baseline: it
resolves `0.0.1` and ignores the `version:` labels. Retag that first draft by
hand; every release after it computes normally.

## Commit and PR conventions

Use [Conventional Commits](https://www.conventionalcommits.org):
`type(scope): summary`. Types: `feat` (minor), `fix` (patch),
`docs` / `chore` / `ci` / `refactor` / `test` / `build` (patch), and any type
with `!` (major). The release notes read only the PR title, so a
`BREAKING CHANGE:` footer alone does not make a release major.

- Keep the subject short, imperative, lowercase, no trailing period.
- The PR title becomes the changelog line, so keep it clean.
- Squash-merge so `main` keeps one commit per PR.

## Checks on every PR

`label-pull-request.yml` runs the labeler. `pull-request.yml` runs
`validate.yml`, which runs
`terraform fmt`, `init`, `validate`, `terraform test`, tflint, Checkov (config in
`.checkov-config.yml`) and a terraform-docs freshness check. A second job
validates every directory under `examples/`. Keep the code formatted with
`terraform fmt`, the `BEGIN_TF_DOCS` block regenerated, and the tests green —
`pre-commit install` does the first two for you.
