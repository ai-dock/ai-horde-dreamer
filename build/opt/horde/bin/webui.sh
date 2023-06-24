#!/bin/bash

trap 'kill $(jobs -p)' EXIT

if [[ -z "$WEB_USER" ]] || [[ -z "$WEB_PASSWORD" ]]; then
    echo "Skipping launch because WEB_USER or WEB_PASSWORD not defined" 1>&2
    exit 0
fi

cd /opt/AI-Horde-Worker

wait -n
micromamba run -n horde python -u webui.py --lan --share --user $WEB_USER --password $WEB_PASSWORD