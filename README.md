# All Things Infra


# Terraform

* Trying to set up something similar to what this (AWS-based bootstrap)[https://github.com/monterail/terraform-bootstrap-example] for GCP. It's kind of a pain
    * GCS has it's own storage account that needs access to KMS
    * How to push local state of the backend to the backend once backend is provisioned
    * Interpolate all the right variables by project/account/credentials file
* Also provision some network and machinery to run a self-managed K8s cluster (and not use GKE or EKS)
* Try out some extra Terraform wrappers: (terragrunt)[https://github.com/gruntwork-io/terragrunt/], (terradiff)[https://github.com/jml/terradiff], (tflint)[https://github.com/wata727/tflint], new HCL syntax?!

# K8s

* Try out (kops)[https://github.com/kubernetes/kops], (kubeadm)[https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm/]
* And then go crazy with: testing Istio, Consul, Vault, Control Planes, etc.