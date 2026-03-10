terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = local.aws_region
}

locals {
  project_name      = "goit-devops"
  aws_region        = "us-east-2"
  cluster_name      = "goit-devops-eks"
  ecr_repository    = "django-app"
  jenkins_namespace = "jenkins"
  argocd_namespace  = "argocd"

  chart_repo_url = "https://github.com/PiotrJasinski1995/goit-devops-charts.git"
  app_repo_url   = "https://github.com/PiotrJasinski1995/goit-devops-app.git"
  git_branch     = "lesson-8-9"

  db_name         = "appdb"
  db_username     = "dbadmin"
  db_password     = "examplepassword"
  db_engine       = "postgres"
  db_engine_ver   = "16.3"
  db_instance_cls = "db.t3.micro"
  use_aurora      = false
  db_multi_az     = false
}

module "s3_backend" {
  source = "./modules/s3-backend"

  bucket_name = "${local.project_name}-tf-state"
  table_name  = "${local.project_name}-tf-locks"
}

module "vpc" {
  source = "./modules/vpc"

  project_name = local.project_name
  vpc_cidr     = "10.0.0.0/16"
  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
  ]
  availability_zones = [
    "${local.aws_region}a",
    "${local.aws_region}b",
  ]
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = local.ecr_repository
}

module "eks" {
  source = "./modules/eks"

  cluster_name       = local.cluster_name
  kubernetes_version = "1.31"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnet_ids
  node_group_name    = "${local.project_name}-nodes"
  instance_types     = ["t3.micro"]
  desired_size       = 8
  min_size           = 7
  max_size           = 8
}

module "jenkins" {
  source = "./modules/jenkins"

  cluster_name     = module.eks.cluster_name
  cluster_endpoint = module.eks.cluster_endpoint
  cluster_ca_data  = module.eks.cluster_certificate_authority_data
  namespace        = local.jenkins_namespace
  chart_version    = "5.8.22"
}

module "argo_cd" {
  source = "./modules/argo_cd"

  cluster_name     = module.eks.cluster_name
  cluster_endpoint = module.eks.cluster_endpoint
  cluster_ca_data  = module.eks.cluster_certificate_authority_data
  namespace        = local.argocd_namespace
  chart_version    = "7.7.16"

  app_name        = "django-app"
  app_namespace   = "django"
  repo_url        = local.chart_repo_url
  target_revision = local.git_branch
  chart_path      = "charts/django-app"
}

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

module "monitoring" {
  source = "./modules/monitoring"

  cluster_name     = module.eks.cluster_name
  cluster_endpoint = module.eks.cluster_endpoint
  cluster_ca_data  = module.eks.cluster_certificate_authority_data

  namespace     = "monitoring"
  chart_version = "58.5.3"

  depends_on = [
    module.eks
  ]
}