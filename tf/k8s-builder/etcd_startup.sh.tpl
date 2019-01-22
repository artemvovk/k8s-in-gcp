#!/bin/bash

# gcloud beta compute ssh etcd-node-0 --internal-ip --zone us-central1-b

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
    etcd

export PRIVATE_IP=$(hostname -I | cut -d' ' -f1)
export NODE_NAME=$(hostname)

mkdir -p /etc/etcd
touch /etc/etcd/etcd.conf
cat <<EOF > /etc/etcd/etcd.conf
#[Member]
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="http://$${PRIVATE_IP}:2380"
ETCD_LISTEN_CLIENT_URLS="http://$${PRIVATE_IP}:2379"
ETCD_NAME="$${NODE_NAME}"
#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://$${PRIVATE_IP}:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://$${PRIVATE_IP}:2379"
ETCD_DISCOVERY="https://discovery.etcd.io/${ETCD_DISCOVERY_TOKEN}"
ETCD_INITIAL_CLUSTER_STATE="new"
EOF

sudo systemctl daemon-reload
systemctl enable etcd
systemctl start etcd
