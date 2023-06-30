#!/bin/bash

WORKSPACE="/workspace"
DEFAULT_WORKER_NAME="Docker Dreamer"

# Replace ___ with a space. Vast.ai fix
while IFS='=' read -r -d '' key val; do
    export ${key}="${val//___/' '}"
done < <(env -0)

if [[ -z $GPU_COUNT ]]; then
    export GPU_COUNT=$(ls -l /proc/driver/nvidia/gpus/ | grep -c ^d)
fi

if [[ -f "/root/.ssh/authorized_keys_mount" ]]; then
    cat /root/.ssh/authorized_keys_mount > /root/.ssh/authorized_keys
fi

# named to avoid conflict with the cloud providers below
if [[ ! -z $SSH_PUBKEY ]]; then
    printf "$SSH_PUBKEY\n" >> /root/.ssh/authorized_keys
fi

# Alt names for $SSH_PUBKEY
# vast.ai
if [[ ! -z $SSH_PUBLIC_KEY ]]; then
    printf "$SSH_PUBLIC_KEY\n" >> /root/.ssh/authorized_keys
fi

# Don't run tmux automatically on vast.ai
touch /root/.no_auto_tmux

# Ensure worker_name for bridge_stable_diffusion.py -n
if [[ -z $BRIDGE_WORKER_NAME || "$BRIDGE_WORKER_NAME" = $DEFAULT_WORKER_NAME ]]; then
    export BRIDGE_WORKER_NAME="$DEFAULT_WORKER_NAME $(uuidgen -r)"
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

micromamba run -n dreamer python /opt/horde/scripts/write-config.py

# Ensure logged in users are in the dreamer mamba environment
printf "micromamba activate dreamer\n" >> /root/.bashrc

# Ensure all variables available for interactive sessions
while IFS='=' read -r -d '' key val; do
    printf "export %s=\"%s\"\n" "$key" "$val" >> /root/.bashrc
done < <(env -0)

exec "$@"