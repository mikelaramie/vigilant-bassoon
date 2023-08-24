resource "kubernetes_service" "user_service" {
  metadata {
    name      = "userservice"
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
      "app"         = "userservice"
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

resource "kubernetes_deployment" "user_service" {
  depends_on = [
    kubernetes_config_map.environment_config,
    kubernetes_config_map.accounts_db_config,
    kubernetes_service_account.bank_of_anthos,
    kubernetes_secret.jwt_key
  ]
  metadata {
    name      = "userservice"
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
        "app"         = "userservice"
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
          "app"         = "userservice"
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
            name  = "TOKEN_EXPIRY_SECONDS"
            value = "3600"
          }
          env {
            name  = "PRIV_KEY_PATH"
            value = "/tmp/.ssh/privatekey"
          }
          env {
            name  = "LOG_LEVEL"
            value = "info"
          }
          name  = "userservice"
          image = "us-central1-docker.pkg.dev/bank-of-anthos-ci/bank-of-anthos/userservice:v0.6.1@sha256:b73e5b03c077ff1e7214885b986f6e9ecb444f78d206c4d3864265449c71b19b"
          port {
            container_port = 8080
            name           = "http-server"
          }
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
              cpu               = "500m"
              ephemeral-storage = "0.25Gi"
              memory            = "256Mi"
            }
            requests = {
              cpu               = "260m"
              ephemeral-storage = "0.25Gi"
              memory            = "128Mi"
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
            name       = "keys"
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
          name = "keys"
          secret {
            secret_name = "jwt-key"
            items {
              key  = "jwtRS256.key"
              path = "privatekey"
            }
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
