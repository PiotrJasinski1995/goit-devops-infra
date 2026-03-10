# GoIT DevOps Infrastructure Project

This repository contains the Infrastructure as Code part of the final DevOps project.  
It provisions AWS and Kubernetes resources required to run a CI/CD pipeline based on **Terraform + Helm + Jenkins + Argo CD + ECR + EKS**.

## Related repositories

This project works together with two additional repositories:

- **Application repository:** `goit-devops-app`
- **Helm charts repository:** `goit-devops-charts`

## Implemented infrastructure

The project includes:

- **S3 + DynamoDB** backend for Terraform state
- **VPC** with public subnets
- **ECR** repository for Docker images
- **EKS** cluster
- **AWS EBS CSI Driver** for dynamic volume provisioning
- **Jenkins** installed with Helm via Terraform
- **Argo CD** installed with Helm via Terraform
- **Argo CD application chart** for GitOps deployment

## Project structure

```
.
├── backend.tf
├── main.tf
├── outputs.tf
├── .terraform.lock.hcl
└── modules/
    ├── s3-backend/
    ├── vpc/
    ├── ecr/
    ├── eks/
    ├── jenkins/
    └── argo_cd/
```

## How to apply Terraform

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Create backend resources first

If the backend resources do not exist yet, apply the backend module first:

```bash
terraform apply -target=module.s3_backend
```

Then reinitialize Terraform if needed:

```bash
terraform init
```

### 3. Deploy infrastructure

```bash
terraform apply
```

This creates the infrastructure needed for:

- EKS cluster
- ECR repository
- Jenkins
- Argo CD

## How to test the Jenkins job

Jenkins is installed in the `jenkins` namespace.

### Check Jenkins resources

```bash
kubectl get pods -n jenkins
kubectl get svc -n jenkins
```

### Jenkins pipeline flow

The Jenkins pipeline is defined in the **application repository** (`goit-devops-app`) in the `Jenkinsfile`.

The intended workflow is:

1. Jenkins checks out the application repository
2. Builds a Docker image from the `Dockerfile`
3. Pushes the image to Amazon ECR
4. Updates the image tag in the Helm chart repository (`goit-devops-charts`)
5. Pushes changes to the Git branch

### Notes

The project is designed to use:

- Kubernetes agent
- Kaniko
- Git-based update of the Helm chart values

## How to view the result in Argo CD

Argo CD is installed in the `argocd` namespace.

### Check Argo CD resources

```bash
kubectl get pods -n argocd
kubectl get svc -n argocd
```

### Access Argo CD

If LoadBalancer access is not available, use port-forward:

```bash
kubectl port-forward svc/argocd-server 8080:443 -n argocd
```

Then open:

```
https://localhost:8080
```

### Argo CD workflow

Argo CD is configured to watch the Helm chart repository (`goit-devops-charts`).

When Jenkins updates the image tag in:

```
charts/django-app/values.yaml
```

Argo CD detects the Git change and synchronizes the application in the cluster.

## Important note about AWS limits

This project was implemented and tested on constrained AWS resources.  
Because of AWS account limits for **On-Demand vCPU quota** and Kubernetes scheduling density on small worker nodes, running **all components simultaneously** on `t3.micro` instances may be limited.

During validation, the following infrastructure components were successfully prepared and tested in stages:

- Terraform modules
- EKS cluster
- ECR repository
- Jenkins deployment
- Argo CD deployment
- Helm chart integration

## Cleanup

To avoid unexpected AWS charges, destroy infrastructure after review:

```bash
terraform destroy
```

### Important

If backend resources are also removed, remember that the Terraform state backend consists of:

- S3 bucket
- DynamoDB lock table

After full cleanup, infrastructure must be recreated in the correct order again.

## Branch for submission

The submission version of the project is prepared on the branch:

```
lesson-8-9
```
