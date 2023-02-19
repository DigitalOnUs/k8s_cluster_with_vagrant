#!/bin/bash

CONTROLPLANE_IP=$(/sbin/ip -o -4 addr list eth1 | awk '{print $4}' | cut -d/ -f1)
POD_NTWK_CIDR=$1

echo " "
echo "### As per this error "msg="validate service connection: CRI v1 runtime API is not implemented    ###"
echo "### for endpoint \"unix:///var/run/containerd/containerd.sock\": rpc error: code = Unimplemented  ###"
echo "### desc = unknown service runtime.v1.RuntimeService containerd conf under /etc/containerd/ needs ###"
echo "### to be removed and containerd should be restarted                                              ###"
echo " "
if [ -s /etc/containerd/config.toml ]; then
    sudo mv /etc/containerd/config.toml /etc/containerd/config.toml.bkp
    sudo systemctl restart containerd
    sudo systemctl status containerd
else
    echo "The config file for containerd doesnt exists, so you can continue..."
    echo " "
fi
echo " "
echo "### Disabling SWAP... "
sudo swapoff -a
echo " "
echo "### Initializing K8s Control Plane ###"
sudo kubeadm init --pod-network-cidr $POD_NTWK_CIDR --apiserver-advertise-address=$CONTROLPLANE_IP >> preflight_checks.log
echo " "
