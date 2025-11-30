resource "google_artifact_registry_repository" "my-repo" {
  location      = var.region
  repository_id = "app-repo"
  description   = "Docker repository for GKE application"
  format        = "DOCKER"
}
