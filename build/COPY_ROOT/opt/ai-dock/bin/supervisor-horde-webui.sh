#!/bin/bash

trap 'kill $(jobs -p)' EXIT

if [[ -z "$WEB_USER" ]] || [[ -z "$WEB_PASSWORD" ]]; then
    printf "Skipping launch because WEB_USER or WEB_PASSWORD not defined\n" 1>&2
    sleep 1
    exit 0
fi

cd /opt/AI-Horde-Worker

printf "Starting Web UI...\n"
if [[ $CF_QUICK_TUNNELS = "true" ]]; then
    cloudflared tunnel --url localhost:7860 > /var/log/supervisor/quicktunnel-horde-webui.log 2>&1 &
fi

micromamba run -n horde python -u webui.py --lan --user $WEB_USER --password $WEB_PASSWORD