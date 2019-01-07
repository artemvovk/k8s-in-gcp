#!/bin/bash -
#===============================================================================
#
#          FILE: setup.sh
#
#         USAGE: ./setup.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (),
#  ORGANIZATION:
#       CREATED: 01/06/2019 18:34
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
export GOOGLE_APPLICATION_CREDENTIALS="${HOME}/.config/gcloud/k8s-builder-tf-cli.json"
gcloud auth activate-service-account --key-file="${HOME}/.config/gcloud/k8s-builder-tf-cli.json"
terraform workspace new backend backend
terraform workspace select backend backend

export TF_VAR_region="us-west1"
export TF_VAR_key_ring_name="tf-state-key-ring"
export TF_VAR_key_name="tf-state-key"

# Create keyring and key so they can be imported
# These resources are not managed by terraform because they cannot be destroyed
# So it's not like you can `terraform destroy` them
gcloud kms keyrings create "${TF_VAR_key_ring_name}" --location "${TF_VAR_region}"
gcloud kms keys create "${TF_VAR_key_name}" --location "${TF_VAR_region}" \
  --keyring "${TF_VAR_key_ring_name}" \
  --purpose encryption \
  --rotation-period "604800s" \
  --next-rotation-time "$(date --date="next day" +%D)"

export TF_VAR_key_ring_link=$(gcloud kms keyrings list --location "${TF_VAR_region}" \
    | grep ${TF_VAR_key_ring_name} \
    | head -n1)
export TF_VAR_key_link=$(gcloud kms keys list \
    --location "${TF_VAR_region}" \
    --keyring ${TF_VAR_key_ring_name} \
    | awk '/projects/ {print $1}' \
    | tail -n1)

terraform init -backend-config=backend.tfvars backend
terraform apply -var-file=terraform.tfvars backend