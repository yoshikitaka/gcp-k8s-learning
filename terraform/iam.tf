# Service Account for External Secrets Operator
resource "google_service_account" "eso_sa" {
  account_id   = "external-secrets-sa"
  display_name = "External Secrets Operator SA"
}

# Grant Secret Manager Access to the SA
resource "google_project_iam_member" "eso_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.eso_sa.email}"
}

# Workload Identity Binding
# Binds the Google SA to the K8s SA (external-secrets/external-secrets)
resource "google_service_account_iam_member" "eso_workload_identity" {
  service_account_id = google_service_account.eso_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[external-secrets/external-secrets]"
}

output "eso_service_account_email" {
  value = google_service_account.eso_sa.email
}
