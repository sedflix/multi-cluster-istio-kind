#!/usr/bin/env bash

SCRIPT_DIR=$(dirname $(realpath "$0"))

# check chip architecture and set the correct env variables
if [[ "$(uname -m)" == "arm64" ]]; then
  source "${SCRIPT_DIR}"/../configs/arm64.env
  echo "Using ARM64 kind node source"
else
  source "${SCRIPT_DIR}"/../configs/amd64.env
  echo "Using AMD64 kind node source"
fi