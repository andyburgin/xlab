terraform {
     required_version = ">= 1.2.5"
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_deployment" "deployment" {
  metadata {
    name      = "nginx"
    namespace = var.namespace
    labels = {
      App = "Nginx"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "Nginx"
      }
    }
    template {
      metadata {
        labels = {
          App = "Nginx"
        }
      }
      spec {
        container {
          image = var.image
          name  = var.namespace

          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "svc" {
  metadata {
    name      = "nginx"
    namespace = var.namespace
  }
  spec {
    selector = {
      App = "Nginx"
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}