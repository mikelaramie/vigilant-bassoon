// Deploy Bank of Anthos
// TODO - Make this a module

resource "kubernetes_namespace" "bankofanthos" {
  count      = var.bankofanthos ? 1 : 0
  depends_on = [google_container_cluster.gke-cluster-01]
  metadata {
    name = "bankofanthos"
  }
}

resource "kubectl_manifest" "bankofanthos-secret" {
  count              = var.bankofanthos ? 1 : 0
  yaml_body          = file("${path.module}/helpers/bank-of-anthos/extras/jwt/jwt-secret.yaml")
  override_namespace = kubernetes_namespace.bankofanthos[0].metadata[0].name
}

data "kubectl_path_documents" "bankofanthos-manifests" {
  count   = var.bankofanthos ? 1 : 0
  pattern = "./helpers/bank-of-anthos/kubernetes-manifests/*.yaml"
}

resource "kubectl_manifest" "bankofanthos" {
  count              = var.bankofanthos ? length(data.kubectl_path_documents.bankofanthos-manifests[0].documents) : 0
  depends_on         = [kubectl_manifest.bankofanthos-secret[0]]
  yaml_body          = element(data.kubectl_path_documents.bankofanthos-manifests[0].documents, count.index)
  override_namespace = kubernetes_namespace.bankofanthos[0].metadata[0].name
}

data "kubernetes_ingress_v1" "bankofanthos" {
  count = var.bankofanthos ? 1 : 0
  metadata {
    name      = "frontend-ingress"
    namespace = kubernetes_namespace.bankofanthos[0].metadata[0].name
  }
}

// Add IAP
resource "kubernetes_secret" "bankofanthos-iap-oauth-client" {
  count = var.bankofanthos && var.enable_iap ? 1 : 0
  metadata {
    name      = "oauth-client"
    namespace = kubernetes_namespace.bankofanthos[0].metadata[0].name
  }

  data = {
    client_id     = google_iap_client.project_client[0].id
    client_secret = google_iap_client.project_client[0].secret
  }
}

resource "kubernetes_manifest" "iap-backendconfig" {
  depends_on = [kubernetes_namespace.bankofanthos]
  count      = var.bankofanthos && var.enable_iap ? 1 : 0
  manifest = {
    "apiVersion" = "cloud.google.com/v1"
    "kind"       = "BackendConfig"
    "metadata" = {
      "name"      = "config-iap"
      "namespace" = kubernetes_namespace.bankofanthos[0].metadata[0].name
    }
    "spec" = {
      "iap" = {
        "enabled" = "true"
        "oauthclientCredentials" = {
          "secretName" = "oauth-client"
        }
      }
    }
  }
}

output "bankofanthos-frontend" {
  value = var.bankofanthos ? "http://${data.kubernetes_ingress_v1.bankofanthos[0].status[0].load_balancer[0].ingress[0].ip}" : null
}
