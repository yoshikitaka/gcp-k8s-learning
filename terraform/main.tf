terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  # Using local backend for initial setup. 
  # Migration to GCS backend is recommended for production/teams.
  backend "local" {}
}

provider "google" {
  project = var.project_id
  region  = var.region
}
