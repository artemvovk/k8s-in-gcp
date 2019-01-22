#!/bin/bash -
set -o nounset                              # Treat unset variables as an error
systemctl daemon-reload

PRIVATE_IP=$(hostname -I)

# sudo chown $(id -u):$(id -g) /root/.kube/config

kubeadm join \
    --discovery-token-unsafe-skip-ca-verification \
    --discovery-token "${BOOTSTRAP_TOKEN}" \
    "${K8S_MASTER_IP}:6443"
