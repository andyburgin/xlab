variable "staging_env" {
  description = "Staging environments settings"
  default = {
    "name" = "staging"
    "image" = "nginx:1.25-alpine-slim"
  }
}