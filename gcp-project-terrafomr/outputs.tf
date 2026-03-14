# outputs.tf

output "project_id" {
  value = google_project.streamtalk.project_id
}

output "dataset_id" {
  value = google_bigquery_dataset.streamtalk.dataset_id
}

output "bucket_name" {
  value = google_storage_bucket.data_lake.name
}