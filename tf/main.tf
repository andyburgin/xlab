terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

variable "host" {
  type = string
}


variable "client_cert" {
  type = string
}

variable "client_key" {
  type = string
}

variable "cluster_cert" {
  type = string
}

provider "kubernetes" {
  host = var.host

  client_certificate     = base64decode(var.client_cert)
  client_key             = base64decode(var.client_key)
  cluster_ca_certificate = base64decode(var.cluster_cert)
}

resource "kubernetes_namespace" "dev_namespace" {
  metadata {
    name = "dev"
  }
}

resource "kubernetes_deployment" "dev_nginx" {
  metadata {
    name      = "dev-nginx"
    namespace = "dev"
    labels = {
      App = "DevNginx"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "DevNginx"
      }
    }
    template {
      metadata {
        labels = {
          App = "DevNginx"
        }
      }
      spec {
        container {
          image = "nginx"
          name  = "dev"

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

resource "kubernetes_service" "dev_nginx" {
  metadata {
    name      = "dev-nginx"
    namespace = "dev"
  }
  spec {
    selector = {
      App = kubernetes_deployment.dev_nginx.spec.0.template.0.metadata[0].labels.App
    }
    port {
      node_port   = 30201
      port        = 80
      target_port = 80
    }

    type = "NodePort"
  }
}

resource "kubernetes_deployment" "stg_nginx" {
  metadata {
    name      = "staging-nginx"
    namespace = "dev"
    labels = {
      App = "StagingNginx"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "StagingNginx"
      }
    }
    template {
      metadata {
        labels = {
          App = "StagingNginx"
        }
      }
      spec {
        container {
          image = "nginx"
          name  = "staging"

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

resource "kubernetes_service" "stg_nginx" {
  metadata {
    name      = "staging-nginx"
    namespace = "dev"
  }
  spec {
    selector = {
      App = kubernetes_deployment.stg_nginx.spec.0.template.0.metadata[0].labels.App
    }
    port {
      node_port   = 30202
      port        = 80
      target_port = 80
    }

    type = "NodePort"
  }
}
