# Calico CNI Installation

This directory contains Helmfile configuration for deploying Calico (Tigera Operator) on EKS.

## Environment Variables

Cluster name and region are configured via helmfile environments. Update `helmfile.yaml` environments section to match your cluster.

## Prerequisites

- EKS cluster already provisioned and accessible
- `kubectl` configured with cluster access
- `helm` installed (v3.x)
- `helmfile` installed

## Installation

### Install Helmfile (if not already installed)

```bash
# macOS
brew install helmfile

# Or download binary
curl -L https://github.com/helmfile/helmfile/releases/download/v0.157.0/helmfile_0.157.0_darwin_amd64.tar.gz | tar xz
sudo mv helmfile /usr/local/bin/
```

### Deploy Calico

```bash
# From this directory
helmfile sync

# Or with diff preview
helmfile diff
helmfile apply
```

## Verification

```bash
# Check operator pods
kubectl get pods -n tigera-operator

# Check Calico system pods
kubectl get pods -n calico-system

# Verify installation
kubectl get installation default -o yaml

# Check Calico API server
kubectl get tigerastatus
```

## Configuration

### Custom IP Pool CIDR

If your EKS cluster uses a different pod CIDR, update `values.yaml`:

```yaml
calicoNetwork:
  ipPools:
    - cidr: 172.20.0.0/16  # Change to match your cluster
      blockSize: 26
```

### Network Policy

Once Calico is installed, you can create network policies:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: default
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
```

## Troubleshooting

### Check operator logs
```bash
kubectl logs -n tigera-operator -l k8s-app=tigera-operator
```

### Check installation status
```bash
kubectl get tigerastatus
kubectl describe installation default
```

### Verify CNI configuration
```bash
kubectl get pods -n kube-system -l k8s-app=calico-node
kubectl logs -n calico-system <calico-node-pod> -c calico-node
```

## Uninstall

```bash
helmfile destroy
kubectl delete namespace tigera-operator
kubectl delete namespace calico-system
```
