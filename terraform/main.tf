terraform {
  required_version = ">= 1.0"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Create a custom network for the containers
resource "docker_network" "nas_network" {
  name = "nas_network"
  driver = "bridge"
}

# Immich - Photo and video backup
resource "docker_container" "immich" {
  name  = "immich"
  image = "ghcr.io/immich-app/immich-server:latest"
  
  networks_advanced {
    name = docker_network.nas_network.name
  }
  
  volumes {
    container_path = "/usr/src/app/upload"
    host_path      = "${var.media_path}/photos"
  }
  
  volumes {
    container_path = "/usr/src/app/data"
    host_path      = "${var.appdata_path}/immich"
  }
  
  env = [
    "NODE_ENV=production",
    "DB_HOSTNAME=immich-postgres",
    "DB_USERNAME=postgres",
    "DB_PASSWORD=${var.immich_password}",
    "DB_DATABASE_NAME=immich",
    "REDIS_HOSTNAME=immich-redis"
  ]
  
  ports {
    internal = 3001
    external = 3001
  }
  
  restart = var.container_restart_policy
  
  depends_on = [
    docker_container.immich_postgres,
    docker_container.immich_redis
  ]
}

# Immich PostgreSQL
resource "docker_container" "immich_postgres" {
  name  = "immich-postgres"
  image = "postgres:15"
  
  networks_advanced {
    name = docker_network.nas_network.name
  }
  
  volumes {
    container_path = "/var/lib/postgresql/data"
    host_path      = "${var.appdata_path}/immich/postgres"
  }
  
  env = [
    "POSTGRES_DB=immich",
    "POSTGRES_USER=postgres",
    "POSTGRES_PASSWORD=${var.immich_password}"
  ]
  
  restart = var.container_restart_policy
}

# Immich Redis
resource "docker_container" "immich_redis" {
  name  = "immich-redis"
  image = "redis:7-alpine"
  
  networks_advanced {
    name = docker_network.nas_network.name
  }
  
  volumes {
    container_path = "/data"
    host_path      = "${var.appdata_path}/immich/redis"
  }
  
  restart = var.container_restart_policy
}

# Shoko Anime Server
resource "docker_container" "shoko_anime" {
  name  = "shoko-anime"
  image = "shokoanime/server:latest"
  
  networks_advanced {
    name = docker_network.nas_network.name
  }
  
  volumes {
    container_path = "/home/shoko/.shoko"
    host_path      = "${var.appdata_path}/shoko"
  }
  
  volumes {
    container_path = "/home/shoko/Anime"
    host_path      = "${var.media_path}/anime"
  }
  
  ports {
    internal = 8111
    external = 8111
  }
  
  ports {
    internal = 8112
    external = 8112
  }
  
  restart = var.container_restart_policy
}

# PixivFE
resource "docker_container" "pixivfe" {
  name  = "pixivfe"
  image = "vnpower/pixivfe:latest"
  
  networks_advanced {
    name = docker_network.nas_network.name
  }
  
  ports {
    internal = 3002
    external = 3002
  }
  
  env = [
    "PIXIVFE_PROXY_URL=${var.pixivfe_proxy_url}"
  ]
  
  restart = var.container_restart_policy
}

# Jellyfin
resource "docker_container" "jellyfin" {
  name  = "jellyfin"
  image = "jellyfin/jellyfin:latest"
  
  networks_advanced {
    name = docker_network.nas_network.name
  }
  
  volumes {
    container_path = "/config"
    host_path      = "${var.appdata_path}/jellyfin"
  }
  
  volumes {
    container_path = "/media"
    host_path      = var.media_path
  }
  
  ports {
    internal = 8096
    external = 8096
  }
  
  env = [
    "JELLYFIN_PublishedServerUrl=${var.domain}"
  ]
  
  restart = var.container_restart_policy
}

# Navidrome
resource "docker_container" "navidrome" {
  name  = "navidrome"
  image = "deluan/navidrome:latest"
  
  networks_advanced {
    name = docker_network.nas_network.name
  }
  
  volumes {
    container_path = "/music"
    host_path      = "${var.media_path}/music"
  }
  
  volumes {
    container_path = "/data"
    host_path      = "${var.appdata_path}/navidrome"
  }
  
  ports {
    internal = 4533
    external = 4533
  }
  
  env = [
    "ND_SCANSCHEDULE=1h",
    "ND_LOGLEVEL=info",
    "ND_BASEURL=/",
    "ND_PORT=4533"
  ]
  
  restart = var.container_restart_policy
}

# Feishin (Music player frontend)
resource "docker_container" "feishin" {
  name  = "feishin"
  image = "ghcr.io/jeffvli/feishin:latest"
  
  networks_advanced {
    name = docker_network.nas_network.name
  }
  
  ports {
    internal = 3003
    external = 3003
  }
  
  env = [
    "FEISHIN_URL=http://${var.domain}:3003",
    "JELLYFIN_URL=http://jellyfin:8096",
    "NAVIDROME_URL=http://navidrome:4533"
  ]
  
  restart = var.container_restart_policy
}

# Komga
resource "docker_container" "komga" {
  name  = "komga"
  image = "gotson/komga:latest"
  
  networks_advanced {
    name = docker_network.nas_network.name
  }
  
  volumes {
    container_path = "/data"
    host_path      = "${var.appdata_path}/komga"
  }
  
  volumes {
    container_path = "/books"
    host_path      = "${var.media_path}/books"
  }
  
  ports {
    internal = 8080
    external = 8080
  }
  
  env = [
    "KOMGA_LIBRARIES_SCAN_CRON=0 0 * * * *",
    "KOMGA_LIBRARIES_SCAN_STARTUP=true"
  ]
  
  restart = var.container_restart_policy
}

# Nginx reverse proxy
resource "docker_container" "nginx_proxy" {
  name  = "nginx-proxy"
  image = "nginx:alpine"
  
  networks_advanced {
    name = docker_network.nas_network.name
  }
  
  volumes {
    container_path = "/etc/nginx/nginx.conf"
    host_path      = "${path.module}/nginx.conf"
    read_only      = true
  }
  
  volumes {
    container_path = "/var/log/nginx"
    host_path      = "${var.appdata_path}/nginx/logs"
  }
  
  ports {
    internal = 80
    external = 80
  }
  
  ports {
    internal = 443
    external = 443
  }
  
  restart = var.container_restart_policy
  
  depends_on = [
    docker_container.immich,
    docker_container.shoko_anime,
    docker_container.pixivfe,
    docker_container.jellyfin,
    docker_container.navidrome,
    docker_container.feishin,
    docker_container.komga
  ]
}
