resource "kubernetes_config_map" "ledger_db_config" {
  metadata {
    name      = "ledger-db-config"
    namespace = var.namespace
    labels = {
      "app"         = "postgres"
      "application" = "bank-of-anthos"
      "environment" = "development"
      "team"        = "ledger"
      "tier"        = "db"
    }
  }

  data = {
    "POSTGRES_DB"                = "postgresdb"
    "POSTGRES_PASSWORD"          = "password"
    "POSTGRES_USER"              = "admin"
    "SPRING_DATASOURCE_PASSWORD" = "password"
    "SPRING_DATASOURCE_URL"      = "jdbc:postgresql://ledger-db:5432/postgresdb"
    "SPRING_DATASOURCE_USERNAME" = "admin"
  }
}

resource "kubernetes_service" "ledger_db_service" {
  metadata {
    name      = "ledger-db"
    namespace = var.namespace
    labels = {
      "environment" = "development"
    }
  }
  spec {
    selector = {
      app         = "ledger-db"
      environment = "development"
    }
    port {
      port        = 5432
      target_port = 5432
    }
    type = "ClusterIP"
  }
}


resource "kubernetes_stateful_set" "ledger_db_statefulset" {
  depends_on = [
    kubernetes_config_map.environment_config,
    kubernetes_config_map.ledger_db_config,
    kubernetes_config_map.demo_data_config
  ] 
  metadata {
    name      = "ledger-db"
    namespace = var.namespace
    labels = {
      "environment" = "development"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app         = "ledger-db"
        environment = "development"
      }
    }
    service_name = "ledger-db"
    template {
      metadata {
        labels = {
          app         = "ledger-db"
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
              name = "ledger-db-config"
            }
          }
          env_from {
            config_map_ref {
              name = "demo-data-config"
            }
          }
          name  = "postgres"
          image = "us-central1-docker.pkg.dev/bank-of-anthos-ci/bank-of-anthos/ledger-db:v0.6.1@sha256:2fe07029725a4ae2cf7beaec17dbdd6f8fc11caa8a9725708b42a603532e7b84"
          port {
            container_port = 5432
          }
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

