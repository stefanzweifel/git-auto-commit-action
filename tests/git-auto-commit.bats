#!/usr/bin/env bats

load '../node_modules/bats-support/load'
load '../node_modules/bats-assert/load'

setup() {
    # Define Paths for local repository used during tests
    export FAKE_LOCAL_REPOSITORY="${BATS_TEST_DIRNAME}/tests_local_repository"
    export FAKE_REMOTE="${BATS_TEST_DIRNAME}/tests_remote_repository"
    export FAKE_TEMP_LOCAL_REPOSITORY="${BATS_TEST_DIRNAME}/tests_clone_of_remote_repository"
    export FAKE_FOLDER_WITHOUT_GIT_REPO="/tmp/tests_folder_without_git_repo"

    # While it is likely the GitHub hosted runners will use master as the default branch,
    # locally anyone may change that. So for tests lets grab whatever is currently set
    # globally. This should also ensure that changes to the GitHub hosted runners'
    # config do not break tests in the future.
    if [[ -z $(git config init.defaultBranch) ]]; then
        git config --global init.defaultBranch "main"
    fi

    export FAKE_DEFAULT_BRANCH=$(git config init.defaultBranch)

    # Set default INPUT variables used by the GitHub Action
    export INPUT_CREATE_GIT_TAG_ONLY=false
    export INPUT_REPOSITORY="${FAKE_LOCAL_REPOSITORY}"
    export INPUT_COMMIT_MESSAGE="Commit Message"
    export INPUT_BRANCH="${FAKE_DEFAULT_BRANCH}"
    export INPUT_COMMIT_OPTIONS=""
    export INPUT_ADD_OPTIONS=""
    export INPUT_STATUS_OPTIONS=""
    export INPUT_FILE_PATTERN="."
    export INPUT_COMMIT_USER_NAME="Test Suite"
    export INPUT_COMMIT_USER_EMAIL="test@github.com"
    export INPUT_COMMIT_AUTHOR="Test Suite <test@users.noreply.github.com>"
    export INPUT_TAG_NAME=""
    export INPUT_TAGGING_MESSAGE=""
    export INPUT_PUSH_OPTIONS=""
    export INPUT_SKIP_DIRTY_CHECK=false
    export INPUT_SKIP_FETCH=false
    export INPUT_SKIP_CHECKOUT=false
    export INPUT_SKIP_PUSH=false
    export INPUT_DISABLE_GLOBBING=false
    export INPUT_CREATE_BRANCH=false
    export INPUT_INTERNAL_GIT_BINARY=git

    # Set GitHub environment variables used by the GitHub Action
    temp_github_output_file=$(mktemp -t github_output_test.XXXXX)
    export GITHUB_OUTPUT="${temp_github_output_file}"

    # Configure Git
    if [[ -z $(git config user.name) ]]; then
        git config --global user.name "Test Suite"
        git config --global user.email "test@github.com"
    fi

    # Create and setup some fake repositories for testing
    _setup_fake_remote_repository
    _setup_local_repository
}

teardown() {
    rm -rf "${FAKE_LOCAL_REPOSITORY}"
    rm -rf "${FAKE_REMOTE}"
    rm -rf "${FAKE_TEMP_LOCAL_REPOSITORY}"
    rm -rf "${INPUT_REPOSITORY}"

    if [ -z ${GITHUB_OUTPUT+x} ]; then
        echo "GITHUB_OUTPUT is not set"
    else
        rm "${GITHUB_OUTPUT}"
    fi
}

# Create a fake remote repository which tests can push against
_setup_fake_remote_repository() {
    # Create the bare repository, which will act as our remote/origin
    rm -rf "${FAKE_REMOTE}"
    mkdir "${FAKE_REMOTE}"
    cd "${FAKE_REMOTE}"
    git init --bare

    # Clone the remote repository to a temporary location.
    rm -rf "${FAKE_TEMP_LOCAL_REPOSITORY}"
    git clone "${FAKE_REMOTE}" "${FAKE_TEMP_LOCAL_REPOSITORY}"

    # Create some files, commit them and push them to the remote repository
    touch "${FAKE_TEMP_LOCAL_REPOSITORY}"/remote-files{1,2,3}.txt
    cd "${FAKE_TEMP_LOCAL_REPOSITORY}"
    git add .
    git commit --quiet -m "Init Remote Repository"
    git push origin "${FAKE_DEFAULT_BRANCH}"
}

# Clone our fake remote repository and set it up for testing
_setup_local_repository() {
    # Clone remote repository. In this repository we will do our testing
    rm -rf "${FAKE_LOCAL_REPOSITORY}"
    git clone "${FAKE_REMOTE}" "${FAKE_LOCAL_REPOSITORY}"

    cd "${FAKE_LOCAL_REPOSITORY}"
}

# Run the main code related to this GitHub Action
git_auto_commit() {
    bash "${BATS_TEST_DIRNAME}"/../entrypoint.sh
}

cat_github_output() {
    # Be sure to dump anything we spit out to the environment file is
    # also available for asserting
    cat "${GITHUB_OUTPUT}"
}

@test "It detects changes, commits them and pushes them to the remote repository" {
    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}"
    assert_line "INPUT_BRANCH value: ${FAKE_DEFAULT_BRANCH}"
    assert_line "INPUT_FILE_PATTERN: ."
    assert_line "INPUT_COMMIT_OPTIONS: "
    assert_line "::debug::Apply commit options "
    assert_line "INPUT_TAG_NAME: "
    assert_line "INPUT_TAGGING_MESSAGE: "
    assert_line "Neither tag nor tag message is set. No tag will be added."
    assert_line "INPUT_PUSH_OPTIONS: "
    assert_line "::debug::Apply push options "
    assert_line "::debug::Push commit to remote branch ${FAKE_DEFAULT_BRANCH}"

    run cat_github_output
    assert_line "changes_detected=true"
    assert_line -e "commit_hash=[0-9a-f]{40}$"
}

