#!/bin/bash -
set -o nounset                              # Treat unset variables as an error

export GOOGLE_SERVICE_ACCOUNT="tf-cli"
export GOOGLE_PROJECT="k8s-builder"
export GOOGLE_APPLICATION_CREDENTIALS="${HOME}/.config/gcloud/${GOOGLE_PROJECT}-${GOOGLE_SERVICE_ACCOUNT}.json"

# These are shared variables between the two deployments but it's awkward to manage them in a file
export TF_VAR_project="${GOOGLE_PROJECT}"
export TF_VAR_service_account="${GOOGLE_SERVICE_ACCOUNT}"
export TF_VAR_prefix="${TF_VAR_project}"
while read l; do
    eval "export TF_VAR_$(echo $l | sed 's/\ =\ /=/')"
done <terraform.tfvars

gcloud auth activate-service-account \
    --key-file="${GOOGLE_APPLICATION_CREDENTIALS}"

# Handling input
COMMAND="apply"
PS3='Which action to perform: '
options=("Apply/Create" "Destroy" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Apply/Create")
            COMMAND="apply"
            break
            ;;
        "Destroy")
            COMMAND="destroy"
            break
            ;;
        "Quit")
            exit 0
            ;;
        *) echo "invalid option $REPLY";;
    esac
done


if [[ "$COMMAND" == "apply" ]]; then
    terraform workspace new backend backend
    terraform workspace select backend backend
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


    terraform init backend
    terraform apply -auto-approve backend

    # Save the remote state setup variables for further use
    echo "bucket = \"${TF_VAR_bucket}\"" > remote.tfvars
    echo "yes" | TF_INPUT="true" terraform init -force-copy -backend-config=remote.tfvars remote
else
    export TF_VAR_key_ring_link=$(gcloud kms keyrings list --location "${TF_VAR_region}" \
        | grep ${TF_VAR_key_ring_name} \
        | head -n1)
    export TF_VAR_key_link=$(gcloud kms keys list \
        --location "${TF_VAR_region}" \
        --keyring ${TF_VAR_key_ring_name} \
        | awk '/projects/ {print $1}' \
        | tail -n1)

    terraform workspace select backend backend
    echo "yes" | TF_INPUT="true" terraform init backend
    terraform destroy -auto-approve backend
    rm -rf remote.tfvars
fi
