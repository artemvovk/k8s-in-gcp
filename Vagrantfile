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
		bash-completion \
		bash-completion-extras \
		bzip2-devel \
		curl \
        ca-certificates \
		db4-devel \
		device-mapper-persistent-data \
		expat-devel \
		gcc \
		gdbm-devel \
        git \
		libffi-devel \
		libpcap-devel \
		lvm2 \
		ncurses-devel \
		net-tools \
		openssl-devel \
		readline-devel \
		sqlite-devel \
		tar \
		tk-devel \
        vim \
		wget \
		xz-devel \
		yum-utils \
		zlib-devel
	sudo yum-config-manager \
    	--add-repo \
        https://download.docker.com/linux/centos/docker-ce.repo
    yum install -y -q \
		docker-ce-18.06.1.ce
	systemctl start docker
    GOVERSION=""go1.11.4
	wget -q https://dl.google.com/go/${GOVERSION}.linux-amd64.tar.gz
	sudo tar -C /usr/local -xzf ${GOVERSION}.linux-amd64.tar.gz
    mkdir -p /home/vagrant/go
	echo 'export PATH=$PATH:/usr/local/go/bin' >> /home/vagrant/.bash_profile

    git clone https://github.com/pyenv/pyenv.git /home/vagrant/.pyenv
	chown -R vagrant /home/vagrant
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> /home/vagrant/.bash_profile
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> /home/vagrant/.bash_profile
    echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> /home/vagrant/.bash_profile
  SHELL

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
	pyenv install 2.7.15
	pyenv install 3.7.0
  SHELL
end
