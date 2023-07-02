variable "production_env" {
  description = "Production environments settings"
  default = {
    "name" = "production"
    "image" = "nginx:1.24-alpine-slim"
  }
}