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

    # Set default INPUT variables
    export INPUT_REPOSITORY="${BATS_TEST_DIRNAME}/test_repo"
    export INPUT_COMMIT_MESSAGE="Commit Message"
    export INPUT_BRANCH="master"
    export INPUT_COMMIT_OPTIONS=""
    export INPUT_FILE_PATTERN="."
    export INPUT_COMMIT_USER_NAME="Test Suite"
    export INPUT_COMMIT_USER_EMAIL="test@github.com"
    export INPUT_COMMIT_AUTHOR="Test Suite <test@users.noreply.github.com>"
    export INPUT_TAGGING_MESSAGE=""
    export INPUT_PUSH_OPTIONS=""
    export INPUT_SKIP_DIRTY_CHECK=false
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

# TODO: Fix Issue where changes in git repo are not detected
# @test "commit-changed-files-and-push-to-remote" {

#     touch "${test_repository}"/new-file-{1,2,3}.txt

#     shellmock_expect git --type partial --match "status"
#     shellmock_expect git --type partial --match "checkout"
#     shellmock_expect git --type partial --match "add"
#     shellmock_expect git --type partial --match '-c'
#     shellmock_expect git --type partial --match 'push origin'

#     run main

#     echo "$output"

#     # Success Exit Code
#     [ "$status" = 0 ]

#     [ "${lines[0]}" = "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}" ]
#     [ "${lines[1]}" = "::set-output name=changes_detected::true" ]
#     [ "${lines[2]}" = "INPUT_BRANCH value: master" ]
#     [ "${lines[3]}" = "INPUT_FILE_PATTERN: ." ]
#     [ "${lines[4]}" = "INPUT_COMMIT_OPTIONS: " ]
#     [ "${lines[5]}" = "::debug::Apply commit options " ]


#     shellmock_verify
#     [ "${capture[0]}" = "git-stub status -s -- ." ]
#     [ "${capture[1]}" = "git-stub checkout master" ]
#     [ "${capture[2]}" = "git-stub add ." ]
#     [ "${capture[3]}" = "git-stub -c user.name=Test Suite -c user.email=test@github.com commit -m Commit Message --author=Test Suite <test@users.noreply.github.com>" ]
#     [ "${capture[4]}" = "git-stub push --set-upstream origin HEAD:master --tags" ]
# }


@test "skip-dirty-on-clean-repo-failure" {

    INPUT_SKIP_DIRTY_CHECK=true

    shellmock_expect git --type exact --match "status -s ."
    shellmock_expect git --type exact --match "checkout master"
    shellmock_expect git --type exact --match "add ."
    shellmock_expect git --type partial --match '-c'
    shellmock_expect git --type partial --match 'push origin'

    run main

    echo "$output"

    shellmock_verify
    [ "${capture[0]}" = "git-stub status -s -- ." ]
    [ "${capture[1]}" = "git-stub checkout master" ]
    [ "${capture[2]}" = "git-stub add ." ]
    [ "${capture[3]}" = "git-stub -c user.name=Test Suite -c user.email=test@github.com commit -m Commit Message --author=Test Suite <test@users.noreply.github.com>" ]
    [ "${capture[4]}" = "git-stub push --set-upstream origin HEAD:master --tags" ]

    # Failed Exit Code
    [ "$status" -ne 0 ]

    [ "${lines[0]}" = "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}" ]
    [ "${lines[1]}" = "::set-output name=changes_detected::true" ]
    [ "${lines[2]}" = "INPUT_BRANCH value: master" ]
    [ "${lines[3]}" = "INPUT_FILE_PATTERN: ." ]
    [ "${lines[4]}" = "INPUT_COMMIT_OPTIONS: " ]
    [ "${lines[5]}" = "::debug::Apply commit options " ]
}

