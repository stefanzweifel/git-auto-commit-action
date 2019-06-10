#!/bin/sh
set -eu

git config --global user.email "actions@github.com"
git config --global user.name "Github Actions"

git add -A
git status
git commit -m "$COMMIT_MESSAGE" --author="$COMMIT_AUTHOR_NAME <$COMMIT_AUTHOR_EMAIL>" || echo "No changes found. Nothing to commit."
git push -u origin HEAD
