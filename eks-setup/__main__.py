import os
from subprocess import call

import pulumi
import pulumi_eks as eks


def read_my_key(name="id_rsa.pub"):
    with open(f'{os.getenv("HOME")}/.ssh/{name}', "r") as f:
        key = f.read()
    return key


def write_to_file(file, data):
    with open(file, "w") as f:
        f.write(data)


def create_eks_cluster(name):
    cluster = eks.Cluster(
        f"{name}",
        public_access_cidrs=["0.0.0.0/0"],
        instance_type="t4g.small",
        desired_capacity=2,
        min_size=1,
        max_size=3,
        node_associate_public_ip_address=True,
        node_public_key=read_my_key(),
        endpoint_public_access=True,
    )
    # eks.ClusterNodeGroupOptionsArgs
    pulumi.export(f"kubeconfig-{name}", cluster.kubeconfig)

create_eks_cluster("cluster1")
rc = call(["./create_admin_kubeconfig.sh", "cluster1"])
