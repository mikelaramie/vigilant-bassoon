// Check for appropriate APIs enabled
resource "google_project_service" "gcp-gar-services" {
  for_each           = toset(var.gcp_gar_service_list)
  service            = each.key
  disable_on_destroy = false
}

// Bank of Anthos Repo
data "google_artifact_registry_repository" "google-boa-repository" {
  project       = "bank-of-anthos-ci"
  location      = "us-central1"
  repository_id = "bank-of-anthos"
}

resource "google_artifact_registry_repository" "boa-repository" {
  location      = var.region
  repository_id = "bank-of-anthos"
  description   = "Mirror of Google's Bank of Anthos Repository"
  format        = "DOCKER"
  mode          = "VIRTUAL_REPOSITORY"
  virtual_repository_config {
    upstream_policies {
      id         = "bank-of-anthos-upstream"
      repository = data.google_artifact_registry_repository.google-boa-repository.id
      //id = "projects/bank-of-anthos-ci/locations/us-central1/repositories/bank-of-anthos"
      priority = 1
    }
  }
  depends_on = [google_project_service.gcp-gar-services]
}

resource "google_artifact_registry_repository_iam_member" "boa-member" {
  location   = google_artifact_registry_repository.boa-repository.location
  repository = google_artifact_registry_repository.boa-repository.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.gke-cluster-01.email}"
}

output "boa-repository-uri" {
  value = google_artifact_registry_repository.boa-repository.id
}


// Online Boutique Repo
/*
data "google_artifact_registry_repository" "google-ob-repository" {
  project = "google-samples"
  location = "us"
  repository_id = "microservices-demo"
}

resource "google_artifact_registry_repository" "ob-repository" {
  depends_on    = [google_project_service.gcp-gar-services]
  location      = var.region
  repository_id = "microservices-demo" //TODO: Update to bankofanthos and automate push/pull
  description   = "Mirror of Google's Online Boutique Repository"
  format        = "DOCKER"
  mode = "VIRTUAL_REPOSITORY"
  virtual_repository_config {
    upstream_policies {
      id = data.google_artifact_registry_repository.google-ob-repository.id
      //id = "projects/bank-of-anthos-ci/locations/us-central1/repositories/bank-of-anthos"
      priority = 1
    }
  }
}

resource "google_artifact_registry_repository_iam_member" "ob-member" {
  location = google_artifact_registry_repository.ob-repository.location
  repository = google_artifact_registry_repository.ob-repository.name
  role = "roles/artifactregistry.reader"
  member = "serviceaccount:${google_service_account.gke-cluster-01.email}"
}

output "ob-repository-uri" {
  value = google_artifact_registry_repository.ob-repository.id
}
*/