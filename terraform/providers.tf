# Standard Kubernetes provider
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Helm provider for installing Traefik, ArgoCD, etc.
provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
    config_context = "default"
  }
}