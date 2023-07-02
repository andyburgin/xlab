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

module "kubernetes_application" {
  source = "./modules/kubernetes_application"
  for_each = { for index, env in var.environments: env.name => env }

  namespace = each.value.name
  image = each.value.image
}