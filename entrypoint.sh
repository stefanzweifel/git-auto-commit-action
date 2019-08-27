#!/bin/sh
set -eu

# Switch to branch from current Workflow run
git switch "${GITHUB_REF:11}"

# Set origin URL
git remote set-url origin https://$TOKEN:x-oauth-basic@github.com/$GITHUB_REPOSITORY

git config --global user.email "actions@github.com"
git config --global user.name "GitHub Actions"

git add -A
git status
git commit -m "$INPUT_COMMIT_MESSAGE" --author="$INPUT_COMMIT_AUTHOR_NAME <$INPUT_COMMIT_AUTHOR_EMAIL>" || echo "No changes found. Nothing to commit."
git push -u origin HEAD
