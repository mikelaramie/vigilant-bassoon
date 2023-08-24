resource "kubernetes_deployment" "loadgenerator" {
  metadata {
    name      = "loadgenerator"
    namespace = var.namespace
    labels = {
      "environment" = "development"
      "team"        = "loadgenerator"
      "tier"        = "test"
    }
  }
  spec {
    selector {
      match_labels = {
        "app"         = "loadgenerator"
        "environment" = "development"
        "team"        = "loadgenerator"
        "tier"        = "test"
      }
    }
    template {
      metadata {
        annotations = {
          "sidecar.istio.io/rewriteAppHTTPProbers" = "true"
        }
        labels = {
          "app"         = "loadgenerator"
          "environment" = "development"
          "team"        = "loadgenerator"
          "tier"        = "test"
        }
      }
      spec {
        container {
          env {
            name  = "FRONTEND_ADDR"
            value = "frontend:80"
          }
          env {
            name  = "USERS"
            value = "5"
          }
          env {
            name  = "LOG_LEVEL"
            value = "error"
          }
          name  = "loadgenerator"
          image = "us-central1-docker.pkg.dev/bank-of-anthos-ci/bank-of-anthos/loadgenerator:v0.6.1@sha256:3bb01473ed1b71b97e0a9c77f1e16db2f8e281344add5fb53d2bb2d889158f46"
          resources {
            limits = {
              cpu    = "250m"
              memory = "1Gi"
            }
            requests = {
              cpu    = "100m"
              memory = "512Mi"
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
        }
        restart_policy = "Always"
        security_context {
          fs_group        = 1000
          run_as_group    = 1000
          run_as_non_root = true
          run_as_user     = 1000
        }
        service_account_name             = "default"
        termination_grace_period_seconds = 5
      }
    }
  }
}
