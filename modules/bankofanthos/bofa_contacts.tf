resource "kubernetes_service" "contacts" {
  metadata {
    name      = "contacts"
    namespace = var.namespace
    labels = {
      "application" = "bank-of-anthos"
      "environment" = "development"
      "team"        = "accounts"
      "tier"        = "backend"
    }
  }
  spec {
    selector = {
      "app"         = "contacts"
      "application" = "bank-of-anthos"
      "environment" = "development"
      "team"        = "accounts"
      "tier"        = "backend"
    }
    port {
      name        = "http"
      port        = 8080
      target_port = 8080
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "contacts" {
  depends_on = [
    kubernetes_config_map.environment_config,
    kubernetes_config_map.accounts_db_config,
    kubernetes_service_account.bank_of_anthos,
    kubernetes_secret.jwt_key
  ]
  metadata {
    name      = "contacts"
    namespace = var.namespace
    labels = {
      "application" = "bank-of-anthos"
      "environment" = "development"
      "team"        = "accounts"
      "tier"        = "backend"
    }
  }
  spec {
    selector {
      match_labels = {
        "app"         = "contacts"
        "application" = "bank-of-anthos"
        "environment" = "development"
        "team"        = "accounts"
        "tier"        = "backend"
      }
    }
    template {
      metadata {
        annotations = {
          "proxy.istio.io/config" = "'{ \"holdApplicationUntilProxyStarts\": true }'"
        }
        labels = {
          "app"         = "contacts"
          "application" = "bank-of-anthos"
          "environment" = "development"
          "team"        = "accounts"
          "tier"        = "backend"
        }
      }
      spec {
        container {
          env_from {
            config_map_ref {
              name = "environment-config"
            }
          }
          env_from {
            config_map_ref {
              name = "accounts-db-config"
            }
          }
          env {
            name  = "VERSION"
            value = "v0.6.1" //TODO
          }
          env {
            name  = "PORT"
            value = "8080"
          }
          env {
            name  = "ENABLE_TRACING"
            value = "true" //TODO
          }
          env {
            name  = "LOG_LEVEL"
            value = "info"
          }
          name  = "contacts"
          image = "us-central1-docker.pkg.dev/bank-of-anthos-ci/bank-of-anthos/contacts:v0.6.1@sha256:b355abdaf59d23f5ab4ee08226fd1296dce8f764892ae3916a420d9d6bb20db4"
          readiness_probe {
            http_get {
              path = "/ready"
              port = 8080
            }
            initial_delay_seconds = 10
            period_seconds        = 5
            timeout_seconds       = 10
          }
          resources {
            limits = {
              cpu               = "250m"
              ephemeral-storage = "0.25Gi"
              memory            = "128Mi"
            }
            requests = {
              cpu               = "100m"
              ephemeral-storage = "0.25Gi"
              memory            = "64Mi"
            }
          }
          security_context {
            allow_privilege_escalation = false
            capabilities {
              drop = [
                "all"
              ]
            }
            privileged                = false
            read_only_root_filesystem = true
          }
          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }
          volume_mount {
            name       = "publickey"
            mount_path = "/tmp/.ssh"
            read_only  = true
          }
        }
        security_context {
          fs_group        = 1000
          run_as_group    = 1000
          run_as_non_root = true
          run_as_user     = 1000
        }
        service_account_name             = "bank-of-anthos"
        termination_grace_period_seconds = 5
        volume {
          name = "tmp"
          empty_dir {}
        }
        volume {
          name = "publickey"
          secret {
            secret_name = "jwt-key"
            items {
              key  = "jwtRS256.key.pub"
              path = "publickey"
            }
          }
        }
      }
    }
  }
}
