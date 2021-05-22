#!/usr/bin/env bash

NUM_CLUSTERS="${NUM_CLUSTERS:-2}"

for i in $(seq "${NUM_CLUSTERS}"); do
  echo "Starting with cluster${i}"
  kubectl create --context="cluster${i}" namespace sample
  kubectl label --context="cluster${i}" namespace sample \
      istio-injection=enabled
  kubectl apply --context="cluster${i}" \
      -f samples/helloworld/helloworld.yaml \
      -l service=helloworld -n sample

  v=$(($(($i%2))+1))
  kubectl apply --context="cluster${i}" \
      -f samples/helloworld/helloworld.yaml \
      -l version="v${v}" -n sample
  echo
done