# Examples

This document shows real-world scenarios where `git-auto-commit` is useful, with a working GitHub Actions workflow for each. The scenarios are based on questions and use cases that have come up in the [issues](https://github.com/stefanzweifel/git-auto-commit-action/issues) and [discussions](https://github.com/stefanzweifel/git-auto-commit-action/discussions) of this repository over the years.

If you have a use case that isn't covered here, [open a discussion](https://github.com/stefanzweifel/git-auto-commit-action/discussions) — we may add it.

## Table of Contents

- [Auto-format code on pull requests](#auto-format-code-on-pull-requests)
- [Auto-fix lint errors](#auto-fix-lint-errors)
- [Update dependency lock files](#update-dependency-lock-files)
- [Build and commit compiled assets](#build-and-commit-compiled-assets)
- [Auto-generate API documentation](#auto-generate-api-documentation)
- [Update README with generated content](#update-readme-with-generated-content)
- [Maintain a CHANGELOG](#maintain-a-changelog)
- [Sync translations / i18n files](#sync-translations--i18n-files)
- [Publish a static site to a separate branch](#publish-a-static-site-to-a-separate-branch)
- [Scheduled data refresh](#scheduled-data-refresh)
- [Create a release tag without a commit](#create-a-release-tag-without-a-commit)
- [Fail the build instead of pushing changes (drift check)](#fail-the-build-instead-of-pushing-changes-drift-check)
- [Sign automated commits with GPG](#sign-automated-commits-with-gpg)
- [Squash automated changes into the previous commit](#squash-automated-changes-into-the-previous-commit)

---

## Auto-format code on pull requests

**Description:** Run a code formatter (Prettier, php-cs-fixer, Black, gofmt, rustfmt, …) on every pull request and commit the resulting changes back to the contributor's branch. Contributors don't have to think about style; the bot fixes it for them.

This is the most common use case for this Action. Running it on `pull_request` means the formatter only touches the PR branch — never your default branch directly.

```yaml
name: Format

on: pull_request

jobs:
  prettier:
    runs-on: ubuntu-latest
    permissions:
      contents: write

    steps:
      - uses: actions/checkout@v5
        with:
          ref: ${{ github.head_ref }}

      - uses: actions/setup-node@v4
        with:
          node-version: 20

      - run: npx prettier --write .

      - uses: stefanzweifel/git-auto-commit-action@v7
        with:
          commit_message: "style: apply prettier formatting"
```

> [!TIP]
> If the PR comes from a fork, the Action can only push back if the contributor enabled "Allow edits by maintainers". See the [forks section in the README](README.md#use-in-forks-from-public-repositories) for details.

---

## Auto-fix lint errors

**Description:** Many linters can both report and auto-fix problems (`eslint --fix`, `rubocop -a`, `ruff --fix`, `stylelint --fix`, …). Use the Action to commit the auto-fixed result so reviewers only see the issues that need human judgement.

```yaml
name: Lint and fix

on: pull_request

jobs:
  eslint:
    runs-on: ubuntu-latest
    permissions:
      contents: write

    steps:
      - uses: actions/checkout@v5
        with:
          ref: ${{ github.head_ref }}

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm

      - run: npm ci
      - run: npx eslint . --fix

      - uses: stefanzweifel/git-auto-commit-action@v7
        with:
          commit_message: "chore: apply eslint --fix"
```

> [!TIP]
> `file_pattern` is intentionally omitted here. If one of several custom patterns does not match a file in the repository, `git add` can fail with a pathspec error. Let the linter decide which files to change, or use a custom pattern that you know exists in your repository.

---

## Update dependency lock files

**Description:** When a dependency tool produces a fresh lock file (`package-lock.json`, `composer.lock`, `Gemfile.lock`, `poetry.lock`, …), commit only the lock file. Pair this with a scheduled job to keep lock files in sync without manual intervention.

```yaml
name: Refresh lock file

on:
  schedule:
    - cron: "0 6 * * 1" # every Monday at 06:00 UTC
  workflow_dispatch:

jobs:
  refresh:
    runs-on: ubuntu-latest
    permissions:
      contents: write

    steps:
      - uses: actions/checkout@v5

      - uses: actions/setup-node@v4
        with:
          node-version: 20

      - run: npm install --package-lock-only

      - uses: stefanzweifel/git-auto-commit-action@v7
        with:
          commit_message: "chore(deps): refresh package-lock.json"
          file_pattern: package-lock.json
```

---

## Build and commit compiled assets

**Description:** For projects that ship a `dist/` folder (libraries, browser extensions, themes), build the assets in CI and commit them so consumers can install directly from the repo without a build step.

```yaml
name: Build dist

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: write

    steps:
      - uses: actions/checkout@v5

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm

      - run: npm ci
      - run: npm run build

      - uses: stefanzweifel/git-auto-commit-action@v7
        with:
          commit_message: "build: update dist/"
          file_pattern: "dist/**"
```

> [!NOTE]
> If `dist/` is in `.gitignore`, the Action will not pick up changes. See the [troubleshooting section in the README](README.md#change-to-file-is-not-detected).

---

## Auto-generate API documentation

**Description:** Tools like TypeDoc, Doxygen, Sphinx, or `cargo doc` generate documentation from source comments. Regenerate on every push to `main` and commit the output so the published docs always match the latest code.

```yaml
name: Docs

on:
  push:
    branches: [main]

jobs:
  typedoc:
    runs-on: ubuntu-latest
    permissions:
      contents: write

    steps:
      - uses: actions/checkout@v5

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm

      - run: npm ci
      - run: npx typedoc --out docs/api src/index.ts

      - uses: stefanzweifel/git-auto-commit-action@v7
        with:
          commit_message: "docs: regenerate API reference"
          file_pattern: "docs/api/**"
```

---

## Update README with generated content

**Description:** Many projects keep dynamic sections in the README — a contributor list, a badge gallery, a table of contents, a list of supported plugins. Regenerate them on a schedule (or when a related file changes) and commit the result.

```yaml
name: Update contributors

on:
  schedule:
    - cron: "0 0 * * 0" # weekly
  workflow_dispatch:

jobs:
  contributors:
    runs-on: ubuntu-latest
    permissions:
      contents: write

    steps:
      - uses: actions/checkout@v5

      - uses: akhilmhdh/contributors-readme-action@v2.3.10
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - uses: stefanzweifel/git-auto-commit-action@v7
        with:
          commit_message: "docs: update contributors"
          file_pattern: README.md
```

---

## Maintain a CHANGELOG

**Description:** Generate or update `CHANGELOG.md` from commit history or release notes after each merge to `main`, and commit it back.

```yaml
name: Update CHANGELOG

on:
  push:
    branches: [main]

jobs:
  changelog:
    runs-on: ubuntu-latest
    permissions:
      contents: write

    steps:
      - uses: actions/checkout@v5
        with:
          fetch-depth: 0 # full history so the generator sees all commits

      - uses: actions/setup-node@v4
        with:
          node-version: 20

      - run: npx conventional-changelog -p angular -i CHANGELOG.md -s

      - uses: stefanzweifel/git-auto-commit-action@v7
        with:
          commit_message: "docs: update CHANGELOG"
          file_pattern: CHANGELOG.md
```

---

## Sync translations / i18n files

**Description:** When translations are managed in an external service (Crowdin, Lokalise, Weblate) or extracted from source, pull or generate the latest catalogs on a schedule and commit them.

```yaml
name: Sync translations

on:
  schedule:
    - cron: "0 3 * * *" # daily at 03:00 UTC

jobs:
  sync:
    runs-on: ubuntu-latest
    permissions:
      contents: write

    steps:
      - uses: actions/checkout@v5

      - name: Download translations
        run: ./scripts/pull-translations.sh
        env:
          CROWDIN_TOKEN: ${{ secrets.CROWDIN_TOKEN }}

      - uses: stefanzweifel/git-auto-commit-action@v7
        with:
          commit_message: "i18n: sync translations from Crowdin"
          file_pattern: "locales/**/*.json"
```

---

## Publish a static site to a separate branch

**Description:** Build a static site on `main` and push the generated output to a `gh-pages` branch so GitHub Pages can serve it. Use a second checkout directory for the publish branch so the source checkout and generated site do not get mixed together.

Create the `gh-pages` branch once before using this workflow.

```yaml
name: Build site

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: write

    steps:
      - uses: actions/checkout@v5
        with:
          path: source

      - uses: actions/checkout@v5
        with:
          ref: gh-pages
          path: site

      - name: Build site
        working-directory: source
        run: ./build-site.sh # produces output in ./public

      - name: Replace publish branch contents
        run: |
          find site -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
          cp -R source/public/. site/

      - uses: stefanzweifel/git-auto-commit-action@v7
        with:
          repository: site
          branch: gh-pages
          commit_message: "site: rebuild from ${{ github.sha }}"
```

> [!NOTE]
> For most Pages workflows the official [`actions/deploy-pages`](https://github.com/actions/deploy-pages) is a better fit. Use this approach when you specifically want the build output stored in a branch.

---

## Scheduled data refresh

**Description:** Pull data from an external source on a schedule and commit it. Common examples: tracking statistics, snapshotting an API response, refreshing a cached dataset.

```yaml
name: Refresh stats

on:
  schedule:
    - cron: "0 * * * *" # hourly
  workflow_dispatch:

jobs:
  refresh:
    runs-on: ubuntu-latest
    permissions:
      contents: write

    steps:
      - uses: actions/checkout@v5

      - run: curl -sSL https://api.example.com/stats.json -o data/stats.json

      - uses: stefanzweifel/git-auto-commit-action@v7
        with:
          commit_message: "data: refresh hourly stats"
          file_pattern: "data/*.json"
```

---

## Create a release tag without a commit

**Description:** Sometimes you want to tag the current HEAD as a release without committing any files. Use `create_git_tag_only` together with `tag_name` and `tagging_message`.

```yaml
name: Tag release

on:
  workflow_dispatch:
    inputs:
      version:
        description: "Version to tag (e.g. v1.4.0)"
        required: true

jobs:
  tag:
    runs-on: ubuntu-latest
    permissions:
      contents: write

    steps:
      - uses: actions/checkout@v5

      - uses: stefanzweifel/git-auto-commit-action@v7
        with:
          create_git_tag_only: true
          tag_name: ${{ inputs.version }}
          tagging_message: "Release ${{ inputs.version }}"
```

---

## Fail the build instead of pushing changes (drift check)

**Description:** Sometimes you don't want a bot to push fixes — you want to fail the build so the contributor fixes them locally. Use the `changes_detected` output as a check: run the formatter, skip branch checkout/fetch/push, and fail if anything changed.

```yaml
name: Format check

on: pull_request

jobs:
  check:
    runs-on: ubuntu-latest
    permissions:
      contents: read

    steps:
      - uses: actions/checkout@v5

      - uses: actions/setup-node@v4
        with:
          node-version: 20

      - run: npx prettier --write .

      - uses: stefanzweifel/git-auto-commit-action@v7
        id: auto-commit
        with:
          skip_checkout: true
          skip_fetch: true
          skip_push: true

      - name: Fail if formatting was needed
        if: steps.auto-commit.outputs.changes_detected == 'true'
        run: |
          echo "::error::Code is not formatted. Run 'npx prettier --write .' locally."
          exit 1
```

---

## Sign automated commits with GPG

**Description:** If your branch protection rules require signed commits, the bot's commits need to be signed too. Import a GPG key first, then tell the Action to use the key's identity as the commit author.

```yaml
name: Format (signed)

on: pull_request

jobs:
  format:
    runs-on: ubuntu-latest
    permissions:
      contents: write

    steps:
      - uses: actions/checkout@v5
        with:
          ref: ${{ github.head_ref }}

      - name: Import GPG key
        id: import-gpg
        uses: crazy-max/ghaction-import-gpg@v6
        with:
          gpg_private_key: ${{ secrets.GPG_PRIVATE_KEY }}
          passphrase: ${{ secrets.GPG_PASSPHRASE }}
          git_user_signingkey: true
          git_commit_gpgsign: true

      - run: npx prettier --write .

      - uses: stefanzweifel/git-auto-commit-action@v7
        with:
          commit_message: "style: apply prettier"
          commit_user_name: ${{ steps.import-gpg.outputs.name }}
          commit_user_email: ${{ steps.import-gpg.outputs.email }}
          commit_author: "${{ steps.import-gpg.outputs.name }} <${{ steps.import-gpg.outputs.email }}>"
```

See discussion [#334](https://github.com/stefanzweifel/git-auto-commit-action/discussions/334) for background.

---

## Squash automated changes into the previous commit

**Description:** Avoid noisy "apply automatic changes" commits by amending the last commit instead. Useful when the bot fix is trivial and you don't want a separate entry in the history.

> [!CAUTION]
> Amending rewrites history. Only use this on branches where force-pushing is acceptable (typically PR branches, never `main`).

```yaml
name: Format (amend)

on: pull_request

jobs:
  format:
    runs-on: ubuntu-latest
    permissions:
      contents: write

    steps:
      - uses: actions/checkout@v5
        with:
          ref: ${{ github.head_ref }}
          fetch-depth: 2 # need previous commit for --amend

      - run: npx prettier --write .

      - name: Read previous commit metadata
        id: last
        run: |
          echo "message=$(git log -1 --pretty=%s)" >> $GITHUB_OUTPUT
          echo "author=$(git log -1 --pretty='%an <%ae>')" >> $GITHUB_OUTPUT

      - uses: stefanzweifel/git-auto-commit-action@v7
        with:
          commit_message: ${{ steps.last.outputs.message }}
          commit_author: ${{ steps.last.outputs.author }}
          commit_options: "--amend --no-edit"
          push_options: "--force"
          skip_fetch: true
```

See discussion [#159](https://github.com/stefanzweifel/git-auto-commit-action/issues/159#issuecomment-845347950) for details.
