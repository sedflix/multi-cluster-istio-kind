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
  # kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.8/manifests/namespace.yaml --context "cluster${i}"
  #kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.8/manifests/metallb.yaml --context "cluster${i}"
  kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.10/config/manifests/metallb-native.yaml --context "cluster${i}"
  kustomize build ${DIR}/kind-setup/metalLb | kubectl apply -f -
  # kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"   --context "cluster${i}"
  sleep ${sleep_duration}
  # TODO: this metallb-configmap need to be automatically generated
  kubectl apply -f ${DIR}/kind-setup/metallb-configmap-${i}-copy.yaml --context "cluster${i}"
  echo "----"
done