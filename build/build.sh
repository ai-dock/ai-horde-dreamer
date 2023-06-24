#!/bin/bash

# Build for specific torch because we need to force Hordelib
# and KoboldAI to use the same version to save space.

while getopts t: flag
do
    case "${flag}" in
        t) torch=${OPTARG};;
    esac
done

if [ -z "$torch" ]
then
    torch=2.0.1
fi

echo "Building for torch Version $torch";

VER_TAG=torch_${torch}

docker build --progress=plain --build-arg TORCH_VERSION=$torch -t dynamedia/ai-horde-dreamer:latest -t dynamedia/ai-horde-dreamer:$VER_TAG . 
docker push dynamedia/ai-horde-dreamer:$VER_TAG &&
docker push dynamedia/ai-horde-dreamer:latest
