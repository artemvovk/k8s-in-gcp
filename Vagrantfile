# -*- mode: ruby -*-
# vvi: set ft=ruby :

VM_NAME = "vagrant-kubes"

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.hostname = VM_NAME
  config.vm.provider "virtualbox" do |v|
    v.name = VM_NAME
    v.memory = 2048
  end
  config.vm.network "forwarded_port", guest: 80, host: 8080
  # config.vm.network "private_network", type: "dhcp"

  config.vm.synced_folder '.', '/home/artem/' + VM_NAME
  config.vm.provision "shell", inline: <<-SHELL
	yum update -y -q
	yum install -y -q \
		curl \
        ca-certificates \
        git \
		net-tools \
		tar \
        vim \
		wget
    GOVERSION=""go1.11.4
	wget -q https://dl.google.com/go/${GOVERSION}.linux-amd64.tar.gz
	sudo tar -C /usr/local -xzf ${GOVERSION}.linux-amd64.tar.gz
    mkdir -p /home/vagrant/go
	echo 'export PATH=$PATH:/usr/local/go/bin' >> /home/vagrant/.bash_profile
  SHELL

end
