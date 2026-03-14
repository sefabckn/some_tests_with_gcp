# bigquery.tf

resource "google_bigquery_dataset" "streamtalk" {
  project       = google_project.streamtalk.project_id
  dataset_id    = "streamtalk"
  friendly_name = "StreamTalk Analytics"
  description   = "Product analytics dataset"
  location      = var.dataset_location

  # Won't run until project exists AND bigquery API is enabled
  depends_on = [google_project_service.bigquery]

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }

  delete_contents_on_destroy = true
}

resource "google_bigquery_table" "users" {
  project             = google_project.streamtalk.project_id
  dataset_id          = google_bigquery_dataset.streamtalk.dataset_id
  table_id            = "users"
  deletion_protection = false
  schema              = file("${path.module}/../sql/schemas/users.json")
}

resource "google_bigquery_table" "streams" {
  project             = google_project.streamtalk.project_id
  dataset_id          = google_bigquery_dataset.streamtalk.dataset_id
  table_id            = "streams"
  deletion_protection = false
  schema              = file("${path.module}/../sql/schemas/streams.json")
}

resource "google_bigquery_table" "sessions" {
  project             = google_project.streamtalk.project_id
  dataset_id          = google_bigquery_dataset.streamtalk.dataset_id
  table_id            = "sessions"
  deletion_protection = false
  schema              = file("${path.module}/../sql/schemas/sessions.json")
}

resource "google_bigquery_table" "events" {
  project             = google_project.streamtalk.project_id
  dataset_id          = google_bigquery_dataset.streamtalk.dataset_id
  table_id            = "events"
  deletion_protection = false
  schema              = file("${path.module}/../sql/schemas/events.json")

  time_partitioning {
    type  = "DAY"
    field = "event_ts"
  }
}

resource "google_bigquery_table" "gifts" {
  project             = google_project.streamtalk.project_id
  dataset_id          = google_bigquery_dataset.streamtalk.dataset_id
  table_id            = "gifts"
  deletion_protection = false
  schema              = file("${path.module}/../sql/schemas/gifts.json")
}