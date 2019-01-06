terragrunt = {
  remote_state {
    backend = "gcs"
    config {
      bucket = "tf-backend-state"
      prefix = "k8s-builder"
    }
  }
}
service-account = "tf-cli"
# Cause they never get deleted so you need a unique one
key-ring-name = "tf-state-key-ring-1"
