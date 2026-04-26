variable "omv_server_ip" {
  description = "OpenMediaVault server IP"
  sensitive   = true
}

variable "omv_nfs_share_path" {
  description = "OpenMediaVault NFS Share Path"
  default     = "/export/media-nfs-jellyfin"
}

variable "cloudflare_api_key" {
  description = "Cloudflare API Key"
  sensitive   = true
}

variable "cloudflare_email_id" {
  description = "Cloudflare Email Address"
  sensitive   = true
}