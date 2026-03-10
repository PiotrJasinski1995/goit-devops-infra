# GoIT DevOps Infrastructure Project

This repository contains the Infrastructure as Code (IaC) for the DevOps project implemented using Terraform.

The infrastructure provisions a complete AWS environment for running a containerized Django application with Kubernetes and GitOps practices.

---

# Related repositories

This infrastructure works together with two additional repositories:

Application repository
https://github.com/PiotrJasinski1995/goit-devops-app

Helm charts repository
https://github.com/PiotrJasinski1995/goit-devops-charts

Repository roles:

**goit-devops-app**

- Django application
- Dockerfile
- Jenkins pipeline

**goit-devops-charts**

- Helm chart for the Django application
- values.yaml updated automatically by Jenkins

**goit-devops-infra (this repository)**

- Terraform infrastructure
- Kubernetes cluster
- Jenkins deployment
- Argo CD deployment
- Reusable RDS / Aurora database module

---

# Infrastructure components

Terraform provisions and configures the following AWS components:

- S3 bucket for Terraform state
- DynamoDB table for Terraform state locking
- VPC networking
- Amazon ECR repository
- Amazon EKS Kubernetes cluster
- AWS EBS CSI Driver
- Jenkins installed via Helm
- Argo CD installed via Helm
- Reusable RDS / Aurora database module

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
    ├── argo_cd/
    └── rds/
```

---

# RDS module

The `modules/rds` module provides a reusable Terraform module for provisioning relational databases.

The module supports two database types:

• Standard RDS instance
• Aurora cluster

The type of database is controlled using the variable:

```
use_aurora
```

---

# Database behaviour

If:

```
use_aurora = false
```

Terraform creates:

- aws_db_instance

If:

```
use_aurora = true
```

Terraform creates:

- aws_rds_cluster
- aws_rds_cluster_instance (writer)

---

# Resources created automatically

In both cases the module creates:

- DB Subnet Group
- Security Group
- Parameter Group

---

# Supported database engines

Standard RDS:

- postgres
- mysql

Aurora:

- aurora-postgresql
- aurora-mysql

---

# Example usage

```
module "rds" {
  source = "./modules/rds"

  name_prefix    = "${local.project_name}-db"
  use_aurora     = local.use_aurora
  engine         = local.db_engine
  engine_version = local.db_engine_ver
  instance_class = local.db_instance_cls
  multi_az       = local.db_multi_az

  db_name  = local.db_name
  username = local.db_username
  password = local.db_password

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids

  allowed_cidrs = ["10.0.0.0/16"]
}
```

---

# Important variables

| Variable       | Description                            |
| -------------- | -------------------------------------- |
| use_aurora     | Switch between standard RDS and Aurora |
| engine         | Database engine                        |
| engine_version | Engine version                         |
| instance_class | Database instance type                 |
| multi_az       | Enable Multi-AZ for standard RDS       |
| db_name        | Initial database name                  |
| username       | Master username                        |
| password       | Master password                        |
| vpc_id         | VPC ID                                 |
| subnet_ids     | Subnets used by the database           |
| allowed_cidrs  | CIDR blocks allowed to connect         |

---

# Changing database type

Standard PostgreSQL:

```
use_aurora = false
engine     = "postgres"
```

Standard MySQL:

```
use_aurora = false
engine     = "mysql"
```

Aurora PostgreSQL:

```
use_aurora = true
engine     = "aurora-postgresql"
```

Aurora MySQL:

```
use_aurora = true
engine     = "aurora-mysql"
```

---

# Terraform usage

Initialize Terraform:

```
terraform init
```

Check infrastructure plan:

```
terraform plan
```

Apply infrastructure:

```
terraform apply
```

---

# Cost notice

Database services may generate AWS costs.

It is recommended to validate the configuration using `terraform plan` before applying infrastructure.

---

# Cleanup

To avoid unexpected AWS charges remove infrastructure after testing:

```
terraform destroy
```

Important: Terraform backend uses S3 and DynamoDB resources for state management.
