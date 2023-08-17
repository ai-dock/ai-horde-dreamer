#!/bin/bash

# Must exit and fail to build if any command fails
set -e

worker_git="https://github.com/Haidra-Org/AI-Horde-Worker"

main() {
    create_env
    clone_horde_worker
}

create_env() {
    apt-get update
    $APT_INSTALL libgl1 \
                 uuid-runtime
    # A new pytorch env costs ~ 300Mb
    exported_env=/tmp/${MAMBA_DEFAULT_ENV}.yaml
    micromamba env export -n ${MAMBA_DEFAULT_ENV} > "${exported_env}"
    $MAMBA_CREATE -n horde --file "${exported_env}"
}

clone_horde_worker() {
    cd /opt
    git clone ${worker_git}
}

main "$@"; exit