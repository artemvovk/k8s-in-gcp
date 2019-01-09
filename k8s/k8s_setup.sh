#!/bin/bash -
#===============================================================================
#
#          FILE: k8s_setup.sh
#
#         USAGE: ./k8s_setup.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (),
#  ORGANIZATION:
#       CREATED: 01/06/2019 10:05
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

# terragrunt init
# terragrunt apply

REGION="us-west1-a"
PROJECT=`gcloud config get-value project`
BUCKET="kops-cluster-store"

export KOPS_STATE_STORE=gs://${BUCKET}/
export KOPS_FEATURE_FLAGS=AlphaAllowGCE # to unlock the GCE features
export KOPS_CLUSTER_NAME="base.k8s.local"
kops create cluster --zones ${REGION} --state gs://${BUCKET}/ --project=${PROJECT} --yes
kops get cluster -o yaml > ${KOPS_CLUSTER_NAME}.yml
kubectl create -f dashboard/adminuser.yaml
kubectl create -f dashboard/dashboard.yaml

