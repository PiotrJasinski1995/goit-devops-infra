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
  description = "Namespace for Jenkins"
  type        = string
  default     = "jenkins"
}

variable "chart_version" {
  description = "Helm chart version for Jenkins"
  type        = string
}
