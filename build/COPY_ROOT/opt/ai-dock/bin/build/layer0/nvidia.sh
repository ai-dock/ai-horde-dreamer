#!/bin/bash

# Must exit and fail to build if any command fails
set -e

main() {
    install_horde
}

install_horde() {
    micromamba run -n horde ${PIP_INSTALL} \
        torch=="${PYTORCH_VERSION}" \
        xformers \
        nvidia-ml-py3 \
        ruamel.yaml

    /opt/horde/bin/update-horde-worker.sh
}

main "$@"; exit