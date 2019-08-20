# git-auto-commit-action

This GitHub Action automatically commits files which have been changed during a Workflow run and pushes the Commit back to GitHub.
The Committer is "GitHub Actions <actions@github.com>" and the Author of the Commit can be configured with environment variables.

If no changes are available, the Actions does nothing.

This Action has been inspired and adapted from the [auto-commit](https://github.com/cds-snc/github-actions/tree/master/auto-commit
)-Action of the Canadian Digital Service.

## Usage

You have to have an Action in your Workflow, which changes some of your project files. 
The most common use case for this, is when you're running a Linter or Code-Style fixer on GitHub Actions.

In this example I'm running `php-cs-fixer` in a PHP project.


```terraform
workflow "php-cs-fixer" {
  on = "push"
  resolves = [
    "auto-commit-php-cs-fixer"
  ]
}

action "php-cs-fixer" {
  uses = "docker://oskarstark/php-cs-fixer-ga"
}

action "auto-commit-php-cs-fixer" {
  needs = ["php-cs-fixer"]
  uses = "stefanzweifel/git-auto-commit-action@v1.0.0"
  secrets = ["GITHUB_TOKEN"]
  env = {
    COMMIT_MESSAGE = "Apply php-cs-fixer changes"
    COMMIT_AUTHOR_EMAIL  = "john.doe@example.com"
    COMMIT_AUTHOR_NAME = "John Doe"
  }
}
```


----

New GitHub Actions syntax:

```yaml
- uses: stefanzweifel/git-auto-commit-action@dev
  with:
    commit_author_email: john.doe@example.com
    commit_author_name: John Doe
    commit_message: Apply automatic changes
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```


## Secrets

The `GITHUB_TOKEN` secret is required. Add the secret in the Workflow Editor on github.com.

## Inputs

The following inputs are required

- `commit_author_email`: The commit message used when changes are available
- `commit_author_name`: The Commit Authors Email Address
- `commit_message`: The Commit Authors Name


## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/stefanzweifel/git-auto-commit-action/tags).

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/stefanzweifel/git-auto-commit-action/blob/master/LICENSE) file for details.
