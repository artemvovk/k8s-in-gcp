# All Things Infra


# Terraform

* Trying to set up something similar to what this [AWS-based bootstrap](https://github.com/monterail/terraform-bootstrap-example) for GCP. It's kind of a pain
    * GCS has it's own storage account that needs access to KMS
    * How to push local state of the backend to the backend once backend is provisioned
    * Interpolate all the right variables by project/account/credentials file: The bash script does an "ugly but working" sourcing of the variables
* Also provision some network and machinery to run a self-managed K8s cluster (and not use GKE or EKS)

### Working:

* `setup.sh` file can `apply` and `destroy` a backend bucket based whatever you define in the `terraform.tfvars` file.
* `k8s-builder` provides a basic `kops-cluster-store` based on the [this documentation](https://github.com/kubernetes/kops/blob/master/docs/tutorial/gce.md)

### TODO:

* Try out some extra Terraform wrappers: [terragrunt](https://github.com/gruntwork-io/terragrunt/), [terradiff](https://github.com/jml/terradiff), [tflint](https://github.com/wata727/tflint), new HCL syntax?!

# K8s

### Working:

* Setup up basic `kops` cluster
* Add [dashboard](https://github.com/kubernetes/dashboard)
* Some work stolen from [this workshop](https://github.com/leecalcote/istio-service-mesh-workshop)

$$$ TODO:

* Proper RBAC
* Add Istio
* And then go crazy with: Prometheus, Consul, Vault, Control Planes, etc.