@test "It detects when files have been deleted, commits changes and pushes them to the remote repository" {
    rm -rf "${FAKE_LOCAL_REPOSITORY}"/remote-files1.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}"
    assert_line "INPUT_BRANCH value: ${FAKE_DEFAULT_BRANCH}"
    assert_line "INPUT_FILE_PATTERN: ."
    assert_line "INPUT_COMMIT_OPTIONS: "
    assert_line "::debug::Apply commit options "
    assert_line "INPUT_TAG_NAME: "
    assert_line "INPUT_TAGGING_MESSAGE: "
    assert_line "Neither tag nor tag message is set. No tag will be added."
    assert_line "INPUT_PUSH_OPTIONS: "
    assert_line "::debug::Apply push options "
    assert_line "::debug::Push commit to remote branch ${FAKE_DEFAULT_BRANCH}"

    run cat_github_output
    assert_line "changes_detected=true"
    assert_line -e "commit_hash=[0-9a-f]{40}$"
}

@test "It applies INPUT_STATUS_OPTIONS when running dirty check" {
    INPUT_STATUS_OPTIONS="--untracked-files=no"

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2}.php

    run git_auto_commit

    assert_success

    assert_line "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}"
    assert_line "Working tree clean. Nothing to commit."

    run cat_github_output
    assert_line "changes_detected=false"
    refute_line -e "commit_hash=[0-9a-f]{40}$"
}

@test "It prints a 'Nothing to commit' message in a clean repository" {
    run git_auto_commit

    assert_success

    assert_line "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}"
    assert_line "Working tree clean. Nothing to commit."

    run cat_github_output
    assert_line "changes_detected=false"
    refute_line -e "commit_hash=[0-9a-f]{40}$"
}

@test "If SKIP_DIRTY_CHECK is set to true on a clean repo it fails to push" {
    INPUT_SKIP_DIRTY_CHECK=true

    run git_auto_commit

    assert_failure

    assert_line "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}"
    assert_line "INPUT_FILE_PATTERN: ."
    assert_line "INPUT_COMMIT_OPTIONS: "
    assert_line "::debug::Apply commit options "

    run cat_github_output
    assert_line "changes_detected=true"
    refute_line -e "commit_hash=[0-9a-f]{40}$"
}

@test "It applies INPUT_ADD_OPTIONS when adding files" {
    INPUT_STATUS_OPTIONS="--untracked-files=no"
    INPUT_ADD_OPTIONS="-u"

    date >"${FAKE_LOCAL_REPOSITORY}"/remote-files1.txt
    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2}.php

    run git_auto_commit

    assert_success

    assert_line "INPUT_STATUS_OPTIONS: --untracked-files=no"
    assert_line "INPUT_ADD_OPTIONS: -u"
    assert_line "::debug::Push commit to remote branch ${FAKE_DEFAULT_BRANCH}"

    # Assert that PHP files have not been added.
    run git status
    assert_output --partial 'new-file-1.php'
}

@test "It applies INPUT_FILE_PATTERN when creating commit" {
    INPUT_FILE_PATTERN="src/*.js *.txt *.html"

    mkdir src
    touch src/new-file-{1,2}.js

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2}.php
    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2}.html

    run git_auto_commit

    assert_success

    assert_line "INPUT_FILE_PATTERN: src/*.js *.txt *.html"
    assert_line "::debug::Push commit to remote branch ${FAKE_DEFAULT_BRANCH}"

    # Assert that PHP files have not been added.
    run git status
    assert_output --partial 'new-file-1.php'
}

@test "It applies INPUT_COMMIT_OPTIONS when creating commit" {
    INPUT_COMMIT_OPTIONS="--no-verify --signoff"

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_COMMIT_OPTIONS: --no-verify --signoff"
    assert_line "::debug::Push commit to remote branch ${FAKE_DEFAULT_BRANCH}"

    # Assert last commit was signed off
    run git log -n 1
    assert_output --partial "Signed-off-by:"
}

@test "It applies commit user and author settings" {
    INPUT_COMMIT_USER_NAME="Custom User Name"
    INPUT_COMMIT_USER_EMAIL="single-test@github.com"
    INPUT_COMMIT_AUTHOR="A Single Test <single@users.noreply.github.com>"

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_COMMIT_USER_NAME: Custom User Name"
    assert_line "INPUT_COMMIT_USER_EMAIL: single-test@github.com"
    assert_line "INPUT_COMMIT_AUTHOR: A Single Test <single@users.noreply.github.com>"
    assert_line "::debug::Push commit to remote branch ${FAKE_DEFAULT_BRANCH}"

    # Asser last commit was made by the defined user/author
    run git log -1 --pretty=format:'%ae'
    assert_output --partial "single@users.noreply.github.com"

    run git log -1 --pretty=format:'%an'
    assert_output --partial "A Single Test"

    run git log -1 --pretty=format:'%cn'
    assert_output --partial "Custom User Name"

    run git log -1 --pretty=format:'%ce'
    assert_output --partial "single-test@github.com"
}

@test "It creates a tag with the commit" {
    INPUT_TAG_NAME="v1.0.0"
    INPUT_TAGGING_MESSAGE="MyProduct v1.0.0"

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_TAG_NAME: v1.0.0"
    assert_line "INPUT_TAGGING_MESSAGE: MyProduct v1.0.0"

    assert_line "::debug::Create tag v1.0.0: MyProduct v1.0.0"
    assert_line "::debug::Push commit to remote branch ${FAKE_DEFAULT_BRANCH}"

    # Assert a tag v1.0.0 has been created
    run git tag -n
    assert_output 'v1.0.0          MyProduct v1.0.0'

    run git ls-remote --tags --refs
    assert_output --partial refs/tags/v1.0.0

    # Assert that the commit has been pushed with --force and
    # sha values are equal on local and remote
    current_sha="$(git rev-parse --verify --short ${FAKE_DEFAULT_BRANCH})"
    remote_sha="$(git rev-parse --verify --short origin/${FAKE_DEFAULT_BRANCH})"

    assert_equal $current_sha $remote_sha
}

