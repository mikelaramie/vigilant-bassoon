// Check for appropriate APIs enabled
resource "google_project_service" "gcp_gke_services" {
  for_each           = toset(var.gcp_gke_service_list)
  service            = each.key
  disable_on_destroy = false
}

// Networks 
resource "google_compute_network" "gke-cluster-01-network" {
  name                    = "gke-cluster-01-net"
  auto_create_subnetworks = true
  routing_mode            = "GLOBAL"
  depends_on              = [google_project_service.gcp_gke_services]
}

// TODO: Remap to use the google kubernetes-engine module
resource "google_service_account" "gke-cluster-01" {
  account_id   = "gke-cluster-01"
  display_name = "GKE Cluster 01 SA"
  depends_on   = [google_project_service.gcp_gke_services]
}

resource "google_project_iam_member" "gke-cluster-01-trace" {
  project = var.project_id
  role    = "roles/cloudtrace.agent"
  member  = "serviceAccount:${google_service_account.gke-cluster-01.email}"
}

resource "google_container_cluster" "gke-cluster-01" {
  name                     = "cluster-01"
  location                 = var.zone
  remove_default_node_pool = true
  initial_node_count       = 2
  networking_mode          = "VPC_NATIVE"
  network                  = google_compute_network.gke-cluster-01-network.name
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "" //defaults to /14
    services_ipv4_cidr_block = "" //defaults to /14
  }
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "public"
    }
  }
}

resource "google_container_node_pool" "gke-project-01-cluster-01-pool-01" {
  name               = "pool-01"
  location           = var.zone
  cluster            = google_container_cluster.gke-cluster-01.name
  initial_node_count = 2

  autoscaling {
    min_node_count = 2
    max_node_count = 3
  }

  node_config {
    preemptible     = false //set to false if you want stable hosts
    machine_type    = "e2-standard-4"
    image_type      = "cos_containerd"
    service_account = google_service_account.gke-cluster-01.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

// Outputs
output "gke-project-01-cluster-01-kubectl-command" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.gke-cluster-01.name} --zone ${google_container_cluster.gke-cluster-01.location} --project ${var.project_id}"
}
