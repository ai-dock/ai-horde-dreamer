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
        hordelib \
        nvidia-ml-py3 \
        ruamel.yaml
    
    micromamba run -n horde ${PIP_INSTALL} \
        -r /opt/AI-Horde-Worker/requirements.txt
}

main "$@"; exit