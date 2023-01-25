# git-auto-commit Action

> The GitHub Action for committing files for the 80% use case.

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

Note that the Action has to be used in a Job that runs on a UNIX system (e.g. `ubuntu-latest`).
If you don't use the default permission of the GITHUB_TOKEN, give the Job or Workflow at least the `contents: write` permission.

The following is an extended example with all available options.

```yaml
- uses: stefanzweifel/git-auto-commit-action@v4
  with:
    # Optional. Commit message for the created commit.
    # Defaults to "Apply automatic changes"
    commit_message: Automated Change

    # Optional. Local and remote branch name where commit is going to be pushed
    #  to. Defaults to the current branch.
    #  You might need to set `create_branch: true` if the branch does not exist.
    branch: feature-123

    # Optional. Options used by `git-commit`.
    # See https://git-scm.com/docs/git-commit#_options
    commit_options: '--no-verify --signoff'

    # Optional glob pattern of files which should be added to the commit
    # Defaults to all (.)
    # See the `pathspec`-documentation for git
    # - https://git-scm.com/docs/git-add#Documentation/git-add.txt-ltpathspecgt82308203
    # - https://git-scm.com/docs/gitglossary#Documentation/gitglossary.txt-aiddefpathspecapathspec
    file_pattern: '*.php src/*.js tests/*.js'

    # Optional. Local file path to the repository.
    # Defaults to the root of the repository.
    repository: .

    # Optional commit user and author settings
    commit_user_name: My GitHub Actions Bot # defaults to "github-actions[bot]"
    commit_user_email: my-github-actions-bot@example.org # defaults to "41898282+github-actions[bot]@users.noreply.github.com"
    commit_author: Author <actions@github.com> # defaults to author of the commit that triggered the run

    # Optional. Tag name being created in the local repository and 
    # pushed to remote repository and defined branch.
    tagging_message: 'v1.0.0'

    # Optional. Option used by `git-status` to determine if the repository is 
    # dirty. See https://git-scm.com/docs/git-status#_options
    status_options: '--untracked-files=no'

    # Optional. Options used by `git-add`.
    # See https://git-scm.com/docs/git-add#_options
    add_options: '-u'

    # Optional. Options used by `git-push`.
    # See https://git-scm.com/docs/git-push#_options
    push_options: '--force'
    
    # Optional. Disable dirty check and always try to create a commit and push
    skip_dirty_check: true    
    
    # Optional. Skip internal call to `git fetch`
    skip_fetch: true    
    
    # Optional. Skip internal call to `git checkout`
    skip_checkout: true

    # Optional. Prevents the shell from expanding filenames. 
    # Details: https://www.gnu.org/software/bash/manual/html_node/Filename-Expansion.html
    disable_globbing: true

    # Optional. Create given branch name in local and remote repository.
    create_branch: true
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
      - main

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
- `commit_hash`: Returns the full hash of the commit if one was created.

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

The goal of this Action is to be "the Action for committing files for the 80% use case". Therefore, you might run into issues if your Workflow falls into the not supported 20% portion.

The following is a list of edge cases the Action knowingly does not support:

**No `git pull` when the repository is out of date with remote.** The Action will not do a `git pull` before doing the `git push`. **You** are responsible for keeping the repository up to date in your Workflow runs. 

**No support for running the Action in build matrices**. If your Workflow is using build matrices, and you want that each job commits and pushes files to the remote, you will run into the issue, that the repository in the workflow will become out of date. As the Action will not do a `git pull` for you, you have to do that yourself.

**No support for `git rebase` or `git merge`**. There are many strategies on how to integrate remote upstream changes to a local repository. `git-auto-commit` does not want to be responsible for doing that. 

**No support for detecting line break changes between CR (Carriage Return) and LF (Line Feed)**. This is a low level issue, you have to resolve differently in your project. Sorry.

If this Action doesn't work for your workflow, check out [EndBug/add-and-commit](https://github.com/EndBug/add-and-commit).

### Checkout the correct branch

You must use `action/checkout@v2` or later versions to check out the repository.
In non-`push` events, such as `pull_request`, make sure to specify the `ref` to check out:

```yaml
- uses: actions/checkout@v2
  with:
    ref: ${{ github.head_ref }}
