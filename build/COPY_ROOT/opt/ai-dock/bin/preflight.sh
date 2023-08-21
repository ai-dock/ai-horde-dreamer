#!/bin/false

# This file will be sourced in init.sh

function preflight_main() {
    preflight_move_to_workspace
    preflight_copy_notebook
    preflight_update_horde
    preflight_set_safe_envs
    preflight_write_config
}

function preflight_move_to_workspace() {
    if [[ $WORKSPACE_MOUNTED = "true" ]]; then
        if [[ ! -d ${WORKSPACE}AI-Horde-Worker ]]; then
            mv /opt/AI-Horde-Worker ${WORKSPACE}
        fi
            rm -rf /opt/AI-Horde-Worker
            ln -s ${WORKSPACE}AI-Horde-Worker /opt/AI-Horde-Worker
    fi
}

function preflight_copy_notebook() {
    if micromamba env list | grep 'jupyter' > /dev/null 2>&1;  then
        if [[ ! -f "${WORKSPACE}dreamer.ipynb" ]]; then
            cp /usr/local/share/ai-dock/dreamer.ipynb ${WORKSPACE}
        fi
    fi
}

function preflight_update_horde() {
    /opt/horde/bin/update-horde-worker.sh
}

function preflight_set_safe_envs() {
    DEFAULT_WORKER_NAME="Docker Dreamer"
    
    # Ensure worker_name for bridge_stable_diffusion.py -n
    if [[ -z $BRIDGE_WORKER_NAME || $BRIDGE_WORKER_NAME = "$DEFAULT_WORKER_NAME" ]]; then
        export BRIDGE_WORKER_NAME="$DEFAULT_WORKER_NAME $(uuidgen -r)"
    fi
    
    if [[ -n $BRIDGE_DREAMER_NAME && $BRIDGE_DREAMER_NAME != $DEFAULT_WORKER_NAME ]]; then
        export BRIDGE_WORKER_NAME="${BRIDGE_DREAMER_NAME}"
    fi
    
    if [[ -z $BRIDGE_DREAMER_NAME ]]; then
        export BRIDGE_DREAMER_NAME="$BRIDGE_WORKER_NAME"
    fi
    
    # Terminal UI will not work when running as a service
    if [[ $HORDE_SKIP_SERVICE != "true" ]]; then
        export BRIDGE_DISABLE_TERMINAL_UI=true
    fi
}

function preflight_write_config() {
    micromamba run -n horde python /opt/horde/scripts/write-config.py
}

preflight_main "$@"