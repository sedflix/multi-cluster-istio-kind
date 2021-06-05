#!/usr/bin/env bash

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail

NUM_CLUSTERS="${NUM_CLUSTERS:-2}"

for i in $(seq "${NUM_CLUSTERS}"); do
  kubectl config use-context "cluster${i}"
  helm upgrade istio . -f "cluster${i}.yaml" --namespace istio-system
done