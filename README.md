# git-auto-commit-action

This GitHub Action automatically commits files which have been changed during a Workflow run and pushes the commit back to GitHub.
The default committer is "GitHub Actions <actions@github.com>" and the default author of the commit is "Your GitHub Username <github_username@users.noreply.github.com>".

If no changes are detected, the Action does nothing.

This Action has been inspired and adapted from the [auto-commit](https://github.com/cds-snc/github-actions/tree/master/auto-commit
)-Action of the Canadian Digital Service and this [commit](https://github.com/elstudio/actions-js-build/blob/41d604d6e73d632e22eac40df8cc69b5added04b/commit/entrypoint.sh)-Action by Eric Johnson.

*This Action currently can't be used in conjunction with pull requests of forks. See [issue #25](https://github.com/stefanzweifel/git-auto-commit-action/issues/25) for more information.*

## Usage

**Note:** This Action requires that you use `action/checkout@v2` or above to checkout your repository.

Add the following step at the end of your job.

```yaml
- uses: stefanzweifel/git-auto-commit-action@v4.1.1
  with:
    commit_message: Apply automatic changes

    # Optional name of the branch the commit should be pushed to
    # Required if Action is used in Workflow listening to the `pull_request` event
    branch: ${{ github.head_ref }}

    # Optional git params
    commit_options: '--no-verify --signoff'

    # Optional glob pattern of files which should be added to the commit
    file_pattern: src/\*.js

    # Optional local file path to the repository
    repository: .

    # Optional commit user and author settings
    commit_user_name: My GitHub Actions Bot
    commit_user_email: my-github-actions-bot@example.org
    commit_author: Author <actions@github.com>

    # Optional tag message. Will create and push a new tag to the remote repository
    tagging_message: 'v1.0.0'
```

The Action will only commit files back, if changes are available. The resulting commit **will not trigger** another GitHub Actions Workflow run!

We recommend to use this Action in Workflows, which listen to the `pull_request` event. You can then use the option `branch: ${{ github.head_ref }}` to set up the branch name correctly.
If you don't pass a branch name, the Action will try to push the commit to a branch with the same name, as with which the repo has been checked out.

## Example Usage

This Action will only work, if the job in your Workflow changes files.
The most common use case for this, is when you're running a Linter or Code-Style fixer on GitHub Actions.

In this example I'm running `php-cs-fixer` in a PHP project.

### Example on `pull_request` event

```yaml
name: php-cs-fixer

on: pull_request

jobs:
  php-cs-fixer:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2
      with:
        ref: ${{ github.head_ref }}

    - name: Run php-cs-fixer
      uses: docker://oskarstark/php-cs-fixer-ga

    - uses: stefanzweifel/git-auto-commit-action@v4.1.1
      with:
        commit_message: Apply php-cs-fixer changes
        branch: ${{ github.head_ref }}
```

### Example on `push` event

```yaml
name: php-cs-fixer

on: push

jobs:
  php-cs-fixer:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2

    - name: Run php-cs-fixer
      uses: docker://oskarstark/php-cs-fixer-ga

    - uses: stefanzweifel/git-auto-commit-action@v4.1.1
      with:
        commit_message: Apply php-cs-fixer changes
```

### Inputs

Checkout [`action.yml`](https://github.com/stefanzweifel/git-auto-commit-action/blob/master/action.yml) for a full list of supported inputs.

## Outputs
You can use these outputs to trigger other Actions in your Workflow run based on the result of `git-auto-commit-action`.

- `changes_detected`: Returns either "true" or "false" if the repository was dirty and files have changed.

## Troubleshooting

### Can't push commit to repository
If your Workflow can't push the commit to the repository because of authentication issues, please update your Workflow configuration and usage of [`actions/checkout`](https://github.com/actions/checkout#usage). (Updating the `token` value with a Personal Access Token should fix your issues)

### Commit of this Action does not trigger a new Workflow run
As mentioned in the [Usage](#Usage) section, the commit created by this Action **will not trigger** a new Workflow run automatically.

This is due to limitations set up by GitHub:

> An action in a workflow run can't trigger a new workflow run. For example, if an action pushes code using the repository's GITHUB_TOKEN, a new workflow will not run even when the repository contains a workflow configured to run when push events occur.
[Source](https://help.github.com/en/actions/reference/events-that-trigger-workflows)

You can change this by creating a new [Personal Access Token (PAT)](https://github.com/settings/tokens/new), storing the token as a secret in your repository and then passing the new token to the [`actions/checkout`](https://github.com/actions/checkout#usage) Action.

#### Example Workflow

```yaml
name: php-cs-fixer

on: push

jobs:
  php-cs-fixer:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2
      with:
        token: ${{ secrets.PAT_TOKEN }}

    - name: Run php-cs-fixer
      uses: docker://oskarstark/php-cs-fixer-ga

    - uses: stefanzweifel/git-auto-commit-action@v4.1.1
      with:
        commit_message: Apply php-cs-fixer changes
```

## Known Issues

- GitHub currently prohibits Actions like this to push changes from a fork to the upstream repository. See [issue #25](https://github.com/stefanzweifel/git-auto-commit-action/issues/25) for more information.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/stefanzweifel/git-auto-commit-action/tags).

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/stefanzweifel/git-auto-commit-action/blob/master/LICENSE) file for details.
