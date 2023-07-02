variable "dev_env" {
  description = "Developemnt environments settings"
  default = {
    "name" = "dev"
    "image" = "nginx:latest"
  }
}