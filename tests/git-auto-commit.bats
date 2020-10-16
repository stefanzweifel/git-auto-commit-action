#!/usr/bin/env bats

setup() {
    . shellmock

    # Build World
    export test_repository="${BATS_TEST_DIRNAME}/test_repo"

    rm -rf "${test_repository}"
    mkdir "${test_repository}"
    touch "${test_repository}"/{a,b,c}.txt
    cd "${test_repository}"

    git init --quiet
    git add . > /dev/null 2>&1

    if [[ -z $(git config user.name) ]]; then
        git config --global user.email "test@github.com"
        git config --global user.name "Test Suite"
    fi

    git commit --quiet -m "Init Repo"
    git remote add origin https://github.com/stefanzweifel/git-auto-commit-action.git

    # Set default INPUT variables
    export INPUT_REPOSITORY="${BATS_TEST_DIRNAME}/test_repo"
    export INPUT_COMMIT_MESSAGE="Commit Message"
    export INPUT_BRANCH="master"
    export INPUT_COMMIT_OPTIONS=""
    export INPUT_FILE_PATTERN="."
    export INPUT_COMMIT_USER_NAME="GitHub Actions"
    export INPUT_COMMIT_USER_EMAIL="actions@github.com"
    export INPUT_COMMIT_AUTHOR="GitHub Actions <actions@users.noreply.github.com>"
    export INPUT_TAGGING_MESSAGE=""
    export INPUT_PUSH_OPTIONS=""
    export INPUT_CHECKOUT_OPTIONS=""
    export INPUT_SKIP_DIRTY_CHECK=false

    skipIfNot "$BATS_TEST_DESCRIPTION"

    if [ -z "$TEST_FUNCTION" ]; then
        shellmock_clean
    fi
}

teardown() {

    if [ -z "$TEST_FUNCTION" ]; then
        shellmock_clean
    fi

    rm -rf "${test_repository}"
}

main() {
    bash "${BATS_TEST_DIRNAME}"/../entrypoint.sh
}


@test "clean-repo-prints-nothing-to-commit-message" {

    run main

    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}" ]
    [ "${lines[1]}" = "::set-output name=changes_detected::false" ]
    [ "${lines[2]}" = "Working tree clean. Nothing to commit." ]
}

@test "commit-changed-files-and-push-to-remote-for-real" {

    TIMESTAMP="$(date +%s)"

    INPUT_BRANCH="ci-test-$TIMESTAMP"
    INPUT_CHECKOUT_OPTIONS="-b"
    INPUT_PUSH_OPTIONS="--force"

    touch "${test_repository}"/new-file-{1,2,3}.txt

    run main

    echo "$output"

    # Success Exit Code
    [ "$status" = 0 ]

    [ "${lines[0]}" = "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}" ]
    [ "${lines[1]}" = "::set-output name=changes_detected::true" ]
    [ "${lines[2]}" = "INPUT_BRANCH value: $INPUT_BRANCH" ]
    # [ "${lines[3]}" = "INPUT_FILE_PATTERN: ." ]
    # [ "${lines[4]}" = "INPUT_COMMIT_OPTIONS: " ]
    # [ "${lines[5]}" = "::debug::Apply commit options " ]
    # [ "${lines[6]}" = "INPUT_TAGGING_MESSAGE: " ]
    # [ "${lines[7]}" = "No tagging message supplied. No tag will be added." ]
    # [ "${lines[8]}" = "INPUT_PUSH_OPTIONS: --force" ]
    # [ "${lines[9]}" = "::debug::Apply push options --force" ]
    # [ "${lines[10]}" = "::debug::Push commit to remote branch ci-target" ]

}
