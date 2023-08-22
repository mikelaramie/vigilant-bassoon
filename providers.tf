terraform {
  required_version = ">= 0.13"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

data "google_client_config" "current" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.gke-cluster-01.endpoint}"
  token                  = data.google_client_config.current.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.gke-cluster-01.master_auth.0.cluster_ca_certificate)
}

provider "kubectl" {
  load_config_file       = false
  host                   = "https://${google_container_cluster.gke-cluster-01.endpoint}"
  token                  = data.google_client_config.current.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.gke-cluster-01.master_auth.0.cluster_ca_certificate)
}