resource "kubernetes_service" "transaction_history" {
  metadata {
    name      = "transactionhistory"
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
      "app"         = "transactionhistory"
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

resource "kubernetes_deployment" "transaction_history" {
  depends_on = [
    kubernetes_config_map.environment_config,
    kubernetes_config_map.ledger_db_config,
    kubernetes_service_account.bank_of_anthos,
    kubernetes_secret.jwt_key
  ]
  metadata {
    name      = "transactionhistory"
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
        "app"         = "transactionhistory"
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
          "app"         = "transactionhistory"
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
            name  = "POLL_MS"
            value = "100"
          }
          env {
            name  = "CACHE_SIZE"
            value = "1000"
          }
          env {
            name  = "CACHE_MINUTES"
            value = "60"
          }
          env {
            name  = "HISTORY_LIMIT"
            value = "100"
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
          name  = "transactionhistory"
          image = "us-central1-docker.pkg.dev/bank-of-anthos-ci/bank-of-anthos/transactionhistory:v0.6.1@sha256:bba73286ab53f8adba4381562e1c0b6c9b6a69c331a5acb3133379c356b5672f"
          liveness_probe {
            http_get {
              path = "/healthy"
              port = 8080
            }
            initial_delay_seconds = 120
            period_seconds        = 5
            timeout_seconds       = 10
          }
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
              path = "/healthy"
              port = 8080
            }
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
