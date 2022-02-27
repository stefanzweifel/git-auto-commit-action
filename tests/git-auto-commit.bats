#!/usr/bin/env bats

load '../node_modules/bats-support/load'
load '../node_modules/bats-assert/load'

setup() {
    # Define Paths for local repository used during tests
    export FAKE_LOCAL_REPOSITORY="${BATS_TEST_DIRNAME}/tests_local_repository"
    export FAKE_REMOTE="${BATS_TEST_DIRNAME}/tests_remote_repository"
    export FAKE_TEMP_LOCAL_REPOSITORY="${BATS_TEST_DIRNAME}/tests_clone_of_remote_repository"

    # Set default INPUT variables used by the GitHub Action
    export INPUT_REPOSITORY="${FAKE_LOCAL_REPOSITORY}"
    export INPUT_COMMIT_MESSAGE="Commit Message"
    export INPUT_BRANCH="master"
    export INPUT_COMMIT_OPTIONS=""
    export INPUT_ADD_OPTIONS=""
    export INPUT_STATUS_OPTIONS=""
    export INPUT_FILE_PATTERN="."
    export INPUT_COMMIT_USER_NAME="Test Suite"
    export INPUT_COMMIT_USER_EMAIL="test@github.com"
    export INPUT_COMMIT_AUTHOR="Test Suite <test@users.noreply.github.com>"
    export INPUT_TAGGING_MESSAGE=""
    export INPUT_PUSH_OPTIONS=""
    export INPUT_SKIP_DIRTY_CHECK=false
    export INPUT_SKIP_FETCH=false
    export INPUT_SKIP_CHECKOUT=false
    export INPUT_DISABLE_GLOBBING=false
    export INPUT_CREATE_BRANCH=false

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
}

# Create a fake remote repository which tests can push against
_setup_fake_remote_repository() {
    # Create the bare repository, which will act as our remote/origin
    rm -rf "${FAKE_REMOTE}";
    mkdir "${FAKE_REMOTE}";
    cd "${FAKE_REMOTE}";
    git init --bare;

    # Clone the remote repository to a temporary location.
    rm -rf "${FAKE_TEMP_LOCAL_REPOSITORY}"
    git clone "${FAKE_REMOTE}" "${FAKE_TEMP_LOCAL_REPOSITORY}"

    # Create some files, commit them and push them to the remote repository
    touch "${FAKE_TEMP_LOCAL_REPOSITORY}"/remote-files{1,2,3}.txt
    cd "${FAKE_TEMP_LOCAL_REPOSITORY}";
    git add .;
    git commit --quiet -m "Init Remote Repository";
    git push origin master;
}

# Clone our fake remote repository and set it up for testing
_setup_local_repository() {
    # Clone remote repository. In this repository we will do our testing
    rm -rf "${FAKE_LOCAL_REPOSITORY}"
    git clone "${FAKE_REMOTE}" "${FAKE_LOCAL_REPOSITORY}"

    cd "${FAKE_LOCAL_REPOSITORY}";
}

# Run the main code related to this GitHub Action
git_auto_commit() {
    bash "${BATS_TEST_DIRNAME}"/../entrypoint.sh
}

@test "It detects changes, commits them and pushes them to the remote repository" {
    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}"
    assert_line "::set-output name=changes_detected::true"
    assert_line -e "::set-output name=commit_hash::[0-9a-f]{40}$"
    assert_line "INPUT_BRANCH value: master"
    assert_line "INPUT_FILE_PATTERN: ."
    assert_line "INPUT_COMMIT_OPTIONS: "
    assert_line "::debug::Apply commit options "
    assert_line "INPUT_TAGGING_MESSAGE: "
    assert_line "No tagging message supplied. No tag will be added."
    assert_line "INPUT_PUSH_OPTIONS: "
    assert_line "::debug::Apply push options "
    assert_line "::debug::Push commit to remote branch master"
}

