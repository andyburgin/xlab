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
  description = "List of environments and images"
  default = [{ 
    "name" = "dev"
    "image" = "nginx:latest"
  },{ 
    "name" = "staging"
    "image" = "nginx:1.25-alpine-slim"
  },{ 
    "name" = "production"
    "image" = "nginx:1.24-alpine-slim"
  }]
}
