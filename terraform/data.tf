data "kubernetes_secret_v1" "argocd_initial_admin_secret" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }

  # Ensure Terraform waits for the Helm chart to finish 
  # before trying to read the secret
  depends_on = [helm_release.argocd]
}