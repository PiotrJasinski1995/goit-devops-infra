output "tf_state_bucket_name" {
  description = "S3 bucket for Terraform state"
  value       = module.s3_backend.bucket_name
}

output "tf_lock_table_name" {
  description = "DynamoDB table for Terraform state locking"
  value       = module.s3_backend.table_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "jenkins_namespace" {
  description = "Jenkins namespace"
  value       = module.jenkins.namespace
}

output "argocd_namespace" {
  description = "Argo CD namespace"
  value       = module.argo_cd.namespace
}
