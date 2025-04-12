.PHONY: all create delete

NUM_CLUSTERS=2

KUBECONFIG := $(HOME)/.kube/test-config.yaml

export NUM_CLUSTERS

all: cluster istio app monitoring

cluster:
	./kind-setup/create-cluster.sh
	./kind-setup/install-metallb.sh
istio:
	./kind-setup/install-cacerts.sh
	./istio-setup/install-istio.sh
	./istio-chart/enable-endpoint-discovery.sh
app:
	./testing/deploy-helloworld.sh
	./testing/deploy-bookinfo.sh
	./testing/deploy-curl.sh

monitoring:
	./testing/monitoring/install-observability.sh
	istioctl dashboard kiali

# TODO: remove the certs so they are created fresh again
clean:
	./kind-setup/delete-clusters.sh
	rm -rf kind-setup/certs/*

clean-istio:
	kubectl delete ns istio-system
	kubectl delete ns metallb-system
	kubectl delete ns istio-operator