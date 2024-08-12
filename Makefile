.PHONY: all create delete

NUM_CLUSTERS=2

KUBECONFIG := $(HOME)/.kube/test-config.yaml

export NUM_CLUSTERS

all: cluster istio app

cluster:
	./kind-setup/create-cluster.sh
	./kind-setup/install-metallb.sh
istio:
	./kind-setup/install-cacerts.sh
	./istio-setup/install-istio.sh
	./istio-chart/enable-endpoint-discovery.sh
app:
	./testing/deploy-application.sh

# TODO: remove the certs so they are created fresh again
clean:
	./kind-setup/delete-clusters.sh
	rm -rf kind-setup/certs/*