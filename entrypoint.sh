#!/bin/bash

set -eu

_main() {
    _switch_to_repository

    if _git_is_dirty; then

        echo \"::set-output name=changes_detected::true\"

        _setup_git

        _switch_to_branch

        _add_files

        _local_commit

        _tag_commit

        _push_to_github
    else

        echo \"::set-output name=changes_detected::false\"

        echo "Working tree clean. Nothing to commit."
    fi
}


_switch_to_repository() {
    echo "INPUT_REPOSITORY value: $INPUT_REPOSITORY";
    cd $INPUT_REPOSITORY
}

_git_is_dirty() {
    [ -n "$(git status -s)" ]
}

# Set up git user configuration
_setup_git ( ) {
    git config --global user.name "$INPUT_COMMIT_USER_NAME"
    git config --global user.email "$INPUT_COMMIT_USER_EMAIL"
}

_switch_to_branch() {
    echo "INPUT_BRANCH value: $INPUT_BRANCH";

    # Switch to branch from current Workflow run
    git checkout $INPUT_BRANCH
}

_add_files() {
    echo "INPUT_FILE_PATTERN: ${INPUT_FILE_PATTERN}"
    git add "${INPUT_FILE_PATTERN}"
}

_local_commit() {
    echo "INPUT_COMMIT_OPTIONS: ${INPUT_COMMIT_OPTIONS}"
    git commit -m "$INPUT_COMMIT_MESSAGE" --author="$INPUT_COMMIT_AUTHOR" ${INPUT_COMMIT_OPTIONS:+"$INPUT_COMMIT_OPTIONS"}
}

_tag_commit() {
    if [ -z "$INPUT_TAGGING_MESSAGE" ]
    then
        # No tag name given. Do nothing.
    else
        git tag -a "$INPUT_TAGGING_MESSAGE" -m "$INPUT_TAGGING_MESSAGE"
    fi
}

_push_to_github() {
    if [ -z "$INPUT_BRANCH" ]
    then
        git push origin --tags
    else
        git push --set-upstream origin "HEAD:$INPUT_BRANCH" --tags
    fi
}

_main