@test "It applies INPUT_PUSH_OPTIONS when pushing commit to remote" {

    touch "${FAKE_TEMP_LOCAL_REPOSITORY}"/newer-remote-files{1,2,3}.txt
    cd "${FAKE_TEMP_LOCAL_REPOSITORY}"
    git add .
    git commit --quiet -m "Add more remote files"
    git push origin ${FAKE_DEFAULT_BRANCH}

    INPUT_PUSH_OPTIONS="--force"

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_PUSH_OPTIONS: --force"
    assert_line "::debug::Apply push options --force"
    assert_line "::debug::Push commit to remote branch ${FAKE_DEFAULT_BRANCH}"

    # Assert that the commit has been pushed with --force and
    # sha values are equal on local and remote
    current_sha="$(git rev-parse --verify --short ${FAKE_DEFAULT_BRANCH})"
    remote_sha="$(git rev-parse --verify --short origin/${FAKE_DEFAULT_BRANCH})"

    assert_equal $current_sha $remote_sha
}

@test "If SKIP_PUSH is true git-push will not be called" {
    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    INPUT_SKIP_PUSH=true

    run git_auto_commit

    assert_success

    assert_line "::debug::git-push will not be executed."

    # Assert that the sha values are not equal on local and remote
    current_sha="$(git rev-parse --verify --short ${FAKE_DEFAULT_BRANCH})"
    remote_sha="$(git rev-parse --verify --short origin/${FAKE_DEFAULT_BRANCH})"

    refute [assert_equal $current_sha $remote_sha]
}

@test "It can checkout a different branch" {
    # Create foo-branch and then immediately switch back to ${FAKE_DEFAULT_BRANCH}
    git checkout -b foo
    git checkout ${FAKE_DEFAULT_BRANCH}

    INPUT_BRANCH="foo"

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_BRANCH value: foo"
    assert_line "::debug::Push commit to remote branch foo"

    # Assert a new branch "foo" exists on remote
    run git ls-remote --heads
    assert_output --partial refs/heads/foo
}

@test "It uses existing branch name when pushing when INPUT_BRANCH is empty" {
    INPUT_BRANCH=""

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_BRANCH value: "
    assert_line --partial "::debug::git push origin"

    # Assert that branch "${FAKE_DEFAULT_BRANCH}" was updated on remote
    current_sha="$(git rev-parse --verify --short ${FAKE_DEFAULT_BRANCH})"
    remote_sha="$(git rev-parse --verify --short origin/${FAKE_DEFAULT_BRANCH})"

    assert_equal $current_sha $remote_sha
}

@test "It uses existing branch when INPUT_BRANCH is empty and INPUT_TAG is set" {
    INPUT_BRANCH=""
    INPUT_TAG_NAME="v2.0.0"
    INPUT_TAGGING_MESSAGE="MyProduct v2.0.0"


    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_TAG_NAME: v2.0.0"
    assert_line "::debug::Create tag v2.0.0: MyProduct v2.0.0"
    assert_line "::debug::git push origin --tags"

    # Assert a tag v2.0.0 has been created
    run git tag
    assert_output v2.0.0

    # Assert tag v2.0.0 has been pushed to remote
    run git ls-remote --tags --refs
    assert_output --partial refs/tags/v2.0.0
}

@test "If SKIP_FETCH is true git-fetch will not be called" {

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    INPUT_SKIP_FETCH=true

    run git_auto_commit

    assert_success

    assert_line "::debug::git-fetch will not be executed."
}

@test "If SKIP_CHECKOUT is true git-checkout will not be called" {

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    INPUT_SKIP_CHECKOUT=true

    run git_auto_commit

    assert_success

    assert_line "::debug::git-checkout will not be executed."
}

@test "It pushes generated commit and tag to remote and actually updates the commit shas" {
    INPUT_BRANCH=""
    INPUT_TAG_NAME="v2.0.0"
    INPUT_TAGGING_MESSAGE="MyProduct v2.0.0"


    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_TAG_NAME: v2.0.0"
    assert_line "::debug::Create tag v2.0.0: MyProduct v2.0.0"
    assert_line "::debug::git push origin --tags"

    # Assert a tag v2.0.0 has been created
    run git tag
    assert_output v2.0.0

    # Assert tag v2.0.0 has been pushed to remote
    run git ls-remote --tags --refs
    assert_output --partial refs/tags/v2.0.0

    # Assert that branch "${FAKE_DEFAULT_BRANCH}" was updated on remote
    current_sha="$(git rev-parse --verify --short ${FAKE_DEFAULT_BRANCH})"
    remote_sha="$(git rev-parse --verify --short origin/${FAKE_DEFAULT_BRANCH})"

    assert_equal $current_sha $remote_sha
}

@test "It pushes generated commit and tag to remote branch and updates commit sha" {
    # Create "a-new-branch"-branch and then immediately switch back to ${FAKE_DEFAULT_BRANCH}
    git checkout -b a-new-branch
    git checkout ${FAKE_DEFAULT_BRANCH}

    INPUT_BRANCH="a-new-branch"
    INPUT_TAG_NAME="v2.0.0"
    INPUT_TAGGING_MESSAGE="MyProduct v2.0.0"


    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_TAG_NAME: v2.0.0"
    assert_line "::debug::Create tag v2.0.0: MyProduct v2.0.0"
    assert_line "::debug::Push commit to remote branch a-new-branch"

    # Assert a tag v2.0.0 has been created
    run git tag
    assert_output v2.0.0

    # Assert tag v2.0.0 has been pushed to remote
    run git ls-remote --tags --refs
    assert_output --partial refs/tags/v2.0.0

    # Assert that branch "a-new-branch" was updated on remote
    current_sha="$(git rev-parse --verify --short a-new-branch)"
    remote_sha="$(git rev-parse --verify --short origin/a-new-branch)"

    assert_equal $current_sha $remote_sha
}

