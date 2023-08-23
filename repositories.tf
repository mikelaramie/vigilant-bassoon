// Check for appropriate APIs enabled
resource "google_project_service" "gcp-gar-services" {
  count              = (var.create_aoss_java_repository || var.create_aoss_python_repository || var.create_bankofanthos_repository) ? length(var.gcp_gar_service_list) : 0
  service            = element(var.gcp_gar_service_list, count.index)
  disable_on_destroy = false
}

// Bank of Anthos Repo
data "google_artifact_registry_repository" "google-boa-repository" {
  count         = var.create_bankofanthos_repository ? 1 : 0
  project       = "bank-of-anthos-ci"
  location      = "us-central1"
  repository_id = "bank-of-anthos"
}

resource "google_artifact_registry_repository" "boa-repository" {
  count         = var.create_bankofanthos_repository ? 1 : 0
  location      = var.region
  repository_id = "bank-of-anthos"
  description   = "Mirror of Google's Bank of Anthos Repository"
  format        = "DOCKER"
  mode          = "VIRTUAL_REPOSITORY"
  virtual_repository_config {
    upstream_policies {
      id         = "bank-of-anthos-upstream"
      repository = data.google_artifact_registry_repository.google-boa-repository[0].id
      //repository = "projects/bank-of-anthos-ci/locations/us-central1/repositories/bank-of-anthos"
      priority = 1
    }
  }
  depends_on = [google_project_service.gcp-gar-services]
}

resource "google_artifact_registry_repository_iam_member" "boa-member" {
  count      = var.create_bankofanthos_repository ? 1 : 0
  location   = google_artifact_registry_repository.boa-repository[0].location
  repository = google_artifact_registry_repository.boa-repository[0].name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.gke-cluster-01.email}"
}

output "boa-repository-uri" {
  value = var.create_bankofanthos_repository ? google_artifact_registry_repository.boa-repository[0].id : null
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

// AOSS Java Repo
resource "google_artifact_registry_repository" "aoss-java-repository" {
  count         = var.create_aoss_java_repository ? 1 : 0
  location      = "us"
  repository_id = "aoss-java"
  description   = "Pullthrough of Google's AOSS Java Repository"
  format        = "MAVEN"
  mode          = "VIRTUAL_REPOSITORY"
  virtual_repository_config {
    upstream_policies {
      id         = "aoss-java-upstream"
      repository = "projects/cloud-aoss/locations/us/repositories/cloud-aoss-java"
      priority   = 100
    }
  }
  depends_on = [google_project_service.gcp-gar-services]
}

resource "google_artifact_registry_repository_iam_member" "aoss-java-member" {
  count      = var.create_aoss_java_repository ? 1 : 0
  location   = google_artifact_registry_repository.aoss-java-repository[0].location
  repository = google_artifact_registry_repository.aoss-java-repository[0].name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.gke-cluster-01.email}"
}

output "aoss-java-repository-uri" {
  value = var.create_aoss_java_repository ? google_artifact_registry_repository.aoss-java-repository[0].id : null
}

// AOSS Python Repo
resource "google_artifact_registry_repository" "aoss-python-repository" {
  count         = var.create_aoss_python_repository ? 1 : 0
  location      = "us"
  repository_id = "aoss-python"
  description   = "Pullthrough of Google's AOSS Python Repository"
  format        = "PYTHON"
  mode          = "VIRTUAL_REPOSITORY"
  virtual_repository_config {
    upstream_policies {
      id         = "aoss-python-upstream"
      repository = "projects/cloud-aoss/locations/us/repositories/cloud-aoss-python"
      priority   = 100
    }
  }
  depends_on = [google_project_service.gcp-gar-services]
}

resource "google_artifact_registry_repository_iam_member" "aoss-python-member" {
  count      = var.create_aoss_python_repository ? 1 : 0
  location   = google_artifact_registry_repository.aoss-python-repository[0].location
  repository = google_artifact_registry_repository.aoss-python-repository[0].name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.gke-cluster-01.email}"
}

output "aoss-python-repository-uri" {
  value = var.create_aoss_python_repository ? google_artifact_registry_repository.aoss-python-repository[0].id : null
}
