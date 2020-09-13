#!/usr/bin/env bats

setup() {
    . shellmock

    # Build default world
    export test_repository="${BATS_TEST_DIRNAME}/test_repo"

    rm -rf "${test_repository}"
    mkdir "${test_repository}"
    touch "${test_repository}"/{a,b,c}.txt
    cd "${test_repository}"
    git init -q
    git add . >/dev/null 2>&1
    git commit -m "Init Repo" >/dev/null 2>&1


    # Set defaults INPUT variables
    export INPUT_REPOSITORY="${BATS_TEST_DIRNAME}/test_repo"
    export INPUT_COMMIT_MESSAGE="Commit Message"
    export INPUT_BRANCH="master"
    export INPUT_COMMIT_OPTIONS=""
    export INPUT_FILE_PATTERN="."
    export INPUT_COMMIT_USER_NAME="Test Suite"
    export INPUT_COMMIT_USER_NAME="test@github.com"
    export INPUT_COMMIT_AUTHOR="Test Suite <test@users.noreply.github.com>"
    export INPUT_TAGGING_MESSAGE=""
    export INPUT_PUSH_OPTIONS=""
    export INPUT_SKIP_DIRTY_CHECK=false

    # TODO:
    # - Create new Git Repo in ${BATS_TMPDIR}
    # - Create some Files with some data
    # - Create Init Commit
}

teardown() {
    if [ -z "$TEST_FUNCTION" ]; then
        shellmock_clean
    fi

    rm -rf "${test_repository}"
    rm -rf "${BATS_TEST_DIRNAME}/tmpstubs"
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

@test "skip-dirty-on-clean-repo-failure" {

    touch "${test_repository}/new-file.txt"

    # INPUT_SKIP_DIRTY_CHECK=true

    # shellmock_expect git --match '-c user.name="$INPUT_COMMIT_USER_NAME" -c user.email="$INPUT_COMMIT_USER_EMAIL" commit -m "$INPUT_COMMIT_MESSAGE" --author="$INPUT_COMMIT_AUTHOR" ${INPUT_COMMIT_OPTIONS:+"${INPUT_COMMIT_OPTIONS_ARRAY[@]}"}'

    run main

    echo $output;

    # shellmock_verify
    # [ "${capture[0]}" = '-c user.name="${INPUT_COMMIT_USER_NAME}"' ]
    # [ "${capture[1]}" = "some-stub2 arg1 arg2" ]


    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "INPUT_REPOSITORY value: ${INPUT_REPOSITORY}" ]
    [ "${lines[1]}" = "::set-output name=changes_detected::true" ]
    [ "${lines[2]}" = "INPUT_BRANCH value: master" ]
    [ "${lines[3]}" = "Already on 'master'" ]
    [ "${lines[4]}" = "INPUT_FILE_PATTERN: ." ]
    # [ "${lines[2]}" = "INPUT_BRANCH value: master" ]
    # [ "${lines[2]}" = "INPUT_BRANCH value: master" ]
    # [ "$output" = "Working tree clean. Nothing to commit." ]
}
