#!/usr/bin/env bash

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail

NUM_CLUSTERS="${NUM_CLUSTERS:-2}"

for i in $(seq "${NUM_CLUSTERS}"); do
  echo "Starting metallb deployment in cluster${i}"
  kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.9/config/manifests/metallb-native.yaml --context "cluster${i}"
  kubectl wait --namespace metallb-system --for=condition=ready pod --selector=app=metallb --timeout=300s --context "cluster${i}"
  kubectl apply -f ./metallb-cr-${i}.yaml --context "cluster${i}"
  echo "----"
done
