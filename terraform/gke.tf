resource "google_service_account" "k8s_sa" {
  account_id   = "k8s-node-sa"
  display_name = "GKE Node Service Account"
}

resource "google_container_cluster" "primary" {
  name     = "k8s-learning-cluster"
  location = var.region

  # We can't create a cluster with no node pool defined, but we want to remove the default one.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  ip_allocation_policy {
    cluster_secondary_range_name  = "k8s-pod-range"
    services_secondary_range_name = "k8s-service-range"
  }
  
  # Workload Identity is best practice
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Private cluster configuration is recommended but adds complexity (requires bastion/VPN).
  # For learning, we'll keep public endpoint but restrict access if needed.
  # private_cluster_config { ... }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "k8s-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.k8s_sa.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
