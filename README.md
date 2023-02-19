# Vagrant Template to create k8s Cluster

## This template will spun up the required VMs for the cluster using virtualbox

### Prereqs

1. Virtualbox app installed
2. Text Editor

### Steps to create the cluster

> **Variables Used in Vagrantfile**
> | Variable | Description |
> |-----------|--------------|
> | K8S_VERSION | Define Version for K8s components (kubeadm, kubelet and kubectl) |
> | NUM_MASTER_NODE | Define the number of Master nodes to create |
> | NUM_WORKER_NODE | Define the number of worker nodes to create |
> | IP_NW | Defines the private CIDR for the nodes subnet |
> | POD_NTWK_CIDR | Define the CIDR range for the pods subnet |

> **Edit the Vagrantfile accordingly to spun up the number of masters and nodes for your cluster**

1. Edit Vagrantfile and set the number of Master and Workers to create
2. Enable Experimental vagrant feature with command `export VAGRANT_EXPERIMENTAL="dependency_provisioners"` for provisioning dependencies
3. Run ` vagrant up `
4. wait until the cluster is up and connect to the **controlplane** `vagrant ssh controlplane`
5. Install your prefered [Network Add On](https://kubernetes.io/docs/concepts/cluster-administration/addons/#networking-and-network-policy)
6. check that you can get nodes and verify the version
   ` kubectl get nodes -o wide `

> **This code is based on KodeKcloud labs on CKA course**
