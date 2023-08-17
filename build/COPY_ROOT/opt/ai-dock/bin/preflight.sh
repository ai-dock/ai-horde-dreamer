#!/bin/bash

function main() {
    move_to_workspace
    update_horde
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

function write_config() {
    micromamba run -n horde python /opt/horde/scripts/write-config.py
}

main "$@"; exit