```

Do this to avoid checking out the repository in a detached state.

### Commits made by this Action do not trigger new Workflow runs

The resulting commit **will not trigger** another GitHub Actions Workflow run.
This is due to [limitations set by GitHub](https://docs.github.com/en/actions/security-guides/automatic-token-authentication#using-the-github_token-in-a-workflow).

> When you use the repository's GITHUB_TOKEN to perform tasks on behalf of the GitHub Actions app, events triggered by the GITHUB_TOKEN will not create a new workflow run. This prevents you from accidentally creating recursive workflow runs.

You can change this by creating a new [Personal Access Token (PAT)](https://github.com/settings/tokens/new),
storing the token as a secret in your repository and then passing the new token to the [`actions/checkout`](https://github.com/actions/checkout#usage) Action step.

```yaml
- uses: actions/checkout@v2
  with:
    token: ${{ secrets.PAT }}
```

If you create a personal access token, apply the `repo` and `workflow` scopes.

If you work in an organization and don't want to create a PAT from your personal account, we recommend using a [robot account](https://docs.github.com/en/github/getting-started-with-github/types-of-github-accounts) for the token.

### Change to file is not detected

Does your workflow change a file, but "git-auto-commit" does not detect the change? Check the `.gitignore` that applies to the respective file. You might have accidentally marked the file to be ignored by git.

## Advanced Uses

### Multiline Commit Messages

If your commit message should span multiple lines, you have to create a separate step to generate the string. 

The example below can be used as a starting point to generate a multiline commit meesage. Learn more how multiline strings in GitHub Actions work in the [GitHub documentation](https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#multiline-strings).

```yaml
    # Building a multiline commit message
    # Adjust to your liking
    - run: echo "Commit Message 1" >> commitmessage.txt
    - run: echo "Commit Message 2" >> commitmessage.txt
    - run: echo "Commit Message 3" >> commitmessage.txt

    # Create a multiline string to be used by the git-auto-commit Action
    - name: Set commit message
      id: commit_message_step
      run: |
        echo 'commit_message<<EOF' >> $GITHUB_OUTPUT
        cat commitmessage.txt >> $GITHUB_OUTPUT
        echo 'EOF' >> $GITHUB_OUTPUT

    # Quick and dirty step to get rid of the temporary file holding the commit message
    - run: rm -rf commitmessage.txt

    - uses: stefanzweifel/git-auto-commit-action@v4
      id: commit
      with:
        commit_message: ${{ steps.commit_message_step.outputs.commit_message }}
```  

### Signing Commits & Other Git Command Line Options

Using command lines options needs to be done manually for each workflow which you require the option enabled. So for example signing commits requires you to import the gpg signature each and every time. The following list of actions are worth checking out if you need to automate these tasks regularly.

- [Import GPG Signature](https://github.com/crazy-max/ghaction-import-gpg) (Suggested by [TGTGamer](https://github.com/tgtgamer))

### Push to forks from private repositories

By default, GitHub Actions doesn't run Workflows on forks from private repositories. To enable Actions for **private** repositories enable "Run workflows from pull requests" in your repository settings.

See [this announcement from GitHub](https://github.blog/2020-08-03-github-actions-improvements-for-fork-and-pull-request-workflows/) or the [GitHub docs](https://docs.github.com/en/github/administering-a-repository/disabling-or-limiting-github-actions-for-a-repository#enabling-workflows-for-private-repository-forks) for details.


### Use in forks from public repositories

<details>
<summary>Expand to learn more</summary>

> **Note**
> This Action technically works with forks. However, please note that the combination of triggers and their options can cause issues. Please read [the documentation](https://docs.github.com/en/free-pro-team@latest/actions/reference/events-that-trigger-workflows) on which triggers GitHub Actions support.\
> Ensure your contributors enable "Allow edits by maintainers" when opening a pull request. ([Learn more](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/allowing-changes-to-a-pull-request-branch-created-from-a-fork)) \
> \
> If you use this Action in combination with a linter/fixer, it's easier if you run the Action on `push` on your `main`-branch.

By default, this Action will not run on Pull Requests which have been opened by forks. (This is a limitation by GitHub, not by us.)   
However, there are a couple of ways to use this Actions in Workflows that should be triggered by forked repositories.

### Workflow should run in **base** repository

The workflow below runs whenever a commit is pushed to the `main`-branch or when activity on a pull request happens, by listening to the  [`pull_request_target`](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#pull_request_target) event.

If the workflow is triggered by the `pull_request_target`-event, the workflow will run in the context of the base of the pull request, rather than in the context of the merge commit, as the `pull_request` event does.
In other words, this will allow your workflow to be run in the repository where the pull request is opened to and will push changes back to the fork.

Check out the discussion in [#211](https://github.com/stefanzweifel/git-auto-commit-action/issues/211) for more information on this.

```yaml
name: Format PHP

