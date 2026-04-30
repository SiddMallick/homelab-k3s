variable "omv_server_ip" {
  type        = string
  description = "OpenMediaVault server IP"
  sensitive   = true
}

variable "omv_nfs_share_path" {
  type        = string
  description = "OpenMediaVault NFS Share Path"
  default     = "/export/media-nfs-jellyfin"
}

variable "cloudflare_api_key" {
  type        = string
  description = "Cloudflare API Key"
  sensitive   = true
}

variable "cloudflare_email_id" {
  type        = string
  description = "Cloudflare Email Address"
  sensitive   = true
}

variable "tailscale_oauth_clientid" {
  type        = string
  description = "Tailscale Oauth client id"
  sensitive   = true
}

variable "tailscale_oauth_client_secret" {
  type        = string
  description = "Tailscale Oauth client secret"
  sensitive   = true
}