@test "It detects when files have been deleted, commits changes and pushes them to the remote repository" {
    rm -rf "${FAKE_LOCAL_REPOSITORY}"/remote-files1.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}"
    assert_line "::set-output name=changes_detected::true"
    assert_line -e "::set-output name=commit_hash::[0-9a-f]{40}$"
    assert_line "INPUT_BRANCH value: master"
    assert_line "INPUT_FILE_PATTERN: ."
    assert_line "INPUT_COMMIT_OPTIONS: "
    assert_line "::debug::Apply commit options "
    assert_line "INPUT_TAGGING_MESSAGE: "
    assert_line "No tagging message supplied. No tag will be added."
    assert_line "INPUT_PUSH_OPTIONS: "
    assert_line "::debug::Apply push options "
    assert_line "::debug::Push commit to remote branch master"
}

@test "It applies INPUT_STATUS_OPTIONS when running dirty check" {
    INPUT_STATUS_OPTIONS="--untracked-files=no"

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2}.php

    run git_auto_commit

    assert_success

    assert_line "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}"
    assert_line "::set-output name=changes_detected::false"
    refute_line -e "::set-output name=commit_hash::[0-9a-f]{40}$"
    assert_line "Working tree clean. Nothing to commit."
}

@test "It prints a 'Nothing to commit' message in a clean repository" {
    run git_auto_commit

    assert_success

    assert_line "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}"
    assert_line "::set-output name=changes_detected::false"
    refute_line -e "::set-output name=commit_hash::[0-9a-f]{40}$"
    assert_line "Working tree clean. Nothing to commit."
}

@test "If SKIP_DIRTY_CHECK is set to true on a clean repo it fails to push" {
    INPUT_SKIP_DIRTY_CHECK=true

    run git_auto_commit

    assert_failure

    assert_line "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}"
    assert_line "::set-output name=changes_detected::true"
    refute_line -e "::set-output name=commit_hash::[0-9a-f]{40}$"
    assert_line "INPUT_BRANCH value: master"
    assert_line "INPUT_FILE_PATTERN: ."
    assert_line "INPUT_COMMIT_OPTIONS: "
    assert_line "::debug::Apply commit options "
}

@test "It applies INPUT_ADD_OPTIONS when adding files" {
    INPUT_FILE_PATTERN=""
    INPUT_STATUS_OPTIONS="--untracked-files=no"
    INPUT_ADD_OPTIONS="-u"

    date > "${FAKE_LOCAL_REPOSITORY}"/remote-files1.txt
    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2}.php

    run git_auto_commit

    assert_success

    assert_line "INPUT_STATUS_OPTIONS: --untracked-files=no"
    assert_line "INPUT_ADD_OPTIONS: -u"
    assert_line "INPUT_FILE_PATTERN: "
    assert_line "::debug::Push commit to remote branch master"

    # Assert that PHP files have not been added.
    run git status
    assert_output --partial 'new-file-1.php'
}

@test "It applies INPUT_FILE_PATTERN when creating commit" {
    INPUT_FILE_PATTERN="src/*.js *.txt *.html"

    mkdir src;
    touch src/new-file-{1,2}.js;

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2}.php
    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2}.html

    run git_auto_commit

    assert_success

    assert_line "INPUT_FILE_PATTERN: src/*.js *.txt *.html"
    assert_line "::debug::Push commit to remote branch master"

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
    assert_line "::debug::Push commit to remote branch master"

    # Assert last commit was signed off
    run git log -n 1
    assert_output --partial "Signed-off-by:"
}

