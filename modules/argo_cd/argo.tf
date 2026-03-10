resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "argo_cd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.this.metadata[0].name
  version    = var.chart_version

  values = [
    file("${path.module}/values.yaml")
  ]

  depends_on = [kubernetes_namespace.this]
}

resource "helm_release" "argocd_apps" {
  name      = "argocd-apps"
  chart     = "${path.module}/charts"
  namespace = kubernetes_namespace.this.metadata[0].name

  set {
    name  = "applications[0].name"
    value = var.app_name
  }
  set {
    name  = "applications[0].namespace"
    value = var.app_namespace
  }
  set {
    name  = "applications[0].repoURL"
    value = var.repo_url
  }
  set {
    name  = "applications[0].targetRevision"
    value = var.target_revision
  }
  set {
    name  = "applications[0].path"
    value = var.chart_path
  }

  depends_on = [helm_release.argo_cd]
}
