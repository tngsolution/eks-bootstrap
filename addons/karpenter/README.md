# Karpenter Installation

This directory contains the Helmfile configuration to deploy Karpenter on EKS.

## Prerequisites

1.  **IAM Roles & Instance Profile**: Ensure that the IAM resources (`karpenter-controller-eks-dev`, `karpenter-node-eks-dev`) have been created by the Terraform module.

2.  **OIDC Provider**: An OIDC provider must be associated with your EKS cluster. The Terraform module should have created it.

3.  **Environment Variables**: Before deploying, export the following variables:

    ```bash
    # Replace with your AWS Account ID
    export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    
    # Endpoint of your EKS cluster
    export K8S_CLUSTER_ENDPOINT=$(aws eks describe-cluster --name eks-dev --region eu-west-3 --query "cluster.endpoint" --output text)
    ```

4.  **Update the role ARN**: Edit `helmfile.yaml` and replace the value of `sa_role_arn` with the correct ARN of the `karpenter-controller-eks-dev` role.

## Deployment

Once the prerequisites are met, you can deploy Karpenter.

```bash
# From this directory
cd /Users/abdoulba/ws/AWS-TRAINING/eks-bootstrap/addons/karpenter

# Deploy with Helmfile
helmfile -e dev sync
```

## Verification

1.  **Check Karpenter pods**:

    ```bash
    kubectl get pods -n karpenter
    # Should display 2 pods `karpenter-xxxx` in Running state.
    ```

2.  **Check logs**:

    ```bash
    kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter -f
    # You should see logs indicating that the controller has started.
    ```

3.  **Check CRDs**:

    ```bash
    kubectl get nodepools
    # Should display the nodepool `default`.
    
    kubectl get ec2nodeclasses
    # Should display the nodeclass `default`.
    ```

## Test Autoscaling

1.  **Create a deployment that cannot be scheduled**:

    ```bash
    kubectl create deployment inflate --image=public.ecr.aws/eks-distro/kubernetes/pause:3.2 --replicas=0
    ```

2.  **Increase replicas to trigger Karpenter**:

    ```bash
    kubectl scale deployment inflate --replicas=5
    ```

3.  **Observe Karpenter**:
    -   Watch the Karpenter logs (`kubectl logs ...`). You will see messages about creating a new node.
    -   Watch the new nodes appear:
        ```bash
        watch kubectl get nodes -L karpenter.sh/nodepool,node.kubernetes.io/instance-type
        ```

## Cleanup

```bash
# Delete the test deployment
kubectl delete deployment inflate

# Uninstall Karpenter
helmfile -e dev destroy
```
