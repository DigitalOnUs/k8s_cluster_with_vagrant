#!/bin/bash

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
echo "### Disabling SWAP... "
sudo swapoff -a
echo " "
echo "### Joining Node to Cluster"
sudo $(cat /vagrant/cluster_join_data.txt)
if [ $? -eq 0 ]; then
    rm -rf /vagrant/cluster_join_data.txt
fi
