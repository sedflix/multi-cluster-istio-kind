#!/usr/bin/env bash

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail

cd "$(dirname "$0")"

NUM_CLUSTERS="${NUM_CLUSTERS:-2}"
APP_SOURCE="https://raw.githubusercontent.com/istio/istio/refs/heads/release-1.24/samples/curl/curl.yaml"
# This is samples in 1.21

for i in $(seq "${NUM_CLUSTERS}"); do
  echo "Starting with cluster${i}"
  kubectl create --context="cluster${i}" namespace "curl-${i}" || true
  kubectl label --context="cluster${i}" namespace "curl-${i}" \
      istio-injection=enabled || true
  kubectl apply --wait --context="cluster${i}" \
      -f "${APP_SOURCE}" \
      -n "curl-${i}"
  echo
done