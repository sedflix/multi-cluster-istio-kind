#!/usr/bin/env bash

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail


NUM_CLUSTERS="${NUM_CLUSTERS:-2}"

mkdir -p certs
pushd certs
make -f ../tools/certs/Makefile.selfsigned.mk root-ca

for i in $(seq "${NUM_CLUSTERS}"); do
  make -f ../tools/certs/Makefile.selfsigned.mk "cluster${i}-cacerts"
  kubectl create namespace istio-system --context "cluster${i}"
  kubectl --context="cluster${i}" label namespace istio-system topology.istio.io/network="network${i}"
  kubectl delete secret cacerts -n istio-system --context "cluster${i}"
  kubectl create secret generic cacerts -n istio-system --context "cluster${i}" \
      --from-file="cluster${i}/ca-cert.pem" \
      --from-file="cluster${i}/ca-key.pem" \
      --from-file="cluster${i}/root-cert.pem" \
      --from-file="cluster${i}/cert-chain.pem"
  echo "----"
done

