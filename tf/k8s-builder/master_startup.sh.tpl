#!/bin/bash

cat <<EOF > /etc/yum.repos.d/kubernetes.repo

[kubernetes]

name=Kubernetes

baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64

enabled=1

gpgcheck=1

repo_gpgcheck=1

gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg

EOF

yum update -y -q && \
    yum install -y -q \
    device-mapper-persistent-data \
    flanneld \
    kubeadm \
    kubectl \
    kubelet \
    lvm2 \
    yum-utils

yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

yum install -y -q docker-ce

sed -i 's/cgroup-driver=systemd/cgroup-driver=cgroupfs/g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

export KUBECONFIG=/etc/kubernetes/admin.conf

sysctl net.bridge.bridge-nf-call-iptables=1
systemctl enable docker
systemctl start docker
systemctl enable kubelet
systemctl start kubelet

systemctl daemon-reload

PRIVATE_IP=$(hostname -I | cut -d' ' -f1)

cat <<EOF > /etc/etcd/etcd.conf
# [member]
ETCD_NAME=etcd1
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="http://$${PRIVATE_IP}:2380"
ETCD_LISTEN_CLIENT_URLS="http://$${PRIVATE_IP}:2379,http://127.0.0.1:2379"
#[cluster]
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://$${PRIVATE_IP}:2380"
ETCD_INITIAL_CLUSTER="etcd1=http://$${PRIVATE_IP}:2380"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="ab5f20b33aa4"
ETCD_ADVERTISE_CLIENT_URLS="http://$${PRIVATE_IP}:2379"
EOF

systemctl enable etcd
systemctl start etcd
sed -i s'/ETCD_INITIAL_CLUSTER_STATE="new"/ETCD_INITIAL_CLUSTER_STATE="existing"/'g /etc/etcd/etcd.conf

kubeadm init \
    --apiserver-advertise-address=$PRIVATE_IP \
    --pod-network-cidr=192.168.0.0/16

mkdir -p /root/.kube
sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config
sudo chown $(id -u):$(id -g) /root/.kube/config

kubectl apply -f \
	https://docs.projectcalico.org/v3.4/getting-started/kubernetes/installation/hosted/etcd.yaml

curl https://docs.projectcalico.org/v3.4/getting-started/kubernetes/installation/hosted/calico.yaml -O

sed -i s'/http:\/\/10\.96\.232\.136:6666\"/http:\/\/'"$PRIVATE_IP"':2379"/' calico.yaml

kubectl apply -f calico.yaml
