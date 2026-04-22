#!/bin/bash

source ./base_template.sh

dnf install -y \
  open-vm-tools

sudo systemctl enable --now vmtoolsd
