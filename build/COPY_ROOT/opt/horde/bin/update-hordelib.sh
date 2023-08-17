#!/bin/bash

printf "Updating Hordelib & Horde Model Reference...\n"

# Pin torch to image version
micromamba run -n horde ${PIP_INSTALL} -U torch==${PYTORCH_VERSION} hordelib horde_model_reference