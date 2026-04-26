output "argocd_admin_password" {
  description = "The initial password for the ArgoCD admin user"
  value       = data.kubernetes_secret_v1.argocd_initial_admin_secret.data["password"]
  sensitive   = true
}