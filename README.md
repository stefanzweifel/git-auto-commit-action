# git-auto-commit Action

> The GitHub Action for committing files for the 80% use case.

<a href="https://github.com/search?o=desc&q=stefanzweifel%2Fgit-auto-commit-action+path%3A.github%2Fworkflows+language%3AYAML&s=&type=Code" target="_blank" title="Public workflows that use this action."><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fapi-git-master.endbug.vercel.app%2Fapi%2Fgithub-actions%2Fused-by%3Faction%3Dstefanzweifel%2Fgit-auto-commit-action%26badge%3Dtrue" alt="Public workflows that use this action."></a>
<a href="https://github.com/stefanzweifel/git-auto-commit-action/actions?query=workflow%3Atests">
    <img src="https://github.com/stefanzweifel/git-auto-commit-action/workflows/tests/badge.svg" alt="">
</a>

A GitHub Action to detect changed files during a Workflow run and to commit and push them back to the GitHub repository.
By default, the commit is made in the name of "GitHub Actions" and co-authored by the user that made the last commit.

If you want to learn more how this Action works under the hood, check out [this article](https://michaelheap.com/git-auto-commit/) by Michael Heap.

## Usage

Add the following step at the end of your job, after other steps that might add or change files.

```yaml
- uses: stefanzweifel/git-auto-commit-action@v4
```

The following is an extended example with all possible options available for this Action.

```yaml
- uses: stefanzweifel/git-auto-commit-action@v4
  with:
    # Optional, but recommended
    # Defaults to "Apply automatic changes"
    commit_message: Automated Change

    # Optional branch name where commit should be pushed to.
    # Defaults to the current branch.
    branch: feature-123

    # Optional. Used by `git-commit`.
    # See https://git-scm.com/docs/git-commit#_options
    commit_options: '--no-verify --signoff'

    # Optional glob pattern of files which should be added to the commit
    # Defaults to all (.)
    # See the `pathspec`-documentation for git
    # - https://git-scm.com/docs/git-add#Documentation/git-add.txt-ltpathspecgt82308203
    # - https://git-scm.com/docs/gitglossary#Documentation/gitglossary.txt-aiddefpathspecapathspec
    file_pattern: src/*.js tests/*.js *.php

    # Optional local file path to the repository
    # Defaults to the root of the repository
    repository: .

    # Optional commit user and author settings
    commit_user_name: My GitHub Actions Bot # defaults to "GitHub Actions"
    commit_user_email: my-github-actions-bot@example.org # defaults to "actions@github.com"
    commit_author: Author <actions@github.com> # defaults to author of the commit that triggered the run

    # Optional tag message 
    # Action will create and push a new tag to the remote repository and the defined branch
    tagging_message: 'v1.0.0'

    # Optional. Used by `git-status`
    # See https://git-scm.com/docs/git-status#_options
    status_options: '--untracked-files=no'

    # Optional. Used by `git-add`
    # See https://git-scm.com/docs/git-add#_options
    add_options: '-u'

    # Optional. Used by `git-push`
    # See https://git-scm.com/docs/git-push#_options
    push_options: '--force'
    
    # Optional. Disable dirty check and always try to create a commit and push
    skip_dirty_check: true    
    
    # Optional. Skip internal call to `git fetch`
    skip_fetch: true    
    
    # Optional. Prevents the shell from expanding filenames. 
    # Details: https://www.gnu.org/software/bash/manual/html_node/Filename-Expansion.html
    disable_globbing: true
```

Please note that the Action depends on `bash`. If you're using the Action in a job in combination with a custom Docker container, make sure that `bash` is installed.

## Example Workflow

In this example, we're running `php-cs-fixer` in a PHP project to fix the codestyle automatically, then commit possible changed files back to the repository.

Note that we explicitly specify `${{ github.head_ref }}` in the checkout Action.
This is required in order to work with the `pull_request` event (or any other non-`push` event).

```yaml
name: php-cs-fixer

on:
  pull_request:
  push:
    branches:
      - "main"

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

### Example

```yaml
  - name: "Run if changes have been detected"
    if: steps.auto-commit-action.outputs.changes_detected == 'true'
    run: echo "Changes!"

  - name: "Run if no changes have been detected"
    if: steps.auto-commit-action.outputs.changes_detected == 'false'
    run: echo "No Changes!"
```

## Limitations & Gotchas

### Checkout the correct branch

You must use `action/checkout@v2` or later versions to checkout the repository.
In non-`push` events, such as `pull_request`, make sure to specify the `ref` to checkout:

```yaml
- uses: actions/checkout@v2
  with:
    ref: ${{ github.head_ref }}
```

You have to do this to avoid that the `checkout`-Action clones your repository in a detached state.

### Commits made by this Action do not trigger new Workflow runs

The resulting commit **will not trigger** another GitHub Actions Workflow run.
This is due to [limitations set by GitHub](https://help.github.com/en/actions/reference/events-that-trigger-workflows#triggering-new-workflows-using-a-personal-access-token).

> When you use the repository's GITHUB_TOKEN to perform tasks on behalf of the GitHub Actions app, events triggered by the GITHUB_TOKEN will not create a new workflow run. This prevents you from accidentally creating recursive workflow runs.

You can change this by creating a new [Personal Access Token (PAT)](https://github.com/settings/tokens/new),
storing the token as a secret in your repository and then passing the new token to the [`actions/checkout`](https://github.com/actions/checkout#usage) Action step.

```yaml
- uses: actions/checkout@v2
  with:
    token: ${{ secrets.PAT }}
```

If you work in an organization and don't want to create a PAT from your personal account, we recommend using a [robot account](https://docs.github.com/en/github/getting-started-with-github/types-of-github-accounts) for the token.


### Using the Action in forks from public repositories

**☝️ Important Notice**: This Action technically works with forks. However, please note that the combination of triggers and their options can cause issues. Please read [the documentation](https://docs.github.com/en/free-pro-team@latest/actions/reference/events-that-trigger-workflows) on which triggers GitHub Actions support.\
If you use this Action in combination with a linter/fixer, it's easier if you run the Action on `push` on your `main`-branch.

---

By default, this Action will not run on Pull Requests which have been opened by forks. (This is a limitation by GitHub, not by us.)

If you want that a Workflow using this Action runs on Pull Requests opened by forks, 2 things have to be changed:

1. In addition to listening to the `pull_request` event in your Workflow triggers, you have to add an additional event: `pull_request_target`. You can learn more about this event in [the GitHub docs](https://docs.github.com/en/actions/reference/events-that-trigger-workflows#pull_request_target).
2. GitHub Action has to be enabled on the forked repository. \
For security reasons, GitHub does not automatically enable GitHub Actions on forks. The user has to explicitly enable GitHub Actions in the "Actions"-tab of the forked repository. (Mention this in your projects README or CONTRIBUTING.md!)

After you have added the `pull_request_target` to your desired Workflow and the forked repository has enabled Actions and a new Pull Request is opened, the Workflow will run **on the forked repository**.

Due to the fact that the Workflow is not run on the repository the Pull Request is opened in, you won't see any status indicators inside the Pull Request.

#### Example

The following workflow runs `php-cs-fixer` (a code linter and fixer for PHP) when a `pull_request` is opened. We've added the `pull_request_target`-trigger too, to make it work for forks.

```yaml
name: Format PHP

on: [push, pull_request, pull_request_target]

jobs:
  php-cs-fixer:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2

    - name: Run php-cs-fixer
      uses: docker://oskarstark/php-cs-fixer-ga

    - uses: stefanzweifel/git-auto-commit-action@v4
      with:
        commit_message: Apply php-cs-fixer changes
```

Next time a user forks your project **and** enabled GitHub Actions **and** opened a Pull Request, the Workflow will run on the the forked repository and will push commits to the same branch.

Here's how the Pull Request will look like:

![Screenshot of a Pull Request from a Fork](https://user-images.githubusercontent.com/1080923/90955964-9c74c080-e482-11ea-8097-aa7f5161f50e.png)


As you can see, your contributors have to go through hoops to make this work. **For Workflows which run linters and fixers (like the example above) we recommend running them when a push happens on the `main`-branch.**


For more information about running Actions on forks, see [this announcement from GitHub](https://github.blog/2020-08-03-github-actions-improvements-for-fork-and-pull-request-workflows/).

### Push to forks from private repositories

By default, GitHub Actions doesn't run Workflows on forks from private repositories. To enable Actions for **private** repositories enable "Run workflows from pull requests" in your repository settings.

See [this announcement from GitHub](https://github.blog/2020-08-03-github-actions-improvements-for-fork-and-pull-request-workflows/) or the [GitHub docs](https://docs.github.com/en/github/administering-a-repository/disabling-or-limiting-github-actions-for-a-repository#enabling-workflows-for-private-repository-forks) for details.

### Signing Commits & Other Git Command Line Options

Using command lines options needs to be done manually for each workflow which you require the option enabled. So for example signing commits requires you to import the gpg signature each and every time. The following list of actions are worth checking out if you need to automate these tasks regulary.

- [Import GPG Signature](https://github.com/crazy-max/ghaction-import-gpg) (Suggested by [TGTGamer](https://github.com/tgtgamer))


## Using `--amend` and `--no-edit` as commit options

If you would like to use this Action to create a commit using [`--amend`](https://git-scm.com/docs/git-commit#Documentation/git-commit.txt---amend) and [`--no-edit`](https://git-scm.com/docs/git-commit#Documentation/git-commit.txt---no-edit) you need to make some adjustments.

**☝️ Important Notice:** You should understand the implications of rewriting history if you amend a commit that has already been published. [See rebasing](https://git-scm.com/docs/git-rebase#_recovering_from_upstream_rebase)

First, you need to extract the previous commit message by using `git log -1 --pretty=%s`.
Then you need to provide this last commit message to the Action through the `commit_message` input option.

Finally, you have to use `push_options: '--force'` to overwrite the git history on the GitHub remote repository. (git-auto-commit will not do a `git-rebase` for you!)

The steps in your workflow might look like this:

```yaml
- uses: actions/checkout@master
  with:
    # Fetch the last 2 commits instead of just 1. (Fetching just 1 commit would overwrite the whole history)
    fetch-depth: 2

# Other steps in your workflow to trigger a changed file

- name: Get last commit message
  id: last-commit-message
  run: |
    echo "::set-output name=msg::$(git log -1 --pretty=%s)"

- uses: stefanzweifel/git-auto-commit-action@v4
  with:
    commit_message: ${{ steps.last-commit-message.outputs.msg }}
    commit_options: '--amend --no-edit'
    push_options: '--force'
    skip_fetch: true
```

See discussion in [#159](https://github.com/stefanzweifel/git-auto-commit-action/issues/159#issuecomment-845347950) for details.

## Troubleshooting
### Action does not push commit to repository

Make sure to [checkout the correct branch](#checkout-the-correct-branch).

### Action does not push commit to repository: Authentication Issue

If your Workflow can't push the commit to the repository because of authentication issues,
please update your Workflow configuration and usage of [`actions/checkout`](https://github.com/actions/checkout#usage).

Updating the `token` value with a Personal Access Token should fix your issues.

### Push to protected branches

If your repository uses [protected branches](https://help.github.com/en/github/administering-a-repository/configuring-protected-branches) you have to make some changes to your Workflow for the Action to work properly: You need a Personal Access Token and you either have to allow force pushes or the Personal Acess Token needs to belong to an Administrator.

First, you have to create a new [Personal Access Token (PAT)](https://github.com/settings/tokens/new),
store the token as a secret in your repository and pass the new token to the [`actions/checkout`](https://github.com/actions/checkout#usage) Action step.

```yaml
- uses: actions/checkout@v2
  with:
    token: ${{ secrets.PAT }}
```
You can learn more about Personal Access Token in the [GitHub documentation](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token).

**Note:** If you're working in an organisation and you don't want to create the PAT from your personal account, we recommend using a bot-account for such tokens.


If you go the "force pushes" route, you have to enable force pushes to a protected branch (See [documentation](https://help.github.com/en/github/administering-a-repository/enabling-force-pushes-to-a-protected-branch)) and update your Workflow to use force push like this.

```yaml
    - uses: stefanzweifel/git-auto-commit-action@v4
      with:
        commit_message: Apply php-cs-fixer changes
        push_options: --force
```

### No new workflows are triggered by the commit of this action

This is due to limitations set up by GitHub, [commits of this Action do not trigger new Workflow runs](#commits-of-this-action-do-not-trigger-new-workflow-runs).

## Running the tests

The package has tests written in [bats](https://github.com/bats-core/bats-core). Before you can run the test suite locally, you have to install the dependencies with `npm` or `yarn`.

```shell
npm install
yarn
```

You can run the test suite with `npm` or `yarn`.

```shell
npm run test
yarn test
```

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/stefanzweifel/git-auto-commit-action/tags).

We also provide major version tags to make it easier to always use the latest release of a major version. For example you can use `stefanzweifel/git-auto-commit-action@v4` to always use the latest release of the current major version.
(More information about this [here](https://help.github.com/en/actions/building-actions/about-actions#versioning-your-action).)

## Credits

* [Stefan Zweifel](https://github.com/stefanzweifel)
* [All Contributors](https://github.com/stefanzweifel/git-auto-commit-action/graphs/contributors)

This Action has been inspired and adapted from the [auto-commit](https://github.com/cds-snc/github-actions/tree/master/auto-commit
)-Action of the Canadian Digital Service and this [commit](https://github.com/elstudio/actions-js-build/blob/41d604d6e73d632e22eac40df8cc69b5added04b/commit/entrypoint.sh)-Action by Eric Johnson.

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/stefanzweifel/git-auto-commit-action/blob/master/LICENSE) file for details.
