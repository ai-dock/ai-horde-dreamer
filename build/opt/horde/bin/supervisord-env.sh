#!/bin/bash

# Script to help overcome difficulties setting envs at vast.ai
# Allows passing environment vars through entrypoint args

# docker run ... supervisord-env.sh SOME_VAR="some value"...
# Also allows killing the container from inside.


trap 'kill $(jobs -p)' EXIT

for i in "$@"; do
    IFS=\= read -r key val <<< "$i"
    if [[ ! -z $key && ! -z $val ]]; then
        export "${key}"="${val}"
        printf "export %s=\"%s\"\n" "$key" "$val" >> /root/.bashrc
    fi
done

# Need to re-write the config if started with this script

micromamba run -n dreamer python /opt/horde/scripts/write-config.py

# Killing supervisord will stop the container
wait -n
supervisord -c /etc/supervisor/supervisord.conf