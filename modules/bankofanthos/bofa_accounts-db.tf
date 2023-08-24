resource "kubernetes_config_map" "accounts_db_config" {
  metadata {
    name      = "accounts-db-config"
    namespace = var.namespace
    labels = {
      "app"         = "accounts-db"
      "application" = "bank-of-anthos"
      "environment" = "development"
      "team"        = "accounts"
      "tier"        = "db"
    }
  }

  data = {
    "ACCOUNTS_DB_URI"   = "postgresql://accounts-admin:accounts-pwd@accounts-db:5432/accounts-db"
    "POSTGRES_DB"       = "accounts-db"
    "POSTGRES_PASSWORD" = "accounts-pwd"
    "POSTGRES_USER"     = "accounts-admin"
  }
}

resource "kubernetes_service" "accounts_db_service" {
  metadata {
    name      = "accounts-db"
    namespace = var.namespace
    labels = {
      "environment" = "development"
    }
  }
  spec {
    selector = {
      app         = "accounts-db"
      environment = "development"
    }
    port {
      port        = 5432
      target_port = 5432
    }
    type = "ClusterIP"
  }
}


resource "kubernetes_stateful_set" "accounts_db_statefulset" {
  depends_on = [
    kubernetes_config_map.environment_config,
    kubernetes_config_map.accounts_db_config,
    kubernetes_config_map.demo_data_config
  ]
  metadata {
    name      = "accounts-db"
    namespace = var.namespace
    labels = {
      "environment" = "development"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app         = "accounts-db"
        environment = "development"
      }
    }
    service_name = "accounts-db"
    template {
      metadata {
        labels = {
          app         = "accounts-db"
          environment = "development"
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
          env_from {
            config_map_ref {
              name = "demo-data-config"
            }
          }
          name  = "accounts-db"
          image = "us-central1-docker.pkg.dev/bank-of-anthos-ci/bank-of-anthos/accounts-db:v0.6.1@sha256:7c4cf161904b4ef869cc8796d7b5bcde1dda6f861898c0cfed6afd4e4affe659"
          port {
            container_port = 5432
          }
          resources {
            limits = {
              cpu    = "250m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }
          volume_mount {
            name       = "postgresdb"
            mount_path = "/var/lib/postgresql/data"
            sub_path   = "postgres"
          }
        }
        service_account_name = "default"
        volume {
          name = "postgresdb"
          empty_dir {}
        }
      }
    }
  }
}

