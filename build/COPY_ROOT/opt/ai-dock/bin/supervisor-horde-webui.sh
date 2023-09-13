#!/bin/bash

trap cleanup EXIT

PORT=7860
METRICS_PORT=1860
SERVICE_NAME="AI Horde Web UI"

function cleanup() {
    kill $(jobs -p) > /dev/null 2>&1
    rm /run/http_ports/$PORT > /dev/null 2>&1
}

if [[ -z "$WEB_USER" ]] || [[ -z "$WEB_PASSWORD" ]]; then
    printf "Skipping launch because WEB_USER or WEB_PASSWORD not defined\n" 1>&2
    sleep 1
    exit 0
fi

printf "{\"port\": \"$PORT\", \"metrics_port\": \"$METRICS_PORT\", \"service_name\": \"$SERVICE_NAME\"}" > /run/http_ports/$PORT

cd /opt/AI-Horde-Worker

printf "Starting Web UI...\n"

micromamba run -n horde python -u webui.py --lan --user $WEB_USER --password $WEB_PASSWORD