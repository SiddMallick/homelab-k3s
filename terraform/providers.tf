# Standard Kubernetes provider
provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "proxmox-k3s"
}

# Helm provider for installing Traefik, ArgoCD, etc.
provider "helm" {
  kubernetes = {
    config_path    = "~/.kube/config"
    config_context = "proxmox-k3s"
  }
}