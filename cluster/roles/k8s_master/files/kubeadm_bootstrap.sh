#!/bin/bash -
set -o nounset                              # Treat unset variables as an error
systemctl daemon-reload

PRIVATE_IP=$(hostname -I)

kubeadm init \
    --apiserver-advertise-address=$PRIVATE_IP \
    --token $BOOTSTRAP_TOKEN \
    --pod-network-cidr=192.168.0.0/16

mkdir -p /root/.kube
sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config
sudo chown $(id -u):$(id -g) /root/.kube/config

kubectl apply -f \
	https://docs.projectcalico.org/v3.4/getting-started/kubernetes/installation/hosted/etcd.yaml

curl https://docs.projectcalico.org/v3.4/getting-started/kubernetes/installation/hosted/calico.yaml -O

sed -i s'/http:\/\/10\.96\.232\.136:6666\"/'"$ETCD_IPS"'"/' calico.yaml

kubectl apply -f calico.yaml

