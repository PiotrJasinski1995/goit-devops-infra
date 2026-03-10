output "namespace" {
  description = "Jenkins namespace"
  value       = kubernetes_namespace.this.metadata[0].name
}

output "release_name" {
  description = "Jenkins Helm release name"
  value       = helm_release.jenkins.name
}
