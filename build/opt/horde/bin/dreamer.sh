#!/bin/bash

trap 'kill $(jobs -p)' EXIT

cd /opt/AI-Horde-Worker

if [[ -z $PROC_NUM ]]; then
    PROC_NUM=0
fi

if [[ $PROC_NUM -eq 0 ]]; then
    worker_name="$BRIDGE_WORKER_NAME"
else
    # Start numbering from #2
    worker_name="${BRIDGE_WORKER_NAME}#$((PROC_NUM+1))"
fi

wait -n
CUDA_VISIBLE_DEVICES=$PROC_NUM micromamba run -n horde python -u bridge_stable_diffusion.py -n "$worker_name"