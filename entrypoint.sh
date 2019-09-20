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


# This section only runs if there have been file changes
echo "Checking for uncommitted changes in the git working tree."
if ! git diff --quiet
then
    git_setup

    echo "INPUT_REF value: $INPUT_REF";

    # Switch to branch from current Workflow run
    git checkout $INPUT_REF

    git add .

    git commit -m "$INPUT_COMMIT_MESSAGE" --author="$INPUT_COMMIT_AUTHOR_NAME <$INPUT_COMMIT_AUTHOR_EMAIL>"

    git push --set-upstream origin "HEAD:$INPUT_REF"
else
    echo "Working tree clean. Nothing to commit."
fi
