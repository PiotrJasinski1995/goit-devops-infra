output "namespace" {
  description = "Argo CD namespace"
  value       = kubernetes_namespace.this.metadata[0].name
}

output "release_name" {
  description = "Argo CD Helm release name"
  value       = helm_release.argo_cd.name
}
