terraform {
  required_version = ">= 1.5"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = var.docker_host
}

# ---------- network and storage ----------
resource "docker_network" "main" {
  name = "shortener-net"
}

resource "docker_volume" "pgdata" {
  name = "shortener-tf-pgdata"
}

# ---------- images ----------
resource "docker_image" "postgres" {
  name         = "postgres:16-alpine"
  keep_locally = true
}

resource "docker_image" "prometheus" {
  name         = "prom/prometheus:latest"
  keep_locally = true
}

resource "docker_image" "grafana" {
  name         = "grafana/grafana:latest"
  keep_locally = true
}

resource "docker_image" "app" {
  name = "shortener-app:tf"
  build {
    context = "${path.module}/../app"
  }
  triggers = {
    src_hash = sha1(join("", [
      for f in fileset("${path.module}/../app/src", "**") :
      filesha1("${path.module}/../app/src/${f}")
    ]))
    pom_hash = filesha1("${path.module}/../app/pom.xml")
  }
}

# ---------- database ----------
resource "docker_container" "db" {
  name    = "shortener-db"
  image   = docker_image.postgres.image_id
  restart = "unless-stopped"

  env = [
    "POSTGRES_DB=shortener",
    "POSTGRES_USER=shortener",
    "POSTGRES_PASSWORD=${var.db_password}",
  ]

  networks_advanced {
    name    = docker_network.main.name
    aliases = ["db"]
  }

  volumes {
    volume_name    = docker_volume.pgdata.name
    container_path = "/var/lib/postgresql/data"
  }

  healthcheck {
    test     = ["CMD-SHELL", "pg_isready -U shortener -d shortener"]
    interval = "5s"
    timeout  = "3s"
    retries  = 10
  }
}

# ---------- application ----------
resource "docker_container" "app" {
  name    = "shortener-app"
  image   = docker_image.app.image_id
  restart = "unless-stopped"

  env = [
    "DB_URL=jdbc:postgresql://db:5432/shortener",
    "DB_USER=shortener",
    "DB_PASSWORD=${var.db_password}",
    "BASE_URL=http://localhost:${var.app_port}",
  ]

  ports {
    internal = 8080
    external = var.app_port
  }

  networks_advanced {
    name    = docker_network.main.name
    aliases = ["app"]
  }

  depends_on = [docker_container.db]
}

# ---------- monitoring ----------
resource "docker_container" "prometheus" {
  name    = "shortener-prometheus"
  image   = docker_image.prometheus.image_id
  restart = "unless-stopped"

  ports {
    internal = 9090
    external = var.prometheus_port
  }

  networks_advanced {
    name    = docker_network.main.name
    aliases = ["prometheus"]
  }

  upload {
    file    = "/etc/prometheus/prometheus.yml"
    content = file("${path.module}/../monitoring/prometheus.yml")
  }

  depends_on = [docker_container.app]
}

resource "docker_container" "grafana" {
  name    = "shortener-grafana"
  image   = docker_image.grafana.image_id
  restart = "unless-stopped"

  env = [
    "GF_SECURITY_ADMIN_USER=admin",
    "GF_SECURITY_ADMIN_PASSWORD=${var.grafana_admin_password}",
  ]

  ports {
    internal = 3000
    external = var.grafana_port
  }

  networks_advanced {
    name    = docker_network.main.name
    aliases = ["grafana"]
  }

  upload {
    file    = "/etc/grafana/provisioning/datasources/datasource.yml"
    content = file("${path.module}/../monitoring/grafana/provisioning/datasources/datasource.yml")
  }

  upload {
    file    = "/etc/grafana/provisioning/dashboards/dashboards.yml"
    content = file("${path.module}/../monitoring/grafana/provisioning/dashboards/dashboards.yml")
  }

  upload {
    file    = "/var/lib/grafana/dashboards/shortener.json"
    content = file("${path.module}/../monitoring/grafana/dashboards/shortener.json")
  }

  depends_on = [docker_container.prometheus]
}