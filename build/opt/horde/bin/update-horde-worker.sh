#!/bin/bash

branch=main

if [[ ! -z "${HORDE_WORKER_BRANCH}" ]]
then
branch="${HORDE_WORKER_BRANCH}"
fi

# -b flag has priority
while getopts b: flag
do
    case "${flag}" in
        b) branch="$OPTARG";;
    esac
done


echo "Updating Horde Worker (${branch})..."

cd /opt/AI-Horde-Worker
git checkout ${branch}
git pull

# Use default gradio css
rm webui.css

cp requirements.txt reqs-mod.txt
sed -i '/^torch.*[\W|=|>|<]*$/d' reqs-mod.txt

micromamba run -n horde $PIP_INSTALL -r reqs-mod.txt
