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
