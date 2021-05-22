#!/usr/bin/env bash

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail



OS="$(uname)"
NUM_CLUSTERS="${NUM_CLUSTERS:-2}"

for i in $(seq "${NUM_CLUSTERS}"); do
  echo "Starting istio deployment in cluster${i}"

  kubectl --context="cluster${i}" get namespace istio-system && \
    kubectl --context="cluster${i}" label namespace istio-system topology.istio.io/network="network${i}"

   sed -e "s/{i}/${i}/" cluster.yaml > "cluster${i}.yaml"
  istioctl install --force --context="cluster${i}" -f "cluster${i}.yaml"

  echo "Generate eastwest gateway in cluster${i}"
  samples/multicluster/gen-eastwest-gateway.sh \
      --mesh "mesh${i}" --cluster "cluster${i}" --network "network${i}" | \
      istioctl --context="cluster${i}" install -y -f -

  echo "Expose services in cluster${i}"
  kubectl --context="clustyer${i}" apply -n istio-system -f samples/multicluster/expose-services.yaml

  echo
done

for i in $(seq "${NUM_CLUSTERS}"); do
  for j in $(seq "${NUM_CLUSTERS}"); do
    if [ "$i" -ne "$j" ]
    then
      echo "Enable Endpoint Discovery between cluster${i} and cluster${j}"

      if [ "$OS" == "Darwin" ]
      then
        # Set container IP address as kube API endpoint in order for clusters to reach kube API servers in other clusters.
        docker_ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "cluster${i}-control-plane")
        istioctl x create-remote-secret \
        --context="cluster${i}" \
        --server="https://${docker_ip}:6443" \
        --name="cluster${i}" | \
          kubectl apply --validate=false --context="cluster${j}" -f -
      else
        istioctl x create-remote-secret \
          --context="cluster${i}" \
          --name="cluster${i}" | \
          kubectl apply --validate=false --context="cluster${j}" -f -
      fi
    fi
  done
done