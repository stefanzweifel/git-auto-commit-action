#!/bin/bash

set -eu

source /lib.sh

_switch_to_repository

if _git_is_dirty; then

    _setup_git

    _switch_to_branch

    _add_files

    _local_commit

    _push_to_github
else
    echo "Working tree clean. Nothing to commit."
fi
