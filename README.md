# AI Horde Dreamer

Run the [AI Horde](https://aihorde.net) Stable Diffusion [Worker](https://github.com/Haidra-Org/AI-Horde-Worker)  (dreamer) in docker either in the cloud or locally on your own computer.

The pre-built image is available on [Docker Hub](https://hub.docker.com/r/dynamedia/ai-horde-dreamer) or you can review the Dockerfile and self-build.

This image contains a snapshot of the worker, Hordelib and all of the required dependencies current at the time the image is built.

AI Horde releases updates frequently so the container will always update to the newest versions available on start. This should normally be very fast.


## Run Locally

You will need to have installed docker and the NVIDIA container toolkit so that your GPU(s) can be accesed from inside the container.A docker-compose.yaml file is included for your convenience. Simply edit the environment variables, save and then type `docker compose up`

## Run in the Cloud

The image is compatible with any GPU cloud platform. You simply need to pass environment variables at runtime. You can use any of the following provider templates for a quick start:
- [Vast.ai](https://cloud.vast.ai/?ref=62897&template_id=c967379624d5b34217274ebf4a422d94)



## Environment Variables

| Variable            | Description |
| ------------------- | ----------- |
| GPU_COUNT           | Limit the number of available GPUs |
| SSH_PUBKEY          | Your public key for SSH |
| HORDE_WORKER_BRANCH | AI-Horde-Worker branch/commit hash. Defaults to main |
| WEB_USER            | Username for the web UI |
| WEB_PASSWORD        | Password for the web UI |
| BRIDGE_API_KEY      | Your AI Horde API key |
| BRIDGE_WORKER_NAME  | Your worker name |
| BRIDGE_*            | * Represents any bridgeData.yaml variable. Must be uppercase |

## Volumes

Data inside docker containers is ephemeral - You'll lose all of it when the container is destroyed.

You may opt to mount a data volume at `/workspace`

If you have mounted the workspace directory then the AI-Horde-Worker will be moved there from its default location in `/opt` and symlinked back into the running container. This is useful to avoid having to re-download all of your models or for making changes to your configuration without a container restart.

The provided docker-compose.yaml will mount the local directory `./workspace` at `/workspace`.

## Running Services

This image will start multiple processes on boot. All processes are managed by supervisord so will restart upon failure until you stop the container.

### Dreamer

A dreamer (stable diffusion worker) will be created for every NVIDIA GPU found in your system unless you have set a limit with the variable `GPU_LIMIT`

The first worker (GPU 0) will be named according to your specification in `BRIDGE_WORKER_NAME`. Extra workers will have this name appended with '#2, #3...'

### Web UI

If you have specified the environment variables `WEB_USER` and `WEB_PASSWORD` the web UI will be launched in the container on port 7860. A gradio tunnel will also be created - Check the logs for the address.

### SSHD

A SSH server will be started if a valid public key is found inside the running container in the file `/root/.ssh/authorized_keys`

There are several ways to get your key to the container.

- If using docker compose, you can paste your key in the local file `authorized_keys` before starting the container.
 
- You can pass the environment variable `SSH_PUBKEY` with your public key as the value.
- Cloud providers often have a built-in method to transfer your key into the container
 

### Logtail

This script follows and prints the log files for each of the above services to stdout. This allows you to follow the progress of your dreamer(s) through docker's own logging system.

If you are logged into the container you can follow the logs by running `logtail.sh`




