resource "kubernetes_namespace_v1" "dev-namespace" {
  metadata {
    name = "dev"
  }
}

# Install ArgoCD
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  cleanup_on_fail  = true
  values = [templatefile("${path.module}/templates/argocd/values.yaml", {
    argo_domain = "argocd.siddhomelab.cc"
  })]
}


resource "kubernetes_manifest" "argo_ingress" {
  depends_on = [helm_release.argocd]
  manifest = yamldecode(templatefile("${path.module}/templates/argocd/ingress.yaml", {
    namespace   = "argocd"
    argo_domain = "argocd.siddhomelab.cc"
  }))
}


# Install cert-manager

resource "helm_release" "cert_manager" {
  depends_on       = [helm_release.argocd]
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  cleanup_on_fail  = true
  values           = [file("${path.module}/templates/cert-manager/values.yaml")]
}

resource "kubernetes_secret_v1" "cloudflare_api_key" {
  metadata {
    name      = "cloudflare-api-token-secret"
    namespace = "cert-manager"
  }

  data = {
    "api-token" = var.cloudflare_api_key
  }

  type = "Opaque"
}


resource "kubernetes_manifest" "cluster_issuer" {
  depends_on = [helm_release.cert_manager, kubernetes_secret_v1.cloudflare_api_key ]

  manifest = yamldecode(templatefile("${path.module}/templates/cert-manager/clusterissuer.yaml", {
    email       = var.cloudflare_email_id
    secret-name = kubernetes_secret_v1.cloudflare_api_key.metadata[0].name
  }))
}
