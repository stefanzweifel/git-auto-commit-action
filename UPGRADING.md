# Upgrading

## From v6 to v7

The previously removed options `create_branch`, `skip_fetch`, and `skip_checkout` have been reintroduced in git-auto-commit v7. If you had removed these options from your workflows when upgrading to v6, you can now add them back if needed.

Tagging a commit has been reworked. In addition to the existing `tagging_message`-option, a new `tag_name` option has been added. If you were using `tagging_message`, you can continue to do so, but if you want to specify a custom tag name and tag message, you can now use the `tag_name` and `tagging_message` option.
(Specifying a `tagging_message` without a `tag_name` will create a tag with the name and message both set to the value of `tagging_message`.)

## From v5 to v6

The following options have been removed from git-auto-commit and can be removed from your workflows.

- `create_branch` (git-auto-commit no longer switches branches locally during a workflow run)
- `skip_fetch`
- `skip_checkout`

