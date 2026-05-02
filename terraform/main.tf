resource "kubernetes_namespace_v1" "dev_namespace" {
  metadata {
    name = "apps-dev"
  }
}

resource "kubernetes_namespace_v1" "prod_namespace" {
  metadata {
    name = "apps-prod"
  }
}

# Install cert-manager

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  cleanup_on_fail  = true
  values           = [file("${path.module}/templates/cert-manager/values.yaml")]
}

resource "kubernetes_secret_v1" "cloudflare_api_key" {
  depends_on = [helm_release.cert_manager]

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
  depends_on = [helm_release.cert_manager, kubernetes_secret_v1.cloudflare_api_key]

  manifest = yamldecode(templatefile("${path.module}/templates/cert-manager/clusterissuer.yaml", {
    email       = var.cloudflare_email_id
    secret-name = kubernetes_secret_v1.cloudflare_api_key.metadata[0].name
  }))
}

# Issue certificate for apps
resource "kubernetes_manifest" "certificate" {
  depends_on = [kubernetes_manifest.cluster_issuer, kubernetes_namespace_v1.dev_namespace]

  manifest = yamldecode(templatefile("${path.module}/manifests/certificate/certificate.yaml", {
    namespace = "default"
  }))
}


# Install Traefik as Gateway API

resource "helm_release" "traefik" {
  depends_on       = [kubernetes_manifest.certificate]
  name             = "traefik"
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  namespace        = "traefik"
  create_namespace = true
  cleanup_on_fail  = true
  values           = [file("${path.module}/templates/traefik/values.yaml")]
}

resource "kubernetes_manifest" "gateway" {
  depends_on = [helm_release.traefik]

  manifest = yamldecode(templatefile("${path.module}/manifests/gateway/gateway.yaml", {
    tls_secret_name  = "local-sidd-cc-tls"
    secret_namespace = "default"
  }))
}


# Install ArgoCD
resource "helm_release" "argocd" {
  depends_on       = [kubernetes_manifest.gateway]
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


# Install Tailscale Operator

resource "helm_release" "tailscale_operator" {
  name             = "tailscale-operator"
  repository       = "https://pkgs.tailscale.com/helmcharts"
  chart            = "tailscale-operator"
  namespace        = "tailscale"
  create_namespace = true
  cleanup_on_fail  = true

  set_sensitive = [
    {
      name  = "oauth.clientId"
      value = var.tailscale_oauth_clientid
    },
    {
      name  = "oauth.clientSecret"
      value = var.tailscale_oauth_client_secret
    }
  ]
}


# Install nfs subdir external
resource "helm_release" "nfs-subdir-external-provisioner" {
  name            = "nfs-subdir-external-provisioner"
  repository      = "https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner"
  chart           = "nfs-subdir-external-provisioner"
  namespace       = "default"
  cleanup_on_fail = true

  set = [
    {
      name  = "nfs.path"
      value = var.omv_nfs_share_path
    },
    {
      name  = "nfs.server"
      value = var.omv_server_ip
    }
  ]
}

# Creating required storage classes for Jellyfin to claim volumes
resource "kubernetes_manifest" "local_storage_class" {
  depends_on = [helm_release.nfs-subdir-external-provisioner]
  manifest   = yamldecode(file("${path.module}/manifests/storage_class/storage-class-local.yaml"))
}

resource "kubernetes_manifest" "nfs_storage_class" {
  depends_on = [helm_release.nfs-subdir-external-provisioner]
  manifest   = yamldecode(file("${path.module}/manifests/storage_class/storage-class-nfs.yaml"))
}



# Apply the ArgoCD application manifest to deploy the app from gitops repo
resource "kubernetes_manifest" "argo_app_of_apps" {
  depends_on = [
    helm_release.argocd,
    helm_release.argocd, helm_release.cert_manager, helm_release.tailscale_operator,
    helm_release.nfs-subdir-external-provisioner, kubernetes_manifest.certificate, kubernetes_manifest.local_storage_class,
    kubernetes_manifest.nfs_storage_class, kubernetes_manifest.cluster_issuer, kubernetes_namespace_v1.dev_namespace
  ]
  manifest = yamldecode(file("${path.module}/../gitops/argocd/root-app.yaml"))
}