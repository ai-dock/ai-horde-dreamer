[![Docker Build](https://github.com/ai-dock/ai-horde-dreamer/actions/workflows/docker-build.yml/badge.svg)](https://github.com/ai-dock/ai-horde-dreamer/actions/workflows/docker-build.yml)

# AI Horde Dreamer

Run the [AI Horde](https://aihorde.net) Stable Diffusion [Worker](https://github.com/Haidra-Org/AI-Horde-Worker)  (dreamer) in docker either in the cloud or locally on your own computer.

This image contains a snapshot of the worker, Hordelib and all of the required dependencies current at the time the image is built.

AI Horde releases updates frequently so the container will always update to the newest versions available on start. This should normally be very fast.

## About AI Horde

The AI Horde is a crowdsourced cluster of image and text generation workers. Running a worker node earns kudos which can be used to prioritise your own image generations. Their website is https://aihorde.net/ 

## Pre-built Images

Docker images are built automatically through a GitHub Actions workflow and hosted at the GitHub Container Registry.

An incremental build process is used to avoid needing a huge cache - The following images are used to provide functionality:

- [nvidia/cuda](https://github.com/NVIDIA/nvidia-docker) / [ubuntu](https://github.com/docker-library/docs/tree/master/ubuntu) &#8628;
- [ai-dock/base-image](https://github.com/ai-dock/base-image) &#8628;
- [ai-dock/python](https://github.com/ai-dock/python) &#8628;
- [ai-dock/pytorch](https://github.com/ai-dock/pytorch) / [ai-dock/jupyter-pytorch](https://github.com/ai-dock/jupyter-pytorch) &#8628;
- ai-dock/ai-horde-dreamer

#### Version Tags

The `:latest` tag points to `:latest-cuda`

Tags follow these patterns:

##### _CUDA_
- `:{jupyter}-pytorch-[pytorch-version]-py[python-version]-cuda-[x.x.x]-base-[ubuntu-version]`

- `:latest-cuda` &rarr; `:pytorch-2.0.1-py3.10-cuda-11.8.0-base-22.04`

- `:latest-cuda-jupyter` &rarr; `:jupyter-pytorch-2.0.1-py3.10-cuda-11.8.0-base-22.04`

Browse [here](https://github.com/ai-dock/ai-horde-dreamer/pkgs/container/ai-horde-dreamer) for an image suitable for your target environment.

You can also self-build from source by editing `.env` and running `docker compose build`.

Supported Python versions: `3.10`

Supported Pytorch versions: `2.0.1`

Supported Platforms: `NVIDIA CUDA`

## Run Locally

A 'feature-complete' `docker-compose.yaml` file is included for your convenience. All features of the image are included - Simply edit the environment variables in `.env`, save and then type `docker compose up`.

If you prefer to use the standard `docker run` syntax, the command to pass is `init.sh`.

## Run in the Cloud

This image should be compatible with any GPU cloud platform. You simply need to pass environment variables at runtime. 

>[!NOTE]  
>Please raise an issue on this repository if your provider cannot run the image.

__Container Cloud__

Container providers don't give you access to the docker host but are quick and easy to set up. They are often inexpensive when compared to a full VM or bare metal solution.

All images built for ai-dock are tested for compatibility with both [vast.ai](https://link.ai-dock.org/template-vast-ai-horde-dreamer) and [runpod.io](https://link.ai-dock.org/template-runpod-ai-horde-dreamer).

Images that include Jupyter are also tested to ensure compatibility with [Paperspace Gradient](https://link.ai-dock.org/console.paperspace.com)

See a list of pre-configured templates [here](#pre-configured-templates)

>[!WARNING]  
>Container cloud providers may offer both 'community' and 'secure' versions of their cloud. If your usecase involves storing sensitive information (eg. API keys, auth tokens) then you should always choose the secure option.

__VM Cloud__

Running docker images on a virtual machine/bare metal server is much like running locally.

You'll need to:
- Configure your server
- Set up docker
- Clone this repository
- Edit `.env`and `docker-compose.yml`
- Run `docker compose up`

Find a list of compatible VM providers [here](#compatible-vm-providers).

### Connecting to Your Instance

All services listen for connections at [`0.0.0.0`](https://en.m.wikipedia.org/wiki/0.0.0.0). This gives you some flexibility in how you interact with your instance:

_**Expose the Ports**_

This is fine if you are working locally but can be **dangerous for remote connections** where data is passed in plaintext between your machine and the container over http.

_**SSH Tunnel**_

You will only need to expose port `22` (SSH) which can then be used with port forwarding to allow **secure** connections to your services.

If you are unfamiliar with port forwarding then you should read the guides [here](https://link.ai-dock.org/guide-ssh-tunnel-do-a) and [here](https://link.ai-dock.org/guide-ssh-tunnel-do-b).

_**Cloudflare Tunnel**_

You can use the included `cloudflared` service to make secure connections without having to expose any ports to the public internet. See more below.

## Environment Variables

| Variable              | Description |
| --------------------- | ----------- |
| `BRIDGE_API_KEY`      | Your AI Horde API key |
| `BRIDGE_WORKER_NAME`  | Your worker name |
| `BRIDGE_*`            | * Represents any bridgeData.yaml variable. Must be uppercase |
| `CF_TUNNEL_TOKEN`     | Cloudflare zero trust tunnel token - See [documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/). |
| `CF_QUICK_TUNNELS`    | Create ephemeral Cloudflare tunnels for web services (default `false`) |
| `GPU_COUNT`           | Limit the number of available GPUs |
| `HORDE_DEV`           | Set `true` to install development dependencies. Defaults to `false` |
| `HORDE_SKIP_SERVICE`  | Set `true` to prevent the worker launching on container start. Defaults to `false` |
| `HORDE_WORKER_BRANCH` | AI-Horde-Worker branch/commit hash. Defaults to `main` |
| `JUPYTER_MODE`        | `lab` (default), `notebook` |
| `JUPYTER_PORT`        | Set an alternative port (default `8888`) |
| `JUPYTER_TOKEN`       | Manually set your password |
| `PROVISIONING_SCRIPT` | URL of a remote script to execute on init. See [note](#provisioning-script). |
| `RCLONE_*`            | Rclone configuration - See [rclone documentation](https://rclone.org/docs/#config-file) |
| `SKIP_ACL`            | Set `true` to skip modifying workspace ACL |
| `SSH_PORT`            | Set a non-standard port for SSH (default `22`) |
| `SSH_PUBKEY`          | Your public key for SSH |
| `WEB_USER`            | Username for the web UI |
| `WEB_PASSWORD`        | Password for the web UI |
| `WORKSPACE`           | A volume path. Defaults to `/workspace/` |

Environment variables can be specified by using any of the standard methods (`docker-compose.yaml`, `docker run -e...`). Additionally, environment variables can also be passed as parameters of `init.sh`.

Passing environment variables to init.sh is usually unnecessary, but is useful for some cloud environments where the full `docker run` command cannot be specified.

Example usage: `docker run -e STANDARD_VAR1="this value" -e STANDARD_VAR2="that value" init.sh EXTRA_VAR="other value"`

## Provisioning script

It can be useful to perform certain actions when starting a container, such as creating directories and downloading files.

You can use the environment variable `PROVISIONING_SCRIPT` to specify the URL of a script you'd like to run.

If you are running locally you may instead opt to mount a script at `/opt/ai-dock/bin/provisioning.sh`.

>[!NOTE]  
>`supervisord` will not spawn any processes until the provisioning script has completed.

>[!WARNING]  
>Only use scripts that you trust and which cannot be changed without your consent.

## Software Management

A small software collection is installed by apt-get to provide basic utility.

All other software is installed into its own environment by `micromamba`, which is a drop-in replacement for conda/mamba. Read more about it [here](https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html).

Micromamba environments are particularly useful where several software packages are required but their dependencies conflict. 

### Installed Micromamba Environments

| Environment    | Packages |
| -------------- | ----------------------------------------- |
| `base`         | micromamba's base environment |
| `horde`        | AI Horde and dependencies |
| `system`       | `supervisord`, `openssh`, `rclone` |
| `fastapi`      | `logtail web UI`, `port redirector web UI` |
| `jupyter`      | `jupyter` |
| `python_[ver]` | `python` |

If you are extending this image or running an interactive session where additional software is required, you should almost certainly create a new environment first. See below for guidance.

### Useful Micromamba Commands

| Command                              | Function |
| -------------------------------------| --------------------- |
| `micromamba env list`                | List available environments |
| `micromamba activate [name]`         | Activate the named environment |
| `micromamba deactivate`              | Close the active environment |
| `micromamba run -n [name] [command]` | Run a command in the named environment without activating |

All ai-dock images create micromamba environments using the `--always-softlink` flag which can save disk space where multiple environments are available.

To create an additional micromamba environment, eg for python, you can use the following:

`micromamba --always-softlink create -y -c conda-forge -n [name] python=3.10`

## Volumes

Data inside docker containers is ephemeral - You'll lose all of it when the container is destroyed.

You may opt to mount a data volume at `/workspace` - This is a directory that ai-dock images will look for to make downloaded data available outside of the container for persistence. 

When the runtime scripts detect a mounted workspace, the `AI-Horde-Worker` will be moved there from its original location in `/opt`.

Any changes you have made to `bridgeData.yaml` will be preserved and models will persist between runs.

You can define an alternative path for the workspace directory by passing the environment variable `WORKSPACE=/my/alternative/path/` and mounting your volume there. This feature will generally assist where cloud providers enforce their own mountpoint location for persistent storage.

The provided docker-compose.yaml will mount the local directory `./workspace` at `/workspace`.

As docker containers generally run as the root user, new files created in /workspace will be owned by uid 0(root).

To ensure that the files remain accessible to the local user that owns the directory, the docker entrypoint will set a default ACL on the directory by executing the commamd `setfacl -d -m u:${WORKSPACE_UID}:rwx /workspace`.

If you do not want this, you can set the environment variable `SKIP_ACL=true`.

## Running Services

This image will spawn multiple processes upon starting a container because some of our remote environments do not support more than one container per instance.

All processes are managed by [supervisord](https://supervisord.readthedocs.io/en/latest/) and will restart upon failure until you either manually stop them or terminate the container.

>[!NOTE]  
>*Some of the included services would not normally be found **inside** of a container. They are, however, necessary here as some cloud providers give no access to the host; Containers are deployed as if they were a virtual machine.*

### Dreamer

A dreamer (stable diffusion worker) will be created for every NVIDIA GPU found in your system unless you have set a limit with the variable `GPU_LIMIT`

The first worker (GPU 0) will be named according to your specification in `BRIDGE_WORKER_NAME`. Extra workers will have this name appended with '#2, #3...'

The terminal UI is disabled when running as a service. If you'd like to use it you should set `HORDE_SKIP_SERVICE=true` and access the container by SSH (or docker exec) and launch the worker manually.

### Web UI

If you have specified the environment variables `WEB_USER` and `WEB_PASSWORD` the web UI will be launched in the container on port 7860.

>[!NOTE]  
>_If you have enabled `CF_QUICK_TUNNELS` a secure `https://[randomly-auto-generated-sub-domain].trycloudflare.com` link will be created. You can find it at `var/log/supervisor/quicktunnel-horde-webui.log`_

### Jupyter (with tag `jupyter` only)

The jupyter server will launch a `lab` instance unless you specify `JUPYTER_MODE=notebook`.

Jupyter server will listen on port `8888` unless you have specified an alternative with the `JUPYTER_PORT` environment variable.

A python kernel will be installed coresponding with the python version of the image.

Jupyter's official documentation is available at https://jupyter.org/

>[!NOTE]  
>_If you have enabled `CF_QUICK_TUNNELS` a secure `https://[randomly-auto-generated-sub-domain].trycloudflare.com` link will be created. You can find it at `/var/log/supervisor/quicktunnel-jupyter.log`_

### Port Redirector

This is a simple list of links to the web services available inside the container.

The service will bind to port `1111`.

For each service, you will find a direct link and, if you have set `CF_QUICK_TUNNELS=true`, a link to the service via a fast and secure Cloudflare tunnel.

>[!NOTE]  
>*This service will not show links to any pre-configured Cloudflare tunnels as the domains are static and already known to the user.*

### Log Viewer

The web based log viewer will start on port `1122`.

It's a very lightweight websocket based stream of the latest updates in `/var/log/logtail.log`.

This service will also be accessible on any other exposed ports until the program designated to that port is ready to use.

### Cloudflared

The Cloudflare tunnel daemon will start if you have provided a token with the `CF_TUNNEL_TOKEN` environment variable.

This service allows you to connect to your local services via https without exposing any ports.

You can also create a private network to enable remote connecions to the container at its local address (`172.x.x.x`) if your local machine is running a Cloudflare WARP client.

If you do not wish to provide a tunnel token, you could enable `CF_QUICK_TUNNELS` which will create a throwaway tunnel for your web services.

Full documentation for Cloudflare tunnels is [here](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/).

>[!NOTE]  
>_Cloudflared is included so that secure networking is available in all cloud environments._

>[!WARNING]  
>You should only provide tunnel tokens in secure cloud environments.

### SSHD

A SSH server will be started if at least one valid public key is found inside the running container in the file `/root/.ssh/authorized_keys`

The server will bind to port `22` unless you specify variable `SSH_PORT`.

There are several ways to get your keys to the container.

- If using docker compose, you can paste your key in the local file `config/authorized_keys` before starting the container.
 
- You can pass the environment variable `SSH_PUBKEY` with your public key as the value.

- Cloud providers often have a built-in method to transfer your key into the container

If you choose not to provide a public key then the SSH server will not be started.

To make use of this service you should map port `22` to a port of your choice on the host operating system.

See [this guide](https://link.ai-dock.org/guide-sshd-do) by DigitalOcean for an excellent introduction to working with SSH servers.

>[!NOTE]  
>_SSHD is included because the end-user should be able to know the version prior to deloyment. Using a providers add-on, if available, does not guarantee this._

### Rclone mount

Rclone allows you to access your cloud storage from within the container by configuring one or more remotes. If you are unfamiliar with the project you can find out more at the [Rclone website](https://rclone.org/).

Any Rclone remotes that you have specified, either through mounting the config directory or via setting environment variables will be mounted at `/workspace/remote/[remote name]`. For this service to start, the following conditions must be met:

- Fuse3 installed in the host operating system
- Kernel module `fuse` loaded in the host
- Host `/etc/passwd` mounted in the container
- Host `/etc/group` mounted in the container
- Host device `/dev/fuse` made available to the container
- Container must run with `cap-add SYS_ADMIN`
- Container must run with `securiry-opt apparmor:unconfined`
- At least one remote must be configured

The provided docker-compose.yaml includes a working configuration (add your own remotes).

In the event that the conditions listed cannot be met, `rclone` will still be available to use via the CLI - only mounts will be unavailable.

If you intend to use the `rclone create` command to interactively generate remote configurations you should ensure port `53682` is accessible. See https://rclone.org/remote_setup/ for further details.

>[!NOTE]  
>_Rclone is included to give the end-user an opportunity to easily transfer files between the instance and their cloud storage provider._

>[!WARNING]  
>You should only provide auth tokens in secure cloud environments.

### Logtail

This script follows and prints the log files for each of the above services to stdout. This allows you to follow the progress of all running services through docker's own logging system.

If you are logged into the container you can follow the logs by running `logtail.sh` in your shell.

## Open Ports

Some ports need to be exposed for the services to run or for certain features of the provided software to function


| Open Port             | Service / Description     |
| --------------------- | ------------------------- |
| `22`                  | SSH server                |
| `1111`                | Port redirector web UI    |
| `1122`                | Log viewer web UI         |
| `7860`                | AI Horde WebUI            |
| `8888`                | Jupyter server            |
| `53682`               | Rclone interactive config |

## Pre-Configured Templates

**Vast.​ai**

- [ai-horde-dreamer:latest](https://link.ai-dock.org/template-vast-ai-horde-dreamer)
- [ai-horde-dreamer:latest-jupyter](https://link.ai-dock.org/template-vast-ai-horde-dreamer-jupyter)
---

**Runpod.​io**

- [ai-horde-dreamer:latest](https://link.ai-dock.org/template-runpod-ai-horde-dreamer)
- [ai-horde-dreamer:latest-jupyter](https://link.ai-dock.org/template-runpod-ai-horde-dreamer-jupyter)
---

**Paperspace**

- Create a [new notebook](https://link.ai-dock.org/console.paperspace.com) with the `Start from Scratch` template.
- Select `Advanced options`
- In Container Name enter `ghcr.io/ai-dock/ai-horde-dreamer:latest-jupyter`
- In Registry Username enter `x` (Paperspace bug)
- In Command enter `init.sh WORKSPACE=/notebooks BRIDGE_API_KEY="**your-api-key**" BRIDGE_WORKER_NAME="**your worker name**" WEB_USER="admin" WEB_PASSWORD="**your-password**" CF_QUICK_TUNNELS=true`

You can use the web UI to do further configuration, or you can supply further environment variables as detailed above.

>[!NOTE]  
>The use of `CF_QUICK_TUNNELS` enables us to reach the web UI with a link supplied by Cloudflare. You can find the link in `/var/log/supervisor/quicktunnel-horde-webui.log`

>[!WARNING]  
>Do not attempt to use tunnels to circumvent Paperspace restrictions (eg. SSH & private networking) - You will lose your account.

---

>[!NOTE]  
>These templates are configured to use the `latest` tag but you are free to change to any of the available CUDA tags listed [here](https://github.com/ai-dock/ai-horde-dreamer/pkgs/container/ai-horde-dreamer)

## Compatible VM Providers

A curated list of VM providers currently offering GPU instances:

- [Akami/Linode](https://link.ai-dock.org/linode.com)
- [Amazon Web Services](https://link.ai-dock.org/aws.amazon.com)
- [Google Compute Engine](https://link.ai-dock.org/cloud.google.com)
- [Vultr](https://link.ai-dock.org/vultr.com)

---

_The author ([@robballantyne](https://github.com/robballantyne)) may be compensated if you sign up to services linked in this document. Testing multiple variants of GPU images in many different environments is both costly and time-consuming; This helps to offset costs_