@test "It does not expand wildcard glob when using INPUT_PATTERN and INPUT_DISABLE_GLOBBING in git-status and git-add" {

    # Create additional files in a nested directory structure
    echo "Create Additional files"
    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-a.py
    mkdir "${FAKE_LOCAL_REPOSITORY}"/nested
    touch "${FAKE_LOCAL_REPOSITORY}"/nested/new-file-b.py

    # Commit changes
    echo "Commit changes before running git_auto_commit"
    cd "${FAKE_LOCAL_REPOSITORY}"
    git add . >/dev/null
    git commit --quiet -m "Init Remote Repository"
    git push origin ${FAKE_DEFAULT_BRANCH} >/dev/null

    # Make nested file dirty
    echo "foo-bar" >"${FAKE_LOCAL_REPOSITORY}"/nested/new-file-b.py

    # ---

    INPUT_FILE_PATTERN="*.py"
    INPUT_DISABLE_GLOBBING=true

    run git_auto_commit

    assert_success

    assert_line "INPUT_FILE_PATTERN: *.py"
    assert_line "::debug::Push commit to remote branch ${FAKE_DEFAULT_BRANCH}"

    # Assert that the updated py file has been commited.
    run git status
    refute_output --partial 'nested/new-file-b.py'
}

@test "it does not throw an error if not changes are detected and SKIP_DIRTY_CHECK is false" {
    INPUT_FILE_PATTERN="."
    INPUT_SKIP_DIRTY_CHECK=false
    INPUT_SKIP_FETCH=false

    run git_auto_commit

    assert_success

    assert_line "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}"

    run git status
    assert_output --partial 'nothing to commit, working tree clean'

    run cat_github_output
    assert_line "changes_detected=false"
}

@test "It does not throw an error if branch is checked out with same name as a file or folder in the repo" {

    # Add File called dev and commit/push
    echo "Create dev file"
    cd "${FAKE_LOCAL_REPOSITORY}"
    echo this is a file named dev >dev
    git add dev
    git commit -m 'add file named dev'
    git update-ref refs/remotes/origin/${FAKE_DEFAULT_BRANCH} ${FAKE_DEFAULT_BRANCH}
    git update-ref refs/remotes/origin/dev ${FAKE_DEFAULT_BRANCH}

    # ---

    INPUT_BRANCH=dev

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{4,5,6}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}"
    assert_line "::debug::Push commit to remote branch dev"

    run cat_github_output
    assert_line "changes_detected=true"
}

@test "It pushes commit to new branch that does not exist yet" {
    INPUT_BRANCH="not-existend-branch"

    run git branch
    refute_line --partial "not-existend-branch"

    run git branch -r
    refute_line --partial "origin/not-existend-branch"

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    INPUT_SKIP_CHECKOUT=true

    run git_auto_commit

    assert_success

    assert_line "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}"
    assert_line "INPUT_BRANCH value: not-existend-branch"

    run git branch
    assert_line --partial ${FAKE_DEFAULT_BRANCH}
    refute_line --partial "not-existend-branch"

    run git branch -r
    assert_line --partial "origin/not-existend-branch"

    run cat_github_output
    assert_line "changes_detected=true"
}

@test "It does not create new local branch and pushes the commit to a new branch on remote" {
    INPUT_BRANCH="not-existend-branch"

    run git branch
    refute_line --partial "not-existend-branch"

    run git branch -r
    refute_line --partial "origin/not-existend-branch"

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    INPUT_SKIP_CHECKOUT=true

    run git_auto_commit

    assert_success

    assert_line "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}"
    assert_line "INPUT_BRANCH value: not-existend-branch"
    assert_line "INPUT_FILE_PATTERN: ."
    assert_line "INPUT_COMMIT_OPTIONS: "
    assert_line "::debug::Apply commit options "
    assert_line "INPUT_TAG_NAME: "
    assert_line "INPUT_TAGGING_MESSAGE: "
    assert_line "Neither tag nor tag message is set. No tag will be added."
    assert_line "INPUT_PUSH_OPTIONS: "
    assert_line "::debug::Apply push options "
    assert_line "::debug::Push commit to remote branch not-existend-branch"

    # Assert that local repo is still on default branch and not on new branch.
    run git branch
    assert_line --partial ${FAKE_DEFAULT_BRANCH}
    refute_line --partial "not-existend-branch"

    # Assert branch has been created on remote
    run git branch -r
    assert_line --partial "origin/not-existend-branch"

    run cat_github_output
    assert_line "changes_detected=true"
    assert_line -e "commit_hash=[0-9a-f]{40}$"
}

@test "It creates new local branch and pushes branch to remote even if the remote branch already exists" {
    # Create `existing-remote-branch` on remote with changes the local repository does not yet have
    cd $FAKE_TEMP_LOCAL_REPOSITORY
    git checkout -b "existing-remote-branch"
    touch new-branch-file.txt
    git add new-branch-file.txt
    git commit -m "Add additional file"
    git push origin existing-remote-branch

    run git branch
    assert_line --partial "existing-remote-branch"

    # ---------
    # Switch to our regular local repository and run `git-auto-commit`
    cd $FAKE_LOCAL_REPOSITORY

    INPUT_BRANCH="existing-remote-branch"
    INPUT_SKIP_CHECKOUT=true

    run git branch
    refute_line --partial "existing-remote-branch"

    run git fetch --all
    run git pull origin existing-remote-branch
    run git branch -r
    assert_line --partial "origin/existing-remote-branch"

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}"
    assert_line "INPUT_BRANCH value: existing-remote-branch"
    assert_line "INPUT_FILE_PATTERN: ."
    assert_line "INPUT_COMMIT_OPTIONS: "
    assert_line "::debug::Apply commit options "
    assert_line "INPUT_TAG_NAME: "
    assert_line "INPUT_TAGGING_MESSAGE: "
    assert_line "Neither tag nor tag message is set. No tag will be added."
    assert_line "INPUT_PUSH_OPTIONS: "
    assert_line "::debug::Apply push options "
    assert_line "::debug::Push commit to remote branch existing-remote-branch"

    run git branch
    assert_line --partial ${FAKE_DEFAULT_BRANCH}
    refute_line --partial "existing-remote-branch"

    run git branch -r
    assert_line --partial "origin/existing-remote-branch"

    # Assert that branch "existing-remote-branch" was updated on remote
    current_sha="$(git rev-parse --verify --short ${FAKE_DEFAULT_BRANCH})"
    remote_sha="$(git rev-parse --verify --short origin/existing-remote-branch)"

    assert_equal $current_sha $remote_sha

    run cat_github_output
    assert_line "changes_detected=true"
    assert_line -e "commit_hash=[0-9a-f]{40}$"
}

