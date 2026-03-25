# variables.tf

variable "project_id" {
  description = "GCP project ID to create — must be globally unique"
  type        = string
}

variable "billing_account_id" {
  description = "GCP billing account ID (from: gcloud billing accounts list)"
  type        = string
  sensitive   = true   # won't print in logs
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "dataset_location" {
  type    = string
  default = "US"
}

variable "environment" {
  type    = string
  default = "dev"
}