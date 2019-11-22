#!/bin/sh

set -eu

# Set up .netrc file with GitHub credentials
git_setup ( ) {
  cat <<- EOF > $HOME/.netrc
        machine github.com
        login $GITHUB_ACTOR
        password $GITHUB_TOKEN

        machine api.github.com
        login $GITHUB_ACTOR
        password $GITHUB_TOKEN
EOF
    chmod 600 $HOME/.netrc

    git config --global user.email "actions@github.com"
    git config --global user.name "GitHub Actions"
}

git_setup

echo "INPUT_BRANCH value: $INPUT_BRANCH";

# Switch to branch from current Workflow run
git checkout $INPUT_BRANCH

echo "INPUT_FILE_PATTERN: ${INPUT_FILE_PATTERN}"

git add "${INPUT_FILE_PATTERN}"

echo "Checking for uncommitted changes in the git working tree."

if ! git diff --staged --quiet
then
    echo "Working tree clean. Nothing to commit."

    exit 0
fi

echo "Found added/changed files."

echo "INPUT_COMMIT_OPTIONS: ${INPUT_COMMIT_OPTIONS}"

git commit -m "$INPUT_COMMIT_MESSAGE" --author="$GITHUB_ACTOR <$GITHUB_ACTOR@users.noreply.github.com>" ${INPUT_COMMIT_OPTIONS:+"$INPUT_COMMIT_OPTIONS"}

git push --set-upstream origin "HEAD:$INPUT_BRANCH"
