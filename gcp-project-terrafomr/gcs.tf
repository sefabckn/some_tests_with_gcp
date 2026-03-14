# gcs.tf

resource "google_storage_bucket" "data_lake" {
  project       = google_project.streamtalk.project_id
  name          = "${var.project_id}-streamtalk-data"
  location      = var.region
  force_destroy = true

  depends_on = [google_project_service.storage]

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition { age = 30 }
    action    { type = "Delete" }
  }

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}