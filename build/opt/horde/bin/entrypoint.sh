#!/bin/bash

WORKSPACE="/workspace"

if [[ -z $GPU_COUNT ]]; then
    export GPU_COUNT=$(ls -l /proc/driver/nvidia/gpus/ | grep -c ^d)
fi

# Ensure worker_name for bridge_stable_diffusion.py -n
if [[ -z $BRIDGE_WORKER_NAME ]]; then
    export BRIDGE_WORKER_NAME="Docker $(uuidgen -r)"
fi

if [[ ! -z $BRIDGE_DREAMER_NAME ]]; then
    export BRIDGE_WORKER_NAME="${BRIDGE_DREAMER_NAME}"
fi

# Terminal UI will not work in the default environment
export BRIDGE_DISABLE_TERMINAL_UI=true

# If we have directory '/workspace' move the worker and create a symlink

if [[ -d "$WORKSPACE" ]]; then
    if [[ ! -d "${WORKSPACE}/AI-Horde-Worker" ]]; then
        mv /opt/AI-Horde-Worker $WORKSPACE
    else
        rm -rf /opt/AI-Horde-Worker
    fi
    ln -s "${WORKSPACE}/AI-Horde-Worker" /opt/AI-Horde-Worker
fi

# Update the worker
/opt/horde/bin/update-hordelib.sh
/opt/horde/bin/update-horde-worker.sh

micromamba run -n horde python /opt/horde/scripts/write-config.py

exec "$@"