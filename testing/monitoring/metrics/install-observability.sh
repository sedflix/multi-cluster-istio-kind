#!/usr/bin/env bash

set -o xtrace
set -o errexit
set -o nounset
# set -o pipefail

cd "$(dirname "$0")"

NUM_CLUSTERS="${NUM_CLUSTERS:-2}"
PROM_SOURCE="https://raw.githubusercontent.com/istio/istio/refs/heads/release-1.21/samples/addons/prometheus.yaml"
KIALI_SOURCE="https://raw.githubusercontent.com/istio/istio/refs/heads/release-1.21/samples/addons/kiali.yaml"

for i in $(seq "${NUM_CLUSTERS}"); do
  echo "Starting prometheus and kiali in cluster${i}"
  kubectl apply --context="cluster${i}" \
      -f "${PROM_SOURCE}"
  kubectl apply --context="cluster${i}" \
      -f "${KIALI_SOURCE}" \
      --wait

done