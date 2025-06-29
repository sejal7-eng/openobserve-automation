resource "kubernetes_namespace" "openobserve" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "openobserve" {
  name       = "openobserve"
  namespace  = kubernetes_namespace.openobserve.metadata[0].name

  # IMPORTANT: use local chart path
  chart      = "../helm-charts/openobserve"
}