@test "It applies commit user and author settings" {
    INPUT_COMMIT_USER_NAME="A Single Test"
    INPUT_COMMIT_USER_EMAIL="single-test@github.com"
    INPUT_COMMIT_AUTHOR="A Single Test <single@users.noreply.github.com>"

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_COMMIT_USER_NAME: A Single Test";
    assert_line "INPUT_COMMIT_USER_EMAIL: single-test@github.com";
    assert_line "INPUT_COMMIT_AUTHOR: A Single Test <single@users.noreply.github.com>";
    assert_line "::debug::Push commit to remote branch master"

    # Asser last commit was made by the defined user/author
    run git log -1 --pretty=format:'%ae'
    assert_output --partial "single@users.noreply.github.com"

    run git log -1 --pretty=format:'%an'
    assert_output --partial "A Single Test"

    run git log -1 --pretty=format:'%cn'
    assert_output --partial "A Single Test"

    run git log -1 --pretty=format:'%ce'
    assert_output --partial "single-test@github.com"
}

@test "It creates a tag with the commit" {
    INPUT_TAGGING_MESSAGE="v1.0.0"

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_TAGGING_MESSAGE: v1.0.0"
    assert_line "::debug::Create tag v1.0.0"
    assert_line "::debug::Push commit to remote branch master"

    # Assert a tag v1.0.0 has been created
    run git tag
    assert_output v1.0.0

    run git ls-remote --tags --refs
    assert_output --partial refs/tags/v1.0.0

    # Assert that the commit has been pushed with --force and
    # sha values are equal on local and remote
    current_sha="$(git rev-parse --verify --short master)"
    remote_sha="$(git rev-parse --verify --short origin/master)"

    assert_equal $current_sha $remote_sha
}

@test "It applies INPUT_PUSH_OPTIONS when pushing commit to remote" {

    touch "${FAKE_TEMP_LOCAL_REPOSITORY}"/newer-remote-files{1,2,3}.txt
    cd "${FAKE_TEMP_LOCAL_REPOSITORY}";
    git add .;
    git commit --quiet -m "Add more remote files";
    git push origin master;


    INPUT_PUSH_OPTIONS="--force"

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_PUSH_OPTIONS: --force"
    assert_line "::debug::Apply push options --force"
    assert_line "::debug::Push commit to remote branch master"

    # Assert that the commit has been pushed with --force and
    # sha values are equal on local and remote
    current_sha="$(git rev-parse --verify --short master)"
    remote_sha="$(git rev-parse --verify --short origin/master)"

    assert_equal $current_sha $remote_sha
}

@test "It can checkout a different branch" {
    # Create foo-branch and then immediately switch back to master
    git checkout -b foo
    git checkout master

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

    # Assert that branch "master" was updated on remote
    current_sha="$(git rev-parse --verify --short master)"
    remote_sha="$(git rev-parse --verify --short origin/master)"

    assert_equal $current_sha $remote_sha
}

@test "It uses existing branch when INPUT_BRANCH is empty and INPUT_TAGGING_MESSAGE is set" {
    INPUT_BRANCH=""
    INPUT_TAGGING_MESSAGE="v2.0.0"

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_TAGGING_MESSAGE: v2.0.0"
    assert_line "::debug::Create tag v2.0.0"
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

    assert_line "::debug::git-fetch has not been executed"
}

@test "If SKIP_CHECKOUT is true git-checkout will not be called" {

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    INPUT_SKIP_CHECKOUT=true

    run git_auto_commit

    assert_success

    assert_line "::debug::git-checkout has not been executed"
}

@test "It pushes generated commit and tag to remote and actually updates the commit shas" {
    INPUT_BRANCH=""
    INPUT_TAGGING_MESSAGE="v2.0.0"

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_TAGGING_MESSAGE: v2.0.0"
    assert_line "::debug::Create tag v2.0.0"
    assert_line "::debug::git push origin --tags"

    # Assert a tag v2.0.0 has been created
    run git tag
    assert_output v2.0.0

    # Assert tag v2.0.0 has been pushed to remote
    run git ls-remote --tags --refs
    assert_output --partial refs/tags/v2.0.0

    # Assert that branch "master" was updated on remote
    current_sha="$(git rev-parse --verify --short master)"
    remote_sha="$(git rev-parse --verify --short origin/master)"

    assert_equal $current_sha $remote_sha
}

