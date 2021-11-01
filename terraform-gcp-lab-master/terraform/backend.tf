terraform {
  backend "gcs" {
    bucket = "terraform-backend-train-cl"
    prefix = "terraform/state"
  }
}
