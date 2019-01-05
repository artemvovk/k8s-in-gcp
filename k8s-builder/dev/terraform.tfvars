terragrunt = {
  remote_state {
    backend = "gcs"
    config {
      bucket = "tf-backend-state"
      prefix = "k8s-builder"
    }
  }
}
