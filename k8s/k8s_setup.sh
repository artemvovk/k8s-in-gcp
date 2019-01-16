#!/bin/bash -
set -o nounset                              # Treat unset variables as an error

REGION="us-central1-a"
PROJECT=`gcloud config get-value project`
BUCKET="kops-cluster-store"

export KOPS_STATE_STORE=gs://${BUCKET}/
export KOPS_FEATURE_FLAGS=AlphaAllowGCE # to unlock the GCE features
export KOPS_CLUSTER_NAME="base.k8s.local"
kops create cluster --zones ${REGION} \
    --state gs://${BUCKET}/ \
    --project=${PROJECT} \
    --associate-public-ip="false" \
    --topology="private" \
    --networking="flannel" \
    --yes
kops get cluster -o yaml > ${KOPS_CLUSTER_NAME}.yml
watch -g kubectl cluster-info
K8S_API_SERVER=$(kubectl config view -o jsonpath="{.clusters[?(@.name==\"${KOPS_CLUSTER_NAME}\")].cluster.server}")
K8S_API_TOKEN=$(kubectl get secrets -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='default')].data.token}"|base64 -d)
echo ${K8S_API_SERVER}
