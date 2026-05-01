<!-- BEGIN_TF_DOCS -->
# Terraform K3s Cluster Bootstrap

This terraform module automates the bootstrapping of a K3s Kubernetes cluster with essential platform components and infrastructure services.

## Bootstrap Stack

### Core Components

- **cert-manager**: Automatic TLS certificate management and renewal via Let's Encrypt and Cloudflare DNS01 challenge
- **Traefik**: Cloud-native ingress controller supporting Kubernetes Gateway API for advanced routing
- **ArgoCD**: GitOps continuous deployment controller for declarative application management

### Additional Platform Services

The cluster is designed to support optional components:
- **Tailscale Operator**: Private mesh networking for secure cluster communication
- **Storage Classes**: Multi-backend storage support (local, NFS, SMB)
- **Monitoring**: Prometheus and Grafana for cluster observability (via platform/monitoring)

## Architecture

The bootstrap process follows a dependency chain:

1. **Certificate Infrastructure** → cert-manager + Cloudflare API integration
2. **Ingress Layer** → Traefik with TLS certificates
3. **GitOps Platform** → ArgoCD for declarative app management
4. **Applications** → Deployed via ArgoCD from gitops/argocd manifests

## Deployment

```bash
./k3s_cluster_bootstrap.sh
```

This script applies terraform in the correct dependency order, with delays to allow Kubernetes to register CRDs.

## GitOps Structure

Applications are organized in `gitops/argocd/` and deployed automatically:
- **Apps**: Homepage, Jellyfin, Drawio, Homelab Docs
- **Platform**: Monitoring stack (Prometheus/Grafana)

Each app has Helm charts with environment-specific values (dev/prod).

## Prerequisites

- K3s cluster provisioned and kubeconfig available
- Terraform with Kubernetes and Helm providers configured
- Cloudflare API credentials for DNS validation
- Environment variables or terraform.tfvars with:
  - `cloudflare_api_key`
  - `cloudflare_email_id`

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 3.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cloudflare_api_key"></a> [cloudflare\_api\_key](#input\_cloudflare\_api\_key) | Cloudflare API Key | `string` | n/a | yes |
| <a name="input_cloudflare_email_id"></a> [cloudflare\_email\_id](#input\_cloudflare\_email\_id) | Cloudflare Email Address | `string` | n/a | yes |
| <a name="input_omv_nfs_share_path"></a> [omv\_nfs\_share\_path](#input\_omv\_nfs\_share\_path) | OpenMediaVault NFS Share Path | `string` | `"/export/media-nfs-jellyfin"` | no |
| <a name="input_omv_server_ip"></a> [omv\_server\_ip](#input\_omv\_server\_ip) | OpenMediaVault server IP | `string` | n/a | yes |
| <a name="input_tailscale_oauth_client_secret"></a> [tailscale\_oauth\_client\_secret](#input\_tailscale\_oauth\_client\_secret) | Tailscale Oauth client secret | `string` | n/a | yes |
| <a name="input_tailscale_oauth_clientid"></a> [tailscale\_oauth\_clientid](#input\_tailscale\_oauth\_clientid) | Tailscale Oauth client id | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_argocd_admin_password"></a> [argocd\_admin\_password](#output\_argocd\_admin\_password) | The initial password for the ArgoCD admin user |
<!-- END_TF_DOCS -->