@test "It fails if local branch is behind remote and when remote has newer commits and skip_checkout is set to true" {
    # Create `existing-remote-branch` on remote with changes the local repository does not yet have
    cd $FAKE_TEMP_LOCAL_REPOSITORY
    git checkout -b "existing-remote-branch"
    touch new-branch-file.txt
    git add new-branch-file.txt
    git commit -m "Add additional file"
    git push origin existing-remote-branch

    run git branch
    assert_line --partial "existing-remote-branch"

    # ---------
    # Switch to our regular local repository and run `git-auto-commit`
    cd $FAKE_LOCAL_REPOSITORY

    INPUT_BRANCH="existing-remote-branch"
    INPUT_SKIP_CHECKOUT=true

    run git branch
    refute_line --partial "existing-remote-branch"

    run git fetch --all
    run git branch -r
    assert_line --partial "origin/existing-remote-branch"

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_failure

    assert_line "hint: Updates were rejected because a pushed branch tip is behind its remote"

    # Assert that branch exists locally and on remote
    run git branch
    assert_line --partial ${FAKE_DEFAULT_BRANCH}
    refute_line --partial "existing-remote-branch"

    run git branch -r
    assert_line --partial "origin/existing-remote-branch"

    # Assert that branch "existing-remote-branch" was not updated on remote
    current_sha="$(git rev-parse --verify --short ${FAKE_DEFAULT_BRANCH})"
    remote_sha="$(git rev-parse --verify --short origin/existing-remote-branch)"

    refute [assert_equal $current_sha $remote_sha]
}

@test "It fails to push commit to remote if branch already exists and local repo is behind its remote counterpart and SKIP_CHECKOUT is used" {
    # Create `new-branch` on remote with changes the local repository does not yet have
    cd $FAKE_TEMP_LOCAL_REPOSITORY

    git checkout -b "new-branch"
    touch new-branch-file.txt
    git add new-branch-file.txt

    git commit --quiet -m "Add additional file"
    git push origin new-branch

    run git branch -r
    assert_line --partial "origin/new-branch"

    # ---------
    # Switch to our regular local repository and run `git-auto-commit`
    cd $FAKE_LOCAL_REPOSITORY

    INPUT_BRANCH="new-branch"
    INPUT_SKIP_CHECKOUT=true

    # Assert that local remote does not have a "new-branch"-branch nor does
    # know about the remote branch.
    run git branch
    refute_line --partial "new-branch"

    run git branch -r
    refute_line --partial "origin/new-branch"

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_failure

    assert_line "INPUT_BRANCH value: new-branch"
    assert_line --partial "::debug::Push commit to remote branch new-branch"

    assert_line --partial "Updates were rejected because a pushed branch tip is behind its remote"
}

@test "throws fatal error if file pattern includes files that do not exist" {
    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.foo

    INPUT_FILE_PATTERN="*.foo *.bar"

    run git_auto_commit

    assert_failure
    assert_line --partial "fatal: pathspec '*.bar' did not match any files"
}

@test "does not throw fatal error if files for file pattern exist but only one is dirty" {
    # Add some .foo and .bar files
    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.foo
    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.bar

    INPUT_FILE_PATTERN="*.foo *.bar"

    run git_auto_commit

    # Add more .foo files
    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{4,5,6}.foo

    INPUT_FILE_PATTERN="*.foo *.bar"

    run git_auto_commit

    assert_success
}

@test "detects and commits changed files based on pattern in root and subfolders" {
    # Add some .neon files
    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-1.neon
    mkdir foo
    touch "${FAKE_LOCAL_REPOSITORY}"/foo/new-file-2.neon

    INPUT_FILE_PATTERN="**/*.neon *.neon"

    run git_auto_commit

    assert_success

    assert_line --partial "new-file-1.neon"
    assert_line --partial "foo/new-file-2.neon"
}

@test "throws error if tries to force add ignored files which do not have any changes" {
    # Create 2 files which will later will be added to .gitignore
    touch "${FAKE_LOCAL_REPOSITORY}"/ignored-file.txt
    touch "${FAKE_LOCAL_REPOSITORY}"/another-ignored-file.txt

    # Commit the 2 new files
    run git_auto_commit

    # Add our txt files to gitignore
    echo "ignored-file.txt" >>"${FAKE_LOCAL_REPOSITORY}"/.gitignore
    echo "another-ignored-file.txt" >>"${FAKE_LOCAL_REPOSITORY}"/.gitignore

    # Commit & push .gitignore changes
    run git_auto_commit

    # Sanity check that txt files are ignored
    run cat "${FAKE_LOCAL_REPOSITORY}"/.gitignore
    assert_output --partial "ignored-file.txt"
    assert_output --partial "another-ignored-file.txt"

    # Configure git-auto-commit
    INPUT_SKIP_DIRTY_CHECK=true
    INPUT_ADD_OPTIONS="-f"
    INPUT_FILE_PATTERN="ignored-file.txt another-ignored-file.txt"

    # Run git-auto-commit with special configuration
    run git_auto_commit

    assert_output --partial "nothing to commit, working tree clean"

    assert_failure
}

@test "expands file patterns correctly and commits all changed files" {
    # Add more .txt files
    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-1.txt
    mkdir "${FAKE_LOCAL_REPOSITORY}"/subdirectory/
    touch "${FAKE_LOCAL_REPOSITORY}"/subdirectory/new-file-2.txt
    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-3.bar

    INPUT_FILE_PATTERN="*.txt *.bar"

    run git_auto_commit

    assert_success

    assert_line --partial "new-file-1.txt"
    assert_line --partial "subdirectory/new-file-2.txt"
    assert_line --partial "new-file-3.bar"
}

@test "expands file patterns correctly and commits all changed files when globbing is disabled" {
    # Add more .txt files
    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-1.txt
    mkdir "${FAKE_LOCAL_REPOSITORY}"/subdirectory/
    touch "${FAKE_LOCAL_REPOSITORY}"/subdirectory/new-file-2.txt
    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-3.bar

    INPUT_FILE_PATTERN="*.txt *.bar"
    INPUT_DISABLE_GLOBBING=true

    run git_auto_commit

    assert_success

    assert_line --partial "new-file-1.txt"
    assert_line --partial "subdirectory/new-file-2.txt"
    assert_line --partial "new-file-3.bar"
}

