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
  default = [ "dev", "staging"]
}

// Map of environment to NodePort
variable "env_nodeport" {
  description = "NodePort map for each environment"
  default = { 
    "dev" = 30201
    "staging" = 30202
  }
}

// Map of environment to Label
variable "env_applabel" {
  description = "Label map for each environment"
  default = { 
    "dev" = "DevNginx"
    "staging" = "StagingNginx"
  }
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

resource "kubernetes_deployment" "deployment" {
  for_each = toset(var.environments)
  metadata {
    name      = "${each.key}-nginx"
    namespace = "dev"
    labels = {
      App = var.env_applabel[each.key]
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = var.env_applabel[each.key]
      }
    }
    template {
      metadata {
        labels = {
          App = var.env_applabel[each.key]
        }
      }
      spec {
        container {
          image = "nginx"
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
    name      = "${each.key}-nginx"
    namespace = "dev"
  }
  spec {
    selector = {
      App = var.env_applabel[each.key]
    }
    port {
      node_port   = var.env_nodeport[each.key]
      port        = 80
      target_port = 80
    }

    type = "NodePort"
  }
}
