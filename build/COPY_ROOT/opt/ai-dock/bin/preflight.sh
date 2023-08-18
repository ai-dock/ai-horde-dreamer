#!/bin/bash

function main() {
    move_to_workspace
    update_horde
    set_safe_envs
    write_config
}

function move_to_workspace() {
    if [[ $WORKSPACE_MOUNTED = "true" ]]; then
        if [[ ! -d "${WORKSPACE}AI-Horde-Worker" ]]; then
            mv /opt/AI-Horde-Worker ${WORKSPACE}
        fi
            rm -rf /opt/AI-Horde-Worker
            ln -s "${WORKSPACE}/AI-Horde-Worker" /opt/AI-Horde-Worker
    fi
}

function update_horde() {
    /opt/horde/bin/update-hordelib.sh
    /opt/horde/bin/update-horde-worker.sh
}

function set_safe_envs() {
    # Ensure worker_name for bridge_stable_diffusion.py -n
    if [[ -z $BRIDGE_WORKER_NAME || "$BRIDGE_WORKER_NAME" = $DEFAULT_WORKER_NAME ]]; then
        export BRIDGE_WORKER_NAME="$DEFAULT_WORKER_NAME $(uuidgen -r)"
    fi
    
    if [[ -n $BRIDGE_DREAMER_NAME ]]; then
        export BRIDGE_WORKER_NAME="${BRIDGE_DREAMER_NAME}"
    fi
    
    # Terminal UI will not work when running as a service
    export BRIDGE_DISABLE_TERMINAL_UI=true
}

function write_config() {
    micromamba run -n horde python /opt/horde/scripts/write-config.py
}

main "$@"; exit