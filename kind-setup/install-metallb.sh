#!/usr/bin/env bash

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail

DIR=$(pwd)
NUM_CLUSTERS="${NUM_CLUSTERS:-2}"

for i in $(seq "${NUM_CLUSTERS}"); do
  echo "Starting metallb deployment in cluster${i}"
  # kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.8/manifests/namespace.yaml --context "cluster${i}"
  #kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.8/manifests/metallb.yaml --context "cluster${i}"
  kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.10/config/manifests/metallb-native.yaml --context "cluster${i}"
  kustomize build ${DIR}/metalLb | kubectl apply -f -
  # kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"   --context "cluster${i}"
  kubectl apply -f ./metallb-configmap-${i}.yaml --context "cluster${i}"
  echo "----"
done