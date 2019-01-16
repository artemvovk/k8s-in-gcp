terragrunt = {
  remote_state {
    backend = "gcs"
    config {
      bucket = "tf-backend-state"
      prefix = "${get_env("GOOGLE_PROJECT", "k8s-builder")}"
    }
  }
}
kops_store = "kops-cluster-store"
