resource "kubernetes_ingress_v1" "frontend" {
  metadata {
    name      = "frontend-ingress"
    namespace = var.namespace
    labels = {
      "application" = "bank-of-anthos"
      "environment" = "development"
      "team"        = "frontend"
      "tier"        = "web"
    }
  }
  spec {
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "frontend"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "frontend" {
  metadata {
    name      = "frontend"
    namespace = var.namespace
    labels = {
      "application" = "bank-of-anthos"
      "environment" = "development"
      "team"        = "frontend"
      "tier"        = "web"
    }
  }
  spec {
    selector = {
      "app"         = "frontend"
      "application" = "bank-of-anthos"
      "environment" = "development"
      "team"        = "frontend"
      "tier"        = "web"
    }
    port {
      name        = "frontend-http"
      port        = 80
      target_port = 8080
    }
    type = "NodePort"
  }
}

resource "kubernetes_deployment" "frontend" {
  depends_on = [
    kubernetes_config_map.environment_config,
    kubernetes_config_map.service_api_config,
    kubernetes_service_account.bank_of_anthos,
    kubernetes_secret.jwt_key
  ]
  metadata {
    name      = "frontend"
    namespace = var.namespace
    labels = {
      "application" = "bank-of-anthos"
      "environment" = "development"
      "team"        = "frontend"
      "tier"        = "web"
    }
  }
  spec {
    selector {
      match_labels = {
        "app"         = "frontend"
        "application" = "bank-of-anthos"
        "environment" = "development"
        "team"        = "frontend"
        "tier"        = "web"
      }
    }
    template {
      metadata {
        annotations = {
          "proxy.istio.io/config" = "'{ \"holdApplicationUntilProxyStarts\": true }'"
        }
        labels = {
          "app"         = "frontend"
          "application" = "bank-of-anthos"
          "environment" = "development"
          "team"        = "frontend"
          "tier"        = "web"
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
          env {
            name = "DEFAULT_USERNAME"
            value_from {
              config_map_key_ref {
                key  = "DEMO_LOGIN_USERNAME"
                name = "demo-data-config"
              }
            }
          }
          env {
            name = "DEFAULT_PASSWORD"
            value_from {
              config_map_key_ref {
                key  = "DEMO_LOGIN_PASSWORD"
                name = "demo-data-config"
              }
            }
          }
          env {
            name = "REGISTERED_OAUTH_CLIENT_ID"
            value_from {
              config_map_key_ref {
                key      = "DEMO_OAUTH_CLIENT_ID"
                name     = "oauth-config"
                optional = true
              }
            }
          }
          env {
            name = "ALLOWED_OAUTH_REDIRECTION_URI"
            value_from {
              config_map_key_ref {
                key      = "DEMO_OAUTH_REDIRECT_URI"
                name     = "oauth-config"
                optional = true
              }
            }
          }
          name  = "front"
          image = "us-central1-docker.pkg.dev/bank-of-anthos-ci/bank-of-anthos/frontend:v0.6.1@sha256:07cb2c7f9a08cf820a81d59670a59b53d183717ce998a035625f0441b24e7544"
          liveness_probe {
            http_get {
              path = "/ready"
              port = 8080
            }
            initial_delay_seconds = 60
            period_seconds        = 15
            timeout_seconds       = 30
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
              cpu    = "250m"
              memory = "128Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "64Mi"
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
