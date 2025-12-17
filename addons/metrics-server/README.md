# Metrics Server Installation

This directory contains the Helmfile configuration to deploy Metrics Server on EKS.

## What is Metrics Server?

Metrics Server is a cluster-wide aggregator of resource usage data. It collects metrics from Kubelets and exposes them in Kubernetes API server through Metrics API for use by Horizontal Pod Autoscaler (HPA) and Vertical Pod Autoscaler (VPA).

## Prerequisites

- EKS cluster already provisioned and accessible
- `kubectl` configured with cluster access
- `helm` installed (v3.x)
- `helmfile` installed

## Deployment

```bash
# From this directory
cd /Users/abdoulba/ws/AWS-TRAINING/eks-bootstrap/addons/metrics-server

# Export required environment variables
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Deploy with Helmfile
helmfile -e dev sync
```

## Verification

Check that Metrics Server is running:

```bash
kubectl get deployment metrics-server -n kube-system
kubectl get pods -n kube-system -l app.kubernetes.io/name=metrics-server
```

Test metrics collection:

```bash
# Wait a minute for metrics to be collected, then:
kubectl top nodes
kubectl top pods -A
```

## Troubleshooting

### Metrics not available

If you get `error: Metrics API not available`, wait a minute for metrics collection to start.

### Check Metrics Server logs

```bash
kubectl logs -n kube-system -l app.kubernetes.io/name=metrics-server
```

## Uninstall

```bash
helmfile -e dev destroy
```
