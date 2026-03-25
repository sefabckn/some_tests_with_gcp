# main.tf

terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  region = var.region
  # No project here — we don't have one yet
}

# ── Create the project ─────────────────────────────────
resource "google_project" "streamtalk" {
  name            = "StreamTalk Analytics"
  project_id      = var.project_id
  billing_account = var.billing_account_id
}

resource "google_project_iam_member" "owner" {
  project = google_project.streamtalk.project_id
  role    = "roles/owner"
  member  = "user:afesbckn@gmail.com"
}

# ── Activate BigQuery API on the new project ───────────
resource "google_project_service" "bigquery" {
  project = google_project.streamtalk.project_id
  service = "bigquery.googleapis.com"

  disable_on_destroy = false
}

# ── Activate GCS API ───────────────────────────────────
resource "google_project_service" "storage" {
  project = google_project.streamtalk.project_id
  service = "storage.googleapis.com"

  disable_on_destroy = false
}