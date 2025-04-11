#!/usr/bin/env bash

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail

cd "$(dirname "$0")"

NUM_CLUSTERS="${NUM_CLUSTERS:-2}"
APP_SOURCE="https://raw.githubusercontent.com/istio/istio/refs/heads/master/samples/bookinfo/platform/kube/bookinfo.yaml"
# This is samples in 1.21
NETWORKING_SOURCE_DR="https://raw.githubusercontent.com/istio/istio/refs/heads/release-1.21/samples/bookinfo/networking/destination-rule-all.yaml"
NETWORKING_SOURCE_VS="https://raw.githubusercontent.com/istio/istio/refs/heads/release-1.21/samples/bookinfo/networking/virtual-service-all-v1.yaml"

for i in $(seq "${NUM_CLUSTERS}"); do
  echo "Starting with cluster${i}"
  kubectl create --context="cluster${i}" namespace "bookinfo-${i}" || true
  kubectl label --context="cluster${i}" namespace "bookinfo-${i}" \
      istio-injection=enabled || true
  kubectl apply --wait --context="cluster${i}" \
      -f "${APP_SOURCE}" \
      -n "bookinfo-${i}"
  kubectl apply --wait --context="cluster${i}" \
      -f "${NETWORKING_SOURCE_DR}" \
      -n "bookinfo-${i}"
  kubectl apply --wait --context="cluster${i}" \
      -f "${NETWORKING_SOURCE_VS}" \
      -n "bookinfo-${i}"
  echo
done