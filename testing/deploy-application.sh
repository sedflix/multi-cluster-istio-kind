#!/usr/bin/env bash

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail

cd "$(dirname "$0")"

NUM_CLUSTERS="${NUM_CLUSTERS:-2}"

for i in $(seq "${NUM_CLUSTERS}"); do
  echo "Starting with cluster${i}"
  kubectl create --context="cluster${i}" namespace sample || true
  kubectl label --context="cluster${i}" namespace sample \
      istio-injection=enabled || true
  kubectl apply --context="cluster${i}" \
      -f samples/helloworld/helloworld.yaml \
      -l service=helloworld -n sample

  v=$(($(($i%2))+1))
  kubectl apply --context="cluster${i}" \
      -f samples/helloworld/helloworld.yaml \
      -l version="v${v}" -n sample
  echo
done