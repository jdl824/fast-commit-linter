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

## 🛠️ Usage Examples

### 1. Basic PR Title Linting (Most Common)

```yaml
name: Lint PR

on:
  pull_request:
    types: [opened, edited, synchronize, reopened]

jobs:
  lint-title:
    runs-on: ubuntu-latest
    steps:
      - uses: harryvasanth/fast-commit-linter@v1
```

### 2. Customizing Allowed Types

Add your own team-specific types like `wip` or `hotfix`.

```yaml
jobs:
  lint-title:
    runs-on: ubuntu-latest
    steps:
      - uses: harryvasanth/fast-commit-linter@v1
        with:
          allowed_types: "feat,fix,docs,chore,wip,hotfix"
```

### 3. Linting all commits inside a Pull Request

If your team uses squash-merging, linting just the PR title is usually enough. But if you want to enforce that _every_ commit in the PR branch is valid:

```yaml
jobs:
  lint-commits:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Get PR Commits
        id: get-commits
        run: |
          COMMITS=$(git log --format=%s origin/${{ github.base_ref }}..origin/${{ github.head_ref }})
          # Output multiline string safely
          EOF=$(dd if=/dev/urandom bs=15 count=1 status=none | base64)
          echo "messages<<$EOF" >> $GITHUB_OUTPUT
          echo "$COMMITS" >> $GITHUB_OUTPUT
          echo "$EOF" >> $GITHUB_OUTPUT

      - uses: harryvasanth/fast-commit-linter@v1
        with:
          pr_title: "" # Disable PR title check if you only want commit messages
          commit_messages: ${{ steps.get-commits.outputs.messages }}
```
