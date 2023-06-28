#!/bin/bash

printf "Updating Hordelib & Horde Model Reference...\n"

micromamba run -n dreamer pip --no-cache-dir install -U hordelib horde_model_reference