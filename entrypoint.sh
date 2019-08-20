#!/bin/sh
set -eu

git config --global user.email "actions@github.com"
git config --global user.name "GitHub Actions"

git add -A
git status
git commit -m "$INPUT_COMMIT_MESSAGE" --author="$INPUT_COMMIT_AUTHOR_NAME <$INPUTCOMMIT_AUTHOR_EMAIL>" || echo "No changes found. Nothing to commit."
git push -u origin HEAD
