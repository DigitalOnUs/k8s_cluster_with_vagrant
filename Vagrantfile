# -*- mode: ruby -*-
# vi: set ft=ruby :

#Define here the version for kubeadm, kubelet and kubectl
K8S_VERSION = "1.25.0-00"

# Define the number of master and worker nodes
# If this number is changed, remember to update setup-hosts.sh script with the new hosts IP details in /etc/hosts of each VM.
NUM_MASTER_NODE = 1
NUM_WORKER_NODE = 1

IP_NW = "192.168.56."
POD_NTWK_CIDR = "10.244.0.0/16"
MASTER_IP_START = 1
NODE_IP_START = 2

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "hashicorp/bionic64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  #Provisioning Control Plane
  (1..NUM_MASTER_NODE).each do |i|
    config.vm.define "controlplane" do |master|
        # Name shown in the GUI
        master.vm.provider "virtualbox" do |vb|
            vb.name = "controlplane"
            vb.memory = 2048
            vb.cpus = 2
        end
        master.vm.hostname = "controlplane"
        master.vm.network :private_network, ip: IP_NW + "#{MASTER_IP_START + i}"
        master.vm.network "forwarded_port", guest: 22, host: "2710"

        master.vm.provision "setup-prereqs", :type => "shell", :path => "resources/pre-reqs.sh" do |k|
          k.args = [K8S_VERSION]
        end

        master.vm.provision "Control Plane Init", :type => "shell", :path => "resources/init_cluster.sh" do |i|
          i.args = [POD_NTWK_CIDR]
        end

        master.vm.provision "Set kubeconfig file", after: "Control Plane Init", :type => "shell", privileged: false,
            inline: "mkdir -p /home/vagrant/.kube && \
            sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config && \
            sudo chown $(id -u):$(id -g) /home/vagrant/.kube/config"

        master.vm.provision "Generate Cluster token", :type => "shell", after: :all do |c|
          c.inline = "kubeadm token create --print-join-command > /vagrant/cluster_join_data.txt"
        end
    end
  end    
  # Provision Worker Nodes
  (1..NUM_WORKER_NODE).each do |i|
    config.vm.define "node0#{i}" do |node|
        node.vm.provider "virtualbox" do |vb|
            vb.name = "node0#{i}"
            vb.memory = 1048
            vb.cpus = 2
        end
        node.vm.hostname = "node0#{i}"
        node.vm.network :private_network, ip: IP_NW + "#{NODE_IP_START + i}"
                node.vm.network "forwarded_port", guest: 22, host: "#{2720 + i}"

        node.vm.provision "setup-prereqs", :type => "shell", :path => "resources/pre-reqs.sh" do |k|
          k.args = [K8S_VERSION]
        end

        node.vm.provision "Join Nodes to the Cluster", :type => "shell", privileged: false,
          :path => "resources/join_node.sh"

    end
  end
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
