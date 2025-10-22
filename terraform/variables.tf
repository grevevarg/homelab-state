variable "domain" {
  description = "Domain name for the NAS"
  type        = string
  default     = "nas.ntsu.dev"
}

variable "media_path" {
  description = "Base path for media storage"
  type        = string
  default     = "/mnt/tank/media"
}

variable "appdata_path" {
  description = "Base path for application data"
  type        = string
  default     = "/mnt/tank/appdata"
}

variable "immich_password" {
  description = "Password for Immich database"
  type        = string
  sensitive   = true
}

variable "jellyfin_password" {
  description = "Password for Jellyfin admin user"
  type        = string
  sensitive   = true
}

variable "komga_password" {
  description = "Password for Komga admin user"
  type        = string
  sensitive   = true
}

variable "pixivfe_proxy_url" {
  description = "Proxy URL for PixivFE"
  type        = string
  default     = ""
}

variable "container_restart_policy" {
  description = "Restart policy for containers"
  type        = string
  default     = "unless-stopped"
}

variable "enable_ssl" {
  description = "Enable SSL/TLS for services"
  type        = bool
  default     = false
}

variable "ssl_cert_path" {
  description = "Path to SSL certificate"
  type        = string
  default     = ""
}

variable "ssl_key_path" {
  description = "Path to SSL private key"
  type        = string
  default     = ""
}