@test "It pushes generated commit and tag to remote branch and updates commit sha" {
    # Create "a-new-branch"-branch and then immediately switch back to master
    git checkout -b a-new-branch
    git checkout master

    INPUT_BRANCH="a-new-branch"
    INPUT_TAGGING_MESSAGE="v2.0.0"

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_TAGGING_MESSAGE: v2.0.0"
    assert_line "::debug::Create tag v2.0.0"
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
    echo "Create Additional files";
    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-a.py
    mkdir "${FAKE_LOCAL_REPOSITORY}"/nested
    touch "${FAKE_LOCAL_REPOSITORY}"/nested/new-file-b.py

    # Commit changes
    echo "Commit changes before running git_auto_commit";
    cd "${FAKE_LOCAL_REPOSITORY}";
    git add . > /dev/null;
    git commit --quiet -m "Init Remote Repository";
    git push origin master > /dev/null;

    # Make nested file dirty
    echo "foo-bar" > "${FAKE_LOCAL_REPOSITORY}"/nested/new-file-b.py;

    # ---

    INPUT_FILE_PATTERN="*.py"
    INPUT_DISABLE_GLOBBING=true

    run git_auto_commit

    assert_success

    assert_line "INPUT_FILE_PATTERN: *.py"
    assert_line "::debug::Push commit to remote branch master"

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
    assert_line "::set-output name=changes_detected::false"

    run git status
    assert_output --partial 'nothing to commit, working tree clean'
}

@test "It does not throw an error if branch is checked out with same name as a file or folder in the repo" {

    # Add File called dev and commit/push
    echo "Create dev file";
    cd "${FAKE_LOCAL_REPOSITORY}";
    echo this is a file named dev > dev
    git add dev
    git commit -m 'add file named dev'
    git update-ref refs/remotes/origin/master master
    git update-ref refs/remotes/origin/dev master

    # ---

    INPUT_BRANCH=dev

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{4,5,6}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}"
    assert_line "::set-output name=changes_detected::true"
    assert_line "::debug::Push commit to remote branch dev"
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
    assert_line "::set-output name=changes_detected::true"
    assert_line "INPUT_BRANCH value: not-existend-branch"
    assert_line "fatal: invalid reference: not-existend-branch"

    run git branch
    refute_line --partial "not-existend-branch"

    run git branch -r
    refute_line --partial "origin/not-existend-branch"
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
    assert_line "::set-output name=changes_detected::true"
    assert_line -e "::set-output name=commit_hash::[0-9a-f]{40}$"
    assert_line "INPUT_BRANCH value: not-existend-branch"
    assert_line "INPUT_FILE_PATTERN: ."
    assert_line "INPUT_COMMIT_OPTIONS: "
    assert_line "::debug::Apply commit options "
    assert_line "INPUT_TAGGING_MESSAGE: "
    assert_line "No tagging message supplied. No tag will be added."
    assert_line "INPUT_PUSH_OPTIONS: "
    assert_line "::debug::Apply push options "
    assert_line "::debug::Push commit to remote branch not-existend-branch"

    run git branch
    assert_line --partial "not-existend-branch"

    run git branch -r
    assert_line --partial "origin/not-existend-branch"
}

