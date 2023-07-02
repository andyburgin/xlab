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

module "kubernetes_application" {
  source = "./modules/kubernetes_application"
  for_each = toset(var.environments)
  namespace = "${each.key}"
  image = var.env_image[each.key]
}


