#!/bin/bash

trap 'kill $(jobs -p)' EXIT

# Tail and print logs for all of our services
# Needed for 'docker logs' and ssh users

# Ensure the log files we need are present, then tail
LOG_DIR="/var/log/supervisor/"

stdout="${LOG_DIR}supervisor.log"
touch $stdout
tail -F $stdout &

stdout="${LOG_DIR}sshd.log"
stderr="${LOG_DIR}sshd.error.log"
touch {"${stdout}","${stderr}"}
tail -F $stdout &
tail -F $stderr &

stdout="${LOG_DIR}webui.log"
stderr="${LOG_DIR}webui.error.log"
touch {"${stdout}","${stderr}"}
tail -F $stdout &
tail -F $stderr &

if [[ $GPU_COUNT -gt 0 ]]; then
    for ((i=0;i<GPU_COUNT;i++)); do
        stdout="${LOG_DIR}dreamer-$i.log"
        stderr="${LOG_DIR}dreamer-$i.error.log"
        touch {"${stdout}","${stderr}"}
        tail -F $stdout &
        tail -F $stderr &
    done
fi
sleep infinity