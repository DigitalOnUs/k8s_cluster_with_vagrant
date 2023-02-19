#!/bin/bash
#set -e
K8S_VERSION=$1

echo "### Downloading and Installing pre-reqs to setup the Kubernetes cluster.... ###"
echo " "
echo " "

#Check if netfilter module is loaded
echo "### Checking if netfilter module is loaded ###"
echo " "
lsmod | grep br_netfilter > /dev/null
echo " "
if [ $? -eq 0 ]; then
   echo "#### Netfilter module is already loaded ###"
   echo " "
else
   sudo modprobe br_netfilter
   lsmod | grep br_netfilter
   if [ $? -eq 0 ]; then
      #exit 0
      echo "### netfilter module loaded ###"
      echo " "
   fi
fi

#Enable netfilter to persist after reboot
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
echo " "
#Reload sysctl config
echo "### Reloading sysctl configs... ###"
echo " "
sudo sysctl --system > /dev/null

#Run update to get latests packages and install curl gnugpg and lsb-release
echo "### Updating packages...###"
echo " "
sudo apt-get update
echo " "
echo "### Installing curl gnugpg and lsb-release ###"
sudo apt-get install -y ca-certificates curl gnupg lsb-release

#Download Docker keyrings and install Docker
echo "### Downloading Docker keyrings ###"
echo " "
if [ -s /etc/apt/keyrings/docker.gpg ]; then
   echo "Docker keyrings are already there"
   echo " "
elif [ ! -d /etc/apt/keyrings ]; then
   sudo mkdir -p /etc/apt/keyrings
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
   if [ $? -eq 0 ]; then
      echo "keyrings successfully downloaded"
      echo " "
   fi
fi
echo " "
#Adding docker repositories to sources list
echo "### Adding Docker repository to sources list ###"
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
echo " "
echo "### Updating packages... ###"
echo " "
sudo apt-get update
echo " "
echo "### Installing Docker... ###"
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
echo " "
echo "### Restarting daemon and docker service ###"
sudo systemctl daemon-reload && sudo systemctl restart docker
echo " "
echo "### Verify docker service is running ###"
echo " "
sudo systemctl status docker > /dev/null
if [ $? -eq 0 ]; then
   echo "Docker service is running..."
   echo " "
fi
echo " "
sudo apt-get install apt-transport-https
#Download K8s Keyrings
echo "### Downloading Kubernetes keyrings ###"
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
if [ $? -eq 0 ]; then
   echo "K8s Keyrings downloaded successfully"
   echo " "
fi
# Adding K8s repository to sources list
echo "### Adding K8s repository to sources list"
echo " "
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
echo " "
echo "Updating packages list"
sudo apt-get update
echo " "
echo "### Installing K8s packages ( kubeadm, kubelet and kubectl ) ###"
sudo apt-get install -y kubectl=$K8S_VERSION kubeadm=$K8S_VERSION kubelet=$K8S_VERSION
echo " " >> /home/vagrant/.profile
echo alias k=\"kubectl\" >> /home/vagrant/.profile