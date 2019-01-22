#!/bin/bash -
set -o nounset                              # Treat unset variables as an error

export GOOGLE_SERVICE_ACCOUNT="tf-cli"
export GOOGLE_PROJECT="k8s-builder"
export GOOGLE_APPLICATION_CREDENTIALS="${HOME}/.config/gcloud/${GOOGLE_PROJECT}-${GOOGLE_SERVICE_ACCOUNT}.json"

gcloud auth activate-service-account \
    --key-file="${GOOGLE_APPLICATION_CREDENTIALS}"

export TF_VAR_project="${GOOGLE_PROJECT}"
export TF_VAR_region="${REGION:-us-central1}"
export TF_VAR_service_account="${GOOGLE_SERVICE_ACCOUNT}"
export TF_VAR_kops_store="kops-cluster-store"
export TF_VAR_region="us-central1"

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
    export TF_VAR_etcd_discovery_token=$(curl -s -w "\n" 'https://discovery.etcd.io/new?size=3')
    terragrunt init
    terragrunt apply -auto-approve
elif [[ "$COMMAND" == "destroy" ]]; then
    export TF_VAR_etcd_discovery_token="does not matter"
    terragrunt destroy
fi

