output "services" {
  description = "Information about deployed services"
  value = {
    immich = {
      url = "http://${var.domain}:3001"
      description = "Photo and video backup"
    }
    shoko_anime = {
      url = "http://${var.domain}:8111"
      description = "Anime server"
    }
    pixivfe = {
      url = "http://${var.domain}:3002"
      description = "Pixiv frontend"
    }
    jellyfin = {
      url = "http://${var.domain}:8096"
      description = "Media server"
    }
    navidrome = {
      url = "http://${var.domain}:4533"
      description = "Music server"
    }
    feishin = {
      url = "http://${var.domain}:3003"
      description = "Music player frontend"
    }
    komga = {
      url = "http://${var.domain}:8080"
      description = "Comics/Manga server"
    }
    nginx_proxy = {
      url = "http://${var.domain}"
      description = "Reverse proxy"
    }
  }
}

output "network_name" {
  description = "Name of the Docker network"
  value       = docker_network.nas_network.name
}

output "container_names" {
  description = "Names of all deployed containers"
  value = [
    docker_container.immich.name,
    docker_container.immich_postgres.name,
    docker_container.immich_redis.name,
    docker_container.shoko_anime.name,
    docker_container.pixivfe.name,
    docker_container.jellyfin.name,
    docker_container.navidrome.name,
    docker_container.feishin.name,
    docker_container.komga.name,
    docker_container.nginx_proxy.name
  ]
}

output "storage_paths" {
  description = "Storage paths used by containers"
  value = {
    media_path = var.media_path
    appdata_path = var.appdata_path
  }
}
