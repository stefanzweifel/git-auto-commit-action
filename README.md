# git-auto-commit Action

> The GitHub Action for committing files for the 80% use case.

This GitHub Action automatically commits files which have been changed during a Workflow run and pushes the commit back to GitHub.  
The default committer is "GitHub Actions <actions@github.com>", and the default author of the commit is "Your GitHub Username <github_username@users.noreply.github.com>".

This Action has been inspired and adapted from the [auto-commit](https://github.com/cds-snc/github-actions/tree/master/auto-commit
)-Action of the Canadian Digital Service and this [commit](https://github.com/elstudio/actions-js-build/blob/41d604d6e73d632e22eac40df8cc69b5added04b/commit/entrypoint.sh)-Action by Eric Johnson.

## Usage

Add the following step at the end of your job, after other steps that might add or change files.

```yaml
- uses: stefanzweifel/git-auto-commit-action@v4
  with:
    # Required
    commit_message: Apply automatic changes

    # Optional branch to push to, defaults to the current branch
    branch: feature-123

    # Optional options appended to `git-commit`
    # See https://git-scm.com/docs/git-commit for a list of available options
    commit_options: '--no-verify --signoff'

    # Optional glob pattern of files which should be added to the commit
    # See the `pathspec`-documentation for git
    # - https://git-scm.com/docs/git-add#Documentation/git-add.txt-ltpathspecgt82308203
    # - https://git-scm.com/docs/gitglossary#Documentation/gitglossary.txt-aiddefpathspecapathspec
    file_pattern: src/*.js tests/*.js

    # Optional local file path to the repository
    repository: .

    # Optional commit user and author settings
    commit_user_name: My GitHub Actions Bot
    commit_user_email: my-github-actions-bot@example.org
    commit_author: Author <actions@github.com>

    # Optional tag message 
    # Action will create and push a new tag to the remote repository and the defined branch
    tagging_message: 'v1.0.0'

    # Optional options appended to `git-push`
    push_options: '--force'
    
    # Optional: Disable dirty check and always try to create a commit and push
    skip_dirty_check: true
```

## Example

In this example, we're running `php-cs-fixer` in a PHP project to fix the codestyle automatically, then commit possible changed files back to the repository.

Note that we explicitly specify `${{ github.head_ref }}` in the checkout Action.
This is required in order to work with the `pull_request` event (or any other non-`push` event).

```yaml
name: php-cs-fixer

on:
  pull_request:
  push:
    branches:
      - "master"

jobs:
  php-cs-fixer:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2
      with:
        ref: ${{ github.head_ref }}

    - name: Run php-cs-fixer
      uses: docker://oskarstark/php-cs-fixer-ga

    - uses: stefanzweifel/git-auto-commit-action@v4
      with:
        commit_message: Apply php-cs-fixer changes
```

## Inputs

Checkout [`action.yml`](https://github.com/stefanzweifel/git-auto-commit-action/blob/master/action.yml) for a full list of supported inputs.

## Outputs

You can use these outputs to trigger other Actions in your Workflow run based on the result of `git-auto-commit-action`.

- `changes_detected`: Returns either "true" or "false" if the repository was dirty and files have changed.

## Limitations & Gotchas

### Checkout the correct branch

You must use `action/checkout@v2` or later versions to checkout the repository.
In non-`push` events, such as `pull_request`, make sure to specify the `ref` to checkout:

```yaml
- uses: actions/checkout@v2
  with:
    ref: ${{ github.head_ref }}
```

You have to do this do avoid that the `checkout`-Action clones your repository in a detached state.

### Commits of this Action do not trigger new Workflow runs

The resulting commit **will not trigger** another GitHub Actions Workflow run.
This is due to [limititations set by GitHub](https://help.github.com/en/actions/reference/events-that-trigger-workflows#triggering-new-workflows-using-a-personal-access-token).

> When you use the repository's GITHUB_TOKEN to perform tasks on behalf of the GitHub Actions app, events triggered by the GITHUB_TOKEN will not create a new workflow run. This prevents you from accidentally creating recursive workflow runs.

You can change this by creating a new [Personal Access Token (PAT)](https://github.com/settings/tokens/new),
storing the token as a secret in your repository and then passing the new token to the [`actions/checkout`](https://github.com/actions/checkout#usage) Action step.

```yaml
- uses: actions/checkout@v2
  with:
    token: ${{ secrets.PAT }}
```

### Unable to commit into PRs from forks

GitHub currently prohibits Actions to push commits to forks, even when they created a PR and allow edits.
See [issue #25](https://github.com/stefanzweifel/git-auto-commit-action/issues/25) for more information.

### Signing Commits & Other Git Command Line Options

Using command lines options needs to be done manually for each workflow which you require the option enabled. So for example signing commits requires you to import the gpg signature each and every time. The following list of actions are worth checking out if you need to automate these tasks regulary
- [Import GPG Signature](https://github.com/crazy-max/ghaction-import-gpg) (Suggested by [TGTGamer](https://github.com/tgtgamer))

## Troubleshooting

### Action does not push commit to repository

Make sure to [checkout the correct branch](#checkout-the-correct-branch).

### Action does not push commit to repository: Authentication Issue

If your Workflow can't push the commit to the repository because of authentication issues,
please update your Workflow configuration and usage of [`actions/checkout`](https://github.com/actions/checkout#usage).

Updating the `token` value with a Personal Access Token should fix your issues.

### Push to protected branches

If your repository uses [protected branches](https://help.github.com/en/github/administering-a-repository/configuring-protected-branches) you have to do the following changes to your Workflow for the Action to work properly.

You have to enable force pushes to a protected branch (See [documentation](https://help.github.com/en/github/administering-a-repository/enabling-force-pushes-to-a-protected-branch)) and update your Workflow to use force push like this.

```yaml
    - uses: stefanzweifel/git-auto-commit-action@v4
      with:
        commit_message: Apply php-cs-fixer changes
        push_options: --force
```

In addition, you have to create a new [Personal Access Token (PAT)](https://github.com/settings/tokens/new),
store the token as a secret in your repository and pass the new token to the [`actions/checkout`](https://github.com/actions/checkout#usage) Action step.

```yaml
- uses: actions/checkout@v2
  with:
    token: ${{ secrets.PAT }}
```
You can learn more about Personal Access Token in the [GitHub documentation](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token).

Note: If you're working in an organisation and you don't want to create the PAT from your personal account, we recommend using a bot-account for such tokens.

### No new workflows are triggered by the commit of this action

This is due to limitations set up by GitHub, [commits of this Action do not trigger new Workflow runs](#commits-of-this-action-do-not-trigger-new-workflow-runs).

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/stefanzweifel/git-auto-commit-action/tags).

We also provide major version tags to make it easier to always use the latest release of a major version. For example you can use `stefanzweifel/git-auto-commit-action@v4` to always use the latest release of the current major version.
(More information about this [here](https://help.github.com/en/actions/building-actions/about-actions#versioning-your-action).)

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/stefanzweifel/git-auto-commit-action/blob/master/LICENSE) file for details.
