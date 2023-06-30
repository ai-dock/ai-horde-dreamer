#!/bin/bash

# Ensure Nvidia container toolkit
FROM nvidia/cuda:11.8.0-base-ubuntu20.04

# Set ENV variables
ENV LANG C.UTF-8
ENV SHELL=/bin/bash
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=$PATH:/opt/horde/bin:/opt/micromamba/bin
ENV APT_INSTALL="apt-get install -y --no-install-recommends"
ENV MAMBA_CREATE="micromamba --experimental create -y -c conda-forge"
ENV PIP_INSTALL="pip --no-cache-dir install"

# Force torch version to match in following mamba envs
ARG TORCH_VERSION=2.0.1

# Minimal base environment with micromamba and supervisor
RUN apt-get update && \
    $APT_INSTALL \
        pkg-config \
        libgl1 \
        git \
        zip \
        unzip \
        curl \
        wget \
        nano \
        less \
        screen \
        tmux \
        supervisor \
        openssh-server \
        uuid-runtime \
        build-essential && \
    rm -rf /var/lib/apt/lists/* && \
    rm /etc/update-motd.d/10-help-text && \
    rm /etc/update-motd.d/60-unminimize && \
    mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh && \
    touch /root/.ssh/authorized_keys && \
    chmod 600 /root/.ssh/authorized_keys && \
    mkdir -p /run/sshd && \
    chmod 700 /run/sshd && \
    mkdir -p /var/log/supervisor && \
    mkdir -p /opt/micromamba && \
    cd /opt/micromamba && \
    curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj bin/micromamba && \
    micromamba shell init --shell=bash --prefix=~/micromamba
   
# AI Horde Worker
RUN cd /opt && \
    git clone https://github.com/Haidra-Org/AI-Horde-Worker && \
    $MAMBA_CREATE -n dreamer python=3.10 && \
    micromamba run -n dreamer $PIP_INSTALL \
        --extra-index https://download.pytorch.org/whl/cu118 \
        torch==${TORCH_VERSION} \
        torchvision \
        torchaudio \
        triton \
        xformers \
        nvidia-ml-py3 \
        ruamel.yaml && \
    micromamba run -n dreamer $PIP_INSTALL \
        -r /opt/AI-Horde-Worker/requirements.txt && \
    micromamba run -n dreamer python -m pip cache purge

ENV AIWORKER_CACHE_HOME=/tmp

ADD ./opt /opt
ADD ./etc /etc

EXPOSE 22
EXPOSE 7860

ENTRYPOINT [ "/opt/horde/bin/entrypoint.sh" ]

CMD ["/opt/horde/bin/supervisord-env.sh"]
