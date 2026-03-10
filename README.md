# GoIT DevOps Final Project - Infrastructure

This repository contains the Terraform infrastructure for the GoIT DevOps Final Project.

The infrastructure provisions a full AWS environment for a containerized Django application running in Kubernetes with CI/CD, GitOps deployment, database support, and monitoring.

---

## Related repositories

This infrastructure works together with two additional repositories.

Application repository:  
https://github.com/PiotrJasinski1995/goit-devops-app

Helm charts repository:  
https://github.com/PiotrJasinski1995/goit-devops-charts

Repository responsibilities:

### goit-devops-app

- Django application source code
- Dockerfile
- Jenkins pipeline

### goit-devops-charts

- Helm chart for the Django application
- values.yaml automatically updated by Jenkins with the new Docker image tag

### goit-devops-infra (this repository)

- Terraform infrastructure
- AWS networking and Kubernetes cluster
- Jenkins deployment
- Argo CD deployment
- Prometheus and Grafana monitoring
- Reusable RDS / Aurora database module

---

## Infrastructure components

Terraform provisions the following AWS infrastructure:

- S3 bucket for Terraform state
- DynamoDB table for Terraform state locking
- VPC networking with subnets and routing
- Amazon ECR container registry
- Amazon EKS Kubernetes cluster
- AWS EBS CSI driver for persistent storage
- Jenkins installed with Helm
- Argo CD installed with Helm
- Prometheus and Grafana monitoring stack
- Reusable RDS / Aurora database module

---

## Security configuration

The infrastructure includes several security layers:

- VPC network isolation
- Security Groups controlling access to services
- IAM roles for EKS nodes and Kubernetes workloads
- Kubernetes namespaces separating Jenkins, Argo CD, and monitoring

This configuration provides network isolation and controlled service access inside the cluster.

---

## Project structure

Project/
├── main.tf  
├── backend.tf  
├── outputs.tf  
└── modules/  
 ├── s3-backend/  
 ├── vpc/  
 ├── ecr/  
 ├── eks/  
 ├── rds/  
 ├── jenkins/  
 ├── argo_cd/  
 └── monitoring/

Each component is implemented as a reusable Terraform module.

---

## CI/CD and GitOps workflow

The application delivery pipeline follows a CI/CD and GitOps approach:

1. Developer pushes code changes to the application repository.
2. Jenkins pipeline builds a Docker image from the Django application.
3. Jenkins pushes the image to Amazon ECR.
4. Jenkins updates the image tag inside the Helm chart repository.
5. Argo CD monitors the Helm chart repository.
6. Argo CD detects changes and synchronizes the application inside the EKS cluster.

This approach separates infrastructure, application code, and deployment configuration.

---

## Monitoring and autoscaling

Monitoring is implemented using the Prometheus and Grafana stack deployed via Helm.

Monitoring components run inside the Kubernetes namespace:

monitoring

Verification command:

kubectl get all -n monitoring

Grafana access can be enabled using port forwarding:

kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring

Grafana will then be available at:

http://localhost:3000

Autoscaling is implemented using Kubernetes Horizontal Pod Autoscaler defined in the Helm chart for the Django application.

The HPA adjusts the number of pods depending on CPU usage.

---

## Jenkins access

Jenkins is installed in the Kubernetes namespace:

jenkins

Check Jenkins resources:

kubectl get all -n jenkins

Access Jenkins locally:

kubectl port-forward svc/jenkins 8080:8080 -n jenkins

Open in browser:

http://localhost:8080

---

## Argo CD access

Argo CD is installed in the namespace:

argocd

Check Argo CD resources:

kubectl get all -n argocd

Access Argo CD locally:

kubectl port-forward svc/argocd-server 8081:443 -n argocd

Open in browser:

https://localhost:8081

---

## RDS module

The modules/rds module provides a reusable Terraform module for provisioning relational databases.

Supported database types:

- standard RDS instance
- Aurora cluster

The database type is controlled by:

use_aurora

### RDS module behaviour

If:

use_aurora = false

Terraform creates:

- aws_db_instance

If:

use_aurora = true

Terraform creates:

- aws_rds_cluster
- aws_rds_cluster_instance

In both cases the module also creates:

- DB subnet group
- security group
- parameter group

### Example RDS module usage

module "rds" {
source = "./modules/rds"

name_prefix = "${local.project_name}-db"
use_aurora = local.use_aurora
engine = local.db_engine
engine_version = local.db_engine_ver
instance_class = local.db_instance_cls
multi_az = local.db_multi_az

db_name = local.db_name
username = local.db_username
password = local.db_password

vpc_id = module.vpc.vpc_id
subnet_ids = module.vpc.public_subnet_ids

allowed_cidrs = ["10.0.0.0/16"]
}

---

## Terraform usage

Initialize Terraform:

terraform init

Preview infrastructure changes:

terraform plan

Deploy infrastructure:

terraform apply

---

## Verification commands

Check Jenkins resources:

kubectl get all -n jenkins

Check Argo CD resources:

kubectl get all -n argocd

Check monitoring resources:

kubectl get all -n monitoring

---

## Cost notice

Running AWS infrastructure such as EKS, RDS, Jenkins, Argo CD, and monitoring services may generate cloud costs.

For educational purposes, the infrastructure was designed in a production-style modular Terraform architecture. Depending on AWS Free Tier limitations, some components may be verified theoretically or partially deployed.

---

## Cleanup

To avoid unexpected AWS charges, remove the infrastructure after testing:

terraform destroy

Note that the Terraform backend uses S3 and DynamoDB resources for state management.
