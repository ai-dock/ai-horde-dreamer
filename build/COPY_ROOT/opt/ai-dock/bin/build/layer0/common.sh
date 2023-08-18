#!/bin/bash

# Must exit and fail to build if any command fails
set -e

worker_git="https://github.com/Haidra-Org/AI-Horde-Worker"

main() {
    create_env
    install_jupyter_kernels
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

install_jupyter_kernels() {
    if [[ $IMAGE_BASE =~ "jupyter-pytorch" ]]; then
        $MAMBA_INSTALL -n horde -c conda-forge -c defaults -y \
            ipykernel \
            ipywidgets
        
        kernel_path=/usr/local/share/jupyter/kernels
        
        # Add the often-present "Python3 (ipykernel) as a horde alias"
        rm -rf ${kernel_path}/python3
        dir="${kernel_path}/python3"
        file="${dir}/kernel.json"
        cp -rf ${kernel_path}/../_template ${dir}
        sed -i 's/DISPLAY_NAME/'"Python3 (ipykernel)"'/g' ${file}
        sed -i 's/PYTHON_MAMBA_NAME/'"horde"'/g' ${file}
        
        dir="${kernel_path}/horde"
        file="${dir}/kernel.json"
        cp -rf ${kernel_path}/../_template ${dir}
        sed -i 's/DISPLAY_NAME/'"Horde"'/g' ${file}
        sed -i 's/PYTHON_MAMBA_NAME/'"horde"'/g' ${file}
    fi
}

clone_horde_worker() {
    cd /opt
    git clone ${worker_git}
}

main "$@"; exit