#!/usr/bin/env bash

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail

cd "$(dirname "$0")"

NUM_CLUSTERS="${NUM_CLUSTERS:-2}"

for i in $(seq "${NUM_CLUSTERS}"); do
  echo "Deploying scenario in cluster${i}"

  kustomize build | kubectl apply --context="cluster${i}"\
   -n bookinfo -f -

  echo "----"
done