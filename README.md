# git-auto-commit Action

> The GitHub Action for committing files for the 80% use case.

<a href="https://github.com/stefanzweifel/git-auto-commit-action/actions?query=workflow%3Atests">
    <img src="https://github.com/stefanzweifel/git-auto-commit-action/workflows/tests/badge.svg" alt="">
</a>

A GitHub Action to detect changed files during a Workflow run and to commit and push them back to the GitHub repository.
By default, the commit is made in the name of "GitHub Actions" and co-authored by the user that made the last commit.

If you want to learn more how this Action works under the hood, check out [this article](https://michaelheap.com/git-auto-commit/) by Michael Heap.

## Usage

Adding git-auto-commit to your Workflow only takes a couple lines of code.

1. Set the `contents`-permission of the default GITHUB_TOKEN to `true`. (Required to push new commits to the repository)
2. Add the following step at the end of your job, after other steps that might add or change files.

```yaml
- uses: stefanzweifel/git-auto-commit-action@v7
```

Your Workflow should look similar to this example.

```yaml
name: Format

on: push

jobs:
  format-code:
    runs-on: ubuntu-latest

    permissions:
      # Give the default GITHUB_TOKEN write permission to commit and push the
      # added or changed files to the repository.
      contents: write

    steps:
      - uses: actions/checkout@v5
        with:
          ref: ${{ github.head_ref }}
          # Value already defaults to true, but `persist-credentials` is required to push new commits to the repository.
          persist-credentials: true

      # Other steps that change files in the repository go here
      # …

      # Commit all changed files back to the repository
      - uses: stefanzweifel/git-auto-commit-action@v7
```

> [!NOTE]
> The Action has to be used in a Job that runs on a UNIX-like system (e.g. `ubuntu-latest`).

The following is an extended example with all available options.

```yaml
- uses: stefanzweifel/git-auto-commit-action@v7
  with:
    # Optional. Commit message for the created commit.
    # Defaults to "Apply automatic changes"
    commit_message: Automated Change

    # Optional. Remote branch name where commit is going to be pushed to. 
    # Defaults to the current branch.
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
    commit_author: Author <actions@github.com> # defaults to "username <numeric_id+username@users.noreply.github.com>", where "numeric_id" and "username" belong to the author of the commit that triggered the run
        
    # Optional. Tag name to be created in the local repository and 
    # pushed to the remote repository on the defined branch.
    # If only one of `tag_name` or `tagging_message` is provided, the value of the provided field will be used for both tag name and message.
    tag_name: 'v1.0.0'

    # Optional. Message to annotate the created tag with.
    # If only one of `tag_name` or `tagging_message` is provided, the value of the provided field will be used for both tag name and message.
    tagging_message: 'Codename "Sunshine"'

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
    
    # Optional. Skip internal call to `git push`
    skip_push: true

    # Optional. Prevents the shell from expanding filenames. 
    # Details: https://www.gnu.org/software/bash/manual/html_node/Filename-Expansion.html
    disable_globbing: true

    # Optional. Create given branch name in local and remote repository.
    create_branch: true

    # Optional. Creates a new tag and pushes it to remote without creating a commit. 
    # Skips dirty check and changed files. Must be used in combination with `tag` and `tagging_message`.
    create_git_tag_only: false
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

    permissions:
      # Give the default GITHUB_TOKEN write permission to commit and push the changed files back to the repository.
      contents: write

    steps:
    - uses: actions/checkout@v5
      with:
        ref: ${{ github.head_ref }}

    - name: Run php-cs-fixer
      uses: docker://oskarstark/php-cs-fixer-ga

    - uses: stefanzweifel/git-auto-commit-action@v7
      with:
        commit_message: Apply php-cs-fixer changes
```

## Inputs

Checkout [`action.yml`](https://github.com/stefanzweifel/git-auto-commit-action/blob/master/action.yml) for a full list of supported inputs.

## Outputs

You can use these outputs to trigger other Actions in your Workflow run based on the result of `git-auto-commit-action`.

- `changes_detected`: Returns either "true" or "false" if the repository was dirty and files have changed.
- `commit_hash`: Returns the full hash of the commit if one was created.
- `create_git_tag_only`: Returns either "true" or "false" if a tag was created, when `create_git_tag_only` was used.

**⚠️ When using outputs, the step needs to be given an id. See example below.**

### Example

```yaml
  - uses: stefanzweifel/git-auto-commit-action@v7
    id: auto-commit-action #mandatory for the output to show up in ${{ steps }}
    with:
      commit_message: Apply php-cs-fixer changes

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

You must use `actions/checkout@v2` or later versions to check out the repository.
In non-`push` events, such as `pull_request`, make sure to specify the `ref` to check out:

```yaml
- uses: actions/checkout@v5
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
- uses: actions/checkout@v5
  with:
    token: ${{ secrets.PAT }}
```

If you create a personal access token (classic), apply the `repo` and `workflow` scopes.
If you create a fine-grained personal access token, apply the `Contents`-permissions.

If you work in an organization and don't want to create a PAT from your personal account, we recommend using a [robot account](https://docs.github.com/en/github/getting-started-with-github/types-of-github-accounts) for the token.

### Prevent Infinite Loop when using a Personal Access Token

If you're using a Personal Access Token (PAT) to push commits to GitHub repository, the resulting commit or push can trigger other GitHub Actions workflows. This can result in an infinite loop.

If you would like to prevent this, you can add `skip-checks:true` to the commit message. See [Skipping workflow runs](https://docs.github.com/en/actions/managing-workflow-runs/skipping-workflow-runs) for details.

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

    - uses: stefanzweifel/git-auto-commit-action@v7
      id: commit
      with:
        commit_message: ${{ steps.commit_message_step.outputs.commit_message }}
```  

### Signing Commits

If you would like to sign your commits using a GPG key, you will need to use an additional action. 
You can use the [crazy-max/ghaction-import-gpg](https://github.com/crazy-max/ghaction-import-gpg) action and follow its setup instructions.

As git-auto-commit by default does not use **your** username and email when creating a commit, you have to override these values in your workflow.

```yml
- name: "Import GPG key"
  id: import-gpg
  uses: crazy-max/ghaction-import-gpg@v6
  with:
    gpg_private_key: ${{ secrets.GPG_PRIVATE_KEY }}
    passphrase: ${{ secrets.GPG_PASSPHRASE }}
    git_user_signingkey: true
    git_commit_gpgsign: true

- name: "Commit and push changes"
  uses: stefanzweifel/git-auto-commit-action@v7
  with:
     commit_author: "${{ steps.import-gpg.outputs.name }} <${{ steps.import-gpg.outputs.email }}>"
     commit_user_name: ${{ steps.import-gpg.outputs.name }}
     commit_user_email: ${{ steps.import-gpg.outputs.email }}
```

See discussion [#334](https://github.com/stefanzweifel/git-auto-commit-action/discussions/334) for details.

### Use in forks from private repositories

By default, GitHub Actions doesn't run Workflows on forks from **private** repositories. To enable Actions for **private** repositories enable "Run workflows from pull requests" in your repository settings.

See [this announcement from GitHub](https://github.blog/2020-08-03-github-actions-improvements-for-fork-and-pull-request-workflows/) or the [GitHub docs](https://docs.github.com/en/github/administering-a-repository/disabling-or-limiting-github-actions-for-a-repository#enabling-workflows-for-private-repository-forks) for details.


### Use in forks from public repositories

> [!NOTE] 
> This Action technically works with forks. However, please note that the combination of triggers and their options can cause issues. Please read [the documentation](https://docs.github.com/en/free-pro-team@latest/actions/reference/events-that-trigger-workflows) on which triggers GitHub Actions support.\
> Ensure your contributors enable "Allow edits by maintainers" when opening a pull request. ([Learn more](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/allowing-changes-to-a-pull-request-branch-created-from-a-fork)) \
> \
> **If you use this Action in combination with a linter/fixer, it's easier if you run the Action on `push` on your `main`-branch.**

> [!WARNING] 
> Due to limitations of GitHub, this Action currently can't push commits to a base repository, if the fork _lives_ under an organisation. See [github/community#6634](https://github.com/orgs/community/discussions/5634) and [this comment](https://github.com/stefanzweifel/git-auto-commit-action/issues/211#issuecomment-1428849944) for details.

By default, this Action will not run on Pull Requests which have been opened by forks. (This is a limitation by GitHub, not by us.)   
However, there are a couple of ways to use this Actions in Workflows that should be triggered by forked repositories.

### Workflow should run in **base** repository

> [!CAUTION]
> The following section explains how you can use git-auto-commit in combination with the `pull_request_target` trigger.   
> **Using `pull_request_target` in your workflows can lead to repository compromise as [mentioned](https://securitylab.github.com/research/github-actions-preventing-pwn-requests/) by GitHub's own security team. This means, that a bad actor could potentially leak/steal your GitHub Actions repository secrets.**   
> Please be aware of this risk when using `pull_request_target` in your workflows.
> 
> If your workflow runs code-fixing tools, consider running the workflow on your default branch by listening to the `push` event or use a third-party tool like [autofix.ci](https://autofix.ci/).   
> We keep this documentation around, as many questions came in over the years, on how to use this action for public forks.

The workflow below runs whenever a commit is pushed to the `main`-branch or when activity on a pull request happens, by listening to the [`pull_request_target`](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#pull_request_target) event.

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
    permissions:
      contents: write

    steps:
    - uses: actions/checkout@v5
      with:
        # Checkout the fork/head-repository and push changes to the fork.
        # If you skip this, the base repository will be checked out and changes
        # will be committed to the base repository!
        repository: ${{ github.event.pull_request.head.repo.full_name }}

        # Checkout the branch made in the fork. Will automatically push changes
        # back to this branch.
        ref: ${{ github.head_ref }}

    - name: Run php-cs-fixer
      uses: docker://oskarstark/php-cs-fixer-ga

    - uses: stefanzweifel/git-auto-commit-action@v7
```

For more information about running Actions on forks, see [this announcement from GitHub](https://github.blog/2020-08-03-github-actions-improvements-for-fork-and-pull-request-workflows/).

### Using `--amend` and `--no-edit` as commit options

If you would like to use this Action to create a commit using [`--amend`](https://git-scm.com/docs/git-commit#Documentation/git-commit.txt---amend) and [`--no-edit`](https://git-scm.com/docs/git-commit#Documentation/git-commit.txt---no-edit) you need to make some adjustments.

> [!CAUTION] 
> You should understand the implications of rewriting history if you amend a commit that has already been published. [See rebasing](https://git-scm.com/docs/git-rebase#_recovering_from_upstream_rebase).

First, you need to extract the previous commit message by using `git log -1 --pretty=%s`.
Then you need to provide this last commit message to the Action through the `commit_message` input option.

By default, the commit author is changed to `username <username@users.noreply.github.com>`, where `username` is the name of the user who triggered the workflow (The [`github.actor`](https://docs.github.com/en/actions/learn-github-actions/contexts#github-context) context is used here). If you want to preserve the name and email of the original author, you must extract them from the last commit and provide them to the Action through the `commit_author` input option.

Finally, you have to use `push_options: '--force'` to overwrite the git history on the GitHub remote repository. (git-auto-commit will not do a `git-rebase` for you!)

The steps in your workflow might look like this:

```yaml
- uses: actions/checkout@4
  with:
    # Fetch the last 2 commits instead of just 1. (Fetching just 1 commit would overwrite the whole history)
    fetch-depth: 2

# Other steps in your workflow to trigger a changed file

- name: Get last commit message
  id: last-commit
  run: |
    echo "message=$(git log -1 --pretty=%s)" >> $GITHUB_OUTPUT
    echo "author=$(git log -1 --pretty=\"%an <%ae>\")" >> $GITHUB_OUTPUT

- uses: stefanzweifel/git-auto-commit-action@v7
  with:
    commit_author: ${{ steps.last-commit.outputs.author }}
    commit_message: ${{ steps.last-commit.outputs.message }}
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

Please note that `persist-credentials` in `actions/checkout` must be set to `true` to push new commits to the repository.

If you still can't push the commit, and you're using branch protection rules or similar features, updating the `token` value with a Personal Access Token should fix your issues.

### git-auto-commit fails to push commit that creates or updates files in `.github/workflows/`

The default `GITHUB_TOKEN` issued by GitHub Action does not have permission to make changes to workflow files located in `.github/workflows/`.
To fix this, please create a personal access token (PAT) and pass the token to the `actions/checkout`-step in your workflow. (Similar to [how to push to protected branches](https://github.com/stefanzweifel/git-auto-commit-action?tab=readme-ov-file#push-to-protected-branches)).

If a PAT does not work for you, you could also create a new GitHub app and use it's token in your workflows. See [this comment in #87](https://github.com/stefanzweifel/git-auto-commit-action/issues/87#issuecomment-1939138661) for details.

See [#322](https://github.com/stefanzweifel/git-auto-commit-action/issues/322) for details and discussions around this topic.

### Push to protected branches

If your repository uses [protected branches](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches) you have to make some changes to your Workflow for the Action to work properly: You need a Personal Access Token and you either have to allow force pushes or the Personal Access Token needs to belong to an Administrator.

First, you have to create a new [Personal Access Token (PAT)](https://github.com/settings/tokens/new),
store the token as a secret in your repository and pass the new token to the [`actions/checkout`](https://github.com/actions/checkout#usage) Action step.

If you create a personal access token (classic), apply the `repo` and `workflow` scopes.
If you create a fine-grained personal access token, apply the `Contents`-permissions.

```yaml
- uses: actions/checkout@v5
  with:
    # We pass the "PAT" secret to the checkout action; if no PAT secret is available to the workflow runner (eg. Dependabot) we fall back to the default "GITHUB_TOKEN".
    token: ${{ secrets.PAT || secrets.GITHUB_TOKEN }}
```
You can learn more about Personal Access Token in the [GitHub documentation](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token).


> [!TIP] 
> If you're working in an organisation, and you don't want to create the PAT from your personal account, we recommend using a bot-account for such tokens.

If you go the "force pushes" route, you have to enable force pushes to a protected branch (see [documentation](https://help.github.com/en/github/administering-a-repository/enabling-force-pushes-to-a-protected-branch)) and update your Workflow to use force push like this.

```yaml
    - uses: stefanzweifel/git-auto-commit-action@v7
      with:
        commit_message: Apply php-cs-fixer changes
        push_options: --force
```

### No new workflows are triggered by the commit of this action

This is due to limitations set up by GitHub, [commits made by this Action do not trigger new Workflow runs](#commits-made-by-this-action-do-not-trigger-new-workflow-runs).

### Pathspec 'x' did not match any files

If you're using the Action with a custom `file_pattern` and the Action throws a fatal error with the message "Pathspec 'file-pattern' did not match any files", the problem is probably that no file for the pattern **exists** in the repository.

`file_pattern` is used both for `git-status` and `git-add` in this Action. `git-add` will throw a fatal error, if for example, you use a file pattern like `*.js *.ts` but no `*.ts` files exist in your projects' repository.

See [Issue #227](https://github.com/stefanzweifel/git-auto-commit-action/issues/227) for details.

### Custom `file_pattern`, changed files but seeing "Working tree clean. Nothing to commit." in the logs

If you're using a custom `file_pattern` and the Action does not detect the changes made in your worfklow, you're probably running into a globbing issue.

Let's imagine you use `file_pattern: '*.md'` to detect and commit changes to all Markdown files in your repository.
If your Workflow now only updates `.md`-files in a subdirectory, but you have an untouched `.md`-file in the root of the repository, the git-auto-commit Action will display "Working tree clean. Nothing to commit." in the Workflow log.

This is due to the fact, that the `*.md`-glob is expanded before sending it to `git-status`. `git-status` will receive the filename of your untouched `.md`-file in the root of the repository and won't detect any changes; and therefore the Action does nothing.

To fix this add `disable_globbing: true` to your Workflow.

```yaml
- uses: stefanzweifel/git-auto-commit-action@v7
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

We also provide major version tags to make it easier to always use the latest release of a major version. For example, you can use `stefanzweifel/git-auto-commit-action@v7` to always use the latest release of the current major version.
(More information about this [here](https://help.github.com/en/actions/building-actions/about-actions#versioning-your-action).)

## Credits

* [Stefan Zweifel](https://github.com/stefanzweifel)
* [All Contributors](https://github.com/stefanzweifel/git-auto-commit-action/graphs/contributors)

This Action has been inspired and adapted from the [auto-commit](https://github.com/cds-snc/github-actions/tree/master/auto-commit
)-Action of the Canadian Digital Service and this [commit](https://github.com/elstudio/actions-js-build/blob/41d604d6e73d632e22eac40df8cc69b5added04b/commit/entrypoint.sh)-Action by Eric Johnson.

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/stefanzweifel/git-auto-commit-action/blob/master/LICENSE) file for details.
