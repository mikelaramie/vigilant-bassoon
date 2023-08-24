resource "kubernetes_service" "ledger_writer" {
  metadata {
    name      = "ledgerwriter"
    namespace = var.namespace
    labels = {
      "application" = "bank-of-anthos"
      "environment" = "development"
      "team"        = "ledger"
      "tier"        = "backend"
    }
  }
  spec {
    selector = {
      "app"         = "ledgerwriter"
      "application" = "bank-of-anthos"
      "environment" = "development"
      "team"        = "ledger"
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

resource "kubernetes_deployment" "ledger_writer" {
  depends_on = [
    kubernetes_config_map.environment_config,
    kubernetes_config_map.service_api_config,
    kubernetes_config_map.ledger_db_config,
    kubernetes_service_account.bank_of_anthos,
    kubernetes_secret.jwt_key
  ]
  metadata {
    name      = "ledgerwriter"
    namespace = var.namespace
    labels = {
      "application" = "bank-of-anthos"
      "environment" = "development"
      "team"        = "ledger"
      "tier"        = "backend"
    }
  }
  spec {
    selector {
      match_labels = {
        "app"         = "ledgerwriter"
        "application" = "bank-of-anthos"
        "environment" = "development"
        "team"        = "ledger"
        "tier"        = "backend"
      }
    }
    template {
      metadata {
        annotations = {
          "proxy.istio.io/config" = "'{ \"holdApplicationUntilProxyStarts\": true }'"
        }
        labels = {
          "app"         = "ledgerwriter"
          "application" = "bank-of-anthos"
          "environment" = "development"
          "team"        = "ledger"
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
              name = "service-api-config"
            }
          }
          env_from {
            config_map_ref {
              name = "ledger-db-config"
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
            name  = "ENABLE_METRICS"
            value = "true" //TODO
          }
          env {
            name  = "JVM_OPTS"
            value = "-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -Xms256m -Xmx512m"
          }
          env {
            name  = "LOG_LEVEL"
            value = "info"
          }
          env {
            name = "NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
          name  = "ledgerwriter"
          image = "us-central1-docker.pkg.dev/bank-of-anthos-ci/bank-of-anthos/ledgerwriter:v0.6.1@sha256:5087bc9f032dee70fda80063d659c3e1e34c7058c8b650d2128a8bdbbd4e5f4d"
          readiness_probe {
            http_get {
              path = "/ready"
              port = 8080
            }
            initial_delay_seconds = 60
            period_seconds        = 5
            timeout_seconds       = 10
          }
          resources {
            limits = {
              cpu               = "500m"
              ephemeral-storage = "0.5Gi"
              memory            = "512Mi"
            }
            requests = {
              cpu               = "100m"
              ephemeral-storage = "0.5Gi"
              memory            = "256Mi"
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
          startup_probe {
            failure_threshold = 30
            http_get {
              path = "/ready"
              port = 8080
            }
            period_seconds = 10
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
