module "bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 2.1.0"

  name       = var.bucketname
  project_id = var.project
  location   = var.region
  iam_members = [{
    role   = "roles/storage.objectViewer"
    member = join(":", ["serviceAccount", data.google_compute_default_service_account.service_account.email])
  }]
  force_destroy = true
}

resource "google_storage_bucket_object" "html" {
  name   = var.indexname
  source = var.sitepath
  bucket = var.bucketname

  depends_on = [module.bucket]
}
