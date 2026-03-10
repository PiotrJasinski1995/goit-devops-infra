resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  namespace  = kubernetes_namespace.this.metadata[0].name
  version    = var.chart_version

  values = [
    file("${path.module}/values.yaml")
  ]

  depends_on = [kubernetes_namespace.this]
}