on:
  push:
    branches:
      - main
  pull_request_target:

jobs:
  php-cs-fixer:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
      with:
        repository: ${{ github.event.pull_request.head.repo.full_name }}
        ref: ${{ github.head_ref }}

    - name: Run php-cs-fixer
      uses: docker://oskarstark/php-cs-fixer-ga

    - uses: stefanzweifel/git-auto-commit-action@v4
```

### Workflow should run in **forked** repository

If the workflow should run in the forked repository, follow these steps:

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

Next time a user forks your project **and** enabled GitHub Actions **and** opened a Pull Request, the Workflow will run on the **forked** repository and will push commits to the same branch.

Here's how the Pull Request will look like:

![Screenshot of a Pull Request from a Fork](https://user-images.githubusercontent.com/1080923/90955964-9c74c080-e482-11ea-8097-aa7f5161f50e.png)


As you can see, your contributors have to go through hoops to make this work. **For Workflows which run linters and fixers (like the example above) we recommend running them when a push happens on the `main`-branch.**


For more information about running Actions on forks, see [this announcement from GitHub](https://github.blog/2020-08-03-github-actions-improvements-for-fork-and-pull-request-workflows/).

</details>

### Using `--amend` and `--no-edit` as commit options

<details>
<summary>Expand to learn more</summary>

If you would like to use this Action to create a commit using [`--amend`](https://git-scm.com/docs/git-commit#Documentation/git-commit.txt---amend) and [`--no-edit`](https://git-scm.com/docs/git-commit#Documentation/git-commit.txt---no-edit) you need to make some adjustments.

> **Warning**
> You should understand the implications of rewriting history if you amend a commit that has already been published. [See rebasing](https://git-scm.com/docs/git-rebase#_recovering_from_upstream_rebase).

First, you need to extract the previous commit message by using `git log -1 --pretty=%s`.
Then you need to provide this last commit message to the Action through the `commit_message` input option.

Finally, you have to use `push_options: '--force'` to overwrite the git history on the GitHub remote repository. (git-auto-commit will not do a `git-rebase` for you!)

The steps in your workflow might look like this:

```yaml
- uses: actions/checkout@master
  with:
    # Fetch the last 2 commits instead of just 1. (Fetching just 1 commit would overwrite the whole history)
    fetch-depth: 2

# Other steps in your workflow to trigger a changed file

- name: Get last commit message
  id: last-commit-message
  run: |
    echo "msg=$(git log -1 --pretty=%s)" >> $GITHUB_OUTPUT

- uses: stefanzweifel/git-auto-commit-action@v4
  with:
    commit_message: ${{ steps.last-commit-message.outputs.msg }}
    commit_options: '--amend --no-edit'
    push_options: '--force'
    skip_fetch: true
