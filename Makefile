.PHONY: all create delete

NUM_CLUSTERS=2

KUBECONFIG := $(HOME)/.kube/test-config.yaml

export NUM_CLUSTERS

all: create test

create:
	./kind-setup/create-cluster.sh
	./kind-setup/install-metallb.sh
	./kind-setup/install-cacerts.sh
	./istio-setup/install-istio.sh
	./istio-chart/enable-endpoint-discovery.sh

test:
	./testing/deploy-application.sh

clean:
	./kind-setup/delete-clusters.sh
# TODO: remove the certs so they are created fresh again