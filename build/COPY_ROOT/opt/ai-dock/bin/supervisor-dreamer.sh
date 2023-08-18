#!/bin/bash

trap 'kill $(jobs -p)' EXIT

cd /opt/AI-Horde-Worker

# Ensure worker_name for bridge_stable_diffusion.py -n
if [[ -z $BRIDGE_WORKER_NAME || "$BRIDGE_WORKER_NAME" = $DEFAULT_WORKER_NAME ]]; then
    export BRIDGE_WORKER_NAME="$DEFAULT_WORKER_NAME $(uuidgen -r)"
fi

if [[ -n $BRIDGE_DREAMER_NAME ]]; then
    export BRIDGE_WORKER_NAME="${BRIDGE_DREAMER_NAME}"
fi

# Terminal UI will not work in the default environment
if [[ -z $BRIDGE_DISABLE_TERMINAL_UI ]]; then
    export BRIDGE_DISABLE_TERMINAL_UI=true
fi

if [[ -z $PROC_NUM ]]; then
    PROC_NUM=0
fi

if [[ $PROC_NUM -eq 0 ]]; then
    worker_name="$BRIDGE_WORKER_NAME"
else
    # Start numbering from #2
    worker_name="${BRIDGE_WORKER_NAME}#$((PROC_NUM+1))"
fi

printf "Starting dreamer $PROC_NUM ($worker_name)...\n"

CUDA_VISIBLE_DEVICES=$PROC_NUM micromamba run -n horde python -u bridge_stable_diffusion.py -n "$worker_name"