@test "expands file patterns correctly and commits all changed files if dirty files are only in subdirectory" {
    # Add more .txt files
    mkdir "${FAKE_LOCAL_REPOSITORY}"/subdirectory/
    touch "${FAKE_LOCAL_REPOSITORY}"/subdirectory/new-file-2.txt
    mkdir "${FAKE_LOCAL_REPOSITORY}"/another-subdirectory/
    touch "${FAKE_LOCAL_REPOSITORY}"/another-subdirectory/new-file-3.txt

    INPUT_FILE_PATTERN="*.txt"
    INPUT_DISABLE_GLOBBING=true

    run git_auto_commit

    assert_success

    assert_line --partial "subdirectory/new-file-2.txt"
    assert_line --partial "another-subdirectory/new-file-3.txt"
}

@test "detects if crlf in files change and does not create commit" {
    # Set autocrlf to true
    cd "${FAKE_LOCAL_REPOSITORY}"
    git config core.autocrlf true
    run git config --get-all core.autocrlf
    assert_line "true"

    # Add more .txt files
    echo -ne "crlf test1\r\n" > "${FAKE_LOCAL_REPOSITORY}"/new-file-2.txt
    echo -ne "crlf test1\n" > "${FAKE_LOCAL_REPOSITORY}"/new-file-3.txt

    # Run git-auto-commit to add new files to repository
    run git_auto_commit

    # Change control characters in files
    echo -ne "crlf test1\n" > "${FAKE_LOCAL_REPOSITORY}"/new-file-2.txt
    echo -ne "crlf test1\r\n" > "${FAKE_LOCAL_REPOSITORY}"/new-file-3.txt

    # Run git-auto-commit to commit the 2 changes files
    run git_auto_commit

    assert_success

    refute_line --partial "2 files changed, 2 insertions(+), 2 deletions(-)"
    assert_line --partial "warning: in the working copy of 'new-file-2.txt', LF will be replaced by CRLF the next time Git touches it"

    assert_line --partial "Working tree clean. Nothing to commit."
    assert_line --partial "new-file-2.txt"
    # assert_line --partial "new-file-3.txt"

    # Changes are not detected
    run cat_github_output
    assert_line "changes_detected=false"
}

@test "detects if crlf in files change and creates commit if the actual content of the files change" {
    # Set autocrlf to true
    cd "${FAKE_LOCAL_REPOSITORY}"
    git config core.autocrlf true
    run git config --get-all core.autocrlf
    assert_line "true"

    # Add more .txt files
    echo -ne "crlf test1\r\n" > "${FAKE_LOCAL_REPOSITORY}"/new-file-2.txt
    echo -ne "crlf test1\n" > "${FAKE_LOCAL_REPOSITORY}"/new-file-3.txt

    # Run git-auto-commit to add new files to repository
    run git_auto_commit

    # Change control characters in files
    echo -ne "crlf test2\n" > "${FAKE_LOCAL_REPOSITORY}"/new-file-2.txt
    echo -ne "crlf test2\r\n" > "${FAKE_LOCAL_REPOSITORY}"/new-file-3.txt

    # Run git-auto-commit to commit the 2 changes files
    run git_auto_commit

    assert_success

    assert_line --partial "2 files changed, 2 insertions(+), 2 deletions(-)"
    assert_line --partial "warning: in the working copy of 'new-file-2.txt', LF will be replaced by CRLF the next time Git touches it"

    assert_line --partial "new-file-2.txt"
    # assert_line --partial "new-file-3.txt"

    # Changes are detected
    run cat_github_output
    assert_line "changes_detected=true"
}


@test "It uses old set-output syntax if GITHUB_OUTPUT environment is not available when changes are committed" {
    unset GITHUB_OUTPUT

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}"
    assert_line "INPUT_BRANCH value: ${FAKE_DEFAULT_BRANCH}"
    assert_line "INPUT_FILE_PATTERN: ."
    assert_line "INPUT_COMMIT_OPTIONS: "
    assert_line "::debug::Apply commit options "
    assert_line "INPUT_TAG_NAME: "
    assert_line "INPUT_TAGGING_MESSAGE: "
    assert_line "Neither tag nor tag message is set. No tag will be added."
    assert_line "INPUT_PUSH_OPTIONS: "
    assert_line "::debug::Apply push options "
    assert_line "::debug::Push commit to remote branch ${FAKE_DEFAULT_BRANCH}"

    assert_line "::set-output name=changes_detected::true"
    assert_line -e "::set-output name=commit_hash::[0-9a-f]{40}$"
}

@test "It uses old set-output syntax if GITHUB_OUTPUT environment is not available when no changes have been detected" {
    unset GITHUB_OUTPUT

    run git_auto_commit

    assert_success

    assert_line "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}"
    assert_line "Working tree clean. Nothing to commit."

    assert_line "::set-output name=changes_detected::false"
    refute_line -e "::set-output name=commit_hash::[0-9a-f]{40}$"
}

@test "It fails hard if git is not available" {
    INPUT_INTERNAL_GIT_BINARY=binary-does-not-exist

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_failure;
    assert_line "::error::git-auto-commit could not find git binary. Please make sure git is available."
}

@test "It creates multi-line commit messages" {
    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    COMMIT_MESSAGE=$(cat <<-END
    this commit message
    has multiple lines
END
)

    INPUT_COMMIT_MESSAGE=$COMMIT_MESSAGE

    run git_auto_commit

    assert_success

    # Assert last commit was signed off
    run git log -n 1
    assert_output --partial $COMMIT_MESSAGE
}

@test "It exits with error message if entrypoint.sh is being run not in a git repository" {
    INPUT_REPOSITORY="${FAKE_FOLDER_WITHOUT_GIT_REPO}"

    mkdir "${INPUT_REPOSITORY}"

    run git_auto_commit

    assert_failure;
    assert_line "::error::Not a git repository. Please make sure to run this action in a git repository. Adjust the `repository` input if necessary."
}

