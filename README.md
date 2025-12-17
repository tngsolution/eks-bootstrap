# eks-bootstrap


This repository contains all post-install configuration for an EKS cluster:

- Kubernetes manifests (see `k8s-manifests/`)
- Addons (see `addons/`)
- Scripts for automation (see `scripts/`)
- Argo CD GitOps applications (see `addons/argocd/argocd-app.yaml`)


## Addons

This repository provides several addons for EKS, located in the `addons/` directory:


- **ArgoCD** (`addons/argocd/helmfile.yaml`):
	- GitOps controller for Kubernetes. Deploys ArgoCD using the official Helm chart via Helmfile.
	- Install:
		```sh
		cd addons/argocd
		helmfile sync
		```

- **Calico** (`addons/calico/`):
	- CNI plugin for Kubernetes networking and network policy.
	- Install:
		```sh
		cd addons/calico
		helmfile sync
		```

- **Karpenter** (`addons/karpenter/`):
	- Autoscaler for provisioning EC2 nodes on demand.
	- Prerequisites: IAM roles, OIDC provider, and environment variables (see `addons/karpenter/README.md`).
	- Install:
		```sh
		cd addons/karpenter
		helmfile -e dev sync
		```

- **Metrics Server** (`addons/metrics-server/`):
	- Aggregates resource usage metrics for HPA/VPA.
	- Install:
		```sh
		cd addons/metrics-server
		helmfile -e dev sync
		```

See each addon's README for prerequisites and advanced configuration.

## Usage

1. Deploy required addons (e.g., ArgoCD):
		```sh
		kubectl apply -f addons/argocd/argocd-app.yaml
		```
2. Apply other manifests or configure additional GitOps applications as needed.

---

For more details, see each subdirectory's README or open an issue for help.
