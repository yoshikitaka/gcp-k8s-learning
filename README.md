# GCP K8s Learning Project

This project sets up a Kubernetes learning environment on Google Cloud Platform (GCP) using Terraform.

## Prerequisites

- Google Cloud SDK (`gcloud`)
- Terraform
- `kubectl`

## Setup Instructions

### 1. Google Cloud Authentication & Setup

The following commands were executed to authenticate and prepare the GCP environment:

```bash
# Login to Google Cloud
gcloud auth login

# Set the active project
gcloud config set project k8s-learning-479716

# Setup Application Default Credentials (ADC) for Terraform
gcloud auth application-default login

# Enable necessary Google Cloud APIs
gcloud services enable \
  compute.googleapis.com \
  container.googleapis.com \
  cloudresourcemanager.googleapis.com \
  secretmanager.googleapis.com \
  iam.googleapis.com
```

### 2. Infrastructure Deployment

Navigate to the `terraform` directory and apply the configuration:

```bash
cd terraform
terraform init
terraform apply
```

This will create:
- VPC network with custom subnets
- GKE cluster with Spot instances
- Artifact Registry repository
- Service accounts with IAM permissions

### 3. Configure kubectl

Get credentials for the GKE cluster:

```bash
gcloud container clusters get-credentials k8s-learning-cluster --region us-central1 --project k8s-learning-479716
```

Verify connection:

```bash
kubectl get nodes
```

### 4. Install External Secrets Operator

```bash
helm repo add external-secrets https://charts.external-secrets.io
helm repo update
helm install external-secrets external-secrets/external-secrets \
  -n external-secrets --create-namespace --set installCRDs=true
```

### 5. Build and Deploy Application

Configure Docker for Artifact Registry:

```bash
gcloud auth configure-docker us-central1-docker.pkg.dev --quiet
```

Build and push the application:

```bash
docker build -t us-central1-docker.pkg.dev/k8s-learning-479716/app-repo/go-app:v1 ./app
docker push us-central1-docker.pkg.dev/k8s-learning-479716/app-repo/go-app:v1
```

Deploy to Kubernetes:

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

### 6. Verify Deployment

Check pods:

```bash
kubectl get pods
```

Get service endpoint:

```bash
kubectl get svc go-app-service
```

Test the application (replace with your LoadBalancer IP):

```bash
curl http://<EXTERNAL-IP>
```

## Architecture

- **GKE Standard Cluster**: 3-node cluster with Spot instances (e2-medium)
- **VPC-native networking**: Custom VPC with secondary ranges for pods/services
- **Artifact Registry**: Private Docker registry for container images
- **External Secrets Operator**: Syncs secrets from Google Secret Manager
- **LoadBalancer Service**: Exposes application via GCP Load Balancer

## Cost Optimization

- Using **Spot/Preemptible instances** (~80% cost savings)
- **E2-medium** machine type (cost-effective for learning)
- **Regional** cluster (not multi-region)
- Remember to destroy resources when not in use:

```bash
cd terraform
terraform destroy
```

## Next Steps

1. **Setup GitHub CI/CD**: Push code and configure GitHub secrets
2. **Test Secret Management**: Create secrets in Secret Manager and use External Secrets
3. **AWS Migration**: Adapt Terraform for AWS EKS deployment

## Troubleshooting

If you encounter ImagePullBackOff, ensure the node service account has Artifact Registry access:

```bash
gcloud projects add-iam-policy-binding k8s-learning-479716 \
  --member=serviceAccount:k8s-node-sa@k8s-learning-479716.iam.gserviceaccount.com \
  --role=roles/artifactregistry.reader
```
