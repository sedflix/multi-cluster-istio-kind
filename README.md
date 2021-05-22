# Multi-Cluster Istio on Kind

This repo contains the minimal configuration to deploy istio in multi-cluster(on different networks) mode using kind.

## Dependencies

- docker
- kubectl
- kind
- istioctl


## Steps

### Create kind cluster

```shell
export NUM_CLUSTERS=2
./kind-setup/create-cluster.sh
```

### Install MetalLB [1](https://kind.sigs.k8s.io/docs/user/loadbalancer/)

Both ingress and egress gateway created by istio need to External IP. MetalLB allocates it for them.

```shell
cd kind-setup
./install-metallb.sh
```

The range of IP addresses that kind cluster controls can be obtained
with `docker network inspect -f '{{$map := index .IPAM.Config 0}}{{index $map "Subnet"}}' kind`

Assuming that the output is of above command is `172.18.0.0/16`, we have
created [metallb-configmap-1.yaml](./kind-setup/metallb-configmap-1.yaml)
and [metallb-configmap-2.yaml](./kind-setup/metallb-configmap-2.yaml). This allocates `172.18.255.225-172.18.255.250`
and `172.18.255.200-172.18.255.224` ip ranges to cluster1 and cluster2 respectively. If you are creating more than two
cluster, create another metallb-configmap.

### Install CA Certs [2](https://istio.io/latest/docs/tasks/security/cert-management/plugin-ca-cert/)

A multicluster service mesh deployment requires that us to establish trust between all clusters in the mesh. We use a
common root to generate intermediate certificates for each cluster

```shell
cd kind-setup
./install-cacerts.sh
```

### Install Istio [3](https://istio.io/latest/docs/setup/install/multicluster/multi-primary_multi-network/)

It does the following for each cluster:

- label istio namespace as "topology.istio.io/network=network${i}"
- install istiod with configuration in [istio-setup/cluster.yaml](istio-setup/cluster.yaml)
- install a gateway dedicated to east-west traffic
- expose all services (*.local) on the east-west gateway
- install remote secret of this cluster in the other cluster to enable k8s api server endpoint discovery

```shell
cd istio-setup
./install-istio.yaml
```

### Deploy Test Applications [4](https://istio.io/latest/docs/setup/install/multicluster/verify/)

It does the following:

- create ns sample in all the cluster
- create service helloworld in all the cluster
- deploy v1 and v2 of helloworld alternatively in each cluster

```shell
cd istio-setup
./deploy-application.sh
```

### Test the magic [4](https://istio.io/latest/docs/setup/install/multicluster/verify/)

Go inside a pod and try: `curl -sS helloworld.sample:5000/hello`. The response should be like when run multiple times

```
Hello version: v1, instance: helloworld-v1-776f57d5f6-znwk5
Hello version: v2, instance: helloworld-v2-54df5f84b-qmg8t..
...
```


## References:

- [Istio: Install Multi-Primary on different networks](https://istio.io/latest/docs/setup/install/multicluster/multi-primary_multi-network/)
- [Istio: Plugin CA Cert](https://istio.io/latest/docs/tasks/security/cert-management/plugin-ca-cert/)
- [Kind: MetalLB](https://kind.sigs.k8s.io/docs/user/loadbalancer/)
- [Istio: Verify MultiCluster Installation](https://istio.io/latest/docs/setup/install/multicluster/verify/)