#!/bin/sh
set -eu

# Switch to branch from current Workflow run
# git checkout "${GITHUB_REF:11}"

# Set origin URL
# git remote set-url origin https://$TOKEN:x-oauth-basic@github.com/$GITHUB_REPOSITORY

# git config --global user.email "actions@github.com"
# git config --global user.name "GitHub Actions"

# git add -A
# git status
# git commit -m "$INPUT_COMMIT_MESSAGE" --author="$INPUT_COMMIT_AUTHOR_NAME <$INPUT_COMMIT_AUTHOR_EMAIL>" || echo "No changes found. Nothing to commit."
# git push -u origin HEAD



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

  # Git requires our "name" and email address -- use GitHub handle
  git config user.email "$GITHUB_ACTOR@users.noreply.github.com"
  git config user.name "$GITHUB_ACTOR"

  # Push to the current branch if PUSH_BRANCH hasn't been overriden
  # : ${PUSH_BRANCH:=`echo "$GITHUB_REF" | awk -F / '{ print $3 }' `}
}


# This section only runs if there have been file changes
echo "Checking for uncommitted changes in the git working tree."
if ! git diff --quiet
then
    git_setup

    git checkout "${GITHUB_REF:11}"
    # git checkout $PUSH_BRANCH
    git add .
    git commit -m "$INPUT_COMMIT_MESSAGE" --author="$INPUT_COMMIT_AUTHOR_NAME <$INPUT_COMMIT_AUTHOR_EMAIL>" || echo "No changes found. Nothing to commit."
    git push -u origin HEAD
    # git push --set-upstream origin "${GITHUB_REF:11}"
    # git push --set-upstream origin $PUSH_BRANCH
else
    echo "Working tree clean. Nothing to commit."
fi
