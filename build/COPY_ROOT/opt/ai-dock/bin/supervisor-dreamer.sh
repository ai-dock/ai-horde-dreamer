#!/bin/bash

trap 'kill $(jobs -p)' EXIT

cd /opt/AI-Horde-Worker

if [[ -z $PROC_NUM ]]; then
    PROC_NUM=0
fi

if [[ -z $PROC_NAME ]]; then
    PROC_NAME="dreamer"
fi

if [[ -n $HORDE_SKIP_SERVICE && $HORDE_SKIP_SERVICE != "false" ]]; then
    printf "Skipping startup for %s %s\n" "${PROC_NAME}" ${PROC_NUM}
    exit 0
fi

if [[ $PROC_NUM -eq 0 ]]; then
    worker_name="$BRIDGE_WORKER_NAME"
else
    # Start numbering from #2
    worker_name="${BRIDGE_WORKER_NAME}#$((PROC_NUM+1))"
fi

printf "Starting dreamer $PROC_NUM ($worker_name)...\n"

CUDA_VISIBLE_DEVICES=$PROC_NUM micromamba run -n horde python -u bridge_stable_diffusion.py -n "$worker_name"