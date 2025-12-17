#!/bin/bash
set -euo pipefail

# Karpenter installation script for EKS
# Based on official documentation: https://karpenter.sh/docs/getting-started/

# Configuration
CLUSTER_NAME="eks-dev"
KARPENTER_VERSION="1.0.12"
KARPENTER_NAMESPACE="karpenter"
AWS_REGION="eu-west-3"

# Get AWS Account ID
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Get cluster endpoint
export CLUSTER_ENDPOINT=$(aws eks describe-cluster --name ${CLUSTER_NAME} --region ${AWS_REGION} --query "cluster.endpoint" --output text)

echo "Installing Karpenter ${KARPENTER_VERSION} on cluster ${CLUSTER_NAME}"
echo "AWS Account: ${AWS_ACCOUNT_ID}"
echo "Cluster Endpoint: ${CLUSTER_ENDPOINT}"

# Logout of helm registry to perform an unauthenticated pull against the public ECR
helm registry logout public.ecr.aws 2>/dev/null || true

# Install Karpenter
helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter \
  --version "${KARPENTER_VERSION}" \
  --namespace "${KARPENTER_NAMESPACE}" \
  --create-namespace \
  --set "settings.clusterName=${CLUSTER_NAME}" \
  --set "settings.clusterEndpoint=${CLUSTER_ENDPOINT}" \
  --set "settings.interruptionQueue=${CLUSTER_NAME}" \
  --set "serviceAccount.annotations.eks\.amazonaws\.com/role-arn=arn:aws:iam::${AWS_ACCOUNT_ID}:role/karpenter-controller-eks-dev" \
  --set controller.resources.requests.cpu=1 \
  --set controller.resources.requests.memory=1Gi \
  --set controller.resources.limits.cpu=1 \
  --set controller.resources.limits.memory=1Gi \
  --wait

echo "Karpenter installed successfully!"

# Apply NodePool and EC2NodeClass
echo "Applying NodePool and EC2NodeClass..."
kubectl apply -f ec2nodeclass.yaml
kubectl apply -f nodepool.yaml

echo "Verifying installation..."
kubectl get pods -n ${KARPENTER_NAMESPACE}
kubectl get nodepools
kubectl get ec2nodeclasses

echo "Installation complete!"