@test "It detects if the repository is in a detached state and logs a warning" {
    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_success

    # Bring local repository into a detached state
    prev_commit=$(git rev-parse HEAD~1);
    git checkout "$prev_commit";

    touch "${FAKE_TEMP_LOCAL_REPOSITORY}"/remote-files{4,5,6}.txt

    run git_auto_commit

    assert_success;
    assert_line "::warning::Repository is in a detached HEAD state. git-auto-commit will likely handle this automatically. To avoid it, check out a branch using the ref option in actions/checkout."
}

@test "it creates a tag if create_git_tag_only is set to true and a message has been supplied" {
    INPUT_CREATE_GIT_TAG_ONLY=true
    INPUT_TAG_NAME=v1.0.0
    INPUT_TAGGING_MESSAGE="MyProduct v1.0.0"

    run git_auto_commit

    assert_success

    assert_line "::debug::Create git tag only"

    assert_line "::debug::Create tag v1.0.0: MyProduct v1.0.0"
    refute_line "Neither tag nor tag message is set. No tag will be added."

    assert_line "::debug::Apply push options "
    assert_line "::debug::Push commit to remote branch ${FAKE_DEFAULT_BRANCH}"

    run cat_github_output
    assert_line "create_git_tag_only=true"
    refute_line "changes_detected=false"
    refute_line -e "commit_hash=[0-9a-f]{40}$"

    # Assert a tag v1.0.0 has been created
    run git tag -n
    assert_output 'v1.0.0          MyProduct v1.0.0'

    run git ls-remote --tags --refs
    assert_output --partial refs/tags/v1.0.0
}

@test "it output no tagging message supplied if no tagging message is set but create_git_tag_only is set to true" {
    INPUT_CREATE_GIT_TAG_ONLY=true
    INPUT_TAG_NAME=""
    INPUT_TAGGING_MESSAGE=""

    run git_auto_commit

    assert_success

    assert_line "INPUT_TAG_NAME: "
    assert_line "INPUT_TAGGING_MESSAGE: "
    assert_line "Neither tag nor tag message is set. No tag will be added."
    assert_line "::debug::Create git tag only"

    run cat_github_output
    assert_line "create_git_tag_only=true"
    refute_line "changes_detected=false"
    refute_line -e "commit_hash=[0-9a-f]{40}$"

    # Assert no tag has been created
    run git tag
    assert_output ""
}

@test "script fails to push commit to new branch that does not exist yet" {
    INPUT_BRANCH="not-existend-branch"
    INPUT_CREATE_BRANCH=false

    run git branch
    refute_line --partial "not-existend-branch"

    run git branch -r
    refute_line --partial "origin/not-existend-branch"

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_failure

    assert_line "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}"
    assert_line "INPUT_BRANCH value: not-existend-branch"
    assert_line "fatal: invalid reference: not-existend-branch"

    run git branch
    refute_line --partial "not-existend-branch"

    run git branch -r
    refute_line --partial "origin/not-existend-branch"

    run cat_github_output
    assert_line "changes_detected=true"
}

@test "It creates new local branch and pushes the new branch to remote" {
    INPUT_BRANCH="not-existend-branch"
    INPUT_CREATE_BRANCH=true

    run git branch
    refute_line --partial "not-existend-branch"

    run git branch -r
    refute_line --partial "origin/not-existend-branch"

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}"
    assert_line "INPUT_BRANCH value: not-existend-branch"
    assert_line "INPUT_FILE_PATTERN: ."
    assert_line "INPUT_COMMIT_OPTIONS: "
    assert_line "::debug::Apply commit options "
    assert_line "INPUT_TAGGING_MESSAGE: "
    assert_line "Neither tag nor tag message is set. No tag will be added."
    assert_line "INPUT_PUSH_OPTIONS: "
    assert_line "::debug::Apply push options "
    assert_line "::debug::Push commit to remote branch not-existend-branch"

    run git branch
    assert_line --partial "not-existend-branch"

    run git branch -r
    assert_line --partial "origin/not-existend-branch"

    run cat_github_output
    assert_line "changes_detected=true"
    assert_line -e "commit_hash=[0-9a-f]{40}$"
}

@test "It does not create new local branch if local branch already exists and SKIP_CHECKOUT is true" {
    git checkout -b not-existend-remote-branch
    git checkout ${FAKE_DEFAULT_BRANCH}

    INPUT_BRANCH="not-existend-remote-branch"
    INPUT_SKIP_CHECKOUT=true

    run git branch
    assert_line --partial "not-existend-remote-branch"

    run git branch -r
    refute_line --partial "origin/not-existend-remote-branch"

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}"
    assert_line "INPUT_BRANCH value: not-existend-remote-branch"
    assert_line "INPUT_FILE_PATTERN: ."
    assert_line "INPUT_COMMIT_OPTIONS: "
    assert_line "::debug::Apply commit options "
    assert_line "INPUT_TAGGING_MESSAGE: "
    assert_line "Neither tag nor tag message is set. No tag will be added."
    assert_line "INPUT_PUSH_OPTIONS: "
    assert_line "::debug::Apply push options "
    assert_line "::debug::Push commit to remote branch not-existend-remote-branch"

    # Assert checked out branch is still the same.
    run git rev-parse --abbrev-ref HEAD
    assert_line --partial ${FAKE_DEFAULT_BRANCH}
    refute_line --partial "not-existend-remote-branch"

    run git branch
    assert_line --partial "not-existend-remote-branch"

    run git branch -r
    assert_line --partial "origin/not-existend-remote-branch"

    run cat_github_output
    assert_line "changes_detected=true"
    assert_line -e "commit_hash=[0-9a-f]{40}$"
}

