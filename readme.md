# ✅ Fast Conventional Commit Linter

A blazing-fast, dependency-free GitHub Action that lints Pull Request titles and commit messages against the [Conventional Commits](https://www.conventionalcommits.org/) specification.

Instead of downloading heavy Node.js runtimes (`npm install`), this action executes natively in milliseconds using built-in Bash regex matching.

## ✨ Features

- ⚡️ **Instant Execution**: Native composite action means zero Docker/Node.js startup time.
- 🤖 **Bot Evader**: Automatically ignores PRs created by `dependabot`, `renovate`, and other `[bot]` accounts to prevent unnecessary CI failures.
- 🛠️ **Configurable Types**: Easily add your own custom commit types without having to write complex Regex.
- 💥 **Breaking Change Support**: Fully supports the `!` syntax (e.g., `feat(api)!: breaking change`).
- 📝 **Multi-linting**: Can lint just the PR title, or every individual commit message in the PR simultaneously.

## 📥 Inputs

| Input             | Description                                     | Required | Default                                                        |
| ----------------- | ----------------------------------------------- | -------- | -------------------------------------------------------------- |
| `pr_title`        | The PR title to validate.                       | No       | `${{ github.event.pull_request.title }}`                       |
| `commit_messages` | Newline-separated list of commits to check.     | No       | `""`                                                           |
| `allowed_types`   | Comma-separated list of valid commit types.     | No       | `feat,fix,docs,style,refactor,perf,test,build,ci,chore,revert` |
| `custom_regex`    | Completely override the validation regex.       | No       | `""`                                                           |
| `ignore_bots`     | Automatically skip validation for bot accounts. | No       | `true`                                                         |

## 💡 Example Inputs & Outputs

Here is how the action behaves under different scenarios:

### Example 1: Valid PR Title (Default Settings)

**Input:**

```yaml
with:
  pr_title: "feat(auth): add JWT login support"
```

**Output (Action passes):**

```console
=== Fast Conventional Commit Linter ===
Using conventional commit regex with types: [feat,fix,docs,style,refactor,perf,test,build,ci,chore,revert]
✓ Valid PR Title: "feat(auth): add JWT login support"

=== Validation Passed! ===

```

### Example 2: Invalid PR Title

**Input:**

```yaml
with:
  pr_title: "Added login support"
```

**Output (Action fails and blocks the PR):**

```console
=== Fast Conventional Commit Linter ===
Using conventional commit regex with types: [feat,fix,docs,style,refactor,perf,test,build,ci,chore,revert]
✖ Invalid PR Title: "Added login support"

=== Validation Failed ===
Expected format: <type>[optional scope][!]: <description>
Example 1: feat(api): add new authentication endpoint
Example 2: fix!: breaking change to database schema
Allowed types: feat,fix,docs,style,refactor,perf,test,build,ci,chore,revert
Error: Process completed with exit code 1.

```

### Example 3: Custom Allowed Types (e.g., adding `wip`)

**Input:**

```yaml
with:
  pr_title: "wip(ui): draft new dashboard layout"
  allowed_types: "feat,fix,wip"
```

**Output (Action passes):**

```console
=== Fast Conventional Commit Linter ===
Using conventional commit regex with types: [feat,fix,wip]
✓ Valid PR Title: "wip(ui): draft new dashboard layout"

=== Validation Passed! ===

```

### Example 4: Validating Multiple Commits

**Input:**

```yaml
with:
  pr_title: ""
  commit_messages: |
    fix: resolve memory leak in worker
    chore: update npm dependencies
```

**Output (Action passes):**

```console
=== Fast Conventional Commit Linter ===
Using conventional commit regex with types: [feat,fix,docs,style,refactor,perf,test,build,ci,chore,revert]

Checking individual commit messages...
✓ Valid Commit: "fix: resolve memory leak in worker"
✓ Valid Commit: "chore: update npm dependencies"

=== Validation Passed! ===

```

### Example 5: Bot Auto-Ignore Triggered

**Input:**
_(Triggered by Dependabot opening a PR with a non-conventional title)_

```yaml
with:
  pr_title: "Bump express from 4.18.1 to 4.18.2"
  ignore_bots: "true"
```

**Output (Action passes without validating the title):**

```console
=== Fast Conventional Commit Linter ===
✓ Skipping validation for automated bot account: dependabot[bot]

```
