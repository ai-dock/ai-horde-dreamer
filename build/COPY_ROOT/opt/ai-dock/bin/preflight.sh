#!/bin/false

# This file will be sourced in init.sh

function preflight_main() {
    preflight_move_to_workspace
    preflight_copy_notebook
    preflight_update_horde
    preflight_set_safe_envs
    preflight_write_config
}

function preflight_move_to_workspace() {
    dir="AI-Horde-Worker"
    ws_dir=${WORKSPACE}${dir}
    opt_dir="/opt/${dir}"
    
    if [[ $WORKSPACE_MOUNTED = "true" ]]; then
        if [[ -d $ws_dir && -L $opt_dir ]]; then
            printf "%s already symlinked to %s\n" $opt_dir $ws_dir
        else
            if [[ -L $ws_dir ]]; then
                rm $ws_dir
            fi
            if [[ -d $ws_dir ]]; then
                if [[ -d $opt_dir && ! -L $opt_dir ]]; then
                    printf "Backing up %s to %s_bak\n" $opt_dir $opt_dir
                    rm -rf ${opt_dir}_bak
                    mv $opt_dir ${opt_dir}_bak
                fi
            else
                if [[ -d $opt_dir && ! -L $opt_dir ]]; then
                    rm -rf ${opt_dir}_bak
                    cp -rf $opt_dir ${opt_dir}_bak
                else
                    rm $opt_dir
                    cp -rf ${opt_dir}_bak $opt_dir
                fi
                printf "Moving %s to %s\n" $opt_dir $ws_dir
                mv $opt_dir $ws_dir
            fi
            printf "Creating symlink from %s to %s\n" $ws_dir $opt_dir
            ln -s $ws_dir $opt_dir
        fi
    else 
        # Should not happen
        if [[ ! -d $opt_dir ]]; then
            cp -rf ${opt_dir}_bak $opt_dir
        fi
        # Should be a symlink unless user has moved things - We can't handle that
        if [[ ! -e $ws_dir ]]; then
            printf "Creating symlink from %s to %s\n" $opt_dir $ws_dir
            ln -s $opt_dir $ws_dir
        fi
    fi
}

function preflight_copy_notebook() {
    if micromamba env list | grep 'jupyter' > /dev/null 2>&1;  then
        if [[ ! -f "${WORKSPACE}dreamer.ipynb" ]]; then
            cp /usr/local/share/ai-dock/dreamer.ipynb ${WORKSPACE}
        fi
    fi
}

function preflight_update_horde() {
    /opt/horde/bin/update-horde-worker.sh
}

function preflight_set_safe_envs() {
    DEFAULT_WORKER_NAME="Docker Dreamer"
    
    # Ensure worker_name for bridge_stable_diffusion.py -n
    if [[ -z $BRIDGE_WORKER_NAME || $BRIDGE_WORKER_NAME = "$DEFAULT_WORKER_NAME" ]]; then
        export BRIDGE_WORKER_NAME="$DEFAULT_WORKER_NAME $(uuidgen -r)"
    fi
    
    if [[ -n $BRIDGE_DREAMER_NAME && $BRIDGE_DREAMER_NAME != $DEFAULT_WORKER_NAME ]]; then
        export BRIDGE_WORKER_NAME="${BRIDGE_DREAMER_NAME}"
    fi
    
    if [[ -z $BRIDGE_DREAMER_NAME ]]; then
        export BRIDGE_DREAMER_NAME="$BRIDGE_WORKER_NAME"
    fi
    
    # Terminal UI will not work when running as a service
    if [[ $HORDE_SKIP_SERVICE != "true" ]]; then
        export BRIDGE_DISABLE_TERMINAL_UI=true
    fi
}

function preflight_write_config() {
    micromamba run -n horde python /opt/horde/scripts/write-config.py
}

preflight_main "$@"