@test "it creates new local branch and pushes branch to remote even if the remote branch already exists" {

    # Create `existing-remote-branch` on remote with changes the local repository does not yet have
    cd $FAKE_TEMP_LOCAL_REPOSITORY
    git checkout -b "existing-remote-branch"
    touch new-branch-file.txt
    git add new-branch-file.txt
    git commit -m "Add additional file"
    git push origin existing-remote-branch

    run git branch
    assert_line --partial "existing-remote-branch"

    # ---------
    # Switch to our regular local repository and run `git-auto-commit`
    cd $FAKE_LOCAL_REPOSITORY

    INPUT_BRANCH="existing-remote-branch"
    INPUT_CREATE_BRANCH=true

    run git branch
    refute_line --partial "existing-remote-branch"

    run git fetch --all
    run git pull origin existing-remote-branch
    run git branch -r
    assert_line --partial "origin/existing-remote-branch"

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}"
    assert_line "INPUT_BRANCH value: existing-remote-branch"
    assert_line "INPUT_FILE_PATTERN: ."
    assert_line "INPUT_COMMIT_OPTIONS: "
    assert_line "::debug::Apply commit options "
    assert_line "INPUT_TAGGING_MESSAGE: "
    assert_line "Neither tag nor tag message is set. No tag will be added."
    assert_line "INPUT_PUSH_OPTIONS: "
    assert_line "::debug::Apply push options "
    assert_line "::debug::Push commit to remote branch existing-remote-branch"

    run git branch
    assert_line --partial "existing-remote-branch"

    run git branch -r
    assert_line --partial "origin/existing-remote-branch"

    # Assert that branch "existing-remote-branch" was updated on remote
    current_sha="$(git rev-parse --verify --short existing-remote-branch)"
    remote_sha="$(git rev-parse --verify --short origin/existing-remote-branch)"

    assert_equal $current_sha $remote_sha

    run cat_github_output
    assert_line "changes_detected=true"
    assert_line -e "commit_hash=[0-9a-f]{40}$"
}

@test "script fails if new local branch is checked out and push fails as remote has newer commits than local" {
    # Create `existing-remote-branch` on remote with changes the local repository does not yet have
    cd $FAKE_TEMP_LOCAL_REPOSITORY
    git checkout -b "existing-remote-branch"
    touch new-branch-file.txt
    git add new-branch-file.txt
    git commit -m "Add additional file"
    git push origin existing-remote-branch

    run git branch
    assert_line --partial "existing-remote-branch"

    # ---------
    # Switch to our regular local repository and run `git-auto-commit`
    cd $FAKE_LOCAL_REPOSITORY

    INPUT_BRANCH="existing-remote-branch"
    INPUT_CREATE_BRANCH=true

    run git branch
    refute_line --partial "existing-remote-branch"

    run git fetch --all
    run git branch -r
    assert_line --partial "origin/existing-remote-branch"

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_failure

    assert_line "hint: Updates were rejected because the tip of your current branch is behind"

    # Assert that branch exists locally and on remote
    run git branch
    assert_line --partial "existing-remote-branch"

    run git branch -r
    assert_line --partial "origin/existing-remote-branch"

    # Assert that branch "existing-remote-branch" was not updated on remote
    current_sha="$(git rev-parse --verify --short existing-remote-branch)"
    remote_sha="$(git rev-parse --verify --short origin/existing-remote-branch)"

    refute [assert_equal $current_sha $remote_sha]
}

@test "It pushes commit to remote if branch already exists and local repo is behind its remote counterpart" {
    # Create `new-branch` on remote with changes the local repository does not yet have
    cd $FAKE_TEMP_LOCAL_REPOSITORY

    git checkout -b "new-branch"
    touch new-branch-file.txt
    git add new-branch-file.txt

    git commit --quiet -m "Add additional file"
    git push origin new-branch

    run git branch -r
    assert_line --partial "origin/new-branch"

    # ---------
    # Switch to our regular local repository and run `git-auto-commit`
    cd $FAKE_LOCAL_REPOSITORY

    INPUT_BRANCH="new-branch"

    # Assert that local remote does not know have "new-branch" locally nor does
    # know about the remote branch.
    run git branch
    refute_line --partial "new-branch"

    run git branch -r
    refute_line --partial "origin/new-branch"

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_BRANCH value: new-branch"
    assert_line --partial "::debug::Push commit to remote branch new-branch"

    # Assert that branch "new-branch" was updated on remote
    current_sha="$(git rev-parse --verify --short new-branch)"
    remote_sha="$(git rev-parse --verify --short origin/new-branch)"

    assert_equal $current_sha $remote_sha
}

@test "Set a tag message only" {
    INPUT_TAGGING_MESSAGE="v1.0.0"

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_TAG_NAME: "
    assert_line "INPUT_TAGGING_MESSAGE: v1.0.0"

    assert_line "::debug::Create tag v1.0.0: v1.0.0"
    assert_line "::debug::Push commit to remote branch ${FAKE_DEFAULT_BRANCH}"

    # Assert a tag v1.0.0 has been created
    run git tag -n
    assert_output 'v1.0.0          v1.0.0'

    run git ls-remote --tags --refs
    assert_output --partial refs/tags/v1.0.0

    # Assert that the commit has been pushed with --force and
    # sha values are equal on local and remote
    current_sha="$(git rev-parse --verify --short ${FAKE_DEFAULT_BRANCH})"
    remote_sha="$(git rev-parse --verify --short origin/${FAKE_DEFAULT_BRANCH})"

    assert_equal $current_sha $remote_sha
}

@test "Set a tag only" {
    INPUT_TAG_NAME="v1.0.0"

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_TAG_NAME: v1.0.0"
    assert_line "INPUT_TAGGING_MESSAGE: "

    assert_line "::debug::Create tag v1.0.0: v1.0.0"
    assert_line "::debug::Push commit to remote branch ${FAKE_DEFAULT_BRANCH}"

    # Assert a tag v1.0.0 has been created
    run git tag -n
    assert_output 'v1.0.0          v1.0.0'

    run git ls-remote --tags --refs
    assert_output --partial refs/tags/v1.0.0

    # Assert that the commit has been pushed with --force and
    # sha values are equal on local and remote
    current_sha="$(git rev-parse --verify --short ${FAKE_DEFAULT_BRANCH})"
    remote_sha="$(git rev-parse --verify --short origin/${FAKE_DEFAULT_BRANCH})"

    assert_equal $current_sha $remote_sha
}