@test "it does not create new local branch if local branch already exists" {

    git checkout -b not-existend-remote-branch
    git checkout master

    INPUT_BRANCH="not-existend-remote-branch"
    INPUT_CREATE_BRANCH=true

    run git branch
    assert_line --partial "not-existend-remote-branch"

    run git branch -r
    refute_line --partial "origin/not-existend-remote-branch"

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}"
    assert_line "::set-output name=changes_detected::true"
    assert_line -e "::set-output name=commit_hash::[0-9a-f]{40}$"
    assert_line "INPUT_BRANCH value: not-existend-remote-branch"
    assert_line "INPUT_FILE_PATTERN: ."
    assert_line "INPUT_COMMIT_OPTIONS: "
    assert_line "::debug::Apply commit options "
    assert_line "INPUT_TAGGING_MESSAGE: "
    assert_line "No tagging message supplied. No tag will be added."
    assert_line "INPUT_PUSH_OPTIONS: "
    assert_line "::debug::Apply push options "
    assert_line "::debug::Push commit to remote branch not-existend-remote-branch"

    run git branch
    assert_line --partial "not-existend-remote-branch"

    run git branch -r
    assert_line --partial "origin/not-existend-remote-branch"
}

@test "it creates new local branch and pushes branch to remote even if the remote branch already exists" {

    # Create `existing-remote-branch` on remote with changes the local repository does not yet have
    cd $FAKE_TEMP_LOCAL_REPOSITORY;
    git checkout -b "existing-remote-branch"
    touch new-branch-file.txt
    git add new-branch-file.txt
    git commit -m "Add additional file";
    git push origin existing-remote-branch;

    run git branch;
    assert_line --partial "existing-remote-branch"

    # ---------
    # Switch to our regular local repository and run `git-auto-commit`
    cd $FAKE_LOCAL_REPOSITORY;

    INPUT_BRANCH="existing-remote-branch"
    INPUT_CREATE_BRANCH=true

    run git branch
    refute_line --partial "existing-remote-branch"

    run git fetch --all;
    run git pull origin existing-remote-branch;
    run git branch -r;
    assert_line --partial "origin/existing-remote-branch"

    touch "${FAKE_LOCAL_REPOSITORY}"/new-file-{1,2,3}.txt

    run git_auto_commit

    assert_success

    assert_line "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}"
    assert_line "::set-output name=changes_detected::true"
    assert_line -e "::set-output name=commit_hash::[0-9a-f]{40}$"
    assert_line "INPUT_BRANCH value: existing-remote-branch"
    assert_line "INPUT_FILE_PATTERN: ."
    assert_line "INPUT_COMMIT_OPTIONS: "
    assert_line "::debug::Apply commit options "
    assert_line "INPUT_TAGGING_MESSAGE: "
    assert_line "No tagging message supplied. No tag will be added."
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

    assert_equal $current_sha $remote_sha;
}

@test "script fails if new local branch is checked out and push fails as remote has newer commits than local" {
    # Create `existing-remote-branch` on remote with changes the local repository does not yet have
    cd $FAKE_TEMP_LOCAL_REPOSITORY;
    git checkout -b "existing-remote-branch"
    touch new-branch-file.txt
    git add new-branch-file.txt
    git commit -m "Add additional file";
    git push origin existing-remote-branch;

    run git branch;
    assert_line --partial "existing-remote-branch"

    # ---------
    # Switch to our regular local repository and run `git-auto-commit`
    cd $FAKE_LOCAL_REPOSITORY;

    INPUT_BRANCH="existing-remote-branch"
    INPUT_CREATE_BRANCH=true

    run git branch
    refute_line --partial "existing-remote-branch"

    run git fetch --all;
    run git branch -r;
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

    refute [assert_equal $current_sha $remote_sha];
}

@test "It pushes commit to remote if branch already exists and local repo is behind its remote counterpart" {
    # Create `new-branch` on remote with changes the local repository does not yet have
    cd $FAKE_TEMP_LOCAL_REPOSITORY;

    git checkout -b "new-branch"
    touch new-branch-file.txt
    git add new-branch-file.txt

    git commit --quiet -m "Add additional file";
    git push origin new-branch;

    run git branch -r
    assert_line --partial "origin/new-branch"

    # ---------
    # Switch to our regular local repository and run `git-auto-commit`
    cd $FAKE_LOCAL_REPOSITORY;

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

    assert_equal $current_sha $remote_sha;
}
