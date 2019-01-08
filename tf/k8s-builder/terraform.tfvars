terragrunt = {
  remote_state {
    backend = "gcs"
    config {
      bucket = "tf-backend-state"
      prefix = "k8s-builder"
    }
  }
}
project = "k8s-builder"
region = "us-west1"
service_account = "tf-cli"
