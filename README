# AI Horde Dreamer
Run the [AI Horde](https://aihorde.net) Stable Diffusion [Worker](https://github.com/Haidra-Org/AI-Horde-Worker)  (dreamer) in docker either in the cloud or locally on your own computer.

## Run locally
You will need to have installed docker and the NVIDIA container toolkit so that your GPU(s) can be accesed from inside the container.A docker-compose.yaml file is included for your convenience. Simply edit the environment variables, save and then type `docker compose up`

## Run in the cloud
The image is compatible with any GPU cloud platform. You simply need to pass environment variables at runtime. You can use any of the following provider templates for a quick start:
- todo
- todo

## Environment variables

| Variable      | Description |
| ----------- | ----------- |
| GPU_COUNT      | Limit the number of available GPUs     
| HORDE_WORKER_BRANCH | AI-Horde-Worker branch. Defaults to main |
| WEB_USER   | Username for the web UI        |
| WEB_PASSWORD   | Password for the web UI        |
| BRIDGE_API_KEY   | Your AI Horde API key  |
| BRIDGE_WORKER_NAME  | Your worker name        |
| BRIDGE_*   | * Represents any bridgeData.yaml variable. Must be uppercase        |

## Volumes

Data inside docker containers is ephemeral - You'll lose all of it when the container is destroyed.

You may opt to mount a data volume at `/workspace`

If you have mounted the workspace directory then the AI-Horde-Worker will be moved there. This is useful to avoid having to re-download all of your models.

## On Run

The image contains a snapshot of the worker, Hordelib and all of the required dependencies current at the time the image is built.

AI Horde releases updates frequently so the container will always update to the newest versions available on start. This should normally be very fast.

If you have specified the environment variables `WEB_USER` and `WEB_PASSWORD` the web UI will be launched in the container on port 7860. A gradio tunnel will also be created - Check the logs for the address.

A worker will be created for every NVIDIA GPU found in your system unless you have set a limit with the variable `GPU_LIMIT`

The first worker (GPU 0) will be named according to your specification in `BRIDGE_WORKER_NAME`. Extra workers will have this name appended with '#2, #3...'

All processes are managed by supervisord so will restart upon failure until you stop the container.



