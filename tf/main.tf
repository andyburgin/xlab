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

// List of environments to be created
variable "environments" {
  description = "List of environments"
  default = [ "dev", "staging", "production"]
}

// Map of environment to image
variable "env_image" {
  description = "image map for each environment"
  default = { 
    "dev" = "nginx:latest"
    "staging" = "nginx:1.25-alpine-slim"
    "production" = "nginx:1.24-alpine-slim"
  }
}

provider "kubernetes" {
  host = var.host

  client_certificate     = base64decode(var.client_cert)
  client_key             = base64decode(var.client_key)
  cluster_ca_certificate = base64decode(var.cluster_cert)
}

resource "kubernetes_namespace" "namespace" {
  for_each = toset(var.environments)
  metadata {
    name = "${each.key}"
  }
}

resource "kubernetes_deployment" "deployment" {
  for_each = toset(var.environments)
  metadata {
    name      = "nginx"
    namespace = "${each.key}"
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
          image = var.env_image[each.key]
          name  = "${each.key}"

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
  for_each = toset(var.environments)
  metadata {
    name      = "nginx"
    namespace = "${each.key}"
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
