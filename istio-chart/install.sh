#!/usr/bin/env bash

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail

source "$(dirname $(realpath "$0"))/../utils/get-config-files.sh"

NUM_CLUSTERS="${NUM_CLUSTERS:-2}"


#helm repo add sedflix https://sedflix.github.io/charts/
#helm dependency update

for i in $(seq "${NUM_CLUSTERS}"); do
  kubectl config use-context "cluster${i}"
  helm install istio . -f "cluster${i}.yaml" --namespace istio-system --create-namespace
done