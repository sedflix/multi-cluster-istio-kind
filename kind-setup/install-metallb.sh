#!/usr/bin/env bash

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail

source "$(dirname $(realpath "$0"))/../utils/get-config-files.sh"

DIR=$(pwd)
NUM_CLUSTERS="${NUM_CLUSTERS:-2}"

for i in $(seq "${NUM_CLUSTERS}"); do
  sleep_duration=$((90/i))
  echo "Starting metallb deployment in cluster${i}"

  kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.10/config/manifests/metallb-native.yaml --context "cluster${i}"
  kustomize build ${DIR}/kind-setup/metalLb | kubectl apply -f -
  # TODO: this metallb-configmap need to be automatically generated
  kubectl wait --for=condition=available --timeout=90s deployment/controller \
      -n metallb-system --context "cluster${i}"
  kubectl apply -f ${DIR}/kind-setup/metallb-configmap-${i}-copy.yaml --context "cluster${i}"
  echo "----"
done