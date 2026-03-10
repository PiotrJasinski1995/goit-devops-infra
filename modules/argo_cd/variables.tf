variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "cluster_ca_data" {
  description = "Base64 encoded cluster CA data"
  type        = string
}

variable "namespace" {
  description = "Namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Helm chart version for Argo CD"
  type        = string
}

variable "app_name" {
  description = "Argo CD application name"
  type        = string
}

variable "app_namespace" {
  description = "Namespace where the app will be deployed"
  type        = string
}

variable "repo_url" {
  description = "Git repository URL for Helm charts"
  type        = string
}

variable "target_revision" {
  description = "Git branch or tag watched by Argo CD"
  type        = string
}

variable "chart_path" {
  description = "Path to the Helm chart inside the Git repo"
  type        = string
}
