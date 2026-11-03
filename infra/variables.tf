variable "docker_host" {
  type    = string
  default = "npipe:////./pipe/dockerDesktopLinuxEngine"
}

variable "app_port" {
  type    = number
  default = 8080
}

variable "grafana_port" {
  type    = number
  default = 3000
}

variable "prometheus_port" {
  type    = number
  default = 9090
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = "shortener"
}

variable "grafana_admin_password" {
  type      = string
  sensitive = true
  default   = "admin"
}