```

See discussion in [#159](https://github.com/stefanzweifel/git-auto-commit-action/issues/159#issuecomment-845347950) for details.

</details>

## Troubleshooting
### Action does not push commit to repository

Make sure to [checkout the correct branch](#checkout-the-correct-branch).

### Action does not push commit to repository: Authentication Issue

If your Workflow can't push the commit to the repository because of authentication issues,
please update your Workflow configuration and usage of [`actions/checkout`](https://github.com/actions/checkout#usage).

Updating the `token` value with a Personal Access Token should fix your issues.

### Push to protected branches

If your repository uses [protected branches](https://help.github.com/en/github/administering-a-repository/configuring-protected-branches) you have to make some changes to your Workflow for the Action to work properly: You need a Personal Access Token and you either have to allow force pushes or the Personal Access Token needs to belong to an Administrator.

First, you have to create a new [Personal Access Token (PAT)](https://github.com/settings/tokens/new),
store the token as a secret in your repository and pass the new token to the [`actions/checkout`](https://github.com/actions/checkout#usage) Action step.

```yaml
- uses: actions/checkout@v2
  with:
    token: ${{ secrets.PAT }}
```
You can learn more about Personal Access Token in the [GitHub documentation](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token).

> **Note**
> If you're working in an organisation, and you don't want to create the PAT from your personal account, we recommend using a bot-account for such tokens.


If you go the "force pushes" route, you have to enable force pushes to a protected branch (See [documentation](https://help.github.com/en/github/administering-a-repository/enabling-force-pushes-to-a-protected-branch)) and update your Workflow to use force push like this.

```yaml
    - uses: stefanzweifel/git-auto-commit-action@v4
      with:
        commit_message: Apply php-cs-fixer changes
        push_options: --force
```

### No new workflows are triggered by the commit of this action

This is due to limitations set up by GitHub, [commits made by this Action do not trigger new Workflow runs](#commits-made-by-this-action-do-not-trigger-new-workflow-runs).

### Pathspec 'x' did not match any files

If you're using the Action with a custom `file_pattern` and the Action throws a fatal error with the message "Pathspec 'file-pattern' did not match any files", the problem is probably that no file for the pattern exists in the repository.

`file_pattern` is used both for `git-status` and `git-add` in this Action. `git-add` will throw a fatal error, if for example, you use a file pattern like `*.js *.ts` but no `*.ts` files exist in your projects' repository.

See [Issue #227](https://github.com/stefanzweifel/git-auto-commit-action/issues/227) for details.

### Custom `file_pattern`, changed files but seeing "Working tree clean. Nothing to commit." in the logs

If you're using a custom `file_pattern` and the Action does not detect the changes made in your worfklow, you're probably running into a globbing issue.

Let's imagine you use `file_pattern: '*.md'` to detect and commit changes to all Markdown files in your repository.
If your Workflow now only updates `.md`-files in a subdirectory, but you have an untouched `.md`-file in the root of the repository, the git-auto-commit Action will display "Working tree clean. Nothing to commit." in the Workflow log.

This is due to the fact, that the `*.md`-glob is expanded before sending it to `git-status`. `git-status` will receive the filename of your untouched `.md`-file in the root of the repository and won't detect any changes; and therefore the Action does nothing.

To fix this add `disable_globbing: true` to your Workflow.

```yaml
- uses: stefanzweifel/git-auto-commit-action@v4
  with:
    file_pattern: '*.md'
    disable_globbing: true
```

See [Issue #239](https://github.com/stefanzweifel/git-auto-commit-action/issues/239) for details.

## Running the tests

The Action has tests written in [bats](https://github.com/bats-core/bats-core). Before you can run the test suite locally, you have to install the dependencies with `npm` or `yarn`.

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

We also provide major version tags to make it easier to always use the latest release of a major version. For example, you can use `stefanzweifel/git-auto-commit-action@v4` to always use the latest release of the current major version.
(More information about this [here](https://help.github.com/en/actions/building-actions/about-actions#versioning-your-action).)

## Credits

* [Stefan Zweifel](https://github.com/stefanzweifel)
* [All Contributors](https://github.com/stefanzweifel/git-auto-commit-action/graphs/contributors)

This Action has been inspired and adapted from the [auto-commit](https://github.com/cds-snc/github-actions/tree/master/auto-commit
)-Action of the Canadian Digital Service and this [commit](https://github.com/elstudio/actions-js-build/blob/41d604d6e73d632e22eac40df8cc69b5added04b/commit/entrypoint.sh)-Action by Eric Johnson.

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/stefanzweifel/git-auto-commit-action/blob/master/LICENSE) file for details.
