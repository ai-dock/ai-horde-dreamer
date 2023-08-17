#!/bin/bash

branch=main

if [[ ! -z "${HORDE_WORKER_BRANCH}" ]]; then
    branch="${HORDE_WORKER_BRANCH}"
fi

# -b flag has priority
while getopts b: flag
do
    case "${flag}" in
        b) branch="$OPTARG";;
    esac
done


printf "Updating Horde Worker (${branch})...\n"

cd /opt/AI-Horde-Worker
git checkout ${branch}
git pull

# Use default gradio css
rm webui.css

# Overide shell scripts in case of interactive use. Defaults will break things - See docs
rm update-runtime.sh
rm horde-bridge.sh
rm runtime.sh
ln -s /opt/horde/bin/worker-update-runtime.sh update-runtime.sh
ln -s /opt/horde/bin/worker-horde-bridge.sh horde-bridge.sh
ln -s /opt/horde/bin/worker-runtime.sh runtime.sh

# We pre-installed pytorch and want a universal version across all micromamba environments (if more than one)
cp requirements.txt reqs-mod-dreamer.txt
sed -i '/^torch.*[\W|=|>|<]*$/d' reqs-mod-dreamer.txt

micromamba run -n horde pip --no-cache-dir install -r reqs-mod-dreamer.txt
