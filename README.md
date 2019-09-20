# git-auto-commit-action

This GitHub Action automatically commits files which have been changed during a Workflow run and pushes the Commit back to GitHub.
The Committer is "GitHub Actions <actions@github.com>" and the Author of the Commit can be configured with input variables.

If no changes are available, the Actions does nothing.

This Action has been inspired and adapted from the [auto-commit](https://github.com/cds-snc/github-actions/tree/master/auto-commit
)-Action of the Canadian Digital Service and the [commit](https://github.com/elstudio/actions-js-build/blob/41d604d6e73d632e22eac40df8cc69b5added04b/commit/entrypoint.sh)-Action by Eric Johnson.

## Usage

Add the following step at the end of your job.

```yaml
- uses: stefanzweifel/git-auto-commit-action@v2.1.0
  with:
    commit_message: Apply automatic changes
    branch: ${{ github.head_ref }}
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

The Action will only commit files back, if changes are available. The resulting commit **will not trigger** another GitHub Actions Workflow run!


### Inputs

The following inputs are required

- `commit_message`: The commit message used when changes are available
- `branch`: Branch name where changes should be pushed to

### Environment Variables

The `GITHUB_TOKEN` secret is required. It is automatically available in your repository. You have to add it to the configuration though.

## Example Usage

This Action will only work, if the job in your workflow changes project files.
The most common use case for this, is when you're running a Linter or Code-Style fixer on GitHub Actions.

In this example I'm running `php-cs-fixer` in a PHP project.


```yaml
on: push
name: php-cs-fixer
jobs:
  php-cs-fixer:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v1
      with:
        fetch-depth: 1

    - name: Run php-cs-fixer
      uses: docker://oskarstark/php-cs-fixer-ga

    - name: Commit changed files
      uses: stefanzweifel/git-auto-commit-action@v2.1.0
      with:
        commit_message: Apply php-cs-fixer changes
        branch: ${{ github.head_ref }}
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

```

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/stefanzweifel/git-auto-commit-action/tags).

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/stefanzweifel/git-auto-commit-action/blob/master/LICENSE) file for details.
