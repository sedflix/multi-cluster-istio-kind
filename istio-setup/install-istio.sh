#!/usr/bin/env bash

set -o xtrace
set -o errexit
set -o nounset
# set -o pipefail

source "$(dirname $(realpath "$0"))/../utils/get-config-files.sh"

cd "$(dirname "$0")"

OS="$(uname)"
NUM_CLUSTERS="${NUM_CLUSTERS:-2}"

for i in $(seq "${NUM_CLUSTERS}"); do
  echo "Starting istio deployment in cluster${i}"

  kubectl --context="cluster${i}" get namespace istio-system && \
    kubectl --context="cluster${i}" label namespace istio-system topology.istio.io/network="network${i}"

   sed -e "s/{i}/${i}/" cluster.yaml > "cluster${i}.yaml"
  istioctl install -y --force --context="cluster${i}" -f "cluster${i}.yaml"

  echo "Generate eastwest gateway in cluster${i}"
  samples/multicluster/gen-eastwest-gateway.sh \
      --mesh "mesh${i}" --cluster "cluster${i}" --network "network${i}" > cluster${i}-ew-iop.yaml

  istioctl --context="cluster${i}" install -y -f cluster${i}-ew-iop.yaml

  echo "Expose services in cluster${i}"
  kubectl --context="cluster${i}" apply -n istio-system -f samples/multicluster/expose-services.yaml

  echo
done

