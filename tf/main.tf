terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "kubernetes" {
  host = var.host

  client_certificate     = base64decode(var.client_cert)
  client_key             = base64decode(var.client_key)
  cluster_ca_certificate = base64decode(var.cluster_cert)
}

module "dev_kubernetes_application" {
  source = "./modules/kubernetes_application"
  namespace = var.dev_env.name
  image = var.dev_env.image
}

module "staging_kubernetes_application" {
  source = "./modules/kubernetes_application"
  namespace = var.staging_env.name
  image = var.staging_env.image
}

module "production_kubernetes_application" {
  source = "./modules/kubernetes_application"
  namespace = var.production_env.name
  image = var.production_env.image
}