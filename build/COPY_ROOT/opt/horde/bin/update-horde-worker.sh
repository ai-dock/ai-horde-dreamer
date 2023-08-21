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
if [[ -f webui.css ]]; then
    git update-index --assume-unchanged webui.css
    rm webui.css
fi
# Ensure the horde shell scripts work without alteration
if [[ -f update-runtime.sh ]]; then
    git update-index --assume-unchanged update-runtime.sh
    rm update-runtime.sh
fi

rm -rf /opt/AI-Horde-Worker/conda > /dev/null 2>&1
rm -rf /opt/AI-Horde-Worker/bin > /dev/null 2>&1
cp -rf /opt/horde/override/bin .
cp -rf /opt/horde/override/conda .

# We pre-installed pytorch and want a universal version across all micromamba environments (if more than one)

cp requirements.txt reqs-ai-horde-dreamer.txt
sed -i '/^--extra-index-url.*[\W|=|>|<]*$/d' reqs-ai-horde-dreamer.txt
sed -i '/^torch.*[\W|=|>|<]*$/d' reqs-ai-horde-dreamer.txt
sed -i '/^xformers.*[\W|=|>|<]*$/d' reqs-ai-horde-dreamer.txt
micromamba run -n horde pip --no-cache-dir install -r reqs-ai-horde-dreamer.txt

if [[ -n $HORDE_DEV && $HORDE_DEV != "false" ]]; then
    cp requirements.dev.txt reqs-ai-horde-dreamer-dev.txt
    sed -i '/^--extra-index-url.*[\W|=|>|<]*$/d' reqs-ai-horde-dreamer-dev.txt
    sed -i '/^torch.*[\W|=|>|<]*$/d' reqs-ai-horde-dreamer-dev.txt
    sed -i '/^xformers.*[\W|=|>|<]*$/d' reqs-ai-horde-dreamer-dev.txt
    micromamba run -n horde pip --no-cache-dir install -r reqs-ai-horde-dreamer-dev.txt
fi

rm reqs-ai-horde-dreamer*.txt