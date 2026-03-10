# GoIT DevOps Infrastructure Project

This repository contains the **Infrastructure as Code (IaC)** for the DevOps CI/CD pipeline project implemented with **Terraform, Kubernetes, Jenkins, Helm, Argo CD, and Amazon ECR**.

The infrastructure provisions all required cloud resources and installs the CI/CD components inside a Kubernetes cluster.

---

# Related repositories

This project works together with two additional repositories:

Application repository  
https://github.com/PiotrJasinski1995/goit-devops-app

Helm charts repository  
https://github.com/PiotrJasinski1995/goit-devops-charts

Repository roles:

**goit-devops-app**

- Django application
- Dockerfile
- Jenkins pipeline (Jenkinsfile)

**goit-devops-charts**

- Helm chart for the Django application
- values.yaml updated automatically by Jenkins

**goit-devops-infra (this repository)**

- Terraform infrastructure
- Kubernetes cluster
- Jenkins deployment
- Argo CD deployment

---

# Infrastructure components

Terraform provisions and configures the following components:

- S3 bucket for Terraform state
- DynamoDB table for Terraform state locking
- VPC networking
- Amazon ECR repository for Docker images
- Amazon EKS Kubernetes cluster
- AWS EBS CSI Driver for persistent volumes
- Jenkins installed via Helm
- Argo CD installed via Helm

---

# Project structure

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

---

# How to apply Terraform

Initialize Terraform:

```
terraform init
```

Create backend resources (S3 + DynamoDB) if they do not exist:

```
terraform apply -target=module.s3_backend
```

Reinitialize Terraform if required:

```
terraform init
```

Deploy the full infrastructure:

```
terraform apply
```

Terraform will create:

- EKS cluster
- ECR repository
- Jenkins deployment
- Argo CD deployment

---

# How to test the Jenkins job

Jenkins runs inside the Kubernetes cluster.

Check Jenkins resources:

```
kubectl get pods -n jenkins
kubectl get svc -n jenkins
```

Jenkins pipeline is defined in the **goit-devops-app** repository.

Pipeline workflow:

1. Jenkins clones the application repository
2. Builds a Docker image from the Dockerfile
3. Pushes the image to Amazon ECR
4. Updates the image tag in the Helm chart repository
5. Pushes the updated values.yaml to Git

The updated Helm chart is then detected by Argo CD.

---

# How to view the result in Argo CD

Check Argo CD resources:

```
kubectl get pods -n argocd
kubectl get svc -n argocd
```

If LoadBalancer access is unavailable, use port forwarding:

```
kubectl port-forward svc/argocd-server 8080:443 -n argocd
```

Open in browser:

```
https://localhost:8080
```

Argo CD monitors the Helm chart repository:

```
https://github.com/PiotrJasinski1995/goit-devops-charts
```

When Jenkins updates the image tag in:

```
charts/django-app/values.yaml
```

Argo CD detects the Git change and synchronizes the application in the cluster.

---

# AWS resource limitations

The project was implemented and tested using limited AWS resources.  
Because of AWS **On-Demand vCPU quotas** and Kubernetes scheduling limits for small instances (such as `t3.micro`), running all components simultaneously in a single cluster may be constrained.

Infrastructure modules, Jenkins deployment, Argo CD deployment, and Helm chart integration were validated during the setup process.

---

# Cleanup

To avoid unexpected AWS charges, remove all infrastructure after testing:

```
terraform destroy
```

Important:

Terraform backend uses:

- S3 bucket
- DynamoDB lock table

If those resources are deleted, Terraform backend must be recreated before running the project again.

---

# Submission branch

The submission version of this project is prepared on the branch:

```
lesson-8-9
```
